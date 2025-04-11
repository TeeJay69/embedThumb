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

    rem Extract hours, minutes, and seconds from the duration string
    set "DURATION=!DURATION:Duration=!"
    for /f "tokens=1-4 delims=:., " %%A in ("!DURATION!") do (
        set /a "hours=%%A"
        set /a "minutes=%%B"
        set /a "seconds=%%C"
    )

    rem Convert duration to total seconds
    set /a "DURATION_SECONDS=hours*3600 + minutes*60 + seconds"

    rem Determine the thumbnail timestamp based on video duration:
    rem - If less than 1 minute, calculate the midpoint.
    rem - If between 1 and 5 minutes, use fixed timestamp 00:01:00.
    rem - If longer than 5 minutes, use fixed timestamp 00:05:00.
    setlocal EnableDelayedExpansion
    if !DURATION_SECONDS! lss 60 (
        rem For videos less than 1 minute, calculate the midpoint.
        set /a "MID_POINT=DURATION_SECONDS/2"
        set /a "min = MID_POINT / 60"
        set /a "sec = MID_POINT %% 60"
        if !min! LSS 10 (set "min=0!min!") else (set "min=!min!")
        if !sec! LSS 10 (set "sec=0!sec!") else (set "sec=!sec!")
        set "TIME_STAMP=00:%min%:%sec%"
    ) else if !DURATION_SECONDS! leq 300 (
        rem For videos between 1 and 5 minutes, use fixed timestamp at 1 minute.
        set "TIME_STAMP=00:01:00"
    ) else (
        rem For videos longer than 5 minutes, use fixed timestamp at 5 minutes.
        set "TIME_STAMP=00:05:00"
    )

    echo Processing file: !FILE!
    echo Duration: !DURATION_SECONDS! seconds, Thumbnail Timestamp: !TIME_STAMP!

    rem Extract thumbnail at the determined timestamp
    ffmpeg -ss !TIME_STAMP! -i "!FILE!" -frames:v 1 "thumbnails\!FILE:~0,-4!.png"

    rem Embed the thumbnail as the cover and overwrite the original file
    ffmpeg -i "!FILE!" -i "thumbnails\!FILE:~0,-4!.png" -map 1 -map 0 -c copy -disposition:0 attached_pic "temp_!FILE!"
    
    rem Replace the original file with the updated one
    move /y "temp_!FILE!" "!FILE!"
    echo Successfully processed "!FILE!"
    endlocal
)
endlocal
echo Done.
pause
