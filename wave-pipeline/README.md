# README for project: wave-pipeline

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com

## Description:   
- This computational pipeline is designed to handle data pertaining to my PhD research. This data will not be extensively described here, as the work is currently unpublished. Nonetheless, the indivudal components of this pipeline may be useful to anyone wishing to automate the analysis of cell biology microscopy images. Should anyone wish to continue my research, this pipeline will be essential. 
- This pipeline processes microscopy data gathered by the Yokogawa CV7000S microscope. 
- The microscopy data contains images of cell nuclei, expressing fluorescent markers in 3 different channels (one to stain the nucleus, and two reporters of biological activity). 
- The pipeline extracts this fluorescence data, processes it, and outputs graphical and numerical data for further analysis. 

## Software requirements: 
- This pipeline uses MATLAB scripts, and was designed for use with MATLAB 2019a. I recommed you use this version. 

## Using the pipeline: 

(1) Following the download of this code, modify you MATLAB path to include this folder, such that all functions can be accessed. 

(2) Open ```WavePipeline.m```. This file contains a script with which you can sequentially run elements of the pipeline. There are several functions, many of which have a variety of input arguments (explained within the code) which can (and should!) be edited. I recommend that you run each function individually, then save the workspace. This way, when you handle vast quantities of data, and windows undergoes an automatic restart, you can minimise lost time. 

(3) You need to have created a trained segmentation model using the following function: ```pixelClassifierTrain.m```. This function can be found within the ```PixelClassifer2_Edited``` folder. This code is not originally mine (see the folder's README), but I've had to re-upload it due to a number of small edits which have made it compatible with my pipeline. If you don't want to train your own model, I've included a pre-trained model (called ```trained_rf_segmentation_model.mat```) which can work very well with small claibrations. 

Once you have trained your model, you will need to use the following code... 
```
%% Select the segmentation model generated usign machine learning.
machineModelFullPath = loadMachineModel;
load(machineModelFullPath); % Loads model. 
% For some reason, when loaded in, the model always loads as a variable called 'model'. Any attempt to load it in with another name fails. Therefore, I let it load in as 'model', then rename it to an output variable later. 
machineModel = model; clear model; clear machineModelFullPath;
```
... to load in your trained segmentation model, or the one I've provided. Simple.  

When the model is used for segmentation by the ```pixelClassifer2``` function, it outputs 3 images.    
(A) An 'adjusted image', one in which the pixel intensity histogram is simply adjusted so that it's easier to see nuclei.  
(B) An RGB probability map, which denotes the probability that each pixel is of a particular class (see my thesis for more detail).   
(C) A binary image of the binary masks.    

The third output isn't actually that usful in itself, as it assumes that you have correctly calibrated the parameters inside the function. To get an accurate image of binary masks, you need to consider the RGB probability map and impose conditional thresholds upon each of the three channels to create a binary mask. You can do so with this code (where ```param``` is specified by you in the main pipeline): 
```
[~, RGBprobs, ~] = pixelClassifier2(imageName, machineModel, param);
backgroundMasks = RGBprobs(:,:,1) > 0.05 & RGBprobs(:,:,2) < 0.5 & RGBprobs(:,:,3) < 0.2; % This is the line you need to change. 
```
The first threshold refers to 'background' intensity, the second to 'nuclear boarder' intensity and the third to 'nuclear' intensity.  

Feed this function an image to calibrate it, then enter the re-calibrated thresholds in two locations: 
(A) Line 204 of ```FFC_Interpolation.m```.    
(B) Line 144 of ```segmentAndDBSCAN.m```.      

Alternatively, you can always swap this out for your own segmentation function. That would work without issue. 

(4) Then, run the rest of the functions within ```WavePipeline.m``` such that your images are:  
      
(A) Binned.  
(B) Flat field corrected.  
(C) Stiched into multi-field images.  
(D) Segmented and DBSCANned.  
(E) Tracked.  
(F) Create .xlsx files for each tracked colony, and movies of the each well through time. 

(5) Finally, open ```analysingWaves.m``` in order to extract numerical features from the .xlsx files. ```analysingWaves.m``` relies upon an additional package, named ```random-forest-generic```, created by Soumya Banerjee in 2015. I have included a copy of this package so that it can conveniently downloaded. ```analysingWaves.m``` can be run to output a condensed list of numerical features, which can then be statistically analysed. 
                    