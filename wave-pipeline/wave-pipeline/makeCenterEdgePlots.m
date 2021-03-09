
function [dataFolders] = makeCenterEdgePlots(colonyStruc, CORRECTEDdirMatrix, folder_well, redChannel, greenChannel, timelapseInterval, cellType)
%%% This function is designed to follow on from
%%% 'analyseColonyIdentityArray'. It takes the colonyStruc and use it to
%%% iterate through all of the colonies which can be analysed. Instead of
%%% analysing all cells per colony, only those within edge/center regions
%%% are considered. 

%% Construct the dataMatrix and necessary directories. 

dataFolders = cell(0,0);

colonyDataMatrix = cell(1,1);
colonyDataMatrix(1,1) = {'Colony'};
colonyDataMatrix(1,2) = {'Well'};
colonyDataMatrix(1,3) = {'Timepoint'};
colonyDataMatrix(1,4) = {'Timepoint (hours)'};
colonyDataMatrix(1,5) = {'Nucleus'};
colonyDataMatrix(1,6) = {'Mean Red Intensity'};
colonyDataMatrix(1,7) = {'Mean Green Intensity'};
colonyDataMatrix(1,8) = {'Red Identity'}; 
colonyDataMatrix(1,9) = {'Green Identity'}; 
colonyDataMatrix(1,10) = {'Location Tag'}; 

wellsOfStruc = string(vertcat(colonyStruc.name));
[numberOfWells, ~] = size(wellsOfStruc);

% Make a new directory to store the data later on.
s1 = folder_well;
    s2 = '\';
    s3 = 'Inner_outer_plots';
    plotsDir = strcat(s1, s2, s3); % Construct the current directory that we want.
if ~exist(plotsDir, 'dir') % If the directory doesn't exist, then create it. 
    cd (folder_well)
    mkdir(plotsDir)
end
cd (plotsDir)

%% Loop through the wells and colonies - Extract the red and green intensities.

for y = 1:numberOfWells % Iterate through the wells which need analysing. 
    
    s1 = 'progress_y_loop____Iterate through wells ='; 
    value = num2str((y/numberOfWells)*100);
    message = cell2mat(strcat(s1,{' '}, value));
    disp(message);
    
    well = colonyStruc(y).name;
    coloniesOfWell = colonyStruc(y).colonies;
    numberOfColonies = length(coloniesOfWell);
    
    % Iterate through the colonies which need anlysing. 
    for u = 1:numberOfColonies 
        
        s1 = 'progress_u_loop____Iterate through colonies = '; 
        value = num2str((u/numberOfColonies)*100);
        message = cell2mat(strcat({'   '},s1,{' '}, value));
        disp(message);
        
        colonyInQuestion = colonyStruc(y).colonies(u,1); % This is the colony number that we're going to analyse.
        cd (CORRECTEDdirMatrix{y}) % This is the directory from which we can load in our images. 
        
        H2BImages = dir(CORRECTEDdirMatrix{y}); % List the corrected grids.
        H2BImages = {H2BImages.name}; % Covert the list to a different data types for processing. 
        nameLength =  cellfun('length',H2BImages);
        index = nameLength == 26; % Get the indexes of all the filenames we wish to analyse.
        H2BImages = H2BImages(index);

        % Loop through each timepoint for the colony which we chose above. 
        for p = 1:colonyStruc(y).colonies(u,2)
            
            s1 = 'progress_p_loop____Gather wave data for each timepoint of the colony ='; 
            value = num2str((p/colonyStruc(y).colonies(u,2))*100);
            message = cell2mat(strcat({'      '},s1,{' '}, value));
            disp(message);
            
            % Read in the H2B image. 
            cd (CORRECTEDdirMatrix{y})
            H2BName = H2BImages{p};
            H2B = imread(H2BName); 
            
            % Read in the corresponding RAW images. 
            folder_wellMat = folder_well;
            s2 = '\Grids\';
            s3 = cell2mat(wellsOfStruc(y));
            RAWImages = strcat(folder_wellMat, s2, s3);
            cd (RAWImages);
            RAWName = H2BName(11:end-1);
            redRaw = RAWName;
            redRaw(11) = num2str(redChannel);
            redRaw = imread(redRaw);
            greenRaw = RAWName;
            greenRaw(11) = num2str(greenChannel);
            greenRaw = imread(greenRaw);
            
            % Isolate the colony of interest. 
            colonyMaskH2B = H2B == colonyInQuestion;
            colonyMaskH2B_2 = bwlabel(colonyMaskH2B, 8); % This is the mask of differently labelled cells. 
            numberOfCellsInColony = max(unique(colonyMaskH2B_2)); % Get the number of cells in the colony.
            
            [CDX2Region, BRARegion, SOX2Region, innerRegion, notInnerRegion] = colonyRegions(colonyMaskH2B);
            
            % loop through each cell of the colony and analyse it's FUCCI signals and tag its location. 
            for a = 1:numberOfCellsInColony
                
                % Get the red intensites for the nuclei.
                redMeasurements = regionprops(colonyMaskH2B_2, redRaw, 'MeanIntensity');
                redIntensityMean = cell2mat(struct2cell(redMeasurements(a)));
                 
                % Get the green intiesities for the nuclei. 
                greenMeasurements = regionprops(colonyMaskH2B_2, greenRaw, 'MeanIntensity');
                greenIntensityMean = cell2mat(struct2cell(greenMeasurements(a)));
                
                % Get the position of the nuclei 
                
                
                % Record the data.
                [lengthColonyDataMatrix, ~] = size(colonyDataMatrix);
                colonyDataMatrix(lengthColonyDataMatrix+1,1) = {colonyInQuestion};
                colonyDataMatrix(lengthColonyDataMatrix+1,2) = {well};
                colonyDataMatrix(lengthColonyDataMatrix+1,3) = {p};
                colonyDataMatrix(lengthColonyDataMatrix+1,4) = {p*timelapseInterval};
                colonyDataMatrix(lengthColonyDataMatrix+1,5) = {a};
                colonyDataMatrix(lengthColonyDataMatrix+1,6) = {redIntensityMean};
                colonyDataMatrix(lengthColonyDataMatrix+1,7) = {greenIntensityMean};
                
            end    
        end 
    end 
end 

%% Identify the red nuclei.
redIntensities = cell2mat(colonyDataMatrix(2:end, 6)); % These are the red intensities. 
redIntensities = sort(redIntensities); % The red intensities are now sorted by size. 

numberOfRedCells = numel(redIntensities); % The number of nuclei for this particular loop. 
index = floor(numberOfRedCells*(0.7)); % This is the thirty-th percentile from the max intensity.
minimumRedSignal = redIntensities(index); % If a nucleus has more red signal than this number, then tis a red cell. 

for r = 2:numberOfRedCells+1 % Iterate through the dataArray and not which cells are red and which are not. 
    valueOfRedIntensity = colonyDataMatrix{r, 6};
    if valueOfRedIntensity >= minimumRedSignal
        colonyDataMatrix(r, 8) = {1};
    else
        colonyDataMatrix(r, 8) = {0};
    end 
end 

%% Identify the green nuclei.
greenIntensities = cell2mat(colonyDataMatrix(2:end, 7));
greenIntensities = sort(greenIntensities); % These are the green intensities. 

numberOfGreenCells = numel(greenIntensities); % The number of nuclei for this particular loop. 
index = floor(numberOfGreenCells*(0.6)); % This is the secenty-th percentile from the max intensity.
minimumGreenSignal = greenIntensities(index); % If a nucleus has more red signal than this number, then tis a green cell. 

for r = 2:numberOfGreenCells+1 % Iterate through the dataArray and 
    valueOfGreenIntensity = colonyDataMatrix{r, 7};
    if valueOfGreenIntensity >= minimumGreenSignal
        colonyDataMatrix(r, 9) = {1};
    else
        colonyDataMatrix(r, 9) = {0};
    end 
end 
        
%% Loop through the wells and colonies - Make wave plots! 

for j = 1:numberOfWells % Iterate through the wells which need analysing. 
    
    s1 = 'progress_j_loop___Iterate through wells ='; 
    value = num2str((j/numberOfWells)*100);
    message = cell2mat(strcat(s1,{' '}, value));
    disp(message);
    
    well = colonyStruc(j).name;
    coloniesOfWell = colonyStruc(j).colonies;
    numberOfColonies = length(coloniesOfWell);
    
    for k = 1:numberOfColonies % Iterate through the colonies which need anlysing. 
        
        s1 = 'progress_k_loop___ Make wave excel files and graphs for each colony ='; 
        value = num2str((k/numberOfColonies)*100);
        message = cell2mat(strcat({'   '}, s1,{' '}, value));
        disp(message);

        colonyInQuestion = colonyStruc(j).colonies(k,1); % This is the colony number that we're going to analyse.
        
        %% Isolate the portion of the table which pertains to the colony in question. 
        wells = table2array(cell2table(colonyDataMatrix(2:end, 2)));
        indices = strcmp(wells, well);
        temporaryColonyDataMatrix = colonyDataMatrix(2:end, :);
        temporaryColonyDataMatrix(~indices, :) = [];
        
        colonies = cell2mat(temporaryColonyDataMatrix(:, 1));
        indices = colonies == colonyInQuestion;
        temporaryColonyDataMatrix(~indices, :) = [];
        
        % Determine the number of timepoints this colony was followed for. 
        numberOfTimepoints = max(cell2mat(temporaryColonyDataMatrix(:,3)));
        
        %% Create the colony_k matrix. 
        colony_k = cell(1,1);
        colony_k(1,1) = {'Colony'};
        colony_k(1,2) = {'Well'};
        colony_k(1,3) = {'Timepoint (hours)'};
        colony_k(1,4) = {'Number of red nuclei'};
        colony_k(1,5) = {'Number of green nuclei'};
        colony_k(1,6) = {'Total number of cells'};
        colony_k(1,7) = {'Proportion of cells in G1 phase'}; 
        colony_k(1,8) = {'Proportion of cells in S, G2 or M phases'}; 
        colony_k(1,9) = {'Upper bound: Proportion of cells in G1 phase'};
        colony_k(1,10) = {'Lower bound: Proportion of cells in G1 phase'};
        colony_k(1,11) = {'Upper bound: Proportion of cells in S, G2 or M phases'}; 
        colony_k(1,12) = {'Lower bound: Proportion of cells in S, G2 or M phases'}; 
        
        %% Loop through each timepoint of the table and count the number of red and green cells. Afterwards, add that info to a table and make a graph out of it! 
        timepoints = cell2mat(temporaryColonyDataMatrix(:,3));
        zeroCellTimepoints = zeros(1,numberOfTimepoints+1,1);
        for z = 1:numberOfTimepoints
             
            % Isolate the data which is relevant to the timpoint in question.
            indices = timepoints == z; 
            timepointColonyDataMatrix = temporaryColonyDataMatrix;
            timepointColonyDataMatrix(~indices, :) = [];
            
            % Identify the number of green cells and red cells. 
            numberOfRedCells = sum(cell2mat(timepointColonyDataMatrix(:,8)));
            numberOfGreenCells = sum(cell2mat(timepointColonyDataMatrix(:,9)));
            
            % If there are no red or green cells detected in the timepoint,
            % then skip to the next iteration of the loop. 
            if numberOfRedCells + numberOfGreenCells == 0               
                zeroCellTimepoints(z+1) = 1;
                continue; 
            end 
            
            % Add the data to the final data table.
            [lengthOfColony_k, ~] = size(colony_k);
            colony_k(lengthOfColony_k+1,1) = {colonyInQuestion};
            colony_k(lengthOfColony_k+1,2) = {well};
            colony_k(lengthOfColony_k+1,3) = timepointColonyDataMatrix(1,4);
            colony_k(lengthOfColony_k+1,4) = {numberOfRedCells};
            colony_k(lengthOfColony_k+1,5) = {numberOfGreenCells};
            colony_k(lengthOfColony_k+1,6) = {numberOfRedCells + numberOfGreenCells};
            colony_k(lengthOfColony_k+1,7) = {numberOfRedCells/(numberOfRedCells + numberOfGreenCells)}; 
            colony_k(lengthOfColony_k+1,8) = {numberOfGreenCells/(numberOfRedCells + numberOfGreenCells)}; 
            colony_k(lengthOfColony_k+1,9) = {((numberOfRedCells*1.1+5)/((numberOfRedCells*1.1+5)+(numberOfGreenCells*0.9)))-(cell2mat(colony_k(lengthOfColony_k+1, 7)))};
            colony_k(lengthOfColony_k+1,10) = {(cell2mat(colony_k(lengthOfColony_k+1, 7)))-((numberOfRedCells*0.9)/((numberOfRedCells*0.9)+(numberOfGreenCells*1.1+5)))};
            colony_k(lengthOfColony_k+1,11) = {((numberOfGreenCells*1.1+5)/((numberOfRedCells*0.9)+(numberOfGreenCells*1.1+5)))-(cell2mat(colony_k(lengthOfColony_k+1, 8)))}; 
            colony_k(lengthOfColony_k+1,12) = {(cell2mat(colony_k(lengthOfColony_k+1, 8)))-((numberOfGreenCells*0.9)/((numberOfGreenCells*0.9)+(numberOfRedCells*1.1+5)))}; 
            
        end 
        
        %% Save the data as an excel file. 
        
        % Make a new directory for the specific well in question. 
        s1 = plotsDir;
            s2 = '\';
            s3 = well;
            wellPlotsdir = strcat(s1, s2, s3); % Construct the current directory that we want.
        if ~exist(wellPlotsdir, 'dir') % If the directory doesn't exist, then create it. 
            cd (plotsDir)
            mkdir(wellPlotsdir)
            
            [heightDataFolders, ~] = size(dataFolders);
            dataFolders(1+heightDataFolders, 1) = {well};
            dataFolders(1+heightDataFolders, 2) = {wellPlotsdir};
        end
        
        cd (wellPlotsdir) % Save the file in the correct dir.
        
        Title = strcat(well, '_Colony','_', num2str(colonyInQuestion),'.xlsx');
        
        % Here we need to save dataArray. This will save over pre-existing files
        % with the same name. 
        writecell(colony_k, fullfile(pwd, Title));

        %% Construct a plot.
        
        xValues = cell2mat(colony_k(2:end, 3));
        yValuesRed = cell2mat(colony_k(2:end, 7));
        yValuesGreen = cell2mat(colony_k(2:end, 8));
        totalNumberOfCells = cell2mat(colony_k(2:end, 6));
        lowerRed = cell2mat(colony_k(2:end, 9));
        upperRed = cell2mat(colony_k(2:end, 10));
        lowerGreen = cell2mat(colony_k(2:end, 11));
        upperGreen = cell2mat(colony_k(2:end, 12));
        
        minimumWidth = 500; 
        widThOfPlotWithoutPoints = 134;
        numberOfPoints = max(xValues)/0.5;
        widthPerPoint = 6.6;
        widthOfPlot = floor(numberOfPoints*widthPerPoint)+widThOfPlotWithoutPoints;
        if widthOfPlot < minimumWidth
            widthOfPlot = minimumWidth;
        end 

        figure('Name', 'Wave Plot',...
            'Visible', 'Off',...
            'Renderer', 'painters',...
            'Position', [10 10 widthOfPlot 550])
        yyaxis left
        errorbar(xValues,yValuesRed,lowerRed,upperRed, 'o',...
            'Color', '[0.87,0,0]',...
            'MarkerSize', 7,...
            'MarkerEdgeColor','[0.87,0,0]',...
            'MarkerFaceColor','[0.87,0,0]')
        ax = gca;
        ax.FontSize = 15;
        ax.FontName = 'Tahoma';
        ax.LineWidth = 1;
        set(gca, 'FontName', 'Arial')
        hold on 
            minX = 0;
            maxX = max(xValues);
            axis([minX maxX 0 1])
            theYLabel = strcat('Proportions of FUCCI-',cellType);
                ylabel(theYLabel) 
            title(char(strcat('Well',{' '},char(well),{': '},'Colony',{' '},num2str(colonyInQuestion))))
            errorbar(xValues,yValuesGreen, lowerGreen, upperGreen,'o',...
                'Color', '[0,0.62,0.27]',...
                'MarkerSize', 7,...
                'MarkerEdgeColor','[0,0.62,0.27]',...
                'MarkerFaceColor','[0,0.62,0.27]')
            yyaxis right
            minX = 0;
            maxX = max(xValues);
            minY = floor(min(totalNumberOfCells)/100)*100;
            maxY = ceil(max(totalNumberOfCells)/100)*100;
                if minY == maxY 
                    maxY = maxY+100;
                end 
            axis([minX maxX minY maxY])
            errorbar(xValues,totalNumberOfCells,totalNumberOfCells*0.1,totalNumberOfCells*0.1,'-o',...
                'Color', '[0.7,0.7,0.7]',...
                'MarkerSize', 5,...
                'MarkerEdgeColor','[0.7,0.7,0.7]',...
                'MarkerFaceColor','[0.7,0.7,0.7]')
            xlabel('Imaging time (hours)') 
            legend('Proportion of cells in G1 phase','Proportion of cells in S, G2 or M phases','Total number of cells',...
                'Location', 'southoutside')
            legend boxoff % Hides the legend's axes (legend border and background)
            ax = gca;
            

            ax.Position = [0.1322 0.24 0.7245 0.70];
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = 'k';
            theOtherYLabel = strcat('Total number of',{' '},cellType);
            ylabel(theOtherYLabel) 
        hold off
        
        %% Save the plot.
        
        thefigure = gcf;
        thefigure.Units = 'Inches';
        pos = get(thefigure,'OuterPosition');
        set(thefigure,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
        savePlotAs = cell2mat(strcat(char(well),{' '},'Colony',{' '},num2str(colonyInQuestion)));
        print(thefigure,savePlotAs,'-dpdf','-r0')
        
        close(gcf);
        
    end 
end 


end 





















