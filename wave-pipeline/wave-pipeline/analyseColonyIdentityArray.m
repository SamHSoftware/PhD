%% analyseColonyIdentityArray.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: This function is designed to follow on from the colony tracking function, the first output of which is the first input for this function. 
% This function analyses the data from the tracking process, and determins which colonies are worth tracking, based on fusion and death events. 

% Function inputs: 
% colonyIdentityLocations [n x 3 cell array] --> First column provides the well name. Second column provides the corresponding directories of corrected megagrids. Third directory contains the name of the colonyIdentity file, containing tracking information for that well.  
% timeThreshold [n x 1 cell array] --> Each cell contains a [string] detailing a directory containing images of tracked colonies of hESCs.  

% Function outputs: 
% colonyStruc [struc] --> Details the colones which need to be analysed per well, and the number of timepoints each should be considered. 

function [colonyStruc] = analyseColonyIdentityArray(colonyIdentityLocations, timeThreshold)
 
[lengthColonyIdentityLocations, ~] = size(colonyIdentityLocations);

 for q = 1:lengthColonyIdentityLocations
     
     %% Read in the data.
     CORRECTEDdir = colonyIdentityLocations{q,2}; % Load in the correct drectory.
     file = colonyIdentityLocations{q,3}; % Load in the correct filename. 
     cd (CORRECTEDdir);
     
     colonyData = readcell(file); % Read in the table. 
     
     %% Identify the analyse-able colonies throughout the timelapse.
    
     colonies = unique(cell2mat(colonyData(4:end, 1)));
     numColonies = numel(colonies);
     
     coloniesWhichWeCanMakeWavesOf=[];
     
     for r = 1 : numColonies
        
        colonyIteration = colonies(r); % This is the colony which we need to investigate for suitability. 
        
        colonyColumn = cell2mat(colonyData(2:end, 1)); % Get the column of colonies.
        index = colonyColumn == colonyIteration; % Get the index of all rows containing the colony of interst.
        
        colonyDataIteration = colonyData(2:end, :);
        colonyDataIteration = colonyDataIteration(index, :); % Construct a table containing info only relevant to this colony.
        
        suitabilityColumn = cell2mat(colonyDataIteration(:,3)); % If the colony hasn't undergone a fusion or something, then it's good to analyse!
        if ismember(1,suitabilityColumn)
            % Do nothing
        else
            duration = cell2mat(colonyDataIteration(end, end));
            if duration <= timeThreshold
                continue; 
            else
            [lengthColoniesWhichWeCanMakeWavesOf, ~] = size(coloniesWhichWeCanMakeWavesOf);
            coloniesWhichWeCanMakeWavesOf(lengthColoniesWhichWeCanMakeWavesOf+1, 1) = colonyIteration;
            
            colonyMaxTimpoint = colonyDataIteration{end, 4};
            coloniesWhichWeCanMakeWavesOf(lengthColoniesWhichWeCanMakeWavesOf+1, 2) = colonyMaxTimpoint;
            end
        end 
        
        clear length colonyColumn index colonyDataIteration 
        
     end 
     
     colonyStruc(q).name = colonyIdentityLocations{q,1};
     colonyStruc(q).colonies = coloniesWhichWeCanMakeWavesOf;
     
 end 
 
disp('analyseColonyIdentityArray complete');
 
end 
 






















