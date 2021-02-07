%% getColonyCentroid.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: This function find the centroid (in pixels) of the colony in
% question. 

% Function inputs: 
% binarycolonyImage [n x m logical] --> The binary image. Colony nuclei should be of value 1, while background should be 0. 

% Function outputs: 
% colony centroid [1 x 2 double array] --> First value is the x position, second is the y position. 

function [x_mid, y_mid] = getColonyCentroid(binaryColonyImage)

    % Get the x and y positions of all the nuclei in the colony. 
    colonyinfo = regionprops(binaryColonyImage, 'centroid'); % Get the regionprops info for the colony.
    all_position = vertcat(colonyinfo.Centroid); % Concatenate all the pixel informations for all the nuclei.
    x = all_position(:,1);
    y = all_position(:,2);
    colony_boundary = boundary(x, y, 1); % Get the boundary of the colony.

    % Fill in the colony. 
    [height, width, ~] = size(binaryColonyImage);
    filled_colony = poly2mask(all_position(colony_boundary,1),all_position(colony_boundary,2),height,width); % Make a mask of the colony. 
    filled_colony = bwareafilt(filled_colony, 1);
    
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
        
end 