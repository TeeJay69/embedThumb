@echo off
setlocal DisableDelayedExpansion

rem Prompt for directory containing MP4 files
set /p "DIRECTORY=Enter the directory path containing MP4 files: "

rem Change to the specified directory
cd /d "%DIRECTORY%"

rem Create a thumbnails directory if not already present
if not exist "thumbnails" mkdir "thumbnails"

rem Loop through all MP4 files in the directory
for %%f in (*.mp4) do (
    set "FILE=%%f"
    rem Get the duration of the video using FFmpeg
    for /f "tokens=*" %%D in ('ffmpeg -i "%%~f" 2^>^&1 ^| find "Duration"') do (
        set "DURATION=%%D"
    )

    setlocal EnableDelayedExpansion
    rem Extract hours, minutes, and seconds from the duration string
    set "DURATION=!DURATION:Duration=!"
    for /f "tokens=1-4 delims=:., " %%A in ("!DURATION!") do (
        set /a "hours=%%A"
        set /a "minutes=%%B"
        set /a "seconds=%%C"
    )

    rem Convert duration to seconds
    set /a "DURATION_SECONDS=!hours!*3600 + !minutes!*60 + !seconds!"

    rem Check if the duration is less than or equal to 300 seconds (5 minutes)
    if !DURATION_SECONDS! leq 300 (
        set "TIME_STAMP=00:01:00"
    ) else (
        set "TIME_STAMP=00:05:00"
    )

    echo Processing file: !FILE!
    echo Timestamp for thumbnail: !TIME_STAMP!

    rem Extract thumbnail at the determined timestamp
    ffmpeg -ss !TIME_STAMP! -i "!FILE!" -frames:v 1 "thumbnails\!FILE:~0,-4!.png"

    rem Embed the thumbnail as the cover and overwrite the original file
    ffmpeg -i "!FILE!" -i "thumbnails\!FILE:~0,-4!.png" -map 1 -map 0 -c copy -disposition:0 attached_pic "temp_!FILE!"
    
    if errorlevel 1 (
        echo Failed to process "!FILE!"
        del "temp_!FILE!"
    ) else (
        move /y "temp_!FILE!" "!FILE!"
        echo Successfully processed "!FILE!"
    )
    endlocal
)

endlocal
echo Done.
pause
