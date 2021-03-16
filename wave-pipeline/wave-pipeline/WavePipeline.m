% WavePipeline.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: This pipeline is deisgned to track human pluripotent stem cell
% colonies and extract fluorescence information from individual nuclei. 

% Pipeline inputs: 
% As described below, the user will need to select a file (the trained
% Random Forest segmentation model) and a directory (that which contans
% images from the Yokogawa CV7000S microscope). 
 
% Pipeline outputs: 
% Cell cycle data pertaining to my PhD. 

%% Clear the workspace and command window. 
clear; clc;

%% Select the folder which contains all the tiff images gathered by the Yoko.
uiwait(msgbox('The biggest issue with this pipeline are automatic windows updates. These destroy whatever stage fo the pipeline which was running. Thus, to be safe, update your computer prior to running this pipeline, then delay all remainig updates for a couple of weeks. Furthermore, run each stage of the pipeline seperately, then save the worksace upon completion of each function.','WARNING!'));
uiwait(msgbox('Select the folder containing the microscopy images','Sample Image','modal'));
folder_well = uipickfiles;

%% Select the segmentation model generated usign machine learning.
machineModelFullPath = loadMachineModel;
load(machineModelFullPath); % Loads model. 
% For some reason, when loaded in, the model always loads as a variable called 'model'. Any attempt to load it in with another name fails. Therefore, I let it load in as 'model', then rename it to an output variable later. 
machineModel = model; clear model; clear machineModelFullPath;

%% Articifially bin the images, if you so desire. 
doYouWantTobinImages = 'No'; % 'No' is the alternative variable. 
scalingFactor = 0.25; % A scaling factor of 0.5 is the equivant of binnning 2 by 2. 
folder_well = binImages(folder_well, doYouWantTobinImages, scalingFactor); % Note that if we use this function, we redefine the folder_well variable, as the folder containing the binned images.

%% Flat field correct the images. 
H2BChannel = 1; % double value needed e.g. 1.
Channels_To_Not_FFC = [4]; % vector of double values which represent the channels which shouldn't be flat field corrected e.g. the brightfield channel. 
doYouWantToFFCImages = 'Yes'; % 'No' is the alternative variable. 
lengthOfPixel = 0.325; % length (microns) of a pixel 20x short working distance lense, with no binning. The pixel size of the sensor is 6.5 um. That means that each pixel for 20x is 6.5/20 = 0.325 um.
binFactor = 4; % This is the amount of binning that has been performed on the images. 
folder_well = FFC_Interpolation(folder_well, machineModel, binFactor, doYouWantToFFCImages, Channels_To_Not_FFC, H2BChannel, lengthOfPixel);

%% This function creates mega-grids: 
% (one for each well that we're analysing). Within each new well-directory, there will be mega-grids of stiched images, ready for analysis! 
matrix_field = [1 2 3 4 5 6; 7 8 9 10 11 12; 13 14 15 16 17 18; 19 20 21 22 23 24; 25 26 27 28 29 30; 31 32 33 34 35 36];
gridsFolder = ConcatenateImagesYoko(folder_well, matrix_field);

%% Segment the grids and then DBSCAN to numerically identify colonies.
H2BChannel = 1; % double value needed e.g. 1.
binFactor = 4; % This is the amount of binning that has been performed on the images. 
lengthOfPixel = 0.325; % length (microns) of a pixel 20x short working distance lense, with no binning. The pixel size of the sensor is 6.5 um. That means that each pixel for 20x is 6.5/20 = 0.325 um.
segmentAndDBSCAN(gridsFolder, H2BChannel, binFactor, lengthOfPixel, machineModel)

%% Here, we track the colonies.
timelapseInterval = 1;
H2BChannel = 1; % double value needed e.g. 1.
binFactor = 4; % This is the amount of binning that has been performed on the images. 
lengthOfPixel = 0.325; % length (microns) of a pixel 20x short working distance lense, with no binning. The pixel size of the sensor is 6.5 um. That means that each pixel for 20x is 6.5/20 = 0.325 um.
[colonyIdentityLocations, CORRECTEDdirMatrix] = colonyTracking(gridsFolder, timelapseInterval,  binFactor, lengthOfPixel);

%% I take the colonyIdentityLocations info, and I use it to determine which colonies we can actually track.
timeThreshold = 24; % The min hours a colony needs to exist for it to be considered for analysis.
colonyStruc = analyseColonyIdentityArray(colonyIdentityLocations, timeThreshold);

%% This takes the colonyStruc and use it to iterate through all of the colonies which can be analysed. 
redChannel = 2; % Normal number needed e.g. 2. 
greenChannel = 3; % Normal number needed e.g. 9. 
cellType = 'hESCs'; % Or iPSCs. Make the name plural.
wholeColony = 'Yes'; % Yes or No. When Yes, considers all nuclei from colony. 
[dataFolders] = makeWavePlots(colonyStruc, CORRECTEDdirMatrix, folder_well, redChannel, greenChannel, timelapseInterval, cellType, wholeColony);

%% Here, you have the option to make movies from the tracked colonies. 
doYouWantToMakeAMovie = 'Yes';
fontSize = 70; % Must be between 1 and 200.
theChosenColourMap = hsv; % This can be changed, but if chanaged, I imagine it'll break everything. 
makeMovie(CORRECTEDdirMatrix, doYouWantToMakeAMovie, theChosenColourMap, dataFolders, fontSize); 

