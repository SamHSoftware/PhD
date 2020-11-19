% Reset the Command Window and the Workspace.
clear;
clc;

%% Collect the file path data. 

% Select the folder containing the first half of the timelapse. 
uiwait(msgbox('Please select the folder containing the first portion of the timelapse'));
first_timelapse_path = uipickfiles;

% Select the folder containing the second half of the timelapse. 
uiwait(msgbox('Please select the folder containing the second portion of the timelapse'));
second_timelapse_path = uipickfiles;

%% Create a new directory to contain the completed timelapse.

first_timelapse_path = cell2mat(first_timelapse_path);
cd (first_timelapse_path)
mkdir complete_timelapse

% Record the folder path for later. We'll need it to save images to the
% correct location. 
new_folder_path = fullfile(first_timelapse_path, 'complete_timelapse');

%% Confirm that the script has ended. 
disp('done')