%%
clear all; 
close all;
clc; 

%% Online code 
addpath('/MATLAB Drive/EEGLAB');
addpath("EEGLAB/functions/firfilt-master/firfilt-master/");

eeglab;

savedata = '/MATLAB Drive/data'; % location of data
save = '/MATLAB Drive/Images'; % saving path

%% set parameters
% included participants 
subjects = {'02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; '6a23f1a0-bdeb-4afd-af1c-cd7e607a93e0'; '7afcd75b-9094-4fdf-9e33-70a99439deda'; ...
    '7d4ab496-f88c-4965-9a8f-4aaa9ae50f13'; '7d9620d5-bbd8-4c63-ab0b-72a3e0a0137a'; '50ad9e5b-fb4c-4e3e-92ea-bf422d43d4d6'; ...
    '87c8f5f3-9dc8-481b-821e-7fc676da19f5'; '723c8bc5-7809-4dfc-990c-36de0f544b72'; '41862e7e-bb0d-484c-9149-37175debeff7'; ...
    'a9412d68-6eaf-4a1f-ab61-b2f408ac5b47'; 'dfb99d79-4595-4a0d-b346-23282e000f10'};

% electrode to be plotted
currElec = 'PO7';

%% set up arrays for saving
% use 358 for epoch [-0.2 0.5] and 1024 for epoch [-0.5 1.5]
avg_erps = zeros(length(subjects),1024); % average of all conditions
erps_face = zeros(length(subjects),1024); % face stimuli
erps_body = zeros(length(subjects),1024); % body stimuli
erps_object = zeros(length(subjects),1024); % object stimuli

% save times
subj_time_all = zeros(length(subjects),1024); % average across all conditions
subj_time_face = zeros(length(subjects),1024); % face stimuli
subj_time_body = zeros(length(subjects),1024); % body stimuli
subj_time_object = zeros(length(subjects),1024); % object stimuli

% iterate through each participant
for s = 1:length(subjects)
    % load dataset for participant
    EEG = pop_loadset(sprintf('4a_interpolation_%s.set', char(subjects(s))),fullfile(savedata));
    EEG = eeg_checkset(EEG); % ensure dataset is intact

    %% epoch the data
    EEG_all = pop_epoch(EEG, {}, [-0.5 1.5]);
    forLedgend_all = 'all trials'; % label for plot
    EEG_all = eeg_checkset(EEG_all); % dataset intact
    EEG_all_data = EEG_all.data(:,:,:); % save EEG data separately

    %% Face stimuli
    EEG_face = pop_epoch(EEG, {'face'}, [-0.5 1.5]); % epoch data
    forLedgend_face = 'face trials'; % label for plot 
    EEG_face = eeg_checkset(EEG_face); % dataset intact
    EEG_face_data = EEG_face.data(:,:,:); % save EEG data separately

    %% body stimuli
    EEG_body = pop_epoch(EEG, {'body'}, [-0.5 1.5]); % epoch data
    forLedgend_body = 'body trials';  % label for plot
    EEG_body = eeg_checkset(EEG_body); % dataset intact
    EEG_body_data = EEG_body.data(:,:,:); % EEG data saved separately

    %% object stimuli
    EEG_object = pop_epoch(EEG, {'object'}, [-0.5 1.5]); % epoch data
    forLedgend_object = 'object trials'; % legend for plot
    EEG_object = eeg_checkset(EEG_object); % intact dataset
    EEG_object_data = EEG_object.data(:,:,:); % EEG data saved separately

    %% Select electrode
    el_idx = find(strcmp({EEG_all.chanlocs.labels}, currElec) == 1); % find position of electrode

    %% calculate means at electrode
    EEG_all.mean = mean(EEG_all_data, 3);
    avg_erps(s,:) = EEG_all.mean(el_idx, :);

    % face stimuli
    EEG_face.mean = mean(EEG_face_data, 3);
    erps_face(s,:) = EEG_face.mean(el_idx, :);

    % body stimuli
    EEG_body.mean = mean(EEG_body_data, 3);
    erps_body(s,:) = EEG_body.mean(el_idx, :);

    % object stimuli
    EEG_object.mean = mean(EEG_object_data, 3);
    erps_object(s,:) = EEG_object.mean(el_idx, :);

    %% save EEG times to compare it across subjects (should be same)
    subj_time_all(s,:) = EEG_all.times;
    subj_time_face(s,:) = EEG_face.times;
    subj_time_body(s,:) = EEG_body.times;
    subj_time_object(s,:) = EEG_object.times;

end 

%% plot average ERPs
subjectsCount = string(numel(subjects)); % amount of subjects

figure;

hold on 

% plot average ERP of all conditions
plot(EEG_all.times, mean(avg_erps), 'Color', [0 0.4470 0.7410 1], 'LineWidth', 2.5, 'DisplayName', 'Mean') % mean across all subjects
plot(EEG_all.times, avg_erps, 'Color', [0 0.4470 0.7410 0.2], 'LineWidth', 1, 'DisplayName', 'Avg') % average of every subject 

% set plot parameter
xlabel('Time [ms]');
ylabel('µV');
xticks([-500, -250, 0, 100, 250, 500, 750, 1000, 1500]);

xline(0, 'HandleVisibility','off')
yline(0, 'HandleVisibility','off')

hold off

legend('Mean', 'Average') % show legend

% save plot
cd(save)
saveas(gca, sprintf('grand_average_erp_%s.jpg', currElec))

%%
% plots single conditions 
figure

hold on

% plot average ERP for face, body, and object stimuli
plot(EEG_all.times, mean(erps_face),'Color', [0 0.4470 0.7410], 'DisplayName', 'Face')
plot(EEG_all.times, mean(erps_body), 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'Body')
plot(EEG_all.times, mean(erps_object), 'Color', [0.9290 0.6940 0.1250], 'DisplayName', 'Object')

% set plot parameters
xlabel('Time [ms]');
ylabel('µV');
xticks([-500, -250, 0, 100, 250, 500, 750, 1000, 1500]);
xline(0, 'HandleVisibility','off')
yline(0, 'HandleVisibility','off')

hold off

legend; % show legend

% save average erp
saveas(gca, sprintf('grand_average_erp_%s_conditions.jpg', currElec))
