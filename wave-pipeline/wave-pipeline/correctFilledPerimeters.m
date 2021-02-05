%% Sometimes the function 'correctCrossedColonies.m doesn't catach all crossed colonies. 
% This script should be used after making a filled perimeter mask, to delete all the weird colony fragments.

function corrected_filledPerimeters = correctFilledPerimeters(filledPerimeters)

colonyList = unique(filledPerimeters);
numColonies = length(colonyList)-1; % number of colonies in t.

        for e = 3:numColonies+1
            
            filledPerimeters_mask = filledPerimeters == colonyList(e);
            [filledPerimeters_mask, numberOfColonies] = bwlabel(filledPerimeters_mask);
            
            if numberOfColonies == 1 
                continue;
            elseif numberOfColonies > 1
                % Identify the biggest colony. 
                filledPerimeters_mask_props = table2array(struct2table(regionprops(filledPerimeters_mask, 'Area')));
                theBiggestColony = max(filledPerimeters_mask_props);
                thebiggestColony_location = find(filledPerimeters_mask_props == theBiggestColony); % Find the row which houses the biggest colony fragment. 
                
                for er = 1 : numberOfColonies
                    if er == thebiggestColony_location
                        continue;
                    else
                        % If the colony is one of the small fragments,
                        % delete it.
                        thecolonyMask_er = filledPerimeters_mask == er;  % The colony fragment mask.  
                        filledPerimeters(thecolonyMask_er) = 0; % Delete that smaller mask from filledPerimeters.
                    end
                end 
            end 
        end 

corrected_filledPerimeters = filledPerimeters;

end 