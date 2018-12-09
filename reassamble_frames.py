import os

os.system("ffmpeg -r 1 -i colorized_frames/img%01d.jpg -vcodec mpeg4 -y colorized_video.mp4")
