%% collect_path_data.m script:

% Author: Sam Huguet
% e-mail: samhuguet1@gmail.com

% This script allows a user to select images and folders, such that their
% path's will be stored as variables and passed to the merge_timelapses()
% function. 

% Inputs: None. 

% Outpouts: The outputs from  to this script are gathered with GUIs, with which 
% the user selects the appropriate images/directories. 
% Script output 1: An example image file name. 
% Script output 2: The folder corresponding to the first half of the
% timelapse. 
% Script output 3: The folder corresponding to the second half of the
% timelapse. 

%% The function: 
function [example_image, first_timelapse_path, second_timelapse_path] = collect_path_data()
    
    % Select an image to act as an example in the merge_timelapses() function. 
    uiwait(msgbox('Please select an example image file.'));
    example_image = uigetfile('*.tiff');

    % Select the folder containing the first half of the timelapse. 
    uiwait(msgbox('Please select the folder containing the first portion of the timelapse'));
    first_timelapse_path = uipickfiles;
    first_timelapse_path = cell2mat(first_timelapse_path);

    % Select the folder containing the second half of the timelapse. 
    uiwait(msgbox('Please select the folder containing the second portion of the timelapse'));
    second_timelapse_path = uipickfiles;
    second_timelapse_path = cell2mat(second_timelapse_path);
