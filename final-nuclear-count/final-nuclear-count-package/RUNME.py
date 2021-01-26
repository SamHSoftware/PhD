# Import the necessary functions.
from final_nuclear_count import *

# A function to allow the user to select the folder containing the data.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
directory = folder_selection_dialog()

# A function to extract, condense and save the final number of nuclei per timepoint. 
# Function input arg 1: directory (string) --> The directory to the folder containing the .xlsx data.
# Function output 1: A .csv (saved to 'directory') containing the summarised information. 
get_final_nuclei(directory)