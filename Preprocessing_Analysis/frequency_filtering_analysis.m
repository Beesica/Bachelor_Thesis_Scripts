%%
clear all; 
close all;
clc; 

%% Online code 
addpath('/MATLAB Drive/EEGLAB');
addpath("EEGLAB/functions/firfilt-master/firfilt-master/");
addpath("EEGLAB/functions/zapline-plus-main/zapline-plus-main/")

eeglab;

uidname = '02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2';
savedata = '/MATLAB Drive/data';

%% 
% load raw data
EEG = pop_loadset(sprintf(['0a_rawChanNames_%s.set'],uidname), savedata);

% import trigger files
trgpath = '/MATLAB Drive/data';
EEG = pop_importevent(EEG, 'event', fullfile(trgpath, strcat('trigger_file_', uidname, '.csv')), 'fields', {'latency', 'type', 'valid', 'rotation','distance','block'}, 'skipline', 1);

%% high pass & low pass filter
% 0.1 Hz high pass filter
% high_pass = .1;
% EEG_high = pop_eegfiltnew(EEG, high_pass, []); % 0.1 is the lower edge

% 0.5 Hz high pass filter
high_pass = .5;
EEG_high = pop_eegfiltnew(EEG, high_pass, []); % 0.5 is the lower edge

% parameters adapted from Czeszumski, 2023 (Hyperscanning Maastricht) 
low_pass = 128;
EEG_high_low = pop_eegfiltnew(EEG_high, [], low_pass); % 128 is the upper edge

% downsample to 512 Hz
EEG_high_low = pop_resample(EEG_high_low, 512);

%% Zapline filter
zaplineConfig=[];
zaplineConfig.noisefreqs='line'; %49.% Today finish 46, 47, 48, 50, 53, 55
97:.01:50.03; %Alternative: 'line'
EEG_high_low_zap = clean_data_with_zapline_plus_eeglab_wrapper(EEG_high_low, zaplineConfig); EEG_high_low.etc.zapline

% remove noise of refresh rate of the glasses (at 90 Hz)
zaplineConfig=[];
zaplineConfig.noisefreqs=89.97:.01:90.03; 
EEG_high_low_zap = clean_data_with_zapline_plus_eeglab_wrapper(EEG_high_low_zap, zaplineConfig); EEG_high_low_zap.etc.zapline

%% face stimuli
% epoch face stimuli
EEG_face = pop_epoch(EEG, {'face'}, [-0.5 1.5]);
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
EEG_object = pop_epoch(EEG, {'object'}, [-0.5 1.5]);
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
EEG_body = pop_epoch(EEG, {'body'}, [-0.5 1.5]);
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
% plot face ERP
plot(EEG_face.times, po8_mean_face, 'DisplayName', forLegend_face)

% set plot specifics
title(sprintf('Mean Activation at %s of participant %s', 'Po8', uidname), 'FontSize', 11);
xlabel('time [ms]');
ylabel('µV');
xticks([-500, -250, 0, 100, 170, 250, 500, 750, 1000, 1500]);
xline(0, 'HandleVisibility','off')
yline(0, 'HandleVisibility','off')
ylim([-20 15])

hold on

% plot object ERP
plot(EEG_object.times, po8_mean_object, 'DisplayName', forLegend_object);

% plot body ERP
plot(EEG_body.times, po8_mean_body, 'DisplayName', forLegend_body)

hold off

legend; % show legend

%% save ERP 
saveas(gca, sprintf('erp_highpass_05_lowpass_zapline_%s.jpg', uidname))