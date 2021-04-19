%% correctColonyMask.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: Sometimes the colonyMask.m creates colonies which are split 
% in two by 'colonyMask' This function deletes the small fragments which 
% get produced. 

% Input data requirements: 
% example_colonyMask [n x m logical] --> A bwlabel labelled image from the mask(s) of a single colony. 

% Function inputs: 
% example_colonyMask [n x m logical] --> A bwlabel labelled image from the mask(s) of a single colony. 

% Function outputs: 
% corrected_colonyMask [n x m logical] --> The corrected mask of the colony, now without small fragments.

function corrected_colonyMask = correctColonyMask(example_colonyMask)

% Figure out how many objects there are within the image. 
colonyList = unique(example_colonyMask);
num_labels = length(colonyList)-1; % Subtract 1 as we don't consider the background pixels. 

% Identify the biggest colony. 
colonyMask_props = table2array(struct2table(regionprops(example_colonyMask, 'Area')));
theBiggestColony = max(colonyMask_props);
thebiggestColony_location = find(colonyMask_props == theBiggestColony); % Find the row which houses the biggest colony fragment. 

% Iterate through the fragments and remove the small erroneous ones. 
for u = 1 : num_labels
    if u == thebiggestColony_location
        continue;
    else
        % If the mask is one of the small fragments, delete it.
        thecolonyMask_er = example_colonyMask == u;  % The colony fragment mask.  
        example_colonyMask(thecolonyMask_er) = 0; % Delete that smaller mask from filledPerimeters.
    end
end 

% Return corrected_colonyMask.
corrected_colonyMask = logical(example_colonyMask);

end 