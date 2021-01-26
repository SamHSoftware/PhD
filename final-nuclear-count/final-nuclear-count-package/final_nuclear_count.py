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

# A function to extract, condense and save the relevant data. 
# Function input arg 1: directory (string) --> The directory to the folder containing the .xlsx data.
# Function output 1: ['DataFrame object] --> Contains a 1D array of the final number of nuclei per .xlsx file.
def get_final_nuclei(directory):
    
    print('test')
    
    # Get a list of the .xlsx files. 
    files = [file for file in os.listdir(directory) if file.endswith('.xlsx')]
    
    # Get the processed data folder. 
    processed_data_directory = os.path.join(directory,'Processed Data')
    processed_data_file = [file for file in os.listdir(processed_data_directory) if file.endswith('.csv')][0]
    processed_data_file = os.path.join(processed_data_directory, processed_data_file)
    
    # Get the list of files we need to process from the previous folder. 
    files_to_analyse = pd.read_csv(processed_data_file).iloc[:,14]
    
    # Create a list to hold the data. 
    df = []

    # Loop through the individual .xlsx files and extract the 'red' information. 
    for t in range(len(files_to_analyse)):

        # Construct the file path. 
        file_t = os.path.join(directory, files_to_analyse[t])
        
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
    print("get_final_nuclei complete. Your data has been saved (as 'final_nuclear_numbers.csv') within the directory you initially selected.")
        
    # Return the df as a function output. 
    return df