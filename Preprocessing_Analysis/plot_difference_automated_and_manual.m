%%
clear all; 
close all;
clc; 

%% Online code 
addpath('/MATLAB Drive/EEGLAB');
addpath('/MATLAB Drive/Scripts');
addpath("EEGLAB/functions/firfilt-master/firfilt-master/");
addpath("EEGLAB/functions/zapline-plus-main/zapline-plus-main/")
addpath("EEGLAB/functions/clean_rawdata/")
addpath("EEGLAB/plugins/amica/")
addpath("EEGLAB/plugins/ICLabel1.6/")
addpath("EEGLAB/plugins/preprocessing_helpers/")

savedata = '/MATLAB Drive/data'; % location for automated preprocessed files 
save = '/MATLAB Drive'; % location for manually preprocessed files

eeglab;

% subject IDs
subjects = {'02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; '6a23f1a0-bdeb-4afd-af1c-cd7e607a93e0'; '7afcd75b-9094-4fdf-9e33-70a99439deda'; ...
    '7d4ab496-f88c-4965-9a8f-4aaa9ae50f13';  '50ad9e5b-fb4c-4e3e-92ea-bf422d43d4d6'; ...
    '87c8f5f3-9dc8-481b-821e-7fc676da19f5'; '723c8bc5-7809-4dfc-990c-36de0f544b72'; '41862e7e-bb0d-484c-9149-37175debeff7'; ...
    'a9412d68-6eaf-4a1f-ab61-b2f408ac5b47'; 'dfb99d79-4595-4a0d-b346-23282e000f10'};

% set electrode for plotting
curElec = 'PO7';

for s = 1:length(subjects)
    % load manual and automated preprocessed data
    EEG = pop_loadset(sprintf('4a_interpolation_%s.set',char(subjects(s))),fullfile(savedata)); % automated
    EEG2 = pop_loadset(sprintf('7_%s_RerefInterp.set',char(subjects(s))),fullfile(save)); % manual

    %% Epoch Automated Preprocessed Data
    % get epochs
    EEG_auto = pop_epoch(EEG, {}, [-0.5 1.5]);
    EEG_auto = eeg_checkset(EEG_auto); % ensure intact dataset

    % store EEG data separately
    EEG_auto_data = EEG_auto.data(:,:,:); 
    
    % calculate the mean of all the trials
    EEG_auto.mean = mean(EEG_auto_data, 3);
    
    % find index of specified electrode
    elec_idx = find(strcmp({EEG_auto.chanlocs.labels}, curElec) == 1);
    
    % get mean of electrode
    elec_mean_auto = EEG_auto.mean(elec_idx, :);

    %% Epoch Manually Preprocessed Data 
    % get epochs 
    EEG_manu = pop_epoch(EEG2, {}, [-0.5 1.5]);
    EEG_manu = eeg_checkset(EEG_manu); % ensure intact data

    % store EEG Data separetly
    EEG_manu_data = EEG_manu.data(:,:,:); 
    
    % calculate the mean of all the trials
    EEG_manu.mean = mean(EEG_manu_data, 3);
    
    % find index of specified electrode
    elec_idx = find(strcmp({EEG_manu.chanlocs.labels}, curElec) == 1);
    
    % get mean at electrode
    elec_mean_manu = EEG_manu.mean(elec_idx, :); 

    %% plot ERP for manual and automated data & difference curve
   
    % plot automated data
    plot(EEG_auto.times, elec_mean_auto, 'DisplayName', 'Automated', 'LineWidth', 2)

    % set plot specifics
    title(sprintf('Mean Activation at %s of participant %s', curElec, char(subjects(s))), 'FontSize', 11);
    xlabel('time [ms]');
    xticks([-500, -250, 0, 100, 170, 250, 500, 750, 1000, 1500]);
    xline(0, 'HandleVisibility','off')
    ylabel('µV');
    yline(0, 'HandleVisibility','off')
    

    hold on
    % plot manual data
    plot(EEG_manu.times, elec_mean_manu, 'DisplayName', 'Manual', 'LineWidth', 2)

    % plot difference curve
    plot(EEG_manu.times, (elec_mean_auto - elec_mean_manu), 'DisplayName', 'Difference', 'Color', 'k')

    hold off

    legend; % display legend
    
    %% save plot
    saveas(gca, sprintf('Difference_%s_%s.jpg', curElec, char(subjects(s))))

end

