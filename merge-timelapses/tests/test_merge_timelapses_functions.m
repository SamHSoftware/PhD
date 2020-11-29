%% merge_timelapses RUNME.m script:

% Author: Sam Huguet
% e-mail: samhuguet1@gmail.com

% This script is designed to test the merge_timelapses function. For this
% script to work, you must download and run this script from this package.
% This is to preserve path heirarchy, which ensures that code know where to
% find the provided test input data dn the expected output data. 

% Script input args: None. 

% Script outputs: If the script does not detect any errors, then a
% statement confirming this will be printed to the command window. If
% errors are detected, then you will also notified via the command window,
% alongside a description of the error. 

%% Create a new ouput from the test data. 

% Load in the path data to feed into the merge_timelapses function. 
exampe_image = 'AssayPlate_PerkinElmer_CellCarrier-96_B02_T0001F001L01A01Z01C01.tiff';
current_directory = matlab.desktop.editor.getActiveFilename;
first_timelapse_path = fullfile(current_directory(1:end-40), 'data', 'timelapse_1');
second_timelapse_path = fullfile(current_directory(1:end-40), 'data', 'timelapse_2');

% generate a merged folder of images from the test data. 
merge_timelapses(example_image, first_timelapse_path, second_timelapse_path);
complete_timeplapse_path = fullfile(first_timelapse_path, 'complete_timelapse'); 

folder_information = dir (complete_timeplapse_path);
test_files = rot90({folder_information.name}, 3); 

%% Load in information pertaining to the expected test output data. 

truth_timelapse_path = fullfile(current_directory(1:end-34),'expected_test_output_data');
folder_information = dir (truth_timelapse_path);
truth_files = rot90({folder_information.name}, 3); 

%% Use assertion errors to make necessary checks. 