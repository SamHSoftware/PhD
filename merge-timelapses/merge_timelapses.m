% Reset the Command Window and the Workspace.
clear;
clc;

%% Collect the file path data. 

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

%% Create a new directory to contain the completed timelapse.

cd (first_timelapse_path)
mkdir complete_timelapse

% Record the folder path for later. We'll need it to save images to the
% correct location. 
new_folder_path = fullfile(first_timelapse_path, 'complete_timelapse');

%% Copy information into the new directory. 

% Copy the first timelapse data into the new folder. 
copyfile(first_timelapse_path, new_folder_path)
disp('First folder copied.');

% Determine the greastest timepoint in the previous data. 
folder_information = dir (first_timelapse_path);
file_list = rot90({folder_information.name}, 3); 
image_length = cellfun('length',cellstr(file_list));

name_length = length(example_image);
file_list(~(image_length == name_length)) = [];
T_index = strfind(example_image, '_T');
file_list = char(file_list);
previous_max_timepoint = max(str2num(file_list(:, T_index+2:T_index+5)));

% Load image names from the second directory.
cd (second_timelapse_path)
folder_information = dir (second_timelapse_path);
file_list = char(rot90({folder_information.name}, 3)); 

% The copying loop. 
for n = 1 : length(folder_information)
    
    % Monitor progress
    if mod(n, 1000) == 0
        disp(n*100/length(folder_information))
    end
    
    % Load in our file. 
    file_in_question = file_list(n, 1:end);
    
    % Search for the timepoint string. 
    T_index = strfind(file_in_question, '_T');
    
    if isempty(T_index)
       
        % If the file in question isnt an image, skip to next loop. 
        continue; 
        
    else 
       
        % If the file is an image, modify the name and copy it to the new
        % directory. 
        current_timepoint = str2double(file_in_question(T_index+2:T_index+5));
        new_timepoint = num2str((current_timepoint + previous_max_timepoint), '%04.f'); 
        new_file_name = file_in_question;
        new_file_name(T_index+2:T_index+5) = new_timepoint;
        
        copyfile(fullfile(second_timelapse_path, file_in_question), fullfile(new_folder_path, new_file_name)) 
        
    end
end
disp('Second folder copied.');

%% Confirm that the script has ended. 
disp('Script complete.')