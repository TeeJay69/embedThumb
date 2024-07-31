@echo off
setlocal enabledelayedexpansion

rem Prompt for directory containing MP4 files
set /p DIRECTORY="Enter the directory path containing MP4 files: "

rem Change to the specified directory
cd /d "%DIRECTORY%"

rem Create a thumbnails directory if not already present
if not exist "thumbnails" mkdir "thumbnails"

rem Loop through all MP4 files in the directory
for %%f in (*.mp4) do (
    echo Processing file: %%f

    rem Turn off delayed expansion to handle special characters in filenames
    setlocal disabledelayedexpansion

    rem Determine the video duration
    for /f "delims=" %%i in ('ffmpeg -i "%%~f" 2^>^&1 ^| find "Duration"') do set duration=%%i
    set duration=!duration:*Duration=!
    set duration=!duration: =!
    set duration=!duration:,%%*!
    set /a "totalSeconds=(!duration:~0,2!*3600)+(!duration:~3,2!*60)+(!duration:~6,2!)"

    rem Set the thumbnail timestamp based on duration
    if !totalSeconds! geq 300 (
        set "TIME_STAMP=00:05:00"
    ) else (
        set "TIME_STAMP=00:01:00"
    )

    rem End the local block to handle special characters
    endlocal

    rem Extract thumbnail at the determined timestamp
    ffmpeg -ss %TIME_STAMP% -i "%%~f" -frames:v 1 "thumbnails\%%~nf.png"

    rem Embed the thumbnail as the cover and overwrite the original file
    ffmpeg -i "%%~f" -i "thumbnails\%%~nf.png" -map 1 -map 0 -c copy -disposition:0 attached_pic "temp_%%~f"
    move /y "temp_%%~f" "%%~f"
)

endlocal
echo Done.
