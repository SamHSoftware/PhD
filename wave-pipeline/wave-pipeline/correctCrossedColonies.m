%% correctCrossedColonies.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: Loop through all the colonies of DBSCAnnedGrid, and check that no
% colonies cross over each other. When a colony is crossed, it is
% split in two. These two daughter colonies confuse things later
% on, as the code assumes that each colony should only have one mask.
% Crossed colonies typically manifest when the second round of DBSCANning
% detects a colony IN THE MIDDLE of another colony. This new 'middle' 
% colony slices the original colony in two. This is a design flawwhich I 
% will fix. 

% Here, I select the smaller of the two daughter colonies, and
% relabel it with a new number. This error management is needed for
% the times when colonies begin to fragment upon the onset of
% differentiation.

% Function inputs: 
% DBSCANnedGrid [n×m double array] --> The DBSCANned image in which
% background is 0, non-clustered cels are 1, and colonies have a distinct
% numerical label. 

% Function outputs: 
% corrected_DBSCANnedGrid [n×m double array] --> The DBSCANned image (now corrected) 
% in which background is 0, non-clustered cels are 1, and colonies have a distinct
% numerical label. 

function corrected_DBSCANnedGrid = correctCrossedColonies(DBSCANnedGrid)

            numberOfColonies = []; % Array to store data. 
            colonyList = unique(DBSCANnedGrid);
            numColonies = length(colonyList)-1; % number of colonies in t.
            filledPerimetersDebug = DBSCANnedGrid;
            
            % Make filledPerimetersDebug, an image with all the coloneis filled in. 
            for e = 3:numColonies+1 % start by making a filled perimeter masks of the colonies. 
                % Get a mask of the colony (a perimiter which has been filled in).
                [thecolonyMask, ~] = colonyMask(DBSCANnedGrid, colonyList(e)); % Make the mask.
                [~, numberOfColonies] = bwlabel(thecolonyMask);
                filledPerimetersDebug(thecolonyMask) = colonyList(e); % Add the mask colony to the overall image. 
            end
            
            % Go through each of the colony values, and see how many 'objects' there are for each colony value.
            for e = 3:numColonies+1 % start by making a filled perimeter masks of the colonies. 
                thecolonyNumber = colonyList(e); % Get the colony number. 
                thecolonyMask_FromfilledPerimetersDebug = filledPerimetersDebug == thecolonyNumber;
                cc = bwconncomp(thecolonyMask_FromfilledPerimetersDebug,8);
                numberOfColonies(e-2, :) = cc.NumObjects;
            end
            
            indexNumberOfColonies = numberOfColonies > 1;
            indexNumberOfColonies = find(indexNumberOfColonies); % finds the non-zero values in the array.            
            numberOfNonZerocolonies = nnz(indexNumberOfColonies); % Get the number of colonies which 

            for e = 1:numberOfNonZerocolonies % Loop through the split colonies, and correct them.
                indexNumberOfColonies_e = indexNumberOfColonies(e)+2; % Get the index associated with the loop, then correct it for the fact that that list excluded the background and non-dbscanned material. 
                thecolonyNumber =  colonyList(indexNumberOfColonies_e); % Get the colony number in the image.
                
                thecolonyMask_e = filledPerimetersDebug == thecolonyNumber;
                [thecolonyMask_e, numberOfColonies] = bwlabel(thecolonyMask_e);
                
                % Identify the biggest colony. 
                thecolonyMask_e_props = table2array(struct2table(regionprops(thecolonyMask_e, 'Area'))); %Col num autocorreclates with row of strct, I've checked. 
                theBiggestColony = max(thecolonyMask_e_props);
                thebiggestColony_location = find(thecolonyMask_e_props == theBiggestColony); % Find the row which houses the biggest colony fragment. 
                
                for er = 1 : numberOfColonies
                    if er == thebiggestColony_location
                        continue;
                    else
                        % If the colony is one of the small fragments,
                        % delete it.
                        thecolonyMask_er = thecolonyMask_e == er;  % The colony fragment mask.  
                        
                        % The actual cells of the colony, not just the mask. 
                        thecolony = DBSCANnedGrid;
                        thecolony(~thecolonyMask_er) = 0; % Here is the colony fragment. 
                        thecolony = thecolony > 0;
                        DBSCANnedGrid(thecolony) = 0; % Delete the pesky fragment from DBSCANnedGrid. Lo and behold, it's no longer an issue. 
                    end
                end 
            end 

corrected_DBSCANnedGrid = DBSCANnedGrid;          
         