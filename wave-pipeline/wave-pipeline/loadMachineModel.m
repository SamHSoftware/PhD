
function machineModelFullPath = loadMachineModel

uiwait(msgbox('Select the segmentation model','Sample Image','modal'));

[modelName, machineModelPathname] = uigetfile({'*.mat','Model (.mat)'});

machineModelFullPath = strcat(machineModelPathname, modelName); % Makes the full filepath to the model.

end