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