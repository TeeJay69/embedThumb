Below is a more comprehensive example README.md for your batch script. Feel free to adapt it however you like!

---

# MP4 Cover Thumbnail Embedder

A simple Windows batch script that:
1. Loops through all `.mp4` files in a specified directory.
2. Automatically determines a timestamp to extract a thumbnail (at 1 minute if the file is under 5 minutes, otherwise at 5 minutes).
3. Embeds the extracted thumbnail as the cover image for each MP4 file.

---

## How It Works

1. **Prompt for Directory**  
   The script asks for the path of the directory containing `.mp4` files.

2. **Check Dependencies**  
   It uses [FFmpeg](https://ffmpeg.org/) to:
   - Retrieve the duration of the MP4 file.
   - Extract the thumbnail at the chosen timestamp.
   - Embed the thumbnail as the cover image in the MP4 file.

3. **Determine Timestamp**  
   - If the video is **5 minutes or shorter** (≤ 300 seconds), the thumbnail is extracted at `00:01:00`.
   - If the video is **longer than 5 minutes**, the thumbnail is extracted at `00:05:00`.

4. **Create/Use Thumbnails Folder**  
   The script creates a folder named `thumbnails` (if it doesn’t already exist) for storing the newly extracted thumbnails.

5. **Embed the Thumbnail**  
   FFmpeg is then used again to embed the extracted thumbnail back into the video as its cover image.

6. **Error Checking**  
   After each operation, the script checks a temporary log file for errors. If no errors are found, the changes are finalized and the log is removed.

---

## Prerequisites

1. **Windows Environment**  
   This script is a `.bat` file, so it should be run in a Windows Command Prompt or PowerShell.

2. **FFmpeg**  
   - Make sure [FFmpeg](https://ffmpeg.org/download.html) is installed and added to your system’s PATH.  
   - To verify FFmpeg is in your PATH, open a terminal and type:
     ```bash
     ffmpeg -version
     ```
     If FFmpeg is installed correctly, you should see version information.

---

## Usage

1. **Clone or Download**  
   - Download the batch script or clone the repository from GitHub.

2. **Open Command Prompt**  
   - Navigate to the directory where the script is located.

3. **Run the Script**  
   - Type the name of the batch file (e.g., `thumbnail_embedder.bat`) and press **Enter**.
   - When prompted, enter the path to the folder containing your `.mp4` files.

4. **Wait for Processing**  
   - The script will process each `.mp4` file it finds in that directory.
   - A progress message will be displayed in the console, showing whether each file was successfully processed.

5. **Results**  
   - A `thumbnails` folder will appear in the directory you specified.
   - Each `.mp4` file in the directory will now have a newly embedded cover image.

---

## Features

- **Handles Filenames with Special Characters**  
  The script uses careful quoting and variable expansions to reduce issues with special characters in file names.

- **Timestamp Logic**  
  Automatically picks a screenshot from `00:01:00` (for videos under 5 minutes) or `00:05:00` (for longer videos).

- **Error Checking**  
  Checks FFmpeg logs for errors and only replaces the original file with the modified one if everything succeeds.

- **No 3rd-Party Tools Required (Besides FFmpeg)**  
  Completely relies on FFmpeg for both duration extraction and thumbnail embedding.

---

## Example

1. **Directory Structure** (before running the script):
    ```
    C:\Videos
    ├── video1.mp4
    ├── video2.mp4
    └── ...
    ```

2. **Run the Script**:
    ```batch
    thumbnail_embedder.bat
    ```
    ```
    Enter the directory path containing MP4 files: C:\Videos
    ```

3. **Processing Output**:
    ```
    Processing file: video1.mp4
    Timestamp for thumbnail: 00:05:00
    Successfully processed "video1.mp4"
    Processing file: video2.mp4
    Timestamp for thumbnail: 00:01:00
    Successfully processed "video2.mp4"
    Done.
    ```

4. **Directory Structure** (after running the script):
    ```
    C:\Videos
    ├── thumbnails
    │   ├── video1.png
    │   └── video2.png
    ├── video1.mp4   (now has embedded cover)
    ├── video2.mp4   (now has embedded cover)
    └── ...
    ```

---

## Troubleshooting

- **FFmpeg Not Found**  
  Make sure FFmpeg is installed and the executable (`ffmpeg.exe`) is added to your PATH environment variable.

- **Permission Issues**  
  Run your command prompt or PowerShell as an administrator if you face permission errors creating/moving files.

- **Malformed Videos**  
  Certain corrupted videos may fail when extracting or embedding. If you see repeated errors, try repairing or re-encoding the video.

---

## License
see [Copyright-Disclaimer](Copyright-Disclaimer.md)