#!/bin/bash

# Argument 0: A Youtube video URL
# Argument 1: The desired frame rate

function error_exit {
    echo "$1" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
    exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

if [[ ("$1" != "") ]]; then
    YOUTUBE_URL=$1
    [[ "${2}" == "" ]] && FRAMERATE=25 || FRAMERATE=$2
    echo "Converting youtube video ($YOUTUBE_URL) to frames with $FRAMERATE fps"
    
    echo "Checking dependencies.."
    nodejs -v > /dev/null 2>&1 || error_exit "Please install nodejs."
    npm -v > /dev/null 2>&1 || error_exit "Please install npm."
    ytdl -V > /dev/null 2>&1  || error_exit "Please install the node package ytdl (globally): sudo npm -g install ytdl"
    which ffmpeg > /dev/null 2>&1 || error_exit "Please install ffmpeg. Run 'sudo apt-get install ffmpeg'"
    if [[ ! -d "deoldify" ]]; then
        error_exit "Please clone and install DeOldify [https://github.com/jantic/DeOldify] into the folder 'deoldify' of this repository."
    fi
    if [[ ! -r "deoldify/colorize_gen_192.h5" ]]; then
        error_exit "DeOldify weights must be available. Train the model or download them to 'deoldify/colorize_gen_192.h5'. [https://github.com/jantic/DeOldify#pretrained-weights]"
    fi
    conda info | grep "active environment : [^base]" > /dev/null || error_exit "Please install conda, create a conda profile 'deoldify' (see README of DeOldify) and activate it (conda activate deoldify)"

    echo "Removing files from previous video convertions.."
    rm -rf original_frames
    mkdir -p original_frames
    rm -rf colorized_frames
    mkdir -p colorized_frames
    mkdir -p results

    echo "Downloading video in highest resolution and tranforming it to frames.."
    ytdl $YOUTUBE_URL --quality highestvideo > original_video.mp4 || error_exit "Failed to download video."
    ffmpeg -i original_video.mp4 \
        -f image2 \
        -bt '20M' \
        -vf "fps=${FRAMERATE}" \
        -loglevel panic \
        -nostdin \
        ./original_frames/frame%03d.jpg || error_exit "Failed to convert video to frames."
    rm original_video.mp4

    echo "Downloading and extracting highest quality audio from original video.."
    ytdl $YOUTUBE_URL --quality highestaudio | ffmpeg -y \
        -i pipe:0 \
        -q:a 0 \
        -map a \
        -loglevel panic \
        original_audio.mp3 || error_exit "Failed to download video or extract audio."

    echo "Colorizing each frame.."
    python3 colorize_frames.py || error_exit "Colorizing frames failed"

    # FFMPEG combines the audio input and frames to a new video
    # You might want to adjust the -r value for the output framerate(?)
    # Alternatively to the image input below, you could reassemble the video in a wrong(!) order, creating stunning videos
    # -pattern_type glob -i "colorized_frames/frame*.jpg"
    echo "Reassembling the now colorized video.."
    YTID=`expr match $YOUTUBE_URL '.*[?&]v=\([^&]*\)' || expr match $YOUTUBE_URL '.*youtu\.be\/\(.*\)'` # Extract the YouTube video id fragment.
    RESULT_FILENAME="colorized_YT_${YTID}_fps_${FRAMERATE}.mp4"
    ffmpeg -framerate $FRAMERATE \
        -i "colorized_frames/frame%03d.jpg" \
        -i original_audio.mp3 \
        -loglevel panic \
        -y \
        -hide_banner \
        -nostats \
        "results/$(echo $RESULT_FILENAME | tr -d ' \n')" || error_exit "Reassembling frames failed"
    rm original_audio.mp3
    
    # Open the colorized video, without tying it to the process
    echo "Et voila! You can find the transformed video in 'results/$(echo $RESULT_FILENAME | tr -d ' \n')'"
    xdg-open "results/$(echo $RESULT_FILENAME | tr -d ' \n')" >/dev/null 2>&1 & disown
else
    echo "Youtube video URL is empty"
fi