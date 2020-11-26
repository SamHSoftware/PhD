# README for MATLAB script: simulations-to-xlsx.m

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com

## Description: 
- Please note, this description is purposfully vague to prevent unwanted dissemination of my research ideas prior to any publication. 
- One method of studying my cell-based phenomena is via simulations. 
- Examples of the data can be found [here](https://github.com/SamHSoftware/PhD/tree/main/simulations-to-xlsx/data).
- This code allows a user to select a folder of simulation data and convert the simulation data to a format (.xlsx files) more commonly used within my other data analysis pipelines and more easilt maniputated in excel. 
- For each .py file provided, there is an accompanying .ipynb file for those who use JupiterLab.

## Here's how to unit test the package before using it: 

(1) Run the ```test_simulations_to_xlsx_functions.py``` file.  

This code will automatically check to see if the outpout of the code is as expected. If an error is detected, the code will notify you of the error and will give a description of what has gone wrong. If no errors are detected, then the code will print a statement confirming this, and the rest of the package will be good to run. 

## How to use the ```RUNME.py``` file and use the package: 

(1) Open the ```RUNME.py``` file. 

(2) Within the ```RUNME.py``` file, first load in the module functions with the following code:

```
# Import the necessary packages.
from simulations_to_xlsx_functions import *
```

(3) Then, with the following function...
```
# A function to allow the user to select the folder containing the simulations.
# Function input args: none. 
# Function output 1: The path of the folder in question. 
file_path = folder_selection_dialog()
```
... a GUI will appear (see the image below), within which, the user should select the folder containing the simulation data you wish to analyse. 

<img src="https://github.com/SamHSoftware/PhD/blob/main/simulations-to-xlsx/img/folder_selection.PNG?raw=true" alt="folder selection GUI" width="500"/>


You can find the example data sets within [this folder](https://github.com/SamHSoftware/PhD/tree/main/simulations-to-xlsx/data). 

(4) Upon loading in your data, you may use the following function to convert the simulation data to a usuable format. 
```
# A function to take simulation data pertaining to my PhD and convert it to usuable .xlsx data.
# Funtion input arg 1: simulation_directory --> The directory containing the simulation folders. 
# Function output: A new directory (called 'simulations_xlsx') which contains the consensed model data.
simluations_to_xlsx(simulation_directory)
```

The code will then output individual .xlsx files for each simulation. These will be stored within the original directory that you selected using the ```folder_selection_dialog()``` function. The new folder of output data will be called 'simulations_xlsx'.

529115dfe5d7b05f16dfa7cf57f5d2d6766bf657

