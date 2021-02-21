function [colonyIdentityLocations, CORRECTEDdirMatrix] = colonyTracking_7(gridsFolder, timelapseInterval,  binFactor, lengthOfPixel)
 %%%%%% This function aims at performing the clustering and tracking of
 %%%%%% colonies through multiple time points. 

%% This portion of the script provides the directory that would otherwise be given by the main code. 
% gridsFolder = cell2mat(uipickfiles); % Select the files. 

wellFolders = dir(gridsFolder); % Get a list of all files and folders in this folder.
dirFlags = [wellFolders.isdir]; % Get a logical vector that tells which is a directory.
subFolders = wellFolders(dirFlags); % Extract only those that are directories.
wellDirectoryArray = cell(1,1); % Make a dataArray for storage of the wells.

for k = 1 : length(subFolders)
  if length(subFolders(k).name) < 3
    continue; 
  else 
      wellDirectoryArray(k,1) = {subFolders(k).name};
  end 
end

wellDirectoryArray = wellDirectoryArray(~cellfun('isempty',wellDirectoryArray)); % Remove empty cells and 'hey presto', you have all the subdirectories.

wellDirectoryArrayStr = convertCharsToStrings(wellDirectoryArray); % I need a string version of the array for later.
index = strlength(wellDirectoryArrayStr) == 3;
wellDirectoryArray = wellDirectoryArray(index);

%% Loop through each of the wellscolonyIdentityLocations and create new folders with DBSCANNED images.

CORRECTEDdirMatrix = cell(1,1);
for n = 15 : numel(wellDirectoryArray)
    
    %% Create matrices to store colony data. 
    
    s1 = 'progress_n___Iterating throuhg wells ='; 
    value = num2str((n/length(wellDirectoryArray)*100));
    message = cell2mat(strcat(s1,{' '}, value));
    disp(message);
    
    colonyIdentity = cell(1,1); 
    colonyIdentity(1,1) = {'Pixel Number'};
    colonyIdentity(2,1) = {0};
    colonyIdentity(2,2) = {'Background'};
    colonyIdentity(2,3) = {'NA'};
    colonyIdentity(3,1) = {1};
    colonyIdentity(3,2) = {'Non-clustered foreground'};
    colonyIdentity(3,3) = {'NA'};
    colonyIdentity(1,2) = {'Identity'};
    colonyIdentity(1,3) = {'Fusion, Fision or touching border (1=Y)'};
    colonyIdentity(1,4) = {'Timepoint'};
    
    %% Loop through the DBSCANNED grids and correct them for fusion and fission. 
    
    s1 = gridsFolder;
    s2 = '\';
    s3 = wellDirectoryArray{n};
    s4 = '_DBSCANNED';
    DBSCANNEDdir = strcat(s1, s2, s3, s4);
    cd (DBSCANNEDdir) % Ensure that the cd is the one containing the DBSCANNED images. 
    DBSCANNEDImagesStruc = dir('*.tiff');
    numImages = length(DBSCANNEDImagesStruc);
    for t = 2:numImages
        %% Create a directory into which we can save the corrected DBSCANned images. 
        
        s1 = 'progress_t';
        s2 = num2str(t);
        s3 = '___Loop through the DBSCANNED grids and correct them for fusion and fission ='; 
        value = num2str((t/numImages)*100);
        message = cell2mat(strcat({'   '},s1,s2,s3,{' '}, value));
        disp(message);
    
        s1 = gridsFolder; % Make a CORRECTED-images directory.      
        s2 = '\';
        s3 = wellDirectoryArray{n};
        s4 = '_CORRECTED';
        CORRECTEDdir = strcat(s1, s2, s3, s4); % Construct the current directory that we want.
        if ~exist(CORRECTEDdir, 'dir') % If the directory doesn't exist, then create it. 
            cd (gridsFolder)
            mkdir(CORRECTEDdir)
         
            % If we're making this new directory, then we need to add it to
            % the CorrecteddirMatrix. 
            CORRECTEDdirMatrix(n,1) = {CORRECTEDdir};
            
            % Also, if this directory doesn't exist, then neither does the first image. We need to prime
            % the first loop iteration by putting in the first image (that
            % of t-1) to allow the loop to begin. 
            cd (DBSCANNEDdir)
            DBSCANnedGridSub1 = imread(DBSCANNEDImagesStruc(1).name);
            cd (CORRECTEDdir)
            s1 = 'CORRECTED';
            s2 = '_';
            s3 = DBSCANNEDImagesStruc(1).name;
                s3 = s3(11:end-5);
            s4 = '.tiff';
            outputFileName = strcat(s1, s2, s3, s4); % Construct the current directory that we want.
            imwrite(DBSCANnedGridSub1, outputFileName, 'Compression', 'none');
        
        end 
        
        % Do any of these colonies touch the periphery of the image? If so, we need to make note of that.
        if t == 2
            doTheseColoniesTouchThePeriphery = DBSCANnedGridSub1;
            colonyList = unique(DBSCANnedGridSub1);
            numColonies = length(colonyList)-1; % number of colonies in t-1.

            for p = 3:numColonies+1
                
                % Progress_p_doTheseColoniesTouchThePeriphery = (p-2)/(numColonies-1)*100
                [theColonyMask, ~] = colonyMask(DBSCANnedGridSub1, colonyList(p)); % Get a mask of the colony (a perimiter which has been filled in).
                
                [theColonyMask, number_objects] = bwlabel(theColonyMask);
                if number_objects ~= 1
                    theColonyMask = correctColonyMask(theColonyMask); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                else 
                    theColonyMask = logical(theColonyMask);
                end 
 
                doTheseColoniesTouchThePeriphery(theColonyMask) = colonyList(p); % Add that colony mask to the overall image. 
            end

            % Make an image with a border.
            [height, width] = size(DBSCANnedGridSub1);
            borderImage = zeros(height, width);
            borderImage(:,1) = 1;
            borderImage(:,end) = 1;
            borderImage(1,:) = 1;
            borderImage(end,:) = 1;

            % Determine which colonies are touching the image border.
            coloniesWhichTouchBorder = doTheseColoniesTouchThePeriphery;
            coloniesWhichTouchBorder(~borderImage) = 0;
            coloniesWhichTouchBorderIndex = unique(coloniesWhichTouchBorder)>1;
            coloniesWhichTouchBorder =  unique(coloniesWhichTouchBorder);
            coloniesWhichTouchBorder = coloniesWhichTouchBorder(coloniesWhichTouchBorderIndex);
        end 
       
        %% Load in the images of t-1 and t. 
        
        % Load in the image of t-1 from CORRECTEDdir. 
        cd (CORRECTEDdir)
        CORRECTEDImagesStruc = dir('*.tiff');
        numImages2 = length(CORRECTEDImagesStruc);
        DBSCANnedGridSub1 = imread(CORRECTEDImagesStruc(numImages2).name);
        
        % Load in the image from t from DBSCANNEDdir.
        cd (DBSCANNEDdir)
        DBSCANnedGrid = imread(DBSCANNEDImagesStruc(t).name);

        %% Loop through the colonies of t-1, and for each colony, record the average centroid. 
        centroidArraySub1 = [];
        colonyCentroidArraySub1 = [];
        coloniesSub1 = unique(DBSCANnedGridSub1);
        numColoniesSub1 = length(unique(DBSCANnedGridSub1))-1; % How many colonies (-1 to exclude the background)
        for c = 3:numColoniesSub1+1
            onlyRelevantNuclei = DBSCANnedGridSub1 == coloniesSub1(c); % Make an image with ONLY the nuclei of the colony we're interested in. 

            stats = regionprops(onlyRelevantNuclei, 'Centroid'); % Get a struc of the centroids of the cells. 

            for f = 1:length(stats) % Record the centroids in an easier to manipulate fashion. 
                centroidArraySub1(f,1) = stats(f).Centroid(1);
                centroidArraySub1(f,2) = stats(f).Centroid(2);
            end 

            xAverage = mean(centroidArraySub1(:,1)); % Average colony x.
            yAverage = mean(centroidArraySub1(:,2)); % Average colony y.

            clear centroidArraySub1
            
            colonyCentroidArraySub1(c-2,1) = coloniesSub1(c); % Record the colony number. 
            colonyCentroidArraySub1(c-2,2) = xAverage; % Record the xAverage of the colony.
            colonyCentroidArraySub1(c-2,3) = yAverage; % Record the yAverage of the colony. 
        end % Record the centroids of the colonies for this image (t-1). 
        
        %% Loop through the colonies of t, and for each colony, record the average centorid.
        centroidArray = [];
        colonyCentroidArray = [];
        coloniesInT = unique(DBSCANnedGrid);
        numColoniesInT = length(unique(DBSCANnedGrid))-1; % How many colonies (-1 because e don't want to include the background).
        for c = 3:numColoniesInT+1
            onlyRelevantNuclei = DBSCANnedGrid == coloniesInT(c); % Make an image with ONLY the nuclei of the colony we're interested in. 

            stats = regionprops(onlyRelevantNuclei, 'Centroid'); % Get a struc of the centroids of the cells. 

            for f = 1:length(stats) % Record the centroids in an easier to manipulate fashion. 
                centroidArray(f,1) = stats(f).Centroid(1);
                centroidArray(f,2) = stats(f).Centroid(2);
            end 
            
            xAverage = mean(centroidArray(:,1)); % Average colony x.
            yAverage = mean(centroidArray(:,2)); % Average colony y.
            
            clear centroidArray
            
            colonyCentroidArray(c-2,1) = coloniesInT(c); % Record the colony number. 
            colonyCentroidArray(c-2,2) = xAverage; % Record the xAverage of the colony.
            colonyCentroidArray(c-2,3) = yAverage; % Record the yAverage of the colony. 
        end % Record the centroids of the colonies for this image. 
        
        %% Perform basic tracking between t-1 and t. 
        
        % If we're in the first iteration of our loop, add the number of colonies to the colonyIdentity. 
        if t == 2 
            for v = 2:numColoniesSub1 
                colonyIdentity(v+2,1) = {v};
                colonyIdentity(v+2,2) = {'Colony'};
                if ismember(v, coloniesWhichTouchBorder) == 1
                    binaryValue = 1;
                else 
                    binaryValue = 0;
                end
                colonyIdentity(v+2,3) = {binaryValue};
                colonyIdentity(v+2,4) = {t-1};
            end 
        end 

        colonyList = unique(DBSCANnedGrid);
        numColonies = length(colonyList)-1; % number of colonies in t.
        sharedPixelData = [];

        colonyListSub1 = unique(DBSCANnedGridSub1);
        colonyMatchingMatrix = colonyListSub1(3:end);
        
        % This image is needed so that the DBSCANed colony values (the actual numbers, not the physical area occupied by the colonies) don't overlap
        % between timepoint t-1 and t. If they do overlap then it messes things
        % up. e.g. if theres 4 colonies then colony no4 needs to become colony no8.
        temporaryDBSCANslice = DBSCANnedGrid+(max(colonyListSub1)); % Confusing stuff here. By incresaing all the pixel values by this amount, we ensure that 2 colonies never have the same values. 
        temporaryDBSCANsliceBackground = temporaryDBSCANslice == (max(colonyListSub1)); % Set background back to 0, step 1.
        temporaryDBSCANslice(temporaryDBSCANsliceBackground) = 0; % Set background back to 0, step 2.

        % Set the non-grouped material of the image back to 1 again.
        nonGroupedMaterial = temporaryDBSCANslice == 1+(max(colonyListSub1)); 
        temporaryDBSCANslice(nonGroupedMaterial) = 1;

        coloniesWhichSpontaneouslyAppeared = []; % Make the dataArray for later on.

        newColony = 0; % Create this variable and set it to '0'.
        
        for v = 3: numColonies+1
            %progress_v_SharedPixels = v/numColonies*100 % progress of the loop.

            % Make an image of the colony boundary.
            [colony_mask, ~] = colonyMask(DBSCANnedGrid, colonyList(v));
            [colony_mask, number_objects] = bwlabel(colony_mask);
            if number_objects ~= 1
                colony_mask = correctColonyMask(colony_mask); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
            else 
                colony_mask = logical(colony_mask);
            end 
            
            % This loop makes an array detailing the number of shared pixels between all colonies in 't' and the colony of interest (in t-1)
            colonyListSub1 = unique(DBSCANnedGridSub1);
            numColoniesSub1 = length(colonyListSub1)-1; % number of colonies in t.
            for u = 3: numColoniesSub1+1 % Remember, we start from 2 because '1' is just unclustered nuclei/debris. We don't want to include it as a colony in the loop. 

                            [colony_maskSub1, ~] = colonyMask(DBSCANnedGridSub1, colonyListSub1(u)); % Get the mask for the first colony in t-1.
                            [colony_maskSub1, number_objects] = bwlabel(colony_maskSub1);
                                if number_objects ~= 1
                                    colony_maskSub1 = correctColonyMask(colony_maskSub1); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                                else 
                                    colony_maskSub1 = logical(colony_maskSub1);
                                end 
                            sharedPixels = (colony_maskSub1 + colony_mask) == 2; % This makes an image with the shared Pixels.       
                            sharedPixelStruc = regionprops(sharedPixels, 'Area'); % regionprops for the shared pixels (we need the area).

                            sharedPixelSum = 0; % Create a value which we can update later. 
                            % Add together all the regions of shared pixels to find out the
                            % overall are which is shared between cthe colony of t-1 and the
                            % colonies of t.
                                for i=1:length(sharedPixelStruc) % sum up the area. 
                                    sharedPixelSum = sharedPixelSum + sharedPixelStruc(i).Area;
                                end 
                            sharedPixelData(u-2,1) = sharedPixelSum; % The values of shared pixel data. 

                            clear sharedPixels sharedPixelSum sharedPixelStruc
            end 

            % Determine which colonies (between t-1 and t) share the most pixels. 
            maxSharedPixels = max(sharedPixelData);
            if maxSharedPixels > 0  % If there was some clear overlap, there determine the location (aka colony identity) this way.
                location = find(ismember(sharedPixelData, maxSharedPixels))+2;
                colony = colonyListSub1(location);
                
                % Make note of the colonies identification in the matched
                % table. 
                index = find(ismember(colonyMatchingMatrix, colony));
                colonyMatchingMatrix(index,2) = 1;
                clear index
                
            elseif maxSharedPixels == 0 % If there was no colony overlap (sod's law) then we need to determine which colony by looking for the closest colony centroid. 

                % First, get a list of permieter pixels of the colony(v)
                colony_perim = bwperim(colony_mask, 8);  
                colony_perim_stats = struct2table(regionprops(colony_perim, 'PixelList'));
                colony_perim_stats = table2array(colony_perim_stats);
                
                distances = []; % This will contain distance data. 
                distances2 = []; 
                distances3 = [];
                distances4 = [];
                
                % Now loop through all of the colonies of DBSCAnnedGridSub1.
                for g = 3: numColoniesSub1+1 % Remember, we start from 2 because '1' is just unclustered nuclei/debris. We don't want to include it as a colony in the loop. 
               
                    [colony_mask_sub1, boundary_presence] = colonyMask(DBSCANnedGridSub1, colonyListSub1(g)); % Line ref: FVGD45 
                            [colony_mask_sub1, number_objects] = bwlabel(colony_mask_sub1);
                            if number_objects ~= 1
                                colony_mask_sub1 = correctColonyMask(colony_mask_sub1); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                            else 
                                colony_mask_sub1 = logical(colony_mask_sub1);
                            end 
                    colony_mask_sub1 = bwperim(colony_mask_sub1, 8);  
                    colony_perim_sub1_stats = struct2table(regionprops(colony_mask_sub1, 'PixelList'));
                    colony_perim_sub1_stats = table2array(colony_perim_sub1_stats);
                    
                    % Now loop through all the pixels of colony of
                    % Sub1, and determine it's distance to the v-loop
                    % colony pixels. 
                    for h = 1 : length(colony_perim_stats)
                        
                        if  strcmp(boundary_presence, 'no_boundry') == 1 % If there isn't a colony boundary, just set the disatances2 to an arbitrarily high number (the width of the image);
                            [width, ~] = size(DBSCANnedGrid);
                            distances2(h,:) = width;
                            continue; 
                        elseif strcmp(boundary_presence, 'no_boundry') == 0
                            x_t = colony_perim_stats(h,1);
                            y_t = colony_perim_stats(h,2); 
                        end 
                        x_sqd = (x_t - colony_perim_sub1_stats(:,1)).^2;
                        y_sqd = (y_t - colony_perim_sub1_stats(:,2)).^2;
                        distances = sqrt(x_sqd + y_sqd);
                        
                        min_distance = min(unique(distances));
                        clear distances
                        
                        distances2(h,:) = min_distance;
                    end 
                    
                        min_distance2 = min(unique(distances2)); % this is the min distance between colony(v) and colonySub1(g);
                        clear distances2
                        distances3(g,:) = min_distance2;
                end
                
                distances3 = distances3(3:end); % We get rid of the first 2 values, as they are the background and non-DBSCANNED material.
                min_distances3 = min(unique(distances3));
                if numel(min_distances3) > 1 
                   min_distances3 = min_distances3(1);  % If multiple colonies are the same distance from the colony of interest, just take the first index. this isnt perfect, but as this point, there's nothing we can do. The graphs will just need to be checked against the video, so errors in data will not occur.
                end 

               % We now need to say - 'if the distace is too big, then this
               % isnt a case of a small colony migrating. It's more likely to
               % be a new colony which has formed from individual migrating
               % cells. 
              
               distanceThreshold = 80/binFactor; % Basically, we're correcting for the fact that the values of 200 will neeed change in accordance with the binning ofthe image. 
               if min_distances3 > distanceThreshold % if that minimum threshold is exceeded, the skip loop iteration and leave the colony alone. 
                    
                    lengthOfArray = length(coloniesWhichSpontaneouslyAppeared); % Determine how big the table is. 
                    coloniesWhichSpontaneouslyAppeared(lengthOfArray+1) = colonyList(v);
                    newColony = 1; % this is for a conditional 'continue;' later on. 
               else
                    distances4 = distances3 == min_distances3; % find the index of the min distance(s).
                    index = find(distances4, 1);
                    colony = colonyListSub1(index+2); % +2 because I removed the first 2 rows of distances3.
                    
                    index = find(ismember(colonyMatchingMatrix, colony));
                    colonyMatchingMatrix(index,2) = 1;
                    clear index
               end 
            end 

            clear sharedPixelData

            % If the colony in question is completely new (and has formed from
            % migrating cells of something) then skip the loop iteration. We
            % dont want to change the colony value juuuust yet. Leave it for
            % later. 
            if newColony == 1 
                newColony = 0;
                continue 
            end 

            % Now that we've determined which colony of t is the same as t-1,
            % we need to impliment that change into the DBscanned images
            % (record the data..)
            weveFoundTheRightColony = temporaryDBSCANslice == (max(colonyListSub1))+colonyList(v);
            temporaryDBSCANslice(weveFoundTheRightColony) = colony; 

        end 

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
        % Here, we determine whether a colony wasn't successfully detected by DBSCANNING. 
            numberOfDissapearingColonies = sum(double(colonyMatchingMatrix(:,2)) == 0); % Number of colonies which just dissapeared, probably because DBSCAN couldn't detect them.
            index1 = find(colonyMatchingMatrix(:,2) == 0);
            colonies_s = colonyMatchingMatrix(:,1); % These are the colonies were making reference to.
            for s = 1:numberOfDissapearingColonies

                colony_s = colonies_s(index1(s)); % Colony number.
                [colonyMask_s, ~] = colonyMask(DBSCANnedGridSub1, colony_s); % Colony mask.
                    [colonyMask_s, number_objects] = bwlabel(colonyMask_s);
                    if number_objects ~= 1
                        colonyMask_s = correctColonyMask(colonyMask_s); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                    else 
                        colonyMask_s = logical(colonyMask_s);
                    end  
                            
                            radius     = 15; % number of micro-meters for the elipse.
                            radius = round((radius/lengthOfPixel)/binFactor); % Convert the number of microns to pixels. 
                            se = strel('disk', radius, 8);
                colonyMask_s_dilated = imdilate(colonyMask_s, se); % Dilate the colony mask. 
                DBSCANnedEasy = DBSCANnedGrid;

                % Remove the cells from DBSCANnedEasy which would touch the
                % border of the colony mask. These cells get 'cut in half', and
                % this can create problems later on. 
                        %Get the border of the perimeter filled colony.
                        se = strel('square', 3);
                        erode_colonyMask_s_dilated = imerode(colonyMask_s_dilated, se);  % Erode away the border of the colony. 
                        border_colonyMask_s_dilated = colonyMask_s_dilated - erode_colonyMask_s_dilated; % This is the border.
                        % Get the intersections between that border and the cells of DBSCANnedGrid.
                        borderCells_DBSCANnedGrid = DBSCANnedGrid;
                        borderCells_DBSCANnedGrid(~border_colonyMask_s_dilated) = 0;
                        borderCells_DBSCANnedGrid = borderCells_DBSCANnedGrid > 0 ;
                        pixelList_border = regionprops(borderCells_DBSCANnedGrid, 'PixelList');
                        pixelList_border = vertcat(pixelList_border(:,:).PixelList);
                        % Get the actual cells at the intersection. 
                        [labelledCells_DBSCANnedGrid, numberOfNuclei] = bwlabel(DBSCANnedGrid);
                        pixelList_labelledCells = regionprops(labelledCells_DBSCANnedGrid, 'PixelList');
                        borderNuclei = [];
                        for h = 1 : numberOfNuclei % identify the nuclei which overlap with the border. 
                            pixelsOfNucleus_labelledCells = pixelList_labelledCells(h).PixelList;
                            [height1, ~] = size(pixelsOfNucleus_labelledCells);
                            for hu = 1: height1
                                coordinates_hu = pixelsOfNucleus_labelledCells(hu,:);
                                [height2, ~] = size(pixelList_border);
                                for huo = 1 : height2
                                    coordinates_huo = pixelList_border(huo,:);
                                   if sum(coordinates_hu == coordinates_huo) == 2 
                                      index = length(borderNuclei);
                                      borderNuclei(index+1,1) = h;
                                   end 
                                end 
                            end 
                        end 
                        borderNuclei = unique(borderNuclei);
                        borderNuclei_image = DBSCANnedGrid;
                        borderNuclei_image(:,:) = 0;
                        for huoi = 1 : length(borderNuclei)
                            nucleus = labelledCells_DBSCANnedGrid == borderNuclei(huoi);
                            borderNuclei_image(nucleus) = 1;
                        end 
                borderNuclei = [];
                borderNuclei_image = logical(borderNuclei_image); % This is the image with the nucleu which would get cut in half. 

                DBSCANnedEasy(~colonyMask_s_dilated) = 0; % Remove all the foreground outside of the old coloniy's area.
                DBSCANnedEasy = DBSCANnedEasy > 0; 
                DBSCANnedEasy(borderNuclei_image) = 0; % Get rid of the nuclei wich would get cut in half.

                            size_threshold_microns_Squared = 21.16; % The are in microns squared. CHANGE THIS VALUE, NOT THE ONE BELOW, AS IT DEPENDS ON PIXEL SIZE AND BINNING.
                                param_CC.size_threshold = round(((sqrt(size_threshold_microns_Squared)/lengthOfPixel)^2)/binFactor^2); % Converting microns squared to pixels, taking into account the pixel size and binning value. 
                            param_CC.numNuclei = 6; % Minimum number of nuclei needed to detect 
                            elipse_microns = 48.75; % The elipse within which a neighboring nucleus can be considered part of the same group.
                                param_CC.elipse = round((elipse_microns/lengthOfPixel)/binFactor); % Convert the number of microns to pixels. 

                % Remove small objects from a test image. Following the size thresholding, is there are no nuclei, then we skip the loop.                 
                looking_for_nuclei_after_filtering = bwareaopen(DBSCANnedEasy, param_CC.size_threshold);         
                [~, numberOfNuclei] = bwlabel(looking_for_nuclei_after_filtering);
                if numberOfNuclei == 0 
                    continue; % By adding this 'continue', we prevent the code from breaking if there are no nulcei after size filtering.
                end 

                DBSCANnedEasy = ClusterColonies(DBSCANnedEasy, param_CC); % DBSCAN with easier parameters. 

                values = unique(DBSCANnedEasy); % Determine the frequency of occurance of different pixel values in the image.
                valuesFrequency = [values,histc(DBSCANnedEasy(:),values)];
                index = valuesFrequency(:,1) < 2; % Remove the rows which describe the number of background or non-DBSCANNED pixels. 
                valuesFrequency(index,:) = [];
                if isempty(valuesFrequency) == 1 % If there really aren't any colonies, even after we've adjusted the DBSCAN perameters, then just skip the loop.. the colony is gone for good! 
                    continue;
                end 

                greatestFrequency = max(valuesFrequency(:,2)); % Determine which pixel value has the greatest number of occurances. 
                index = find(valuesFrequency(:,2) == greatestFrequency);
                colonyInFrame = valuesFrequency(:,1);
                colonyInFrame = colonyInFrame(index);

                colonyWhichAlmostDissapeared = DBSCANnedEasy == colonyInFrame; % Isolate the nuclei of the colony. 

                temporaryDBSCANslice(colonyWhichAlmostDissapeared) = colony_s; % Re-add that colony back into the image.

                [hieghtColonyIdentity, ~] = size(colonyIdentity);
                colonyIdentity(hieghtColonyIdentity+1,1) = {colony_s};
                colonyIdentity(hieghtColonyIdentity+1,2) = {'Colony'};
                colonyIdentity(hieghtColonyIdentity+1,3) = {0};
                colonyIdentity(hieghtColonyIdentity+1,4) = {t};
            end 

            % Add the corrected (but not yet complete... still have to accound for fusions/fissions/new colonies...) data to DBSCANed grid.
            DBSCANnedGrid = temporaryDBSCANslice;
        
        % Change the values of the spontaneously appearing colonies to new, unique numbers.
        spontaneouslyAppearedColonyNewValues = [];
        if numel(coloniesWhichSpontaneouslyAppeared) > 0
            for y = 1:numel(coloniesWhichSpontaneouslyAppeared)
                spontaneouslyAppearedColony = coloniesWhichSpontaneouslyAppeared(y); % This is the colony number in DBSCANedGrid...
                spontaneouslyAppearedColony = spontaneouslyAppearedColony + (max(colonyListSub1));  % ... but... we need the equivalent col number in temporary DBSCANNED slice. 
                
                max1 = max([colonyIdentity{2:end,1}]); % Figure out the max value of colonies when considering both colonyIdentity and DBSCAnnedGrid. 
                max2 = max(unique(DBSCANnedGrid));
                maximum = max(max1, max2);
                
                newValueForColony = y+maximum;
                theColony = DBSCANnedGrid == spontaneouslyAppearedColony;
                DBSCANnedGrid(theColony) = newValueForColony;
                spontaneouslyAppearedColonyNewValues(y) = newValueForColony;
            end 
        end 
        
        % Update the colonyIdentity array. 
        colonyList = unique(DBSCANnedGrid);
        numColonies = length(colonyList)-1; % number of colonies in t.
        for s=3:numColonies+1
            [hieghtColonyIdentity, ~] = size(colonyIdentity);
            colonyIdentity(hieghtColonyIdentity+1,1) = {colonyList(s)};
            colonyIdentity(hieghtColonyIdentity+1,2) = {'Colony'};
            if ismember(colonyList(s), spontaneouslyAppearedColonyNewValues)
                binaryValue = 1;
            else
                binaryValue = 0;
            end 
            colonyIdentity(hieghtColonyIdentity+1,3) = {binaryValue};
            colonyIdentity(hieghtColonyIdentity+1,4) = {t};
        end 
        clear coloniesWhichSpontaneouslyAppeared
        clear spontaneouslyAppearedColonyNewValues
        
        % Correct for crossed colonies.
        DBSCANnedGrid = correctCrossedColonies(DBSCANnedGrid);

        %% Correct for colony fusion. 
        
        % First we need to make an image in which colonies of t-1 have been converted to perimeter filled masks. 
        filledPerimetersSub1 = DBSCANnedGridSub1; % Make an image to store the filled perimeters. 

        colonyListSub1 = unique(DBSCANnedGridSub1);
        numColoniesSub1 = length(colonyListSub1)-1; % number of colonies in t-1.

        for e = 3:numColoniesSub1+1
            % Get a mask of the colony (a perimiter which has been filled in).
            [thecolonyMask, ~] = colonyMask(DBSCANnedGridSub1, colonyListSub1(e)); % Make the mask.
            filledPerimetersSub1(thecolonyMask) = colonyListSub1(e); % Add the mask colony to the overall image. 
        end

        % Sometimes 'correctCrossedColonies' doesn't work. This fixes that issue. 
        filledPerimetersSub1 = correctFilledPerimeters(filledPerimetersSub1);
        
        % Figure out which colonies of T contain pixels from numerous colonies in t-1. 
        colonyList = unique(DBSCANnedGrid);
        numColonies = length(colonyList)-1; % number of colonies in t.

        for L = 3:numColonies+1 % loop from 2, as thats the first colony value (0 is bkgrnd and 1 is no-DBSCANNED stuff). 

            % Get a mask of the colony (a perimiter which has been filled in).
            [theColonyMask, ~] = colonyMask(DBSCANnedGrid, colonyList(L));
                [theColonyMask, number_objects] = bwlabel(theColonyMask);
                if number_objects ~= 1
                    theColonyMask = correctColonyMask(theColonyMask); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                else 
                    theColonyMask = logical(theColonyMask);
                end  
                    
            % Get the area which each colony in t overlaps with in t-1.
            overlapBetweenTandTSub1 = filledPerimetersSub1; 
            overlapBetweenTandTSub1(~theColonyMask) = 0; 

            coloniesInOverlap = unique(overlapBetweenTandTSub1); % Get all the pixel values which the t mask contains in t-1. 
            correctIndices = coloniesInOverlap>1; % Exclude the background and non-DNSCanned stuff. 
            coloniesInOverlap = coloniesInOverlap(correctIndices); % Apply the indices above to get the colony numbers above 0 and 1.
            
            % Here, I ask which PIXEL values are within the overlap. 
            if numel(coloniesInOverlap) == 0
                % warningMessage = 'Note that this colony doesnt overlap with any others during the fusion check. Its probably a spontaneously appearing colony.'
            elseif numel(coloniesInOverlap) == 1
                % Do nothing here. This happens when there is no colony fusion.
            elseif numel(coloniesInOverlap) > 1 % Colony fusion MIGHT have occured! The mask of a colony in t contains the pixels of more than one colony in t-1. 

                % Deduce whether there has been colony fusion of simply some
                % colony migration. The difference between the two should
                % numerically manifest as a HUGE difference in colony overlap
                % between t and t-1. e.g. Fused colonies will incorporate most
                % of the area of their parent colonies. However, migrating
                % colonies might just touch the lip of another colony,
                % resulting in a low level of overlap. 

                percentageColonyOverlap = []; % Create storage for the percentage of each colony which is overlapped in the next timepoint. 
                for m = 1:numel(coloniesInOverlap) % loop through all the colonies involved in the overlap. 

                    colonyNumber = coloniesInOverlap(m); % Deduce the colony we need to analyse for the loop. 
                    colonyMaskM_Tsub1 = filledPerimetersSub1 == colonyNumber;

                    % Get the area which each colony in t overlaps with in t-1.
                    colonyMaskM_Overlap = colonyMaskM_Tsub1;
                    colonyMaskM_Overlap(~theColonyMask) = 0; 

                    % Get the number of pixels in the colony of t-1 
                    Tsub1Area = cell2mat(struct2cell(regionprops(colonyMaskM_Tsub1, 'Area')));

                    % Get the number of pixels in the colony of t-1 
                    TArea = sum(cell2mat(struct2cell(regionprops(colonyMaskM_Overlap, 'Area'))));

                    % Calculate the percentage overlap of the colony; 
                    percentageOverlap = (TArea/Tsub1Area)*100;

                    % Enter the data into the table. 
                    percentageColonyOverlap(m,1) = colonyNumber;
                    percentageColonyOverlap(m,2) = percentageOverlap;

                end

                % Here, I ask which COLONIES are involved in the overlap. 
                overlapthreshold = 25; % percentage threshold for overlap of colonies. 
                indices = percentageColonyOverlap(:,2) > overlapthreshold; % Get the logical indices for the overlaps above the threshold. 
                NoColoniesInOverlap = sum(indices(:) == 1);
                if NoColoniesInOverlap == 0 
                    % errorMsg = 'Apparently a colony has dissapeared between one timepoint and the next.';
                elseif NoColoniesInOverlap == 1 
                    % Do nothing. 
                elseif NoColoniesInOverlap > 1 

                    % Renumber the colony in t such that it is of a new value.
                    % First, we need to deduce the maximum colony value in the data Array. 
                    max1 = max([colonyIdentity{2:end,1}]); % Figure out the max value of colonies when considering both colonyIdentity and DBSCAnnedGrid. 
                    max2 = max(unique(DBSCANnedGrid));
                    maxColonyValue = max(max1, max2);
                    
                    newColonyValue = maxColonyValue+1; % Calculate the new value for the fused colony.
                    fissionedColony = DBSCANnedGrid == colonyList(L); % Get the fused colony in an image. 
                    temporaryGrid = DBSCANnedGrid; % Make a copy of the grid for timepoint t. 
                    temporaryGrid(fissionedColony) = newColonyValue; % change the value of the colony which has undergone fusion. 
                    DBSCANnedGrid = temporaryGrid; % Add the image back into the 3D clusteredColonies stack.

                    % Also, log this colony as having fused. 
                    oldColonyValue = colonyList(L); % Determine the value of the fused colony (it's the loop iteration). 
                    pixelValues = [colonyIdentity{2:end,1}]; % Get all the current colonies stored away in the datatable. 
                    index = find(pixelValues==oldColonyValue, 1, 'last')+1; % /Find out where the colony numbr resides in the table. 
                    colonyIdentity(index, 1) = {newColonyValue};
                    colonyIdentity(index, 2) = {'Colony'};
                    colonyIdentity(index, 3) = {1};
                    clear maxColonyValue newColonyValue
                end 

            end 

        end 

        %% Correct for colony fission. 
        
        % Correct for crossed colonies.
        DBSCANnedGrid = correctCrossedColonies(DBSCANnedGrid);
        
        % First we need to make an image in which colonies of t have been converted to perimeter filled masks. 
        filledPerimeters = DBSCANnedGrid; % Make an image to store the filled perimeters. 

        colonyList = unique(DBSCANnedGrid);
        numColonies = length(colonyList)-1; % number of colonies in t.

        for e = 3:numColonies+1
            [theColonyMask, ~] = colonyMask(DBSCANnedGrid, colonyList(e)); % Get a mask of the colony (a perimiter which has been filled in).
            filledPerimeters(theColonyMask) = colonyList(e); % Add that colony mask to the overall image. 
        end
        
        % Sometimes 'correctCrossedColonies' doesn't work. This fixes that issue. 
        filledPerimeters = correctFilledPerimeters(filledPerimeters);

        % Figure out which colonies of T-1 contain pixels from numerous colonies in t. 

        colonyListSub1 = unique(DBSCANnedGridSub1);
        numColoniesSub1 = length(colonyListSub1)-1; % number of colonies in t-1.

        for f = 3:numColoniesSub1+1

            % Get a mask of the colony (a perimiter which has been filled in).
            [theColonyMask, ~] = colonyMask(DBSCANnedGridSub1, colonyListSub1(f));
                [theColonyMask, number_objects] = bwlabel(theColonyMask);
                if number_objects ~= 1
                    theColonyMask = correctColonyMask(theColonyMask); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                else 
                    theColonyMask = logical(theColonyMask);
                end  
            
            overlapBetweenTandTSub1 = filledPerimeters; 
            overlapBetweenTandTSub1(~theColonyMask) = 0; % Get the area which each colony in t overlaps with in t-1.

            coloniesInOverlap = unique(overlapBetweenTandTSub1); % Get all the pixel values which the t mask contains in t. 
            correctIndices = coloniesInOverlap>1; % Exclude the background and non-DNSCanned stuff. 
            coloniesInOverlap = coloniesInOverlap(correctIndices); % Apply the indices above to get the colony numbers above 0 and 1.

            % Here, I ask which PIXEL values are within the overlap. 
            if numel(coloniesInOverlap) == 0
                 errorMsg = 'Somethings fucked up. As far as the script is concerned, a colony has just dissapeared from one timepoint to the next.';
            elseif numel(coloniesInOverlap) == 1
                % Do nothing here. This happens when there is no colony fission.
            elseif numel(coloniesInOverlap) > 1 % Colony fusion MIGHT have occured! The mask of a colony in t contains the pixels of more than one colony in t-1. 

                % Deduce whether there has been colony fusion or simply some
                % colony migration. The difference between the two should
                % numerically manifest as a HUGE difference in colony overlap
                % between t and t-1. e.g. Fused colonies will incorporate most
                % of the area of their parent colonies. However, migrating
                % colonies might just touch the lip of another colony,
                % resulting in a low level of overlap. 

                percentageColonyOverlap = []; % Create storage for the percentage of each colony which is overlapped in the next timepoint. 
                for m = 1:numel(coloniesInOverlap) % loop through all the colonies involved in the overlap. 

                    [fissionParentColony, ~] = colonyMask(DBSCANnedGridSub1, colonyListSub1(f)); % Deduce the colony we need to analyse for the loop (from which the fission has occured)
                        [fissionParentColony, number_objects] = bwlabel(fissionParentColony);
                        if number_objects ~= 1
                            fissionParentColony = correctColonyMask(fissionParentColony); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                        else 
                            fissionParentColony = logical(fissionParentColony);
                        end  

                    colonyNumber = coloniesInOverlap(m); % Deduce the colony we need to analyse for the loop (from which the fission has occured)
                    fissionDaughterColony = filledPerimeters == colonyNumber;

                    % Get the area which each colony in t-1 overlaps with in t.
                    ParentDaughter_Overlap = fissionParentColony;
                    ParentDaughter_Overlap(~fissionDaughterColony) = 0; % Get the area which each colony in t overlaps with in t-1.

                    % Get the number of pixels in the colony of t-1 
                    OverlapArea = sum(cell2mat(struct2cell(regionprops(ParentDaughter_Overlap, 'Area'))));

                    % Get the number of pixels in the colony of t-1 
                    DaughterArea = cell2mat(struct2cell(regionprops(fissionDaughterColony, 'Area')));

                    % Calculate the percentage overlap of the colony; 
                    percentageOverlap = (OverlapArea/DaughterArea)*100;

                    % Enter the data into the table. 
                    percentageColonyOverlap(m,1) = colonyNumber;
                    percentageColonyOverlap(m,2) = percentageOverlap;

                end

                % Here, I ask which COLONIES are involved in the overlap. 
                overlapthreshold = 15; % percentage threshold for overlap of colonies. 
                indices = percentageColonyOverlap(:,2) > overlapthreshold; % Get the logical indices for the overlaps above the threshold. 
                NoColoniesInOverlap = sum(indices(:) == 1);
                ColoniesInOverlap = coloniesInOverlap(indices);

                if NoColoniesInOverlap == 0 
                    % errorMsg = 'Apparently a colony has dissapeared between one timepoint and the next. A bug is bugging!';
                elseif NoColoniesInOverlap == 1 
                    % Do nothing. 
                elseif NoColoniesInOverlap > 1 

                    % Loop through the new colonies (formed from fission) and
                    % re-number them. 
                    for r = 1 : NoColoniesInOverlap

                    % Re-number the colony in t such that it is of a new value.
                    % First, we need to deduce the maximum colony value. 
                    max1 = max([colonyIdentity{2:end,1}]); % Figure out the max value of colonies when considering both colonyIdentity and DBSCAnnedGrid. 
                    max2 = max(unique(DBSCANnedGrid));
                    maxColonyValue = max(max1, max2);
                    
                    newColonyValue = maxColonyValue+1; % Calculate the new value for the fused colony.

                    fissionColonyNumber = ColoniesInOverlap(r); % This is the colony number we need to change. 
                    fissionedColony = DBSCANnedGrid == fissionColonyNumber; % Get the fused colony in an image. 
                    temporaryGrid = DBSCANnedGrid; % Make a copy of the grid for timepoint t. 
                    temporaryGrid(fissionedColony) = newColonyValue; % change the value of the colony which has undergone fusion. 
                    DBSCANnedGrid = temporaryGrid; % Add the image back into the 3D clusteredColonies stack.

                    % Also, log this colony as having fused. 
                    pixelValues = [colonyIdentity{2:end,1}]; % Get all the current colonies stored away in the datatable. 
                    index = find(pixelValues==fissionColonyNumber, 1, 'last')+1; % /Find out where the colony numbr resides in the table. 
                    colonyIdentity(index, 1) = {newColonyValue};
                    colonyIdentity(index, 2) = {'Colony'};
                    colonyIdentity(index, 3) = {1};

                    end 
                end 

            end 

        end 
        
        %% Identify colonies which touch the periphery of the image.
        
        doTheseColoniesTouchThePeriphery = DBSCANnedGrid;
        colonyList = unique(DBSCANnedGrid);
        numColonies = length(colonyList)-1; % number of colonies in t-1.

        for p = 3:numColonies+1
            % Progress_p_doTheseColoniesTouchThePeriphery = (p-2)/(numColonies-1)*100
            [theColonyMask, ~] = colonyMask(DBSCANnedGrid, colonyList(p)); % Get a mask of the colony (a perimiter which has been filled in).
                [theColonyMask, number_objects] = bwlabel(theColonyMask);
                if number_objects ~= 1
                    theColonyMask = correctColonyMask(theColonyMask); % Sometimes the mask of an individual colony is made but it has multiple components! This function deletes, all but the biggest colony mask. 
                else 
                    theColonyMask = logical(theColonyMask);
                end  
                    
            doTheseColoniesTouchThePeriphery(theColonyMask) = colonyList(p); % Add that colony mask to the overall image. 
        end
        
        % Make an image with a border.
        [height, width] = size(DBSCANnedGrid);
        borderImage = zeros(height, width);
        borderImage(:,1) = 1;
        borderImage(:,end) = 1;
        borderImage(1,:) = 1;
        borderImage(end,:) = 1;
        
        % Determine which colonies are touching the image border.
        coloniesWhichTouchBorder = doTheseColoniesTouchThePeriphery;
        coloniesWhichTouchBorder(~borderImage) = 0;
        coloniesWhichTouchBorderIndex = unique(coloniesWhichTouchBorder)>1;
        coloniesWhichTouchBorder =  unique(coloniesWhichTouchBorder);
        coloniesWhichTouchBorder = coloniesWhichTouchBorder(coloniesWhichTouchBorderIndex);
        
        % log the colony as '1' in the colonyIdentity matrix. 
        for a = 1 : length(coloniesWhichTouchBorder)
            borderColonyNumber = coloniesWhichTouchBorder(a);
            pixelValues = [colonyIdentity{2:end,1}]; % Get all the current colonies stored away in the datatable. 
            index = find(pixelValues==borderColonyNumber, 1, 'last')+1; % /Find out where the colony numbr resides in the table. 
            
            if colonyIdentity{index,4} ~= t
                msg = 'colonyIdentity matric is being edited incorrectly. A timepoint of t should be being edited, but instead, a different timepoint is being chnaged';
                error(msg);
            end 
            colonyIdentity(index, 3) = {1};
        end 
        
        %% Save the corrected image (of t). 
        
        cd (CORRECTEDdir)
        s1 = 'CORRECTED';
        s2 = '_';
        s3 = DBSCANNEDImagesStruc(t).name;
            s3 = s3(11:end-5);
        s4 = '.tiff';
        outputFileName = strcat(s1, s2, s3, s4); % Construct the current directory that we want.
        imwrite(DBSCANnedGrid, outputFileName, 'Compression', 'none');
       
    end 

    %% Save the colonyIdentity array for each well. 

    colonyIdentity(1,5) = {'Timepoint (hours)'};
    for t = 4:length(colonyIdentity)
         colonyIdentity(t,5) = {colonyIdentity{t,4}*timelapseInterval};   
    end 

    s1 = wellDirectoryArray{n};
    s2 = '_colonyIdentity.xlsx';
    filename = strcat(s1,s2);

    cd (CORRECTEDdir)

    xlswrite(filename,colonyIdentity)

    % Also, update the colonyIdentityLocations variable for export later on. 
    colonyIdentityLocations(n,1) = wellDirectoryArray(n);
    colonyIdentityLocations(n,2) = {CORRECTEDdir};
    colonyIdentityLocations(n,3) = {filename};
    
end 

disp('colonyTracking_2 complete');

end 


