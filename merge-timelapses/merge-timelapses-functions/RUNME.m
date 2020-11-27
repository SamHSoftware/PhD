%% merge_timelapses RUNME.m script:

% Author: Sam Huguet
% e-mail: samhuguet1@gmail.com

% The Yokogawa CV7000S microscope can take timelapse movies of cells.
% Unfortunately, the imaging process cannot be paused. As a result of this,
% when the media is changed, one end one imaging protocl then start
% another. This results in the formation of two seperate folders of images,
% which, for all intensive purposes, belong to the same timelapse. 

% This script considers the first and second halves of the timelapse, then
% merges them together into a new folder, located within the directory
% containing the first half of the images. This new folder is called
% 'complete-timelapse'. 

% The timepoints of images within the second half of the timelapse are
% corrected, such that they follow on from the maximum timepoint of the
% first timelapse. 

%% Run the following functions: 
% Function purpose: user is prompted with automatic dialog boxes, from
% which they can select the appropriate input images/directories. 

% Script output 1: An example image file name. 
% Script output 2: The folder corresponding to the first half of the
% timelapse. 
% Script output 3: The folder corresponding to the second half of the
% timelapse. 
[example_image, first_timelapse_path, second_timelapse_path] = collect_path_data();

% Function purpose: Merge the first and second timelapse folders. 
% Function inputs: The outputs of collect_path_data().
% Script output 1: A new folder named 'complete-timelapse', containing all
% of the images. 
merge_timelapses(example_image, first_timelapse_path, second_timelapse_path);