% A double image. 

%% set parameters
function [adjustedIm, RGBprobs, nuclearMasks] = pixelClassifier2(imageName, machineModel, param)

nSubsets = 100;
% the set of pixels to be classified is split in this many subsets;
% if nSubsets > 1, the subsets are classified using 'parfor' with
% the currently-opened parallel pool (or a new default one if none is open);
% see imClassify.m for details;
% it's recommended to set nSubsets > the number of cores in the parallel pool;
% this can make classification substantially faster than when a
% single thread is used (nSubsets = 1).

%% classify
    image = imreadGrayscaleDouble(imageName);
        imageDouble = double(image - (min(unique(image))));
        adjustedIm = imageDouble/(max(unique(imageDouble)));  
    F = imageFeatures(image,machineModel.sigmas,machineModel.offsets,machineModel.osSigma,machineModel.radii,machineModel.cfSigma,machineModel.logSigmas,machineModel.sfSigmas);
    [~,classProbs] = imClassify(F,machineModel.treeBag,nSubsets);
    
    RGBprobs(:,:,1) = classProbs(:,:,1);
    RGBprobs(:,:,2) = classProbs(:,:,2);
    RGBprobs(:,:,3) = classProbs(:,:,3); 

    grid = RGBprobs(:,:,1) < 0.2 & RGBprobs(:,:,2) < 0.6 & RGBprobs(:,:,3) > 0.35;

%% Post process the segmented image. (watershedding etc). 

    binary_mask           = bwareaopen(grid,param.size_threshold); % Remove small object

    distance              = bwdist(1 - binary_mask); %%% binary_mask is your binarized image of your nuclei. 
    %%% MATLAB computes the distance from 0 pixels to non-zero pixels. This why
    %%% I did 1 - binary_mask, we want the cells to be 0 and the bgd to be 1 to
    %%% use that function. 

    % figure
    % imshow(distance,[]); % To take a look at it.
    % 

    %%% We will now modify the distance transform so that we only detect the
    %%%  local maxima with amplitude bigger than h.

    h      = param.h_maxima; % set the value of h --> too small oversegmentation , too large under segmentation
    marker = distance - h; % we shift the image
    IM     = imreconstruct(marker,distance); % reconstruct it with morphological operator
    im_h   = distance - IM; % Take the difference between original and reconstructed

    region_local_max         = zeros(size(marker,1), size(marker,2));
    region_local_max(im_h>0) = 1; % local maxima region are the non zero value

    % figure
    % imshow(region_local_max,[]) % take a look at the maxima region.


    D2 = imimposemin(-distance,region_local_max); %modify the distance map so that only have the previously detected maxima


    b         = watershed(D2); %Apply the watershed
    im_result = double(b).*double(binary_mask); %Extract the watershed region only where there is signal


    size_threshold = param.size_threshold;  %min size of your nuclei
    nuclearMasks      = bwareaopen(im_result,size_threshold); % remove the too smaller than size_threshold


% 
%     im_result          = bwconncomp(im_result);  %
%     segmentation_mask  = labelmatrix(im_result); % Output the results as a label matrix instead of binary (optional)
%     segmentation_mask  =  imfill(segmentation_mask ,'holes');
%     a                  = mask2poly(segmentation_mask);


    if param.show 
        figure
        imshow(image,[])
        hold all
        plot(a(:,1), a(:,2),'.','col','red')
    end 

    
end