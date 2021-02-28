%% Sometimes the function colonyMasks get split in two by 'colonyMask' This function deletes the small fragments which get produced. 
% Feed this function a bwlabel labelled image of a single colony. 

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