%% analysingWaves.m

% Author: Sam Huguet 
% Author e-mail: samhuguet1@gmail.com

% Purpose: Consider a folder of .xlsx files (each containing the data for a
% wave) and extract the numerical wave features. These are used to assign
% each wave a 'grade' between 1 (low synchrony) and 4 (high synchrony). The
% wave grades and wave features are then saved to the original directory. 

% Here, I select the smaller of the two daughter colonies, and
% relabel it with a new number. This error management is needed for
% the times when colonies begin to fragment upon the onset of
% differentiation.

% Function inputs: 
% The folder of .xlsx files (each containing the data for a
% wave)

% Function outputs:
% The wave grades and wave features (these are saved to the original
% directory).

%% Reset the Command Window and the Workspace.
clear;
clc;

%% Determine whether the user wants to analyse all the individual waves, or whether it's already been done. 

button = questdlg('Do you want to analyse all the wave files? If so, click continue. If you want to skip straight to the analysis of pre-analysed data, click no.', ...
	'Select the type of analysis you wish to perform', ...
	'Continue','No','Continue');

switch button 
    case 'Continue' 

    %% Open the 'AnaysingWaves...' excel file.
    [file, filePath] = uigetfile('*.xlsx*');

    % We now need to set the WD to Original_Path.
    cd(filePath);

    %% list all the files within the directory and filter them, to remove
    % any funny single character names (e.g. '.') which I've seen appear.
    allFiles = dir(filePath);
    allNames = {allFiles.name};
    [~, numberOfImages] = size(allNames);
    nameLength =  cellfun('length',allNames);
    logicalRepresentation = nameLength > 3;

    % Here are the correct names, generated by the process above. 
    correctNames = allNames(logicalRepresentation);
    numberOfCorrectNames = numel(correctNames);

    for g = 1 : numberOfCorrectNames
        [~,~,ext] = fileparts(correctNames{g});
        if strcmp(ext, '.xlsx') == 1 
            array_g(g) = 1;
        else
            array_g(g) = 0; 
        end 
    end 

    array_g = logical(array_g);
    correctNames = correctNames(array_g);
    numberOfCorrectNames = numel(correctNames);

    %% Loop thorugh waves and extract quantifiable information. 
    waveData = cell(1,1);

    deleteRowIndexes= [];

    phaseData = cell(1,1);

    for u = 1:numberOfCorrectNames

        %% Get the red wave data and the time data.

        disp((u/numberOfCorrectNames)*100);

        file = correctNames{u};
        waveData(u,15) = {file};

        table = readtable(file);

        greenData = table2array(table(1:end,8)); % Data for the green nuclei. 
        redData = table2array(table(1:end,7)); % Data for the red nuclei.
        timeData = table2array(table(1:end,3));

        %% Enter a loop which (1) interpolates the data, (2) Smoothes the data. 

        % Step (1). Interpolation. 
            xq  = min(timeData):0.5:max(timeData); % Define the range and frequency of the new interpolated points along the x axis.
            vq = interp1(timeData,redData,xq); % Interpolate the y points for the xq points. 
            [pk,lk] = findpeaks(vq,'MinPeakDistance',11); % this is needed for step 2 (and to make the commented out graph below).
            lk = lk/2;
            %plot(xq, vq,lk, pk, 'o');
            smoothedData = vq; % Just a renaming step for convenience later on.
            smoothedDataGreen = 1-smoothedData; % I'm mirroring the newly smoothened red data to make the green data.

        % Identify the local minima and the local maxima within the red curve. 
            DataInv = [];
            Maxima = [];
            MaxIdx = [];
            clearvars max 
            [Maxima,MaxIdx] = findpeaks(smoothedData); % Find the maxima.
            DataInv = 1.01*max(smoothedData) - smoothedData;
            [Minima,MinIdx] = findpeaks(DataInv);
            Minima = smoothedData(MinIdx); % Find the minima.
            if numel(Minima)+numel(Maxima) < 3 
                disp('Not enough maxima and minima. MATLAB has skipped analysing this file.')
                    waveData(u,3) = {'NA'};
                    waveData(u,3) = {'NA'};
                    waveData(u,3) = {'NA'};
                deleteRowIndexes(u,1) = 1; 
                continue; 
            end 

        % Step (2). Enter the loop. If the data isn't smoothened enough, keep going! 
        stopValue = 1; 
        while  stopValue == 1 

            smoothedData = smoothdata(smoothedData,'gaussian','samplepoints',xq); % Red data.
            smoothedDataGreen = 1-smoothedData; % I'm mirroring the newly smoothened red data to make the green data.
            xLimit = max(timeData);

            % Identify the local minima and the local maxima within the red curve. 
                DataInv = [];
                Maxima = [];
                MaxIdx = [];
                clearvars max 
                [Maxima,MaxIdx] = findpeaks(smoothedData); % Find the maxima.
                DataInv = 1.01*max(smoothedData) - smoothedData;
                [Minima,MinIdx] = findpeaks(DataInv);
                Minima = smoothedData(MinIdx); % Find the minima.

                % If the number of minima+maxia is less than 3 skip the
                % iteration. 
                if numel(Minima)+numel(Maxima) < 3 
                    disp('Not enough maxima and minima. MATLAB has skipped analysing this file.')
                    waveData(u,3) = {'NA'};
                    waveData(u,3) = {'NA'};
                    waveData(u,3) = {'NA'};
                    stopValue = 3; 
                    deleteRowIndexes(u,1) = 1; 
                    break;
                end 
            % Plot to check where the minima and the maxima fall.
            plot(xq, smoothedData, 'r');
            title('Plot of original data points and smoothened line')
                hold on 
                plot(timeData, redData, 'rx');
                plot(xq, smoothedDataGreen, 'g');
                plot(timeData, greenData, 'gx');
                xlabel('Time (hours)');
                ylabel('Proportions of FUCCI tagged nuclei (red or green)');
                ylim([0 1]);
                xlim([0 xLimit]);
                plot(xq(MaxIdx), Maxima, 'bO');
                plot(xq(MinIdx), Minima, 'bO'); 
                hold off 
            list1 = {'Keep Smoothing','Perfect!'}; % This makes the list of suggested wave qualities for the user.
            [stopValue,~] = listdlg('ListString',list1,...
                         'SelectionMode','single',...
                         'ListSize',[150,100]);
            close() % Once the user has given their respone from the list, the figures will close, and the loop will go to the next .xlsx file.

        end

        % This refers back to when there weren't enough maxima and minima. I
        % need this 'continue' to be outside of the 'while' loop to affect the
        % 'u' loop. 
        if stopValue == 3
            continue;
        end 

        %% Fast fourrier transform the data, and extract the top 5 most prevalent frequencies. 

        % Establish starting variables. 
        timeStep = xq(2)-xq(1); % Sampling period in hours.
        T = timeStep*60*60; % Sampling period in seconds: 1800 = 30min.
        Fs = 1/T; % Sampling rate in Hz.   
        L = length(vq); % Length of signal
        t = (0:L-1)*T; % Time vector

        % Do the FFT. 
        Y = fft(vq);

        % Create the x axis. 
        P2 = abs(Y/L); % This computes the two sides spectrum. 
        P1 = P2(1:floor(L/2)+1); % This computes the one sided spectrum. 
        P1(2:end-1) = 2*P1(2:end-1);

        % Create the Y axis. 
            f = Fs*(0:(L/2))/L; % Y axis: frequncy in Hz.
        ff = f.^-1; 
        ff = (ff/60);
            ff = (ff/60); % Y axis: Period in hours. 

        % Here, I remove the first x value, which is 'inf' and keeps ruining
        % plots. I also adjustt he y data so that there are the same number of
        % x and y values.
        f = f(2:end);
        ff = ff(2:end);
        P1 = P1(2:end);

            % Plot if needs be. 
    %         plot(ff,P1) 
    %         title('Single-Sided Amplitude Spectrum of X(t)')
    %         xlabel('f (Hz)')
    %         ylabel('|P1(f)|')

        % Find the peaks in the plots of differnt periods. 
        xx = []; 
            xx(:,1) = P1;
            xx(:,2) = ff;
            xx = sortrows(xx,2);
            [pks, locs] = findpeaks(xx(:,1), xx(:,2));
        yy = [];
            yy(:,1) = pks/(max(pks));
            yy(:,2) = locs;
            yy = sortrows(yy,1);    
            largest_Peaks = yy(end-4:end,:);

        % Enter the data into the table. 
        waveData{u, 2} = largest_Peaks(4,1);
        waveData{u, 3} = largest_Peaks(3,1);
        waveData{u, 4} = largest_Peaks(2,1);
        waveData{u, 5} = largest_Peaks(1,1);

        waveData{u, 6} = largest_Peaks(5,2);
        waveData{u, 7} = largest_Peaks(4,2);
        waveData{u, 8} = largest_Peaks(3,2);
        waveData{u, 9} = largest_Peaks(2,2);
        waveData{u, 10} = largest_Peaks(1,2);


        Y2 = fftshift(Y);
        theta = angle(Y2);
        theta = theta(1:47);
        theta_pi = theta/pi; 

        % Plot if needs be. 
    %         stem(ff, theta_pi);
    %         title('Single-Sided Phase Spectrum of X(t)')
    %         xlabel('f (Hz)')
    %         ylabel('Phase / pi')

        index = ff == largest_Peaks(end, end); 
        index = find(index, 1);
        waveData(u,16) = {theta_pi(index)}; % The phase of the dominant frequency. 

        %% Make sine wave to check that our values of phase and major frequency are accurate. 

    %     timeStep = xq(2)-xq(1); % Sampling period in hours.
    %     T = timeStep*60*60; % Sampling period in seconds: 1800 = 30min.
    %     Fs = 1/T; % Sampling rate in Hz.   
    %     L = length(vq); % Length of signal
    %     t = (0:L-1)*T; % Time vector
    %     
    %     t2 = (t/60)/60;
    %     xlim_FFT = max(t2);
    %     
    %     period_hours = largest_Peaks(5,2); 
    %     period_seconds = period_hours*60*60;
    %     frequency_Hz = 1/period_seconds;
    %     
    %     phase = waveData{u,16}; 
    %     
    %     x = cos(2*pi*frequency_Hz*t+phase*pi);
    %     
    %     x2 = rescale(x,min(smoothedData),max(smoothedData));
    %     
    %     % Make the graph:
    %     for ttt = 1 : 1
    %     figure('Renderer', 'painters', 'Position', [200 200 700 480])
    %     set(gcf, 'Color', 'white')
    %     pos1 = [0.14 0.35 0.85 0.63];
    %     subplot('Position',pos1) 
    %     plot(xq, smoothedData, 'r');
    %     set(gcf, 'Color', 'None')
    %             hold on 
    %             p1 = plot(timeData, redData, 'rx');
    %             p2 = plot(xq, smoothedDataGreen, 'g');
    %             p3 = plot(timeData, greenData, 'gx');
    %             xlabel('Time (hours)');
    %             ylabel({'Proportions of FUCCI-hESCs'});
    %             ylim([0 1]);
    %             xlim([0 xLimit]);
    %             p4 = plot(t2, x2, 'b');
    %             legend([p1 p3 p4], {'Proportion of cells in S, G2 or M phases','Proportion of cells in G1 phase','FFT sine wave'}, 'Location', 'eastoutside', 'FontSize',10)
    %             hold off 
    %     pos3 = [0.5 0 0.5 0.3];
    %     subplot('Position',pos3) 
    %         text{1} = ['Dominant wave frequency: ' num2str(frequency_Hz) ' ' 'Hz'];
    %         text{2} = ['Dominant wave period: ' num2str(period_hours) ' ' 'hours'];
    %         text{3} = ['Dominant wave phase (ranges between -? and ?): ' num2str(phase) ' ' '?'];
    %         text{4} = 'Equation structure: y = cos((2? * frequency (Hz) * time (s)) + phase (?) * ?)';
    %         text{5} = ['Final equation: y = cos((2? * ' num2str(frequency_Hz) ' * time) + ' num2str(phase) '?)'];
    %         dim = [0.1 0 0.6 0.25];
    %         annotation('textbox',dim,'String',text,'FitBoxToText','on');
    %         set(gca,'visible','off')
    %         set(gcf, 'Color', 'white')
    %     end 

        %% Root mean square error. 

        rmse = sqrt(immse(vq, smoothedData));
        nrmse = rmse/(mean(redData));

        waveData{u, 13} = nrmse; 

        %% Determine the gradient (representing change in wave amplitude over time).

        % Identify the local minima and the local maxima within the red curve. 
        DataInv = [];
        Maxima = [];
        MaxIdx = [];
        clearvars max 
        [Maxima,MaxIdx] = findpeaks(smoothedData); % Find the maxima.
            Maxima = rot90(Maxima);
            MaxIdx = rot90(MaxIdx);
            Maxs = [Maxima MaxIdx];
        DataInv = 1.01*max(smoothedData) - smoothedData;
        [~,MinIdx] = findpeaks(DataInv);
        Minima = smoothedData(MinIdx); % Find the minima.
            Minima = rot90(Minima);
            MinIdx = rot90(MinIdx);
            Mins = [Minima MinIdx];
        MaxsMins = [Maxs; Mins];
        MaxsMins = sortrows(MaxsMins, 2);

        % Is the first point a peak or a trough. 
                minimum_trough = min(MinIdx);
                minimum_peak = min(MaxIdx);
                if minimum_peak <  minimum_trough
                    first_point = 'peak';
                elseif minimum_trough < minimum_peak
                    first_point = 'trough';
                end 

        % Loop through the peaks and troughs, and record their amplitudes
        % relative to the next peak/trough along. 
        n = (numel(Minima)+numel(Maxima)-1);
        amplitudes = []; 
        for w = 1 : n
            amplitudes(w,1) = (xq(MaxsMins(w,2))+xq(MaxsMins(w+1,2)))/2; % Time.
            amplitudes(w,2) = abs(MaxsMins(w,1)-MaxsMins(w+1,1)); % Amplitude. 
        end 

        % Deduce the equation for fitting the data. 
        p = polyfit(amplitudes(:,1),amplitudes(:,2),1);
        waveData{u,11} = p(1);

        % Deduce the exponential decay rate of the data.
        f = fit(amplitudes(1:2,1), amplitudes(1:2,2), 'exp1');
        f = coeffvalues(f);
        f = f(2);

        waveData{u,12} = f;

        %% Calulate the ratio of numberof waves:total imagaging time. 

        total_imaging_time = max(timeData);

        numberOfWaves = (numel(Minima)+numel(Maxima))/2;

        numberOfWavesRatio = numberOfWaves/total_imaging_time;

        waveData{u,14} = numberOfWavesRatio;

        %% Grade waves between 1 (bad) and 4 (Great). 
        % Plot to check where the minima and the maxima fall, and grade the
        % plot, between 1 and 4. 
        plot(xq, smoothedData, 'r');
        title('Plot of original data points and smoothened line')
            hold on 
            plot(timeData, redData, 'rx');
            plot(xq, smoothedDataGreen, 'g');
            plot(timeData, greenData, 'gx');
            xlabel('Time (hours)');
            ylabel('Proportions of FUCCI tagged nuclei (red or green)');
            ylim([0 1]);
            xlim([0 xLimit]);
            plot(xq(MaxIdx), Maxima, 'bO');
            plot(xq(MinIdx), Minima, 'bO'); 
            hold off 
        list2 = {'Bad (1)','Mediocre (2)','Good (3)','Great (4)'}; % This makes the list of suggested wave qualities for the user.
            [indx,tf] = listdlg('ListString',list2,...
                 'SelectionMode','single',...
                 'ListSize',[150,100]);
            close() % Once the user has given their respone from the list, the figures will close, and the loop will go to the next .xlsx file.

        waveData{u, 1} = indx;


    end 

    %% Delete rows which don't have any data within them. 
    deleteRowIndexes = logical(deleteRowIndexes);
    waveData(deleteRowIndexes,:) = []; 

    %% Random forest.
    s2='Processed Data';
        saveDIR = strcat(filePath, s2); % Construct the current directory that we want.
    if ~exist(saveDIR, 'dir') % If the directory doesn't exist, then create it. 
        cd (filePath)
        mkdir(saveDIR)
    end

    % Change the WD.
    cd (saveDIR)

    training = readtable('C:\Users\Samuel Huguet\OneDrive\Documents\PhD\Experiments\Experiment 30 - Drug experiments\Training data for AnalysingWaves_Part2_RandForestRegression\All training data.xlsx');
    training_grades = table2array(training(:,1));
    training_X = table2array(training(:,2:14));

    % Remove the data to be classified from the trianing set. 
    training_categories = vertcat(unique((table2cell(training(:,18)))),{'No matches'});
    [indx,~] = listdlg('ListString',training_categories,...
        'PromptString',{'Select the experiment which is currently being analysed.'},...
     'SelectionMode','single',...
                         'ListSize',[300,250]);
    close() % Once the user has given their respone from the list, the figures will close, and the loop will go to the next .xlsx file.
    current_Category = training_categories(indx);
    index_list = ismember(table2cell(training(:,18)), current_Category);
    training_grades(index_list,:) = []; 
    training_X(index_list,:) = []; 
    
    test = waveData;
    test_grades = test(:,1);
    test_X = cell2mat(test(:,2:14));

    BaggedEnsemble = generic_random_forests(training_X,training_grades,200,'regression');
    predictions = predict(BaggedEnsemble,test_X);
    close all force 

    waveData = horzcat(waveData, num2cell(predictions));

    case 'No' 
    
    %% Open the 'AnaysingWaves...' csv file.
    [file, filePath] = uigetfile('*.csv*');

    % We now need to set the WD to Original_Path.
    cd(filePath);

    %% Random forest. 
    s2='Processed Data';
        saveDIR = strcat(filePath, s2); % Construct the current directory that we want.
    if ~exist(saveDIR, 'dir') % If the directory doesn't exist, then create it. 
        cd (filePath)
        mkdir(saveDIR)
    end

    % Change the WD.
    cd (saveDIR)

    training = readtable('C:\Users\Samuel Huguet\OneDrive\Documents\PhD\Experiments\Experiment 30 - Drug experiments\Training data for AnalysingWaves_Part2_RandForestRegression\All training data.xlsx');
    training_grades = table2array(training(:,1));
    training_features = table2array(training(:,2:14));

    % Remove the data to be classified from the trianing set. 
    training_categories = vertcat(unique((table2cell(training(:,18)))),{'No matches'});
    [indx,~] = listdlg('ListString',training_categories,...
        'PromptString',{'Select the experiment which is currently being analysed.'},...
     'SelectionMode','single',...
                         'ListSize',[300,250]);
    close() % Once the user has given their respone from the list, the figures will close, and the loop will go to the next .xlsx file.
    current_Category = training_categories(indx);
    index_list = ismember(table2cell(training(:,18)), current_Category);
    training_grades(index_list,:) = []; 
    training_features(index_list,:) = []; 
    
    % Get the data to classify.
    test_grades = table2array(training(:,1));
    test_features = table2array(training(:,2:14));
        test_features = test_features(index_list,:);
        
    BaggedEnsemble = generic_random_forests(training_features,training_grades,200,'regression');
    predictions = predict(BaggedEnsemble,test_features);
    close all force 

    waveData = horzcat(waveData, num2cell(predictions));
        
end 

%% Save data. 

% Save amplitudeArray. 
c = clock;
year = num2str(c(1));
month = num2str(c(2));
day = num2str(c(3));
hour = num2str(c(4));
minute = num2str(c(5));

title = strcat('AnalysingWaves_P1_P2_Combined','_',year,month,day,'_', hour, minute,'.csv');
waveData = cell2table(waveData);
writetable(waveData, title);





