%%
clear all; 
close all;
clc; 
%% 
savepath = 'F:/Bachelor Thesis_';
addpath('F:/Bachelor Thesis_');
addpath('F:/Bachelor Thesis_/Analysis');
addpath('F:/Bachelor Thesis_/Matlab/eeglab2024.0');
addpath('F:/Bachelor Thesis_/Matlab/');
addpath('F:/Bachelor Thesis_/preprocessed/')
addpath('F:/Bachelor Thesis_/Debbie/')

% load EEGlab
eeglab;

basepath = 'F:/Bachelor Thesis_/AA_Jessica/';
cd(basepath);

%% 
uidname = '7d9620d5-bbd8-4c63-ab0b-72a3e0a0137a'; % participant ID

ymin = -8; % minimum of y-axis for ERP plot
ymax = 10; % maximum of y-axis for ERP plot

% saving path of automated and manually preprocessed data
mpath = ['F:/Bachelor Thesis_/preprocessed/', uidname, '/'];
apath = ['F:/Bachelor Thesis_/AA_Jessica/', uidname,'/automated_preproc/'];

%% 
% file names for automated preprocessing
files =  {'1a_triggersFiltering_%s', '2a_cleanDataChannels_%s', '2a_cleanDataChannels_woRejection_%s', '3a_ICA_%s', '4a_interpolation_%s'};

% iterate through each of the files
for step = 1:length(files)
    
    % load the data file
    file = append(files{step}, '.set');
    EEG = pop_loadset(sprintf(file,uidname), apath);

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
    ylim([ymin ymax])

    hold on

    % plot object ERP
    plot(EEG_object.times, po8_mean_object, 'DisplayName', forLegend_object);

    % plot body ERP
    plot(EEG_body.times, po8_mean_body, 'DisplayName', forLegend_body)

    hold off

    legend; % show legend

    %% save plot
    cd([basepath, 'ERPs_for_each_participant/', uidname, '/Step_by_Step/']);

    % save ERP
    pic = append(files{step}, '.jpg');
    saveas(gca, sprintf(pic, uidname));

end 


%% 
% file names for manual preprocessing
files = {'2_%s_bandpass_resample_deblank', '3_%s_channelrejTriggersXensor', '4_%s_Clean', '5_%s_ICAEpoched', '6_%s_ICAcleancont', '7_%s_RerefInterp'};

for step = 1:length(files)
    % loading the file
    file = append(files{step}, '.set');
    EEG = pop_loadset(sprintf(file,uidname), mpath);

    %% Plot ICAepoched (has different data boundaries)
    if strcmp(files{step}, '5_%s_ICAEpoched')
        %% face stimuli
        % get epochs for face stimuli
        EEG_face = pop_epoch(EEG, {'face'}, [-0.1 0.398]);
        EEG_face = eeg_checkset(EEG_face); % make sure dataset is intact
        forLegend_face = 'face'; % save condition name for plot labels
    
        % save EEG data separetly 
        EEG_face_data = EEG_face.data(:,:,:); 
        
        % calculate the mean of all the trials
        EEG_face.mean = mean(EEG_face_data, 3);
        
        % find index of PO8 electrode
        po8_idx = find(strcmp({EEG_face.chanlocs.labels}, 'PO8') == 1); 
        
        % get mean at electrode PO8
        po8_mean_face = EEG_face.mean(po8_idx, :); 
    
        %% object stimuli
        % epoch object stimuli
        EEG_object = pop_epoch(EEG, {'object'}, [-0.1 0.398]); 
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
   
        %% body stimuli
        % get epochs of body stimuli
        EEG_body = pop_epoch(EEG, {'body'}, [-0.1 0.398]);
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
        ylim([ymin ymax])
        
        hold on
        
        % plot object ERP
        plot(EEG_object.times, po8_mean_object, 'DisplayName', forLegend_object);
        
        % plot body ERP
        plot(EEG_body.times, po8_mean_body, 'DisplayName', forLegend_body)
        
        hold off
        
        legend; % show legend
    
    else 
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
        ylim([ymin ymax])
        
        hold on
        
        % plot object ERP
        plot(EEG_object.times, po8_mean_object, 'DisplayName', forLegend_object);
        
        % plot body ERP
        plot(EEG_body.times, po8_mean_body, 'DisplayName', forLegend_body)
        
        hold off
        
        legend; % show legend
    end 

    %% save plot
    cd([basepath, 'ERPs_for_each_participant/', uidname, '/Step_by_Step/']);

    pic = append(files{step}, '.jpg');
    saveas(gca, sprintf(pic, uidname))

end