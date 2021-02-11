% Script designed to use interpolation to flat field correct images from
% the Yoko. 

function folder_well = FFC_Interpolation(folder_well, machineModel, binFactor, doYouWantToFFCImages, Channels_To_Not_FFC, H2BChannel, lengthOfPixel)

switch doYouWantToFFCImages
    
    case 'No' 
        
        disp('You have chosen not to flat field correct your images');
        
    case 'Yes' 

        disp('Commencing flat field correction of images');
        
        %% Load up all the images in the folder. 

        % any funny single character names (e.g. '.') which I've seen appear.
        if iscell(folder_well) == 1
            folder_well = cell2mat(folder_well);
        end 
        allFiles = dir(folder_well);
        cd (folder_well)
        allNames = {allFiles.name};
        numberOfImages = size(allNames);
        numberOfImages = numberOfImages(2);
        nameLength =  cellfun('length',allNames);
        logicalRepresentation = nameLength > 60;

        % Here are the correct names, generated by the process above. 
        correctNames = allNames(logicalRepresentation);
        numberOfCorrectNames = numel(correctNames);
        
        %% Figure out how many fields of view are being used (this is assumed to be constant between wells).

        greatestFOV = 0; % Create the array to store the biggest field of view. 
        correctNames = rot90(correctNames,3);% We need to rotate the name array for use later on. 

        for q=1:numberOfCorrectNames
            % Extracting the first file name as a string. 
            Name = correctNames{q};

            % Extracting the field from the 'correctNames' string. 
            field = Name(end-18:end-16);
            field = str2double(field);

            % If FOV number we're just calculated is greater than the last one in
            % the loop, then update that value. 
            if field > greatestFOV
                greatestFOV = field; % This is the FOV with the highest number. 
            end 
        end

        %% Get a list of the channels corresponding to each image + remove image names which shouldn't be flat field corrected. 

        correctNames2 = rot90(correctNames,3);% We need to rotate the name array for use later on. 
        channelArray = [];
        
        for q=1:numberOfCorrectNames
            % Extracting the first file name as a string. 
            Name = correctNames2{q};

            % Extracting the well from the 'correctNames' string. 
            channel = str2num(Name(end-4:end-4));
            channelArray(q,1) = channel; 
        end
        
        % Remove the image names from correctedNames2 that we shouldn't FFC
        % e.g. brightfield. 

        DeleteName_index = ismember(channelArray, Channels_To_Not_FFC);
        correctNames2(DeleteName_index) = []; 
        correctNames2 = rot90(correctNames2);
        numberOfCorrectNames = numel(correctNames2);
        
        % Get a list of the channels thatw e need to FFC. 
        channelArray(DeleteName_index) = [];
        channel_list = unique(channelArray);
        
        %% Get the local indices of images in the first timepoint of the image. 
        
        timepointArray = [];
    
        for q=1:numberOfCorrectNames
            % Extracting the first file name as a string. 
            Name = correctNames2{q};

            % Extracting the well from the 'correctNames' string. 
            timepoint = str2num(Name(end-23:end-20));
            timepointArray(q,1) = timepoint; 
        end
       
        % Get a list of names in timepoint = 1. 
        timpoint_1_index = timepointArray ~= 1; 
        correctNames2_T1 = correctNames2;
        correctNames2_T1(timpoint_1_index) = []; 
        numberOfCorrectNames_T1 = numel(correctNames2_T1);
        
        %% Make the Background_Illumination images.
                
        % Iterate through the fields of view, creating the Background_Illumination images for each. 
        for g = 1 : greatestFOV

            s1 = 'progress_g';
            s2 = num2str(g);
            s3 = '___FOV =';
            value = num2str((g/greatestFOV*100));
            message = cell2mat(strcat(s1,s2,s3,{' '}, value));
                disp(message);       
        
            % Make a list of all the names affiliated with this FOV. Infostored in: name_structure(h).Image_Names
            clear name_structure
            for h = 1 : numel(channel_list)

                temporary_Names = correctNames2_T1;
                clear FOV_Array channel_Array

                for q=1:numberOfCorrectNames_T1

                    % Extracting the first file name as a string. 
                    Name = correctNames2_T1{q};

                    % Extracting the well from the 'correctNames' string. 
                    FOV = str2num(Name(end-18:end-16));
                    FOV_Array(q,1) = FOV; 
                end

                FOV_index = FOV_Array == g;
                temporary_Names(~FOV_index) = []; 
                numberOfCorrectNames_temporary = numel(temporary_Names);

                for q=1:numberOfCorrectNames_temporary

                    % Extracting the first file name as a string. 
                    Name = temporary_Names{q};

                    % Extracting the well from the 'correctNames' string. 
                    channel = str2num(Name(end-5:end-4));
                    channel_Array(q,1) = channel; 
                end

                channel_index = channel_Array == h;
                temporary_Names(~channel_index) = []; 

                name_structure(h).Image_Names = temporary_Names;
            end 

            % Loop through the channels one by one, and make the Background_Illumination images for each. 
            for k = 1 : numel(channel_list)    
                
                s1 = 'progress_k';
                s2 = num2str(k);
                s3 = '___Channel =';
                value = num2str((k/numel(channel_list)*100));
                message = cell2mat(strcat({'   '},s1,s2,s3,{' '}, value));
                    disp(message);    
                
                % Loop through the images, and make a 3D stack of the relevant, interpolated, FOVs. Then, average them and make one single FOV. 
                image_stack = []; 

                images_y = name_structure(k).Image_Names;
                images_y_No = numel(images_y);

                for y = 1 : images_y_No

                    s1 = 'progress_y';
                    s2 = num2str(y);
                    s3 = '___Image stack =';
                    value = num2str((y/images_y_No*100));
                    message = cell2mat(strcat({'      '},s1,s2,s3,{' '}, value));
                        disp(message);    
                    
                    cd (folder_well);

                    imageName_h2B = name_structure(H2BChannel).Image_Names{y}; % Get the H2B image for the mask.
                    
                    image_y = images_y{y}; % Get the other image (it might be H2B too!)  
                    image_y = imread(image_y);
                    [height, width] = size(image_y);

                    imageName_h2B(end-4:end-4) = '1'; % We want to change the name so that it reflects the H2B channel. 
                    
                                            param.h_maxima          = 2.2;
                    size_threshold_microns_Squared = 21.16; % The area in microns squared. CHANGE THIS VALUE, NOT THE ONE BELOW, AS IT DEPENDS ON PIXEL SIZE AND BINNING.
                        param.size_threshold = round(((sqrt(size_threshold_microns_Squared)/lengthOfPixel)^2)/binFactor^2); % Converting microns squared to pixels, taking into account the pixel size and binning value. 
                    param.show              = 0;
                    [~, RGBprobs, nuclearMasksTest] = pixelClassifier2(imageName_h2B, machineModel, param);
                    backgroundMasks = RGBprobs(:,:,1) > 0.05 & RGBprobs(:,:,2) < 0.5 & RGBprobs(:,:,3) < 0.2;
                    
                    % Get the locations of the background pixels.
                    backgroundProps = regionprops(backgroundMasks, 'PixelList');
                    background_PixelList = vertcat(backgroundProps.PixelList);
                    background_PixelList_x = background_PixelList(:,1);
                    background_PixelList_y = background_PixelList(:,2);  
          
                    % Get the pixel values of the image.
                    pixel_values = [];
                        for f = 1: length(background_PixelList_x)
                            pixel_values(f,:) = image_y(background_PixelList_y(f), background_PixelList_x(f));
                        end 

                    % Interpolate from the data we have.
                    F = scatteredInterpolant(background_PixelList,pixel_values);
                    F.Method = 'natural';
                    F.ExtrapolationMethod = 'linear';
                    [Xq,Yq] = meshgrid(1:width, 1:height);
                    Vq = F(Xq,Yq);

                    if numel(Vq) == 0 % If Vq is empty due to failed interpolation. Skip the interation. 
                        continue;
                    end 

                    % Look to see if the interpolation has gone wrong (method 1): (every now and again, it rins the images). 
                    Vq_uint16 = uint16(Vq);
                    equality_image = Vq_uint16 == image_y;
                    equal_pixels = sum(equality_image(:) == 1);
                    percentage_equality = (equal_pixels/numel(image_y))*100;
                    if percentage_equality < 40 % If interpolation ruined the image with the 'triangle artifact' then skip adding this image to the image_stack. 
                        disp('Skipped image via method 1')
                        continue;
                    end 
                    % Look to see if the interpolation has gone wrong(method 2):
                    similarity_image = Vq;
                    similarity_image = similarity_image/mean(pixel_values);
                    comparison_image = similarity_image < 0.5 | similarity_image(:,:) > 1.5;
                    percentage_differnce = ((sum(comparison_image, 'all'))/(width*height))*100;
                    if percentage_differnce > 1
                        disp('Skipped image via method 2')
                        continue;
                    end 
                    
                    [height, ~, depth] = size(image_stack);
                        if height == 0 
                            depth = 0;
                        end 
                    
                    image_stack(:,:,depth+1) = Vq;

                end   
                    
                Background_Illumination = mean(image_stack,3); % The averaged image. 
                
                
                % Gaussian blur the images. 
                %Background_Illumination = imgaussfilt(Background_Illumination, 3);
                %Background_Illumination = imgaussfilt(Background_Illumination, 3);
                %Background_Illumination = imgaussfilt(Background_Illumination, 15);                   

                % Make a Background_Illumination-images directory. 
                s1 = folder_well;
                    s2 = '\';
                    s3 = 'Background_Illumination';
                    Background_Illumination_dir = strcat(s1, s2, s3); % Construct the current directory that we want.
                if ~exist(Background_Illumination_dir, 'dir') % If the directory doesn't exist, then create it. 
                    cd (folder_well)
                    mkdir(Background_Illumination_dir)
                end

                % Save our new image. 
                s1 = 'C0';
                s2 = num2str(k);
                s3 = 'F';
                s4 = sprintf('%03d', g);
                FFCImageName = strcat(s1, s2, s3, s4);
                cd (Background_Illumination_dir)
                save(FFCImageName,'Background_Illumination')
                % bbb = load('C01F001.mat');
                % necessaryImage = bbb.Background_Illumination;    

            end

        end 

        %% Loop through the uncorrected images and flat field correct them.       
        
        % any funny single character names (e.g. '.') which I've seen appear.
        allFiles = dir(folder_well);
        cd (folder_well)
        allNames = {allFiles.name};
        numberOfImages = size(allNames);
        numberOfImages = numberOfImages(2);
        nameLength =  cellfun('length',allNames);
        logicalRepresentation = nameLength > 60;

        % Here are the correct names, generated by the process above. 
        correctNames = allNames(logicalRepresentation);
        numberOfCorrectNames = numel(correctNames);
        
        % Get the max pixel value for each of the channels that we're
        % using.
        for k = 1 : numel(channel_list) % gg produce meanChannelIntensity_T1 (structure). 
        
            channel = channel_list(k);
            channelArray = [];
            
            for q=1:numberOfCorrectNames_T1
                % Extracting the first file name as a string. 
                Name = correctNames2_T1{q};

                % Extracting the well from the 'correctNames' string. 
                channel_2 = str2num(Name(end-4:end-4));
                channelArray(q,1) = channel_2; 
            end
            
            % Remove the image names from correctedNames2 that we shouldn't FFC
            % e.g. brightfield. 
            DeleteName_index = ismember(channelArray, channel);
            correctNames2_T1_2 = correctNames2_T1;
            correctNames2_T1_2(~DeleteName_index) = []; 
            
            for r = 1 : numel(correctNames2_T1_2)
                image_stack(:,:,r) = imread(correctNames2_T1_2{r});
            end 
            mean_pixel_value = mean(image_stack, 'all');
            clear image_stack; 
            channel_sting = strcat('C0',num2str(channel));
            meanChannelIntensity_T1.(channel_sting) = mean_pixel_value;
        end 
        
        
        % Loop through the uncorrected images, and correct them. Save the
        % images in a new folder. 
        delete(gcp('nocreate'))
        parpool(4)
        parfor b = 1 : numberOfCorrectNames
            
            cd (folder_well) % Load the image we need to correct.
            uncorrected_image_name = correctNames{b};
            uncorrected_image = imread(uncorrected_image_name); 
            
            field = uncorrected_image_name(end-19:end-16); % Construct the name of the background_illumination image. 
            channel = uncorrected_image_name(end-6:end-4);
            s3 = '.mat';
            background_illumination_image_name = strcat(channel, field, s3);
            
            channel2 = str2num(uncorrected_image_name(end-4:end-4)); % When we encounter a channel which isn't to be flat field corrected, ignore it. 
            if ismember(channel2, channel_list) == 0
                continue;
            end 
            
            cd (Background_Illumination_dir) % Load the background_illumination image. 
            background_illumination_image = load(background_illumination_image_name);
            background_illumination_image = background_illumination_image.Background_Illumination;    
            
            % FFC correct the image.
            meanChannelIntensity = meanChannelIntensity_T1.(channel);
            background_illumination_image2 = background_illumination_image/meanChannelIntensity;

            uncorrected_image_double = double(uncorrected_image);

            corrected_image = uncorrected_image_double./background_illumination_image2; % Correct the If image by dividing it by the FFC image. 
            corrected_image = uint16(corrected_image);
            
            % Make a Background_Illumination-images directory. 
            s1 = folder_well;
                s2 = '\';
                s3 = 'FFCorrected';
                FFC_dir = strcat(s1, s2, s3); % Construct the current directory that we want.
            if ~exist(FFC_dir, 'dir') % If the directory doesn't exist, then create it. 
                cd (folder_well)
                mkdir(FFC_dir)
            end
            
            cd (FFC_dir) 
            imwrite(corrected_image, uncorrected_image_name, 'Compression', 'none');
            
        end 
        
        %% Change the folder_well directory. 
        s1 = folder_well;
                s2 = '\';
                s3 = 'FFCorrected';
                FFC_dir = strcat(s1, s2, s3); % Construct the current directory that we want.
        folder_well = FFC_dir;
        
end

       
        
        
        
        
        
        
        
        
        
        
     
        
 