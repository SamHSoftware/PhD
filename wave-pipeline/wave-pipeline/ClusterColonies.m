%% ClusteredColonies.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: 
% Performs spatial clustering of cells in a 2D image for a single timepoint. 
% This function is used within the segmentAndDBSCAN function. 

% Function inputs: 
% mask_nuc [array] --> Binary image with background = 0, and nuclei = 1. 
% param_CC [struc] --> Structure with parameters for this function. Example values are below. 
%   param_CC.size_threshold = 200;
%   param_CC.numNuclei = 6;
%   param_CC.elipse = 85;

% Function outputs: 
% clusteredColonies [array] --> The image of nuclei, now clustered such
% that the nuclei of each colony are of a distinct value. Background = 0
% and lone-nuclei = 1. 

function clusteredColonies = ClusterColonies(mask_nuc, param_CC)

%% Remove small objects from the image. 
mask_nuc = bwareaopen(mask_nuc, param_CC.size_threshold);

%% Detect all the centroids of the nuclei. 
object          = bwconncomp(mask_nuc);  %- Detecting the single nucleus
nuc_struct      = regionprops(object, 'Centroid','PixelList'); %- Extracting centroid location of object.
centroid_nuclei = vertcat(nuc_struct.Centroid);

%% Perform the dbscan clustering on the centroids. 
res_clust = (dbscan(centroid_nuclei,param_CC.elipse,param_CC.numNuclei)); %- do dbscan to cluster the cells centroid. This makes a list of centroid identities. 

% scatter(centroid_nuclei(:,1), centroid_nuclei(:,2), [], res_clust) % This can plot a scatter plot of the cells. 

%% Colour the image acording to the dbscan values. 

mask_nuc16 = double(mask_nuc); % Make a uint16 image so that you acn label the nuclei with different values. 

for h = 1 : object.NumObjects % Loop through all blobs.
	
	thisNucleusPixels = nuc_struct(h).PixelList;  % Get list of pixels in current nucleus.
    
        for b = 1:length(thisNucleusPixels) % Loop through all the pixels in the nucleus and change their value 
            
            yi = thisNucleusPixels(b,1);
            xi = thisNucleusPixels(b,2);
            mask_nuc16(xi,yi) = res_clust(h);
            
        end 
end

%% We now need to swap the background (value = 0) and theungrouped nucelei (value = -1 for some reason), 
% then add one to them, so that background is 0 and then non grouped nuclei are 1.
backgroundMask = mask_nuc16 == 0; % thsi is the background mask.
nonGroupedNuclei = mask_nuc16 == -1; % These is the non- grouped nuclei mask. 
mask_nuc16 = mask_nuc16 + 1; % Add 1 to the entire image. 
mask_nuc16(backgroundMask) = 0; % Set the background to 0.
mask_nuc16(nonGroupedNuclei) = 1; % Set the non-grouped nuclei to 1;

clusteredColonies = mask_nuc16;

% colourColonies = label2rgb(mask_nuc16, 'hsv', 'k', 'shuffle');

