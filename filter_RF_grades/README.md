# README for Python module: filter_RF_grades 

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com
Date of creation: 15<sup>th</sup> January 2021

## Description: 
- This module is designed to take data containing a series of numerical 'grades'. Further descriptions of the data will not be included until publication of this work. 
- The purpose of the script is to filter the data such that each row of features has a grade of greater than 2.5. 
- The main module folder contains .ipynb files and equivalent .py files. 

## How to unit test the module before use: 

(1) Download the package, and avoid altering the organisation of the files/directories within, as this will ensure that the knows where to look for unit testing data ([You can find the unit testing data here](https://github.com/SamHSoftware/PhD/tree/main/filter_RF_grades/tests)).

(2) Open and run the ```RUNME_tests``` file in the tests folder. This code will use assertion errors to check for array equality between a newly filtered array, and a pre-provided output 'truth' array. If nothing is wrong, the code will print such a conformation. An assertion error is raised is something goes awry. 

## How to use the ```RUNME``` file: 

(1) Open the ```RUNME``` file. 
    
(2) The with the following function... 
```
# Import the necessary functions and packages.
from filter_RF_grades import *

# A function to allow the user to select the file they wish to analyse. 
# Function inputs args: None. 
# Function output 1: The file path of that which was selected by the user. 
file_path = file_selection_dialog()
```
... you will load in the the necessary module functions. Then, you will see a GUI appear (see the example below) with which you can select the .csv file made by the MATLAB based random forrest regression model script. Usually, these files have a name such as 'AnalysingWaves_P1_P2_Combined_date', and it needs to contain the numerical grades we're intersted in. 

<img src="https://github.com/SamHSoftware/PhD/blob/main/filter_RF_grades/img/file_selection.PNG?raw=true" alt="folder selection GUI" width="500"/>

(3) Upon loading in the data and getting the file_path variable with the previous function, use the following code...
```
# A function to filter .xlsx data and make a new folder including grades 2.5 to 4, while excluding grades 1 to 2.5.
# Function input arg 1: directory (string) --> The directory to the file containing the grading data. 
# Funciton output 1: A new folder including grades 2.5 to 4, while excluding classes 1 to 2.5. 
filter_classes(file_path)    
```
... to create the output file.  