import multiprocessing
import os
import tensorboardX
from torch import autograd
from deoldify.fastai.transforms import TfmType
from deoldify.fasterai.transforms import *
from deoldify.fastai.conv_learner import *
from deoldify.fasterai.images import *
from deoldify.fasterai.dataset import *
from deoldify.fasterai.visualize import *
from deoldify.fasterai.callbacks import *
from deoldify.fasterai.loss import *
from deoldify.fasterai.modules import *
from deoldify.fasterai.training import *
from deoldify.fasterai.generators import *
from deoldify.fasterai.filters import *
from deoldify.fastai.torch_imports import *
from pathlib import Path
from itertools import repeat
import numpy as np
import cv2
import math

# Todo: Sort functions
# Todo: Move to a class, add instance variables

def colorize_frame(visualizer:ModelImageVisualizer, inputPath:Path, render_factor:int=None):
  return visualizer._get_transformed_image_ndarray(inputPath, render_factor)

def save_frame(visualizer:ModelImageVisualizer, frame, targetPath:Path):
  return visualizer._save_result_image(targetPath, frame)

def add_render_factor_to_file(filename:str, render_factor:int):
  parts = filename.split('.')
  parts[-2] = parts[-2] + "_" + str(render_factor)
  filename_with_render_factor = '.'.join(parts)
  return filename_with_render_factor

def calculate_grayscale_histogram(imagePath:Path):
  image = cv2.imread(str(imagePath))
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
  return cv2.calcHist([gray], [0], None, [256], [0, 256])

RENDER_FACTORS = range(12, 46)
def ternary_search_best_render_factor(visualizer:ModelImageVisualizer, original_histogram, input_path):
  # Idea: first, take 3 samples
  # Repeat: create sample between the best value and the second best neighbor
  # End if two adjacent cells have been rendered

  triple = {
    'left': {
      'index': 0,
      'render_factor': RENDER_FACTORS[0],
      'histogram_correlation': histogram_correlation(visualizer, original_histogram, input_path, RENDER_FACTORS[0])
    },
    'right': {
      'index': len(RENDER_FACTORS)-1,
      'render_factor': RENDER_FACTORS[len(RENDER_FACTORS)-1],
      'histogram_correlation': histogram_correlation(visualizer, original_histogram, input_path, RENDER_FACTORS[len(RENDER_FACTORS)-1])
    }
  }

  triple['center'] = compute_triple_center(triple, visualizer, original_histogram, input_path)
  print_triple_status(triple)

  while triple['left']['index'] < triple['center']['index'] and triple['center']['index'] < triple['right']['index']:
    max_correleation_key = find_max_correleation_key(triple)
    if max_correleation_key == 'left':
      # Continue search between [left, old center]
      triple['right'] = triple['center']
    elif max_correleation_key == 'center':
      left_is_second_best = triple['left']['histogram_correlation'] > triple['right']['histogram_correlation']
      if left_is_second_best:
        # Continue search between [left, old center]
        triple['right'] = triple['center']
      else:
        # Continue search between [old center, right]
        triple['left'] = triple['center']
    elif max_correleation_key == 'center':
      # Continue search between [old center, right]
      triple['left'] = triple['center']
    
    triple['center'] = compute_triple_center(triple, visualizer, original_histogram, input_path)
    print_triple_status(triple)

  #import pdb; pdb.set_trace() # ByeBug
  return triple[find_max_correleation_key(triple)]['render_factor']

def compute_triple_center(triple:dict, visualizer:ModelImageVisualizer, original_histogram, input_path):
  center_index = (triple['left']['index'] + triple['right']['index']) // 2
  return {
    'index': center_index,
    'render_factor': RENDER_FACTORS[center_index],
    'histogram_correlation': histogram_correlation(visualizer, original_histogram, input_path, RENDER_FACTORS[center_index])
  }

def find_max_correleation_key(triple:dict):
  key_correlation_mapping = {}
  for key in triple.keys():
    key_correlation_mapping[key] = triple[key]['histogram_correlation']
  max_correleation_key = [key for key in key_correlation_mapping.keys() if key_correlation_mapping[key] == max(key_correlation_mapping.values())]
  return max_correleation_key[0]

def histogram_correlation(visualizer:ModelImageVisualizer, original_histogram, input_path, render_factor):
  frame = colorize_frame(visualizer, input_path, render_factor)
  save_frame(visualizer, frame, input_path)

  frame_path = visualizer.results_dir/input_path.name
  current_histogram = calculate_grayscale_histogram(frame_path)

  # For other correlation methods, see
  # https://docs.opencv.org/2.4/modules/imgproc/doc/histograms.html?highlight=comparehist#comparehist
  histogram_correlation = cv2.compareHist(original_histogram, current_histogram, cv2.HISTCMP_CORREL)
  return histogram_correlation

def print_triple_status(triple:dict):
  left_border = triple['left']['render_factor']
  right_border = triple['right']['render_factor']
  left_correlation = triple['left']['histogram_correlation']
  center_correlation = triple['center']['histogram_correlation']
  right_correlation = triple['right']['histogram_correlation']
  print(f'Searching render factors[{left_border}, {right_border}] - current correlations:')
  print(f'(left, center, right) = ({left_correlation}, {center_correlation}, {right_correlation})')

plt.style.use('dark_background')
torch.backends.cudnn.benchmark=True

filters = [Colorizer34(gpu=None, weights_path='./deoldify/colorize_gen_192.h5')]
visualizer = ModelImageVisualizer(filters, render_factor=42, results_dir='colorized_frames')

for subdir, dirs, files in os.walk('original_frames'):
  for file in files:
    input_path = Path(os.path.join(subdir, file))

    if file.lower().endswith('jpg'):
      original_histogram = calculate_grayscale_histogram(input_path)
      # Experimental: render_factor = ternary_search_best_render_factor(visualizer, original_histogram, input_path)
      render_factor = 24

      print("Found the best render factor " + str(render_factor) + " for the image " + file)
      frame = colorize_frame(visualizer, input_path, render_factor)
      save_frame(visualizer, frame, input_path)

    os.remove(input_path)


print("All frames have been converted")