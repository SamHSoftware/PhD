%% loadMachineModel.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: The function returns the full path to the machine model. 

% Input data requirements: 
% The model is expected to have been generated using pixelClassifierTrain
% (written by Marcelo Cicconet, and adapted for use in this pipeline).

% Function inputs: 
% The trained machine model [struc] --> This is stored within the .mat file
% you select.

% Function outputs: 
% The full file path for the machine model. 

%% The function proper. 
function machineModelFullPath = loadMachineModel

uiwait(msgbox('Select the segmentation model','Sample Image','modal'));

[modelName, machineModelPathname] = uigetfile({'*.mat','Model (.mat)'});

machineModelFullPath = strcat(machineModelPathname, modelName); % Makes the full filepath to the model.

end