# Import the necessary packages.
from LSTM_wave_classifier_functions import *

# Select the training data.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
training_directory = folder_selection_dialog()

# A function to extract and condense the relevant training data. 
# Function input arg 1: directory (string) --> The directory to the folder containing the .xlsx data.
# Function input arg 2: train_or_classify (string) --> Use 'train', when collecting data to train the model. Use 'classify' when collecting data which needs to be classified.
# Function output 1: df --> The pandas dataframe containing the training information.
df = get_red_waves(directory,
                   train_or_classify = 'train')

# Train the LSTM model to recognise repetitive sequence data as having 'waves' or not. 
# Function inputs arg 1: df --> pandas dataframe as provided by the 'get_red_waevs()' function. 
# Function inputs arg 2: save_plot --> True or False. When True, saves plot to the img folder of the package. 
# Function inputs arg 3: display_plot --> True or False. When True, displays plot within conole. 
# Function output 1: The trained model.
LSTM_model = train_LSTM(df,
                        save_plot = False,
                        display_plot = True):
    
# Select the folder containing the data which needs to be classified.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
classifiation_directory = folder_selection_dialog()

# A function to take the trained LSTM model, and use it to classify our data. 
# Function input arg 1: directory [string] --> The directory containing the data which needs to be classified. 
# Function input arg 1: LSTM_model [bound method] --> The trained LSTM model from the 'train_LSTM' function. 
classify_waves(classifiation_directory,
               LSTM_model = trained_model)