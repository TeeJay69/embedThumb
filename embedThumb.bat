@echo off
rem Enable delayed expansion for proper variable updates inside loops.
setlocal EnableDelayedExpansion

rem Prompt for the directory containing MP4 files
set /p "DIRECTORY=Enter the directory path containing MP4 files: "

rem Change to the specified directory
cd /d "%DIRECTORY%"

rem Create a thumbnails directory if it doesn’t exist
if not exist "thumbnails" mkdir "thumbnails"

rem Loop through all MP4 files in the directory
for %%F in (*.mp4) do (
    set "FILE=%%F"
    
    rem Get the duration line output from FFmpeg (which contains 'Duration:')
    for /f "tokens=*" %%D in ('ffmpeg -i "%%F" 2^>^&1 ^| find "Duration"') do (
        set "DURATION=%%D"
    )

    rem --- Clean up the duration string ---
    rem Remove the leading "Duration: " text.
    set "DURATION=!DURATION:Duration: =!"
    rem The duration line typically looks like: 00:00:15.25, start: 0.000000, bitrate: ...
    rem Remove everything after the fraction (remove text after the comma).
    for /f "tokens=1 delims=," %%X in ("!DURATION!") do (
        set "DURATION=%%X"
    )
    
    rem --- Tokenize the cleaned duration string ---
    rem For example, if DURATION is "00:00:15.25" then tokens are:
    rem   %%A = 00, %%B = 00, %%C = 15, and %%D = 25 (the fractional part; we ignore it)
    for /f "tokens=1-4 delims=:." %%A in ("!DURATION!") do (
        set /a hours=1%%A-100
        set /a minutes=1%%B-100
        set /a seconds=1%%C-100
    )

    rem Calculate the duration in total seconds
    set /a DURATION_SECONDS=hours*3600 + minutes*60 + seconds

    rem --- Determine the thumbnail timestamp based on video duration ---
    rem If the video is less than 1 minute, use the midpoint.
    rem If between 1 and 5 minutes (i.e. 60 to 300 seconds), use 00:01:00.
    rem If longer than 5 minutes, use 00:05:00.
    if !DURATION_SECONDS! lss 60 (
        rem Calculate midpoint
        set /a MID_POINT=DURATION_SECONDS/2
        set /a min = MID_POINT / 60
        set /a sec = MID_POINT %% 60
        if !min! LSS 10 (set "min=0!min!") else (set "min=!min!")
        if !sec! LSS 10 (set "sec=0!sec!") else (set "sec=!sec!")
        set "TIME_STAMP=00:!min!:!sec!"
    ) else if !DURATION_SECONDS! leq 300 (
        set "TIME_STAMP=00:01:00"
    ) else (
        set "TIME_STAMP=00:05:00"
    )

    echo.
    echo Processing file: !FILE!
    echo Duration: !DURATION_SECONDS! seconds, Thumbnail Timestamp: !TIME_STAMP!
    
    rem --- Extract the thumbnail ---
    ffmpeg -y -ss !TIME_STAMP! -i "!FILE!" -frames:v 1 "thumbnails\!FILE:~0,-4!.png"

    rem --- Embed the thumbnail as a cover, then overwrite the original file ---
    ffmpeg -y -i "!FILE!" -i "thumbnails\!FILE:~0,-4!.png" -map 1 -map 0:v? -map 0:a? -c copy -disposition:0 attached_pic "temp_!FILE!"
    
    move /y "temp_!FILE!" "!FILE!"
    echo Successfully processed "!FILE!"
)

endlocal
echo.
echo Done.
pause
