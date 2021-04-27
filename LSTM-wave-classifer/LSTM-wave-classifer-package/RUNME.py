# Import the necessary packages.
from LSTM_wave_classifier_functions import *

# A function to allow the user to select the folder containing the data.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
training_directory = folder_selection_dialog()

# A function to extract and condense the relevant data. 
# Function input arg 1: directory (string) --> The directory to the folder containing the .xlsx data.
# Function input arg 2: train_or_classify (string) --> Use 'train', when collecting data to train the model. Use 'classify' when collecting data which needs to be classified.
# Function output 1: df --> The pandas dataframe containing the training information.
df = get_red_waves(directory,
                   train_or_classify = 'train')


