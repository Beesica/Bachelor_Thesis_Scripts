%%
clear all; 
close all;
clc; 

%% Online code 
addpath('/MATLAB Drive/EEGLAB');
addpath("EEGLAB/functions/firfilt-master/firfilt-master/");
addpath("EEGLAB/functions/zapline-plus-main/zapline-plus-main/")
addpath("EEGLAB/functions/clean_rawdata/")
addpath("EEGLAB/plugins/amica/")
addpath("EEGLAB/plugins/ICLabel1.6/")
addpath("EEGLAB/plugins/preprocessing_helpers/")

eeglab;

savedata = '/MATLAB Drive/data';
save = '/MATLAB Drive/Images';

%% set parameters
% included participants 
subjects = {'02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; '6a23f1a0-bdeb-4afd-af1c-cd7e607a93e0'; '7afcd75b-9094-4fdf-9e33-70a99439deda'; ...
    '7d4ab496-f88c-4965-9a8f-4aaa9ae50f13'; '7d9620d5-bbd8-4c63-ab0b-72a3e0a0137a'; ...
    '87c8f5f3-9dc8-481b-821e-7fc676da19f5'; '723c8bc5-7809-4dfc-990c-36de0f544b72'; '41862e7e-bb0d-484c-9149-37175debeff7'; ...
    'a9412d68-6eaf-4a1f-ab61-b2f408ac5b47'};

% electrode to be plotted
currElec = 'PO8';

% arrays to save distance and rotation values
distance_diff = zeros(8, length(subjects));
rotation_diff = zeros(114, length(subjects));

%% 
for s = 1:length(subjects) % for each subject
    % load dataset
    EEG = pop_loadset(sprintf('4a_interpolation_%s.set', char(subjects(s))),fullfile(savedata));
    EEG = eeg_checkset(EEG); % dataset intact
    
    % create array with column for distance and rotation for face stimuli
    event_face = EEG.event(arrayfun(@(x) strcmp(x.('type'), 'face'), EEG.event));

    % get unique distance and rotation value
    distance_values = unique([event_face.distance]);
    rotation_values = unique([event_face.rotation]);
    
    % index of electrode
    el_idx = find(strcmp({EEG.chanlocs.labels}, currElec) == 1);

    %% Calculate time difference to align peaks
    % set window to find P100
    p100 = pop_epoch(EEG, {}, [0.05 0.22]);
    p100 = eeg_checkset(p100); % dataset intacts
    p100_data = p100.data(:,:,:); % save data separately
    p100.mean = mean(p100_data, 3); % calculate mean of data
    p100_elec   = p100.mean(el_idx, :); % get mean at electrode

    % sort according to peak height
    [pks, locs] = findpeaks(p100_elec, 'SortStr', 'descend');

    % calculate difference between 100ms and actual time of P100
    delay = 100 - p100.times(locs(1));

    % adjust for time shift of P100
    start = 0.09 - (delay * 0.001);
    ending = 0.18 - (delay * 0.001);

    %% Distance
    for d = 1:8 % maximum distance is 8
        % get rows with specified distance value
        rows_d = arrayfun(@(x) x.('distance') == distance_values(d) , event_face);
    
        peak_face = pop_epoch(EEG, {'face'}, [start ending]); % epoch data
        peak_face = eeg_checkset(peak_face); % intact dataset
        peak_face_data = peak_face.data(:,:,rows_d); % save rows with specific distance value
        peak_face.mean = mean(peak_face_data, 3); % calculate mean
        peak_face_elec   = peak_face.mean(el_idx, :); % get mean for electrode
    
        % calculate peak difference 
        dif_face = peak2peak(peak_face_elec);
        distance_diff(d,s) = dif_face; % save peak-to-peak difference
        
    end

    %% rotation
    for r = 1:114 % maximum rotation value is 114
        % get rows with specific rotation value
        rows_r = arrayfun(@(x) x.('rotation') == r , event_face);
    
        peak_face = pop_epoch(EEG, {'face'}, [start ending]); % epoch data
        peak_face = eeg_checkset(peak_face); % intact dataset
        peak_face_data = peak_face.data(:,:,rows_r); % save rows with rotation value
        peak_face.mean = mean(peak_face_data, 3); % calculate mean
        peak_face_elec   = peak_face.mean(el_idx, :); % get mean for electrode
    
        % calculate peak difference 
        dif_face = peak2peak(peak_face_elec);
        rotation_diff(r,s) = dif_face; % save peak-to-peak difference
        
    end

end 
%% Distribution plots for rotation and distance
% rotation
face = pop_epoch(EEG, {'face'}, [-0.5 1.5]);
histogram([face.event.rotation]);
xlabel("Rotation in degrees");
title("Distribution of Rotation Values for Face Stimuli");

saveas(gca , "Rotation Distribution.jpg")

% distance
face = pop_epoch(EEG, {'face'}, [-0.5 1.5]);
histogram([face.event.distance]);
xlabel("Distance");
title("Distribution of Distance Values for Face Stimuli");

saveas(gca , "Distance Distribution.jpg")

%% Line plot of distance
plot(distance_values, distance_diff)
title('Peak-to-Peak differences with respect to Distance')
xlabel('Distance')
ylabel('Peak-to-Peak Difference')
xlim([0 max(distance_values)+1])

%% Scatter plot of rotation
scatter([1:1:114], rotation_diff)
title('Peak-to-Peak differences with respect to Rotation')
xlabel('Rotation')
ylabel('Peak-to-Peak Difference')
xlim([0 max(rotation_values)+1])


