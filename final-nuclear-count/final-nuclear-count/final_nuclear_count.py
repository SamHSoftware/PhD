from tkinter import *
from tkinter import filedialog
import os 
import pandas as pd
import numpy as np

# A function to allow the user to select the folder containing the data.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
def folder_selection_dialog():
    root = Tk()
    root.title('Please select the directory containing the .xlsx files')
    root.filename = filedialog.askdirectory(initialdir="/", title="Select A Folder")
    directory = root.filename
    root.destroy()

    return directory

# A function to extract and condense the relevant data. 
# Function input arg 1: directory (string) --> The directory to the folder containing the .xlsx data.
# Function output 1: A .csv (saved as 'final_nuclear_numbers.csv' to directory) containing the summarized information. 
def get_final_nuclei(directory):
     
    # Get a list of the .xlsx files. 
    files = [file for file in os.listdir(directory) if file.endswith('xlsx')]
    
    # Create a list to hold the data. 
    df = []

    # Loop through the individual .xlsx files and extract the 'red' information. 
    for t in range(len(files)):

        # Construct the file path. 
        file_t = os.path.join(directory, files[t])
        
        # Load in the .xlsx data. 
        data = pd.read_excel(file_t, index_col=None)
    
        # Add the number of nucleai at the last timepoit to our list. 
        nuclei = data.iloc[-1,5]
        nuclei = np.array(nuclei).tolist()
        df.append(nuclei)

    # Convert the list to a pandas dataframe. 
    df = pd.DataFrame(df)
    
    # Save the DataFrame to a .csv file. 
    new_file_name = os.path.join(directory, 'final_nuclear_numbers.csv')
    df.to_csv(new_file_name, index=False)
    
    # Confirm the code is done. 
    print("Process complete. Your data has been saved (as 'final_nuclear_numbers.csv') within the directory you initially selected.")
    