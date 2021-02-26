function [outer25um_nuclei, notOuter25um_nuclei, innerRegion_nuclei, notInnerRegion_nuclei] = colonyRegions(binaryColonyImage)

% If the image doesn't have any nuclei, assign the images to the original
% empty image.
if sum(binaryColonyImage(:)) == 0 
    outer25um_nuclei = binaryColonyImage;
    notOuter25um_nuclei = binaryColonyImage;
    innerRegion_nuclei = binaryColonyImage;
    notInnerRegion_nuclei = binaryColonyImage;
    
    return
end 

colonyinfo = regionprops(binaryColonyImage, 'centroid'); % Get the regionprops info for the colony.
all_position = vertcat(colonyinfo.Centroid); % concatenate all the pixel informations for all the nuclei.

x = all_position(:,1);
y = all_position(:,2);
colony_boundary = boundary(x, y, 1); % Get the boundary of the colony.

[height, width, ~] = size(binaryColonyImage);
filled_colony = poly2mask(all_position(colony_boundary,1),all_position(colony_boundary,2),height,width); % Make a mask of the colony. 
filled_colony = bwareafilt(filled_colony, 1);
se = strel('disk',20);
filled_colony2 = imdilate(filled_colony,se);

% Get the colony perimeter. 
boundary_pixels = bwboundaries(filled_colony);
boundary_pixels = boundary_pixels{1,1};
boundary_pixels_x = boundary_pixels(:,2);
boundary_pixels_y = boundary_pixels(:,1);
colony_perimeter = zeros(size(filled_colony));
for x = 1 : length(boundary_pixels)
    colony_perimeter(boundary_pixels_y(x), boundary_pixels_x(x)) = 1; 
end 

% Get a list of nuclear centroids. 
labelled_nuclei = bwlabel(binaryColonyImage); 
colony_info = regionprops(binaryColonyImage, 'Centroid'); 
centroids = vertcat(colony_info.Centroid); 

% Create the peripheral 25 um (42 pixels) of the colony.
% These are the nuclei at the edge. 
se = strel('disk',38);
dilated_edge = imdilate(colony_perimeter,se);
notOuter25um = filled_colony - dilated_edge;
notOuter25um = notOuter25um == 1; 

se = strel('disk',10);
outer25um = imdilate(dilated_edge, se) - notOuter25um; 
outer25um = outer25um == 1;

outer25um_nuclei = binaryColonyImage;
for nuclei = 1 : max(labelled_nuclei(:)) 
    if outer25um(round(centroids(nuclei, 2)), round(centroids(nuclei, 1))) == 0
        the_nucleus = labelled_nuclei == nuclei; 
        outer25um_nuclei(the_nucleus) = 0; 
    end 
end 

% Get notOuter25um.
notOuter25um_nuclei = binaryColonyImage;
for nuclei = 1 : max(labelled_nuclei(:)) 
    if notOuter25um(round(centroids(nuclei, 2)), round(centroids(nuclei, 1))) == 0
        the_nucleus = labelled_nuclei == nuclei; 
        notOuter25um_nuclei(the_nucleus) = 0; 
    end 
end 

% Get the center of the colony 
feature_frame.colony_polygon = [all_position(colony_boundary,1) all_position(colony_boundary,2)]; %- position of the colony

s = regionprops(filled_colony,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','Circularity','Eccentricity');
    s = s(1);
    short_angle = (s.Orientation)*pi/180;
    long_length = s.MajorAxisLength;
    centroid_coords = s.Centroid;
    xend = floor(centroid_coords(1)+long_length*sin(short_angle));
    yend = floor(centroid_coords(2)+long_length*cos(short_angle));
    xstart = floor(centroid_coords(1)-long_length*sin(short_angle));
    ystart = floor(centroid_coords(2)-long_length*cos(short_angle));
    [x_line,y_line] = bresenham(xstart,ystart,xend,yend);
    [Vin, ~] = inpoly2([x_line,y_line],feature_frame.colony_polygon);
    x_in = x_line(Vin);
    y_in = y_line(Vin);
    x_mid = x_in(ceil(end/2));
    y_mid = y_in(ceil(end/2));
    
% Get the inner region.
colony_inner = zeros(size(filled_colony));
colony_inner(y_mid, x_mid) = 1; 
se = strel('disk',50);
innerRegion = imdilate(colony_inner,se);
removal_mask = ones(size(filled_colony))-filled_colony;
innerRegion = innerRegion - removal_mask; 
innerRegion = innerRegion == 1; 
innerRegion_nuclei = binaryColonyImage;
for nuclei = 1 : max(labelled_nuclei(:)) 
    if innerRegion(round(centroids(nuclei, 2)), round(centroids(nuclei, 1))) == 0
        the_nucleus = labelled_nuclei == nuclei; 
        innerRegion_nuclei(the_nucleus) = 0; 
    end 
end 

% Get the notInner region. 
notInnerRegion = filled_colony2 - innerRegion;
notInnerRegion_nuclei = binaryColonyImage;
for nuclei = 1 : max(labelled_nuclei(:)) 
    if notInnerRegion(round(centroids(nuclei, 2)), round(centroids(nuclei, 1))) == 0
        the_nucleus = labelled_nuclei == nuclei; 
        notInnerRegion_nuclei(the_nucleus) = 0; 
    end 
end 

end 