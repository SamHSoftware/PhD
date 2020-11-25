# Import the necessary packages.
from simulations_to_xlsx_functions import *

# A function to allow the user to select the folder containing the simulations.
# Function input args: none. 
# Function output 1: The path of the folder in question. 
file_path = folder_selection_dialog()

# A function to take simulation data pertaining to my PhD and convert it to usuable .xlsx data.
# Funtion input arg 1: simulation_directory --> The directory containing the simulation folders. 
# Function output: A new directory (called 'simulations_xlsx') which contains the consensed model data.
simluations_to_xlsx(simulation_directory)