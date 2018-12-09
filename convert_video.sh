#!/bin/bash

# Argument 0: A Youtube video URL
# Argument 1: The desired frame rate

function error_exit {
    echo "$1" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
    exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

if [[ ("$1" != "") ]]; then
    ["$2" == ""] && FRAMERATE=25 || FRAMERATE=$2
    echo "Converting youtube video ($1) to frames with $FRAMERATE fps"
    
    # Checking dependencies
    nodejs -v > /dev/null 2>&1 || error_exit "Please install nodejs."
    npm -v > /dev/null 2>&1 || error_exit "Please install npm."
    npm list | grep  youtube-frames > /dev/null 2>&1 || error_exit "Please install the node package youtube-frames: npm install --save youtube-frames"
    which ffmpeg > /dev/null 2>&1 || error_exit "Please install ffmpeg. Run 'sudo apt-get install ffmpeg'"
    mkdir -p colorize_frames

    # Download a high-res audi and video version (mp4)
    # Transform high res video to frames
    node video_to_frames.js $1 $FRAMERATE > /dev/null || error_exit "Downloading or transforming video to frames failed."

    # let ffmpegProcess = spawn('ffmpeg', [
    # '-i', `${self.path}/${self.videoName}.mp4`,
    # '-ss', `${begin}`,
    # '-to', `${end}`,
    # '-f', 'image2',
    # '-bt', '20M',
    # '-vf', `fps=${self.fps}`,
    # `${self.path}/${self.videoName}%03d.jpg`,
    # '-loglevel', 'panic',
    # '-nostdin'
    # ]);

    # Extract audio from original video
    ffmpeg -y -i original_frames/video_output_highestaudio.mp4 -q:a 0 -map a output-audio.mp3

    conda info --env | grep "*" | grep "fastai" > /dev/null || error_exit "Please install conda, create a conda profile 'fastai-cpu' and activate it (conda activate <>)"
    python3 colorize_frames.py || error_exit "Colorizing frames failed"

    # FFMPEG combines the audio input and frames to a new video
    # You might want to adjust the -r value for the output framerate(?)
    ffmpeg -framerate $FRAMERATE -i "colorized_frames/video_output%03d.jpg" -i output-audio.mp3 colorized_video.mp4 || error_exit "Reassembling frames failed"

    # Alternatively, you could reassemble the video in a wrong order, creating stunning videos
    # ffmpeg -framerate $FRAMERATE -pattern_type glob -i "colorized_frames/video_output*.jpg" -i output-audio.mp3 colorized_video.mp4 || error_exit "Reassembling frames failed"
    rm -r colorize_frames
    xdg-open colorized_video.mp4
else
    echo "Youtube video URL is empty"
fi