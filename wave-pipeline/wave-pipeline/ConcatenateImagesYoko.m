%%% SCRIPT TO CONCATENATE IMAGES 

% folder_well = uipickfiles;

function [folder_output] = ConcatenateImagesYoko(folder_well, matrix_field)

%% Get images structure 

if iscell(folder_well) == 0
    folder_well = {folder_well};
end 

s2 = '\Grids';
folder_output = strcat(folder_well, s2);

file_image    = [] ; 


for i_well = 1:length(folder_well)

cd(folder_well{i_well});

file_image_well  = dir(fullfile('*.tif'));
file_image_well = file_image_well(cellfun(@(x) strcmp('Assay',x(1:5)), {file_image_well.name}));

for i_image = 1:length(file_image_well)
     
    fname = file_image_well(i_image).name ;
    
    channel=regexp(fname,'C(\d{2,}).tif','tokens','once');
    numchannel=str2double(channel);
    
    time=regexp(fname,'_T(\d{4,})','tokens','once');
    numtime=str2double(time);
    
    field=regexp(fname,'F(\d{3,})L','tokens','once');
    numfield=str2double(field);
    
    well=regexp(fname,'_(...)_T','tokens','once');
    
file_image_well(i_image).channel = channel ;  
file_image_well(i_image).time    = time ;  
file_image_well(i_image).well    = cell2mat(well) ;  
file_image_well(i_image).field   = field ;  

file_image_well(i_image).channel = numchannel ;  
file_image_well(i_image).time    = numtime ;  
file_image_well(i_image).field   = numfield ;  

end
file_image = [file_image ; file_image_well ];

end

table_files = struct2table(file_image);

%% Concatenate and save images

a          = imread(fullfile(table_files.folder{1}, table_files.name{1}));
image_size = size(a);
well = unique(table_files.well);
% well = well([1,2,3,6,7,8])


for i_well = 1:length(well)
    
    s1 = 'progress_i_well___Iterating through wells ='; 
    value = num2str((i_well/length(well))*100);
    message = cell2mat(strcat(s1,{' '}, value));
    disp(message);
    
    well_ID = well{i_well};
    
    table_files_well = table_files(find(strcmp(table_files.well,well_ID)),:);
    
    num_images = size(table_files_well);
    if num_images(1) ~= 5184
        continue; 
    end
    
    time_frame = unique([table_files.time]);
    field_view = unique([table_files.field]);
    channel    = unique([table_files.channel]);
    
    
    if length(time_frame) < 3
        continue;
    end
    
    table_files_well_time = table_files_well([table_files_well.time] == time_frame(4),:);
    


for i = 1:length(time_frame)
    %         for i = 1:5
    
    s1 = 'progress_i___Making megagrids ='; 
    value = num2str((i/length(time_frame))*100);
    message = cell2mat(strcat({'   '},s1,{' '}, value));
    disp(message);
    
    table_files_well_time = table_files_well([table_files_well.time] == time_frame(i),:);
    
    
    for i_channel = 1:length(channel)
        
        
        
        
        table_files_well_time_channel = table_files_well_time([table_files_well_time.channel] == channel(i_channel),:)    ;
        
        if ~isempty(table_files_well_time_channel)
            
            big_image                    = zeros(size(matrix_field,1)*image_size(1), size(matrix_field,2)*image_size(2));
            
            
            
            for i_field = 1:length(field_view)
                
                
                [ind_field_x, ind_field_y] = ind2sub(size(matrix_field), find(matrix_field == field_view(i_field)));
                
                
                table_files_well_time_channel_field = table_files_well_time_channel([table_files_well_time_channel.field] == field_view(i_field),:);
                table_files_well_time_channel_field.name{1};
                image = imread(fullfile(table_files_well_time_channel_field.folder{1}, table_files_well_time_channel_field.name{1}));
           
               
                
                big_image((ind_field_x-1)*image_size(1) +1:(ind_field_x-1)*image_size(1) + image_size(1),(ind_field_y-1)*image_size(2) +1:(ind_field_y-1)*image_size(2) + image_size(2)) = image;
                
            end
            
            
            fname = table_files_well_time_channel_field.name{1};
            
            outdir = cell2mat(strcat(folder_output,'\',well{i_well}));
            if ~exist(outdir)
                mkdir(outdir);
            end
            outName = strcat('\',well{i_well},'\',well{i_well},'T',num2str(i,'%04d'),'C',num2str(channel(i_channel),'%02d'),'.tif');
            imwrite(uint16(big_image), cell2mat(fullfile(folder_output,outName)));
            
        end

    end
    
    
end

end

folder_output = cell2mat(folder_output);
disp('ConcatenateImagesYoko complete');
end 