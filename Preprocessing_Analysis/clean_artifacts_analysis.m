%%
clear all; 
close all;
clc; 

%%  
addpath('/MATLAB Drive/EEGLAB');
addpath('/MATLAB Drive/Scripts');
addpath("EEGLAB/functions/clean_rawdata/")

eeglab; % load EEGLAB

data = '/MATLAB Drive/data';
save = '/MATLAB Drive/Images';
uidname = '02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; % subject ID
%%
% use these to modify clean_artifacts parameter 
burst = 20; 
rejection = 'on'; 
highpass = 'off'; 

%% load data file
EEG = pop_loadset(sprintf('1a_triggersFiltering_%s.set',uidname),fullfile(data)); % data is filtered with 0.1 Hz highpass filter, 128 Hz lowpass filter, & zapline filter (50 Hz, 90 Hz)

%% Data Cleaning
clean = pop_reref(EEG, []); % ensure average reference

% data cleaning
clean = clean_artifacts(clean, 'BurstCriterion', burst, 'BurstRejection', rejection, 'Highpass', highpass); 

% interpolate missing channels
clean = pop_reref(clean, [], 'interpchan', []);

% visualization of cleaned data
vis_artifacts(clean, EEG);

% save first segment
cd(save)
saveas(gca, sprintf('segment_clean_artifacts_BurstCri_%d_BurstRej_%s_Highpass_%s_%s.jpg', burst, rejection, num2str(highpass), uidname))

%% face stimuli
% epoch face stimuli
EEG_face = pop_epoch(clean, {'face'}, [-0.5 1.5]);
EEG_face = eeg_checkset(EEG_face); % ensure that dataset is intact
forLegend_face = 'face'; % save condition name for plot legend

% save data of EEG separately
EEG_face_data = EEG_face.data(:,:,:); 

% calculate the mean of all the trials
EEG_face.mean = mean(EEG_face_data, 3);

% find index of PO8 electrode
po8_idx = find(strcmp({EEG_face.chanlocs.labels}, 'PO8') == 1);

% get mean for electrode PO8
po8_mean_face = EEG_face.mean(po8_idx, :);

%% object stimuli
% epoch object stimuli
EEG_object = pop_epoch(clean, {'object'}, [-0.5 1.5]);
EEG_object = eeg_checkset(EEG_object); % ensure that dataset is intact
forLegend_object = 'object'; % save condition name for plot legend

% save data of EEG separately
EEG_object_data = EEG_object.data(:,:,:); 

% calculate the mean of all the trials
EEG_object.mean = mean(EEG_object_data, 3);

% find index of PO8 electrode
po8_idx = find(strcmp({EEG_object.chanlocs.labels}, 'PO8') == 1);

% get mean for electrode PO8
po8_mean_object = EEG_object.mean(po8_idx, :);

%% Body Stimuli
% epoch body stimuli
EEG_body = pop_epoch(clean, {'body'}, [-0.5 1.5]);
EEG_body = eeg_checkset(EEG_body); % ensure dataset is intact
forLegend_body = 'body'; % save condition name for the plot legend

% save EEG data separately 
EEG_body_data = EEG_body.data(:,:,:); 

% calculate the mean of all the trials
EEG_body.mean = mean(EEG_body_data, 3);

% find index of PO8 electrode
po8_idx = find(strcmp({EEG_body.chanlocs.labels}, 'PO8') == 1);

% get mean of data for electrode PO8
po8_mean_body = EEG_body.mean(po8_idx, :);

%% plot ERP for all stimuli
figure;

% plot face ERP
plot(EEG_face.times, po8_mean_face, 'DisplayName', forLegend_face)

% set plot specifics
xlabel('time [ms]');
ylabel('µV');
xticks([-500, -250, 0, 100, 250, 500, 750, 1000, 1500]);
xline(0, 'HandleVisibility','off')
yline(0, 'HandleVisibility','off')

hold on

% plot object ERP
plot(EEG_object.times, po8_mean_object, 'DisplayName', forLegend_object);

% plot body ERP
plot(EEG_body.times, po8_mean_body, 'DisplayName', forLegend_body)

hold off

legend; % show legend

%% save ERP 
cd(save)
saveas(gca, sprintf('erp_clean_artifacts_BurstCri_%d_BurstRej_%s_Highpass_%s_%s.jpg', burst, rejection, num2str(highpass), uidname))
