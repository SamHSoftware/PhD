# A function to allow the user to select the file they wish to analyse. 
# Function inputs args: None. 
# Function output 1: The file path of that which was selected by the user. 
file_path = file_selection_dialog()

# A function to filter .xlsx data and make a new folder including grades 2.5 to 4, while excluding grades 1 to 2.5.
# Function input arg 1: directory (string) --> The directory to the file containing the grading data. 
# Funciton output 1: A new folder including grades 2.5 to 4, while excluding classes 1 to 2.5. 
filter_classes(file_path)