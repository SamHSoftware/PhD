# Import the necessary packages and modules. 
import os
current_directory = os.getcwd()
module_directory = current_directory.replace('tests', 'simulations-to-xlsx-package')
import sys
sys.path.insert(0, module_directory)
from simulations_to_xlsx_functions import *
import numpy as np
from pandas._testing import assert_frame_equal

# Test the function 'simluations_to_xlsx()' against the provided outputs. 
# Function input args: None. 
# Function returns: When no errors are detected, a statement confirming this is printed. When errors are detcted, assertion errors are raised. 
def test_simluations_to_xlsx(): 

    # Get a list of the simulation folders. 
    current_directory = os.getcwd()
    folder_path = current_directory.replace('tests', 'data')
    folder_path = os.path.join(folder_path, 'test_1')
    
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
            'NaN',
            'NaN',
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
    df = df.iloc[:,2:13]
    df = df.round(decimals=4) # Limit number of decimal places to account for rounding errors. 
    
    # Load in the Truth data. 
    truth_data_path = os.path.join(current_directory, 'data', 'test_1.xlsx')
    truth_data = pd.read_excel(truth_data_path)
    truth_data = truth_data.iloc[:,2:13]
    truth_data = truth_data.round(decimals=4) # Limit number of decimal places to account for rounding errors. 

    # Test 1: Check to see whether the condensed simulation data is equal to the expected values. 
    assert pd.DataFrame.equals(truth_data, df), "Test 1 failed. Condensed simulation data is not equal to the expected values."

    print('Tests complete. No errors found.')
    
# Run the function for unit testing
test_simluations_to_xlsx()
