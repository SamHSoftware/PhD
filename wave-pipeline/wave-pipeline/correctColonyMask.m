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

colonyList = unique(example_colonyMask);
num_labels = length(colonyList)-1; % number of colonies in t.

% Identify the biggest colony. 
colonyMask_props = table2array(struct2table(regionprops(example_colonyMask, 'Area')));
theBiggestColony = max(colonyMask_props);
thebiggestColony_location = find(colonyMask_props == theBiggestColony); % Find the row which houses the biggest colony fragment. 

for er = 1 : num_labels
    if er == thebiggestColony_location
        continue;
    else
        % If the colony is one of the small fragments,
        % delete it.
        thecolonyMask_er = example_colonyMask == er;  % The colony fragment mask.  
        example_colonyMask(thecolonyMask_er) = 0; % Delete that smaller mask from filledPerimeters.
    end
end 

corrected_colonyMask = logical(example_colonyMask);

end 