% Reset the Command Window and the Workspace.
clear;
clc;

%% Load image.

% Open the file (in this case a .tiff) needed for nuclear analysis. 
Original_Path = uipickfiles;

% We now need to set the WD to Original_Path so as to create a new dir in
%the correct location. 
cd(Original_Path);

% Here, Matlab can read and show the image. 
Original_Im_Read = imread(Original_Im);



%% Confirm that the script has ended. 
disp('done')