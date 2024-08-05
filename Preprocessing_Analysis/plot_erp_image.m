%%
clear all; 
close all;
clc; 

%% Online code 
addpath('/MATLAB Drive/EEGLAB');
addpath("EEGLAB/functions/firfilt-master/firfilt-master/");

eeglab;

savedata = '/MATLAB Drive/data';
save = '/MATLAB Drive/Images';

%% 
% included participants 
subjects = {'02c5e2dc-2cd8-4d48-9d4e-16d55a8fe6d2'; '6a23f1a0-bdeb-4afd-af1c-cd7e607a93e0'; '7afcd75b-9094-4fdf-9e33-70a99439deda'; ...
    '7d4ab496-f88c-4965-9a8f-4aaa9ae50f13'; '7d9620d5-bbd8-4c63-ab0b-72a3e0a0137a'; '50ad9e5b-fb4c-4e3e-92ea-bf422d43d4d6'; ...
    '87c8f5f3-9dc8-481b-821e-7fc676da19f5'; '723c8bc5-7809-4dfc-990c-36de0f544b72'; '41862e7e-bb0d-484c-9149-37175debeff7'; ...
    'a9412d68-6eaf-4a1f-ab61-b2f408ac5b47'; 'dfb99d79-4595-4a0d-b346-23282e000f10'};

% excluded participant
% subjects = {'68f235ce-7948-4d1d-b50f-85dbbbf4c506'; '944be082-2674-42b2-9f50-7849d9e14946'; 'c304049a-99c5-4184-abd1-ba2178c5e1e6'; ...
%     'ed990ae1-f2e6-4e25-b6c1-e596181c248a'; 'f8780dc1-6310-4759-9d7b-a59548ab6397'};

for s = 1:length(subjects)
     
    % load final data file for participant
    EEG = pop_loadset(sprintf(['4a_interpolation_%s.set'], char(subjects(s))), savedata);

    % epoch data 
    EEG = pop_epoch(EEG, {}, [-0.5 1.5]);

    %% plot ERP image
    erp = figure;
    erpimage(mean(EEG.data([64], :),1), ones(1, EEG.trials)*EEG.xmax*1000, linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts), 'PO8', 10, 1 ,'yerplabel','\muV','erp','on','cbar','on','topo', { [64] EEG.chanlocs EEG.chaninfo } );

    %% save ERP image
    cd(save)
    saveas(erp ,sprintf('erpimage_%s.jpg', char(subjects(s))),'jpg')
end 
