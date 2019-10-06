# Video Colorization
Good thing we live in the future, and better still that there is Open Source software.
[jantic](https://github.com/jantic) has created the awesome tool [DeOldify](https://github.com/jantic/DeOldify) that is colorizing images based on Deep Learning, and **this is an attempt to apply his colorizing software to videos, frame by frame**.


## Deprecation notice
```
Good news: Video colorization has found it's way to the Deoldify project, including models trained for exactly this purpose and astonishing result.
I'll discontinue my work on this side project and try to upstream changes to the other repository. 
```

## System requirements
* This software has been tested on **Ubuntu** Mate **18.04**, other Linux distributions might be able to run it with minor or no adjustments.
* Converting a video using machine learning requires some heavy lifting, which means in this case that your machine needs a **[CUDA-supporting GPU](https://developer.nvidia.com/cuda-gpus)**. A very eary version of this script supported CPU-execution, but the speed loss is somewhere near factor 10.
* The amount of **GPU RAM** you have limits the quality of the result.

## Build instruction
* Clone this repository [including the "DeOldify" submodule](https://blog.github.com/2016-02-01-working-with-submodules/):

  `git clone --recursive git@github.com:Ichaelus/video-colorization.git`

* Follow the [installation instructions of DeOldify](https://github.com/jantic/DeOldify/#easy-install). You should at least have a **conda** environment set up to run the colorization stuff and downloaded the pretrained weights.

  `conda activate deoldify`

* Colorize your own video! The script will tell you about further missing dependencies.

  `./colorize_video.sh`

## Command reference
These commands are using a sample video from YouTube, the historical milestone "Dickson Experimental Sound Film (1894)".

`./colorize_video.sh <YOUTUBE_VIDEO_URL> <FRAMERATE>`

<table>
  <tr>
    <th>Fragment</th>
    <th>Explanation</th>
  </tr>
  <tr>
    <td><b>./colorize_video.sh</b></td>
    <td>The main program executable. To be called for any video conversion.</td>
  </tr>
  </tr>
  <tr>
    <td><b>YOUTUBE_VIDEO_URL</b></td>
    <td>Required parameter. The full URL to a YouTube video, e.g. "https://www.youtube.com/watch?v=SwIcRSvQ_TY".</td>
  </tr>
  </tr>
  <tr>
    <td><b>FRAMERATE</b></td>
    <td>Optional parameter. The framerate of the original and resulting video. Can be inspected in YouTube by activating "Statistics for nerds". Default value: 25.</td>
  </tr>
</table>


You can view the colorized video in the `results` directory.

## Examples
For the above example of the "Dickson Experimental Sound Film", you can see the results at 30fps with a render factor of 30 here:
https://www.youtube.com/watch?v=kU3-m4Gc1Q8&feature=youtu.be

This example was created using a very early version of both the machine learning model and this tool.

Some more examples:

[![Colorized Dickson Experimental Sound Film](https://img.youtube.com/vi/kU3-m4Gc1Q8/0.jpg)](https://www.youtube.com/watch?v=kU3-m4Gc1Q8 "Colorized Dickson Experimental Sound Film")

_**Dickson Experimental Sound Film**_

[![Colorized video: Oliver Heldens feat. RUMORS - Ghost](https://img.youtube.com/vi/1hGzCKObrlY/0.jpg)](https://www.youtube.com/watch?v=1hGzCKObrlY "Oliver Heldens feat. RUMORS - Ghost")

_**Oliver Heldens feat. RUMORS - Ghost**_


## Things likely to be implemented 

* [ ] Adding an optional parameter that controls DeOldify's `render_factor`
* [ ] Guessing the best value for DeOldify's parameter `render_factor`. It depends on the users GPU-RAM, and will vary for each hardware. Higher is better.
* [ ] Guessing the input format (Youtube or local mp4 video) and allowing both.
* [ ] Guessing the `render_factor` based on a "ternary search". I.e. comparing the grayscale histogram of each frame with the original histogram, and thus evaluating if the result is feasible or not. (This will definitely increase the runtime of this tool, and should not be default)


## Troubleshooting

* `Status code: 403 - Failed to download video.`. You might be using an old version of `ytdl` that is now incompatible with the current YouTube API. Update it, e.g. with `sudo npm -g update ytdl`.