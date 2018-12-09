## System requirements
* This software has been tested on Ubuntu Mate 18.04, other Linux distributions might be able to run it with minor adjustments
* Converting a video using machine learning requires some heavy lifting, you are doing better with a CUDA-supporting GPU.
  I developed this program using a modern CPU only, so you should do fine in either case - just slower.
* Have >= 16GB of RAM, and allow your system to swap a litte bit. The "render_factor" of DeOldify seems to be limited by your RAM capacity, and it influences the maximum outcome of the colorization. On the other hand, choosing a smaller render_factor means your frames are converted _way_ faster, so feel free to experiment here.

## Build instruction
* Clone [DeOldify](https://github.com/jantic/DeOldify/) into the `deoldify` subfolder
* Follow their installation instructions. 
  * You should have a working copy of `fastai` inside that project folder
  * You should have a conda environment set up to run the colorization stuff
* Example for converting the "Dickson Experimental Sound Film (1894)" from YouTube:
  * Activate the conda profile with `conda activate <profile name>`, in my case `fastai-cpu`
  * Run `./convert_video.sh https://www.youtube.com/watch?v=SwIcRSvQ_TY`
* To change the default framerate (25), pass it as the second argument.
* View the colorized video in the `results` directory.

## Example
For the above example of the "Dickson Experimental Sound Film", you can see the results at 30fps with a render factor of 30 here:
https://www.youtube.com/watch?v=kU3-m4Gc1Q8&feature=youtu.be

This example was created using a very early version of both the ML model and this tool.

## Things it's like to implement

* [ ] Adding an optional parameter that controls DeOldify's `render_factor`
* [ ] Making it possible to colorize local videos (i.e. implementing a YT URL matcher, copying the local file if it doesn't match)
* [ ] Guessing the `render_factor` based on a "ternary search". I.e. comparing the grayscale histogram of each frame with the original histogram, and thus evaluating if the result is feasible or not.
* [ ] Dropping dependencies. I'd like to remove NodeJS and end up with `ffmpeg` + DeOldify dependencies.