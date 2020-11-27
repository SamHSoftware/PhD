# README for MATLAB script: merge-timelapses.m

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com

## Description: 
- The Yokogawa CV7000S microscope can take timelapse movies of cells. Unfortunately, the imaging process cannot be paused. As a result of this, when the media is changed, one end one imaging protocl then start another. This results in the formation of two seperate folders of images, which, for all intensive purposes, belong to the same timelapse. 
- This script considers the first and second halves of the timelapse, then merges them together into a new folder, located within the directory containing the first half of the images. This new folder is called 'complete-timelapse'. 
- The timepoints of images within the second half of the timelapse are corrected, such that they follow on from the maximum timepoint of the first timelapse. 
- The inputs to this script are prompted with automatic dialog boxes, from which you can select the appropriate images/directories. 

## How to use the ```RUNME.m``` file:

(1) Open the ```RUNME.m``` file. 

(2) Then, with the following function... 
```
% Script output 1: An example image file name. 
% Script output 2: The folder corresponding to the first half of the
% timelapse. 
% Script output 3: The folder corresponding to the second half of the
% timelapse. 
[example_image, first_timelapse_path, second_timelapse_path] = collect_path_data();
```
... A series of GUI's will appear (see the image below), with which, you will be prompted to select an example image, the folder containing the first half of the timelapse, and the folder containing the second half of the timelapse. 

<img src="https://github.com/SamHSoftware/PhD/blob/main/merge-timelapses/img/folder_selection.PNG?raw=true" alt="folder selection GUI" width="500"/>

You can find the example data sets within [this folder](https://github.com/SamHSoftware/PhD/tree/main/merge-timelapses/data).

(4) Upon loading in your data, you may use the following function to merge the two timelapses into a new folder named 'complete-timelapse', located within the first timelapse folder. 
```
% Function purpose: Merge the first and second timelapse folders. 
% Function inputs: The outputs of collect_path_data().
% Script output 1: A new folder named 'complete-timelapse', containing all
% of the images. 
merge_timelapses(example_image, first_timelapse_path, second_timelapse_path);
```







Inputs and outputs: 
- Script input 1: An example image. 
- Script input 2: The folder corresponding to the first half of thetimelapse. 
- Script input 3: The folder corresponding to the second half of the timelapse. 
- Script output 1: A new folder named 'complete-timelapse', containing all of the images. 