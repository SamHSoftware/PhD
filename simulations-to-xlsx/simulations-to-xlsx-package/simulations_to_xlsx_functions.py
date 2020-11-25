from tkinter import *
from tkinter import filedialog
import os 
import pandas as pd 
import numpy as np

# A function to allow the user to select the folder contianing the simulations.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
def folder_selection_dialog():
    root = Tk()
    root.title('Please select the directory containing the folders fo simulation data.')
    root.filename = filedialog.askdirectory(initialdir="/", title="Select A Folder")
    simulation_directory = root.filename
    root.destroy()

    return simulation_directory

# A function to take simulation data pertaining to my PhD and convert it to usuable .xlsx data.
# Funtion input arg 1: simulation_directory --> The directory containing the simulation folders. 
# Function output: A new directory (called 'simulations_xlsx') which contains the consensed model data.
def simluations_to_xlsx(simulation_directory):

    # Get a list of the simulation folders. 
    folder_list = os.listdir(simulation_directory) 
    
    # Create a new output folder. 
    simultions_xlsx_dir = os.path.join(simulation_directory, "simulations_xlsx")
    os.mkdir(simultions_xlsx_dir)
    
    # Loop through the simulation folders.
    for n in range(len(folder_list)):
        
        # Construct the folder path. 
        folder_path = os.path.join(simulation_directory, folder_list[n])
        
        # Get a list of all the files within the folder. 
        files = os.listdir(folder_path) 
        
        # Create a list to hold the data. 
        df = []
        
        # Loop through the individual simulation files and condense their information into a usable format. 
        for t in range(len(files)):

            # Construct the file path. 
            file_t = os.path.join(folder_path, f"time{t+1}.csv")
            
            # Extract the relevant data from the .cvs file.
            data = pd.read_csv(file_t, dtype=float)
            data = data.iloc[:,3]
            
            # Count instances of red and green
            red_count = sum(data == 1)
            green_count = sum((data == 2) | (data == 3) | (data == 4))
            
            # Record the data.
            d = [
                'NA',
                'NA',
                ((t*0.5)+0.5),
                red_count,
                green_count,
                red_count + green_count,
                red_count / (red_count + green_count),
                green_count / (red_count + green_count),
                ((red_count*1.1+5)/((red_count*1.1+5)+(green_count*0.9)))-(red_count/(red_count+green_count)),
                (red_count / (red_count + green_count))-((red_count*0.9)/((red_count*0.9)+(green_count*1.1+5))),
                ((green_count*1.1+5)/((red_count*0.9)+(green_count*1.1+5)))-(green_count/(red_count + green_count)),
                (green_count / (red_count + green_count))-((green_count*0.9)/((green_count*0.9)+(red_count*1.1+5)))
            ]
            df.append(d)
        
        # Append all the information to our dataframe. 
        df = pd.DataFrame(df, columns=['Colony','Well','Timpoint (hours)','Number of red nuclei','Number of green nuclei','Total number of nuclei','Proportion of red nuclei','Proportion of green nuclei','Upper bound: red','Lower bound: red','Upper bound: green','Lower bound: green'])
    
        # Save our data.
        folder_name =  os.path.basename(os.path.normpath(folder_path))
        df.to_excel(os.path.join(simultions_xlsx_dir, f"{folder_name}.xlsx"), index=False)