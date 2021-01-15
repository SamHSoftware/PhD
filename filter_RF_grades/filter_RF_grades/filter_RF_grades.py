from tkinter import *
from tkinter import filedialog
import os 
import pandas as pd 
import re 
import shutil
from shutil import copy

# A function to allow the user to select the file they wish to analyse. 
# Function inputs args: None. 
# Function output 1: The file path of that which was selected by the user. 
def file_selection_dialog():
    root = Tk()
    root.title('Please select the file in question')
    root.filename = filedialog.askopenfilename(initialdir="/", title="Select A File", filetypes=[("All files", "*.*")])
    file_path = root.filename
    root.destroy()

    return file_path

# A function to filter .xlsx data and make a new folder including grades 2.5 to 4, while excluding grades 1 to 2.5.
# Function input arg 1: directory (string) --> The directory to the file containing the grading data. 
# Funciton output 1: A new folder including grades 2.5 to 4, while excluding classes 1 to 2.5. 
def filter_classes(file_path):
        
    # Import the .csv file. 
    data = pd.read_csv(file_path, dtype=str)
    
    # Get the file names and their corresponding grades. 
    grades = data.iloc[:,16].astype(float)
    files = data.iloc[:,14].astype(str)
    
    # Identify the files with logical indices. 
    indices = grades > 2.5
    filtered_files = files[indices.values]
    
    # Create a new folder path ('filtered') to store the filtered files. 
    path_end = re.search('(Processed.*)', file_path).group(1)
    new_folder = file_path.replace(path_end, 'filtered')
    os.mkdir(new_folder)
    
    # Iterativey copy files to the new directory. 
    old_directory = file_path.replace(path_end, '')
    for x in range(len(filtered_files)):
        file = os.path.join(old_directory, filtered_files.iloc[x])
        shutil.copy(file, new_folder)
        
    # Indicate that the script is complete. 
    print('Filtering complete.')        