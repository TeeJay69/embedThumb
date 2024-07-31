@echo off
setlocal

rem Specify the video file
set "VIDEO_FILE=video.mp4"

rem Specify the output file
set "OUTPUT_FILE=out.mp4"

rem Specify the directory to store the thumbnail
set "THUMBNAIL_DIR=thumbnails"

rem Ensure the thumbnail directory exists
if not exist "%THUMBNAIL_DIR%" mkdir "%THUMBNAIL_DIR%"

rem Extract image from 5 minutes (300 seconds) into the video
ffmpeg -ss 00:05:00 -i "%VIDEO_FILE%" -frames:v 1 "%THUMBNAIL_DIR%\cover.png"

rem Embed the extracted image as the cover art in the same MP4 file
ffmpeg -i "%VIDEO_FILE%" -i "%THUMBNAIL_DIR%\cover.png" -map 1 -map 0 -c copy -disposition:0 attached_pic "%OUTPUT_FILE%"

rem The thumbnail is already in the desired directory, so no need to move it

endlocal
echo Done.