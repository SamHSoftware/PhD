%% correctFilledPerimeters.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: Sometimes the function 'correctCrossedColonies.m doesn't catach all crossed colonies. 
% This script should be used after making a filled perimeter mask, to delete the buggy colony fragments which form.

% Function inputs: 
% filledPerimeters [int array] --> A filled colony perimeter mask, potentially with colonies erroneously crossing over. 

% Function outputs: 
% corrected_filledPerimeters [int array] --> A filled colony perimeter mask, now with no colonies crossing over. 

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