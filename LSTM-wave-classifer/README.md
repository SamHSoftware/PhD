# README for project: LSTM-wave-classifer

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com
Date created: 9<sup>th</sup> December 2020

## Description: 
- This code is designed to train an classify single-feature time series data as either 'class 0' or 'class 1'. This data is related to my PhD, and will not be extensivly described here until the publishing of this work. Thus, certain references to the data may seem vague unless you are working within our research group. 
- The classification is achieved using a Long-Short-Term-Memory (LSTM) model constructed using the Pytorch package.
- LSTMs are a type of RNN, and are commonly used to make predictions based on a series of data with repeating patterns. For instance, given past data, you can use LSTMs to predict global temperatures, share prices, or (as in this instance) you can consider time series data and classify it into different groups.
- For each python file, there is a .ipynb file for those who use JupyterLab.
- The functions will provide a number of outputs, including the trained model, and a folder of the excel files which correspond to class '1' data. 

## Here's how to use the package: 

(1) Open the RUNME.py file, and run the following code: 
```
# Import the necessary packages.
from LSTM_wave_classifier_functions import *

# Select the training data.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
training_directory = folder_selection_dialog()
```

This will open a GUI (see the image below), which which you should navigate to and select the folder of excel files you wish to use to train the LSTM. Regarding the format of the excel files (including what each column should contain), please refer to the data from my PhD, and explore my 'PhD' folder on the University of Bristol RDSF. In the drug experiments folder, you will find many example data sets. 

<img src="https://github.com/SamHSoftware/PhD/blob/main/LSTM-wave-classifer/img/folder_selection.PNG?raw=true" alt="folder selection GUI" width="500"/>

(2) Run the following code to extract and condense the relevant data for the LSTM:
```
# A function to extract and condense the relevant training data. 
# Function input arg 1: directory (string) --> The directory to the folder containing the .xlsx data.
# Function input arg 2: train_or_classify (string) --> Use 'train', when collecting data to train the model. Use 'classify' when collecting data which needs to be classified.
# Function output 1: df --> The pandas dataframe containing the training information.
df = get_red_waves(directory,
                   train_or_classify = 'train')
```

(3) Train the LSTM with the following code: 
```
# Train the LSTM model to recognise repetitive sequence data as having 'waves' or not. 
# Function inputs arg 1: df --> pandas dataframe as provided by the 'get_red_waevs()' function. 
# Function inputs arg 2: save_plot --> True or False. When True, saves plot to the img folder of the package. 
# Function inputs arg 3: display_plot --> True or False. When True, displays plot within conole. 
# Function output 1: The trained model.
trained_model = train_LSTM(df,
                        save_plot = False,
                        display_plot = True):
```

It should be noted that if you use this model, you will need to make a number of modifications to the ```train_LSTM``` function. The include optimisations to the number of epochs, the batch size and the optimizer. I havent included these parameters as input args, as these edits will be numerous and will go beyond quick numerical changes. 

Once optimised and run, the code will output a number of different images, which you can use to assess how well the model has trained. I have included examples below, after the model was partially trained over a few epochs. These images will either be displayed as the script runs, or they will be saved within a new folder (named ```img```) in the previous input arg, ```directory```.

<img src="https://github.com/SamHSoftware/PhD/blob/main/LSTM-wave-classifer/img/confusion_matrix.png?raw=true" alt="folder selection GUI" width="500"/>  

<img src="https://github.com/SamHSoftware/PhD/blob/main/LSTM-wave-classifer/img/training_and_validation_accuracy.png?raw=true" alt="folder selection GUI" width="500"/>  

<img src="https://github.com/SamHSoftware/PhD/blob/main/LSTM-wave-classifer/img/training_and_validation_loss.png?raw=true" alt="folder selection GUI" width="500"/>

(4) Finally, run the following code to select the folder of excel files you wish to classify: 
```
# Select the folder containing the data which needs to be classified.
# Function inputs args: None. 
# Function output 1: The path of that the folder selected by the user. 
classifiation_directory = folder_selection_dialog()

# A function to take the trained LSTM model, and use it to classify our data. 
# Function input arg 1: directory [string] --> The directory containing the data which needs to be classified. 
# Function input arg 1: LSTM_model [bound method] --> The trained LSTM model from the 'train_LSTM' function. 
classify_waves(classifiation_directory,
               LSTM_model = trained_model)
```

The code will output a new folder, named ```grade_1_waves``` in the ```classifiation_directory```. You can then analyse these as you please. 