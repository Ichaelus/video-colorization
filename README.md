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