# README for Python module: final_nuclear_count

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com  
Date of creation: 27<sup>th</sup> January 2021

# Description: 
- This module is designed to take .xlsx data of the number of nuclei within a colony per microscopy timepoint. 
- The purpose of this code is to consider a folder of .xlsx file (each representing a colony), and take the final number of nuclei within each colony. Finally, the code simply makes a new excel file containing these values.
- I have included .py files and .ipynb files for those who use JupyterLab. 

## How to unit test the module before use: 

(1) Download the package, and avoid altering the organisation of the files/directories within, as this will ensure that the code knows where to look for unit testing data ([You can find the unit testing data here, organised as the code expects to find it.](https://github.com/SamHSoftware/PhD/tree/main/final-nuclear-count/data)).

(2) Open and run the ```test_final_nuclear_count``` file in the tests folder. This code will use assertion errors to see if the code considers the relevant .xlsx files, and whether their information is correclty extracted and reformatted. If nothing is wrong, the code will print such a conformation. An assertion error is raised is something goes awry. 