%%
clear all; 
close all;
clc; 

%% Online code 
addpath('/MATLAB Drive/EEGLAB');
addpath("EEGLAB/functions/firfilt-master/firfilt-master/");

eeglab;

savedata = '/MATLAB Drive/data'; % location of preprocessed files 
save = '/MATLAB Drive/Images'; % saving location

%% set parameters
% included participants 
subjects = {'02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; '6a23f1a0-bdeb-4afd-af1c-cd7e607a93e0'; '7afcd75b-9094-4fdf-9e33-70a99439deda'; ...
    '7d4ab496-f88c-4965-9a8f-4aaa9ae50f13'; '7d9620d5-bbd8-4c63-ab0b-72a3e0a0137a'; '50ad9e5b-fb4c-4e3e-92ea-bf422d43d4d6'; ...
    '87c8f5f3-9dc8-481b-821e-7fc676da19f5'; '723c8bc5-7809-4dfc-990c-36de0f544b72'; '41862e7e-bb0d-484c-9149-37175debeff7'; ...
    'a9412d68-6eaf-4a1f-ab61-b2f408ac5b47'; 'dfb99d79-4595-4a0d-b346-23282e000f10'};

electrodes = {'PO8'; 'P8'; 'PO7'; 'P7'}; % electrodes

for s = 1:length(subjects)
    %% set up arrays for saving
    % use 358 for epoch [-0.2 0.5] and 1024 for epoch [-0.5 1.5]
    avg_erp_auto = zeros(length(electrodes),1024); % for automated preprocessed data
    avg_erp_manu = zeros(length(electrodes),1024); % for manually preprocessed data
    
    subj_time_auto = zeros(length(electrodes),1024);
    subj_time_manu = zeros(length(electrodes),1024);
    
    % get erps for each of the subjects
    for elec = 1:length(electrodes)
        % load datasets of participant
        EEG = pop_loadset(sprintf('4a_interpolation_%s.set', char(subjects(s))),fullfile(savedata));
        EEG = eeg_checkset(EEG); % ensure that dataset is intact
    
        EEG2 = pop_loadset(sprintf('7_%s_RerefInterp.set',char(subjects(s))),fullfile(savedata)); 
        EEG2 = eeg_checkset(EEG2); % ensure that dataset is intact
    
        %% epoch the data
        EEG_auto = pop_epoch(EEG, {}, [-0.5 1.5]); % epoch automated data
        EEG_auto = eeg_checkset(EEG_auto); % ensure dataset is intact
        EEG_auto_data = EEG_auto.data(:,:,:); % save EEG data separetely
    
        EEG_manu = pop_epoch(EEG2, {}, [-0.5 1.5]); % epoch manual data
        EEG_manu = eeg_checkset(EEG_manu); % ensure intact dataset
        EEG_manu_data = EEG_manu.data(:,:,:); % save EEG data separetly
    
        %% Select electrode
        el_idx = find(strcmp({EEG_auto.chanlocs.labels}, char(electrodes(elec))) == 1);
        el_idx2 = find(strcmp({EEG_manu.chanlocs.labels}, char(electrodes(elec))) == 1);
    
        %% calculate mean 
        EEG_auto.mean = mean(EEG_auto_data, 3); % calculate mean of data
        avg_erp_auto(s,:)   = EEG_auto.mean(el_idx, :); % save mean of specific electrode
    
        EEG_manu.mean = mean(EEG_manu_data, 3); % calculate mean of data
        avg_erp_manu(s,:)   = EEG_manu.mean(el_idx2, :); % save mean of specific electrode
        %% save EEG times to compare it across subjects (should be same)
        subj_time_auto(s,:) = EEG_auto.times;
        subj_time_manu(s,:) = EEG_manu.times;
    
    end 
    
    %% plot ERPs & difference curve
    figure;
    
    hold on 

    % plot automated data
    plot(EEG_auto.times, mean(avg_erps), 'Color', [0 0.4470 0.7410 1], 'DisplayName', 'Automated')

    % plot manual data
    plot(EEG_manu.times, mean(avg_erps2), 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'Manual')

    % plot difference curve
    plot(EEG_auto.times, (mean(avg_erp_autos) - mean(avg_erp_autos2)), '--', 'DisplayName', 'Difference', 'Color', 'k')
    
    % set plot parameter
    xlabel('Time [ms]');
    ylabel('µV');
    yline(0, 'HandleVisibility','off');
    xline(0, 'HandleVisibility','off')
    xticks([-500, -250, 0, 100, 250, 500, 750, 1000, 1500]);
    
    legend() % show legend
    
    %% save plot
    cd(save)
    saveas(gca ,sprintf('mean_erp_4_elec_%s.jpg', char(subjects(s))))
    
end
