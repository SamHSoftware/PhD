# README for MATLAB script: merge-timelapses.m

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com

## Description: 
- The Yokogawa CV7000S microscope can take timelapse movies of cells. Unfortunately, the imaging process cannot be paused. As a result of this, when the media is changed, one end one imaging protocl then start another. This results in the formation of two seperate folders of images, which, for all intensive purposes, belong to the same timelapse. 
- This script considers the first and second halves of the timelapse, then merges them together into a new folder, located within the directory containing the first half of the images. This new folder is called 'complete-timelapse'. 
- The timepoints of images within the second half of the timelapse are corrected, such that they follow on from the maximum timepoint of the first timelapse. 
- The inputs to this script are prompted with automatic dialog boxes, from which you can select the appropriate images/directories. 

## Inputs and outputs: 
- Script input 1: An example image. 
- Script input 2: The folder corresponding to the first half of thetimelapse. 
- Script input 3: The folder corresponding to the second half of the timelapse. 
- Script output 1: A new folder named 'complete-timelapse', containing all of the images. 