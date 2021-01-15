# README for Python module: filter_RF_grades 

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com
Date of creation: 15<sup>th<\sup> January 2021

## Description: 
- This module is designed to take data containing a series of numerical 'grades'. These grades correspond to folders of excel files. Each excel file has a grade. Further descriptions of the data will not be included until publication of this work. 
- The purpose of the script is to filter the excel files, and create a new folder containg those fils with a grade of greater than 2.5. 
- The main module folder contains .ipynb files and equivalent .py files. 
 
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

<img src="" alt="folder selection GUI" width="500"/>

(3) Upon loading in the data and getting the file_path variable with the previous function, use the following code...
```
# A function to filter .xlsx data and make a new folder including grades 2.5 to 4, while excluding grades 1 to 2.5.
# Function input arg 1: directory (string) --> The directory to the file containing the grading data. 
# Funciton output 1: A new folder including grades 2.5 to 4, while excluding classes 1 to 2.5. 
filter_classes(file_path)    
```
... to create the output folder.  