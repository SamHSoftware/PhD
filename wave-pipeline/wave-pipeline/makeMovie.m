%% makeMovie.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: The function makes binary and colour movies of colonies as they
% are tracked through time and space. 

% Function inputs: 
% CORRECTEDdirMatrix [n�1 cell array] --> Provided by colony tracking function. Each cell contains a directory to a folder of tracked mega-grids e.g. 'D:\B02_CORRECTED'.
% doYouWantToMakeAMovie [string] --> 'Yes' or 'No'. When set to 'Yes', the script will make the movies. 
% theChosenColourMap [colormap] --> The chosen colormap e.g. hsv. 
% dataFolders [n x m cell array] --> Provided by makeWavePlots fucntion. First column denotes the well name e.g. 'D02'. Second column denotes the corresponding directories into which the movies are saved. 
% fontSize [int] --> Recommended font size of 70. 

% Function outputs: 
% binary and colour movies of colonies are they are tracked through space and time. movies save to same location as wave .xlsx files.

function makeMovie(CORRECTEDdirMatrix, doYouWantToMakeAMovie, theChosenColourMap, dataFolders, fontSize)

switch doYouWantToMakeAMovie
    
    case 'No'
        
        disp('You have chosen not to make any movies.');  
        
    case 'Yes'
        
        numberOfMovies = length(CORRECTEDdirMatrix); % Calculate the number of movies we'll need to make.
        
        for d = 1:numberOfMovies
            
            %% Load in the directory and image names. 
            
            directoryInQuestion = CORRECTEDdirMatrix{d}; % Load up the name of the directory which we need to analyse. 
            cd (directoryInQuestion); % Enter that directory. 
            
            % list all the files within the directory and filter them, to remove
            % any funny single character names (e.g. '.') which I've seen appear.
            folderStruc = dir(cd); % Load the struc of the folder.
            gridNames = {folderStruc.name};
            numberOfImages = size(gridNames);
            numberOfImages = numberOfImages(2);
            nameLength =  cellfun('length',gridNames);
            logicalRepresentation = nameLength == 26;

            % Here are the correct names, generated by the process above. 
            gridNames = gridNames(logicalRepresentation);
            numberOfGrids = numel(gridNames);

            %%  Determind the directory that we need to save in.
            
            well = directoryInQuestion(end-12:end-10);
            
            potentialWells = table2array(cell2table(dataFolders(:,1)));
            index = strcmp(well, potentialWells);
            savingDirectoryLine = dataFolders;
            savingDirectoryLine(~index, :) = [];
            savingDirectory = savingDirectoryLine{2};
            
            %% Make a binary movie. 
            
            s1 = well;
            s2 = '_Binary.mp4';
            movieName = strcat(s1, s2); % Make the movie name. 
            
            cd (savingDirectory);
            
            v = VideoWriter(movieName,'Uncompressed AVI');
            v.FrameRate = 4;
            open(v);
            for k=1:numberOfGrids    
                percentageCompletion = (k/numberOfGrids)*100;
                percentageCompletion = num2str(percentageCompletion);
                s1 = 'Creating_';
                s2 = '_____';
                s3 = '%';
                message = strcat(s1, movieName, s2, percentageCompletion, s3);
                disp(message);
                
                cd (directoryInQuestion); % Enter images directory. 
                
                img = imread(gridNames{k});
                img = uint8(img);
                imgForeground = img > 0;
                img(imgForeground) = 255;
                
                [heightImg, widthImg] = size(img); % size of the img.
                heightTOwidth = heightImg/widthImg;
                nrows = heightTOwidth*1000;
                ncols = 1000;
                img = imresize(img, [nrows,ncols]);
                
                cd (savingDirectory);
                writeVideo(v,img);
            end

            close(v);     
            
            %% Make a Colour movie. 
                      
            s1 = well;
            s2 = '_Coloured.mp4';
            movieName = strcat(s1, s2); % Make the movie name. 
            
            cd (savingDirectory);
            
            v = VideoWriter(movieName,'Uncompressed AVI');
            v.FrameRate = 4;
            open(v);
            
            theColourMap = theChosenColourMap;
            theColourMap(end+1, 1:3) = 0;
            colourIndex= [];
            
            for k=1:numberOfGrids 
                percentageCompletion = (k/numberOfGrids)*100;
                percentageCompletion = num2str(percentageCompletion);
                s1 = 'Creating_';
                s2 = '_____';
                s3 = '%';
                message = strcat(s1, movieName, s2, percentageCompletion, s3);
                disp(message); % This message tells us how far the loop we are. 

                cd (directoryInQuestion); % Enter images directory. 
                
                img = imread(gridNames{k}); % Load in the grayscale image. 
                uniqueValues = unique(img); % Get all the pixel values in the image.
                numberUniqueValues = numel(uniqueValues); % Get the number of unique pixel values in the image. 
                
                imgRGB =  ind2rgb8(img, theColourMap);
                
                % Iterate through each of the pixel values of the image,
                % and manually change them to RGB colours which don't
                % change when new colonies appear (this happens with
                % LABEL2RGB). 
                for h = 1:numberUniqueValues

                    pixelValue = uniqueValues(h); % This is the pixel value we want to change to and RGB value. 
                    imgPixelValue = img == pixelValue; % The mask of that pixel value.  
                    
                    if isempty(colourIndex) == 1 
                        option = 2; 
                    elseif ismember(pixelValue, colourIndex(:,1)) == 1
                        option = 1;
                    else
                        option = 2; 
                    end 
                        
                    if  option == 1
                        
                        locationIndex = ismember(colourIndex(:,1), pixelValue); % Get the correct colour from here. 
                        
                        usedColours = colourIndex(:,2);
                        randomColourIndex = usedColours(locationIndex);
                        
                        RGBValues = theColourMap(randomColourIndex, :);
                        
                    elseif option == 2
                        
                        if pixelValue == 0
                            
                            [heightColourIndex, ~] = size(colourIndex);
                            colourIndex(heightColourIndex+1, 1) = pixelValue;
                            setColourIndex = length(theColourMap);
                            colourIndex(heightColourIndex+1, 2) = setColourIndex;
                            
                            RGBValues = [0,0,0];
                            
                        else
                            
                            [heightColourIndex, ~] = size(colourIndex);
                            colourIndex(heightColourIndex+1, 1) = pixelValue;
                            randomColourIndex = randi([1 length(theColourMap)]);
                            colourIndex(heightColourIndex+1, 2) = randomColourIndex;
                            
                            RGBValues = theColourMap(randomColourIndex, :);
                            
                        end 
                    
                    end 
                    
                    % Extract the individual red, green, and blue color channels.
                    redChannel = imgRGB(:, :, 1);
                    greenChannel = imgRGB(:, :, 2);
                    blueChannel = imgRGB(:, :, 3);
                    
                    redChannel(imgPixelValue) = RGBValues(1)*255;
                    greenChannel(imgPixelValue) = RGBValues(2)*255;
                    blueChannel(imgPixelValue) = RGBValues(3)*255;

                    % Recombine separate color channels into a single, true color RGB image.
                    imgRGB = cat(3, redChannel, greenChannel, blueChannel);

                end
                
                %% Add number to label each colony.
                
                [heightImg, widthImg] = size(img); % size of the img.
                fourCorners = cell(0,0); % make an empty matrix to store the positions of the 4 corners.
                fourCorners(1,1) = {1}; % start filling in this matrix. Later, this'll be used to see which of the four corners the colonies are closest too.
                fourCorners(1,2) = {1};
                fourCorners(1,3) = {'TL'};
              
                fourCorners(2,1) = {widthImg};
                fourCorners(2,2) = {1};
                fourCorners(2,3) = {'TR'};
                
                fourCorners(3,1) = {1};
                fourCorners(3,2) = {heightImg};
                fourCorners(3,3) = {'BL'};
                
                fourCorners(4,1) = {widthImg};
                fourCorners(4,2) = {heightImg};
                fourCorners(4,3) = {'BR'};
                
                numberOfColonies = length(unique(img));
                colonies = unique(img);
           
                for g = 3 : numberOfColonies % Loop through each of the colonies and label them.
                    colonyInQuestion = colonies(g);
                    fourCornersCopy = fourCorners;
                 
                    thecolonyMask = colonyMask(img, colonies(g)); % Make the mask.
                    colonyCentoids = struct2table(regionprops(thecolonyMask, 'Centroid'));
                    colonyCentoids = table2array(colonyCentoids);
                    
                    fourCornersCopy(:,4) = {colonyCentoids(1,1)};
                    fourCornersCopy(:,5) = {colonyCentoids(1,2)};
                    
                    [heightFourCornersCopy, ~] = size(fourCornersCopy); % Determine the maximum distance to any of the corners. 
                    for j = 1:heightFourCornersCopy 
                     
                        aSQRD = (cell2mat(fourCornersCopy(j,1))-(cell2mat(fourCornersCopy(j,4))))^2;
                        bSQRD = (cell2mat(fourCornersCopy(j,2))-(cell2mat(fourCornersCopy(j,5))))^2;
                        fourCornersCopy(j,6) = {round(sqrt(aSQRD+bSQRD))};
                    end 
                    maximumDistance = max(cell2mat(fourCornersCopy(:,6)));
                    index = find(cell2mat(fourCornersCopy(:,6)) == maximumDistance, 1, 'first');
                    furthestCorner = cell2mat(fourCornersCopy(index, 3)); % this is the corner the colony is furthest from.
                    
                    % Get the bounding box of the colony, then add a number
                    % to the corner which is closest to the furthest corner
                    boundingBox = struct2table(regionprops(thecolonyMask, 'BoundingBox'));
                    boundingBox = table2array(boundingBox);
             
                    % Add the text.
                    box_color = {'white'};
                    if strcmp(furthestCorner, 'TL') == 1
                        xCoordinate = boundingBox(1);
                        yCoordinate = boundingBox(2);
                        position = [xCoordinate yCoordinate]; 
                        imgRGB = insertText(imgRGB,position,colonyInQuestion,'FontSize',fontSize,'BoxColor',...
                            box_color,'BoxOpacity',0.4,'TextColor','white', 'AnchorPoint','RightBottom');
                    elseif strcmp(furthestCorner, 'TR') == 1
                        xCoordinate = boundingBox(1)+boundingBox(3);
                        yCoordinate = boundingBox(2);
                        position = [xCoordinate yCoordinate]; 
                        imgRGB = insertText(imgRGB,position,colonyInQuestion,'FontSize',fontSize,'BoxColor',...
                            box_color,'BoxOpacity',0.4,'TextColor','white', 'AnchorPoint','LeftBottom');
                    elseif strcmp(furthestCorner, 'BL') == 1
                        xCoordinate = boundingBox(1);
                        yCoordinate = boundingBox(2)+boundingBox(4);
                        position = [xCoordinate yCoordinate]; 
                        imgRGB = insertText(imgRGB,position,colonyInQuestion,'FontSize',fontSize,'BoxColor',...
                            box_color,'BoxOpacity',0.4,'TextColor','white', 'AnchorPoint','RightTop');
                    elseif strcmp(furthestCorner, 'BR') == 1
                        xCoordinate = boundingBox(1)+boundingBox(3);
                        yCoordinate = boundingBox(2)+boundingBox(4);
                        position = [xCoordinate yCoordinate]; 
                        imgRGB = insertText(imgRGB,position,colonyInQuestion,'FontSize',fontSize,'BoxColor',...
                            box_color,'BoxOpacity',0.4,'TextColor','white', 'AnchorPoint','LeftTop');
                    end
  
                end 
                
                %% Resize and write in the video frame.
                
                heightTOwidth = heightImg/widthImg;
                nrows = heightTOwidth*1000;
                ncols = 1000;
                imgRGB = imresize(imgRGB, [nrows,ncols]);
        
                cd (savingDirectory);
                writeVideo(v,imgRGB);
         
            end
            
            close(v);


        end 
        
end 

disp('makeMovie complete');

end 









