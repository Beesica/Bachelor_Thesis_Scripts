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

savedata = '/MATLAB Drive/data'; % location of data
save = '/MATLAB Drive/Images'; % saving location

%% set parameters

% included participants 
subjects = {'02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; '6a23f1a0-bdeb-4afd-af1c-cd7e607a93e0'; '7afcd75b-9094-4fdf-9e33-70a99439deda'; ...
    '7d4ab496-f88c-4965-9a8f-4aaa9ae50f13'; '7d9620d5-bbd8-4c63-ab0b-72a3e0a0137a'; '50ad9e5b-fb4c-4e3e-92ea-bf422d43d4d6'; ...
    '87c8f5f3-9dc8-481b-821e-7fc676da19f5'; '723c8bc5-7809-4dfc-990c-36de0f544b72'; '41862e7e-bb0d-484c-9149-37175debeff7'; ...
    'a9412d68-6eaf-4a1f-ab61-b2f408ac5b47'};

% electrode to be plotted
currElec = 'PO8';

% array to track peak-to-peak difference
diff = zeros(length(subjects), 3); % one column per condition

%%
for s = 1:length(subjects) % iterate through subjects

    % load dataset for participant
    EEG = pop_loadset(sprintf('4a_interpolation_%s.set', char(subjects(s))),fullfile(savedata));
    EEG = eeg_checkset(EEG); % dataset intact

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

    % plot(p100.times, p100_elec) % plot time window used to calculate time delay

    %% calculate peak-to-peak difference
    % adjust for time shift of P100
    start = 0.09 - (delay * 0.001);
    ending = 0.18 - (delay * 0.001);

    %% Face stimuli
    peak_face = pop_epoch(EEG, {'face'}, [start ending]); % epoch data
    peak_face = eeg_checkset(peak_face); % intact dataset
    peak_face_data = peak_face.data(:,:,:); % save EEG data separately
    peak_face.mean = mean(peak_face_data, 3); % calculate means
    peak_face_elec = peak_face.mean(el_idx, :); % get mean at electrode

    % find peak-to-peak difference for subject for P100 and N170
    dif_face = peak2peak(peak_face_elec);

    %% body stimuli
    peak_body = pop_epoch(EEG, {'body'}, [start ending]); % epoch data
    peak_body = eeg_checkset(peak_body); % intact dataset
    peak_body_data = peak_body.data(:,:,:); % save EEG data separately
    peak_body.mean = mean(peak_body_data, 3); % calculate means
    peak_body_elec   = peak_body.mean(el_idx, :); % get mean at electrode

    % find peak-to-peak difference for subject for P100 and N170
    dif_body = peak2peak(peak_body_elec);

    %% object stimuli
    peak_object = pop_epoch(EEG, {'object'}, [start ending]); % epoch data
    peak_object = eeg_checkset(peak_object); % intact dataset
    peak_object_data = peak_object.data(:,:,:); % save EEG data separately
    peak_object.mean = mean(peak_object_data, 3); % calculate means
    peak_object_elec   = peak_object.mean(el_idx, :); % get mean at electrode

    % find peak-to-peak difference for subject for P100 and N170
    dif_object = peak2peak(peak_object_elec);

    % plot(peak_face.times, peak_face_elec) % plot time window used for peak2peak difference

    %% save difference values
    diff(s,1) = dif_face;
    diff(s,2) = dif_body;
    diff(s,3) = dif_object;

end

%% plot boxplots for difference
difference = array2table(diff, 'VariableNames', {'face', 'body', 'object'}); % transfer array to table to get column headings

boxchart(diff) % plot boxplot

% set plot parameters
xticklabels({'face', 'body', 'object'})
ylabel('Peak-to-Peak Difference')
title('Peak-to-Peak Difference between Categories')
