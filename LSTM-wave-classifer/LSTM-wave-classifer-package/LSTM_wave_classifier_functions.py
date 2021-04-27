from tkinter import *
from tkinter import filedialog
import matplotlib.pyplot as plt
import os

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

# Function inputs arg 1: num_epochs --> The number of iterations over which the model is refined. 
# Function inputs arg 2: training_loss --> Array of size 1 x num_epochs. This array contains the calculated values of loss for training. 
# Function inputs arg 3: validation_loss --> Array of size 1 x num_epochs. This array contains the calculated values of loss for validation. 
# Function inputs arg 4: save_plot --> True or Flase. When true, saves plot to data directory.  
# Function inputs arg 5: display_plot --> True or Flase. When true, displays the plot. 
# Function output: Graph with the loss per epoch.
def loss_graph(num_epochs, 
               training_loss, 
               validation_loss, 
               save_plot, 
               display_plot):
    
    # Plot the loss per epoch. 
    y = list(range(0,num_epochs))
    plt.plot(y, training_loss, label="Training loss")
    plt.plot(y, validation_loss, label="Validation loss")
    plt.rcParams.update({'font.size': 15})
    plt.ylabel('BCE calculated loss', labelpad=10) # The leftpad argument alters the distance of the axis label from the axis itself. 
    plt.xlabel('Epoch', labelpad=10)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)

    # Save the plot if the user desires it.
    if save_plot:
        current_directory = os.getcwd()
        file_path, _ = os.path.split(current_directory)
        file_path = os.path.join(file_path, 'img', 'training_and_validation_loss.png')
        plt.savefig(file_path, dpi=200, bbox_inches='tight')
    
    # Display the plot if the user desires it. 
    if (display_plot == False):
        plt.close()
    else:
        plt.show()   

# Function inputs arg 1: num_epochs --> The number of iterations over which the model is refined. 
# Function inputs arg 2: training_accuracy --> Array of size 1 x num_epochs. This array contains the calculated values of training accuracy. 
# Function inputs arg 3: validation_accuracy --> Array of size 1 x num_epochs. This array contains the calculated values of validation accuracy. 
# Function inputs arg 4: save_plot --> True or Flase. When true, saves plot to data directory.  
# Function inputs arg 5: display_plot --> True or Flase. When true, displays the plot. 
# Function output: Graph with the training and validation accuracy per epoch.
def accuracy_graph(num_epochs, 
               training_accuracy, 
               validation_accuracy, 
               save_plot, 
               display_plot):
    
    # Plot the BCE calculated loss per epoch. 
    y = list(range(0,num_epochs))
    plt.plot(y, training_accuracy, label="Training accuracy")
    plt.plot(y, validation_accuracy, label="Validation accuracy")
    plt.rcParams.update({'font.size': 15})
    plt.ylabel('Accuracy', labelpad=10) # The leftpad argument alters the distance of the axis label from the axis itself. 
    plt.xlabel('Epoch', labelpad=10)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)

    # Save the plot if the user desires it.
    if save_plot:
        current_directory = os.getcwd()
        file_path, _ = os.path.split(current_directory)
        file_path = os.path.join(file_path, 'img', 'training_and_validation_accuracy.png')
        plt.savefig(file_path, dpi=200, bbox_inches='tight')
    
    # Display the plot if the user desires it. 
    if (display_plot == False):
        plt.close()
    else:
        plt.show()   