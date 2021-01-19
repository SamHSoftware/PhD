# Import the necessary packages and modules. 
import os
import pandas as pd
import numpy as np

# A function to unit test the data filtering module against example input and example output data. 
def test_filter_classes(): 
    
    # Load in the example input data. 
    current_directory = os.getcwd()
    example_input_path = current_directory.replace('tests', os.path.join('data','example_input.csv'))
    example_input = pd.read_csv(example_input_path, dtype={'waveData1':np.float64,
                                                          'waveData2':np.float64,
                                                          'waveData3':np.float64,
                                                          'waveData4':np.float64,
                                                          'waveData5':np.float64,
                                                          'waveData6':np.float64,
                                                          'waveData7':np.float64,
                                                          'waveData8':np.float64,
                                                          'waveData9':np.float64,
                                                          'waveData10':np.float64,
                                                          'waveData11':np.float64,
                                                          'waveData12':np.float64,
                                                          'waveData13':np.float64,
                                                          'waveData14':np.float64,
                                                          'waveData15':str,
                                                          'waveData16':np.float64,
                                                          'waveData17':np.float64}).round(decimals=6)
    # Get the file names and their corresponding grades. 
    grades = example_input.iloc[:,16].astype(float)
    
    # Filter the data such that it only contains rows with grades of greater than 2.5. 
    indices = grades > 2.5
    filtered_example_input = example_input[indices.values]
    filtered_example_input = filtered_example_input.reset_index(drop=True)
    
    # Load in the example output data. 
    example_output_path = current_directory.replace('tests', os.path.join('data', 'example_output.csv'))
    example_output = pd.read_csv(example_output_path, dtype={'waveData1':np.float64,
                                                          'waveData2':np.float64,
                                                          'waveData3':np.float64,
                                                          'waveData4':np.float64,
                                                          'waveData5':np.float64,
                                                          'waveData6':np.float64,
                                                          'waveData7':np.float64,
                                                          'waveData8':np.float64,
                                                          'waveData9':np.float64,
                                                          'waveData10':np.float64,
                                                          'waveData11':np.float64,
                                                          'waveData12':np.float64,
                                                          'waveData13':np.float64,
                                                          'waveData14':np.float64,
                                                          'waveData15':str,
                                                          'waveData16':np.float64,
                                                          'waveData17':np.float64}).round(decimals=6)
    
    # Test to ensure that the newly filterd file and the example output file are identical. 
    assert filtered_example_input.equals(example_output), 'The filtered example input data array is unequal in shape or content to the provided test output array.'
    
    # Let the user know the unit testing was successful. 
    print('Unit testing complete. No errors present.')
    
# Run the function to perform unit testing. 
test_filter_classes()