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
rotation_diff = zeros(44, length(subjects));

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
    for r = 1:length(rotation_values) % maximum rotation value is 114
        current_r = rotation_values(r); % get current rotation value
        % get rows with specific rotation value
        rows_r = arrayfun(@(x) x.('rotation') == current_r , event_face);
    
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
figure

% rotation
face = pop_epoch(EEG, {'face'}, [-0.5 1.5]);
histogram([face.event.rotation]);
set(gca, 'FontSize', 16)
xlabel("Rotation [degree]");
ylabel("Count")
xlim([0 120])

% save plot
cd(save)
saveas(gca , "Rotation_Distribution.jpg")

figure

% distance
face = pop_epoch(EEG, {'face'}, [-0.5 1.5]);
histogram([face.event.distance]);
set(gca, 'FontSize', 16)
xlabel("Distance [Unity Units]");
ylabel("Count")

% save plot
cd(save)
saveas(gca , "Distance_Distribution.jpg")

%% Line plot of distance
figure

hold on

distance_diff_mean = mean(distance_diff, 2); % Calculate mean across subjects

p = polyfit(distance_values, distance_diff_mean, 1); % Fit linear function to mean values
yfit = polyval(p, distance_values); % Evaluate the polynomial

plot(distance_values, distance_diff, 'LineWidth', 1) % plot line plot
plot(distance_values, yfit, '--', 'Color',['k'], 'LineWidth', 1.5); % Plot the regression line

% set plot specifications
xlabel('Distance [Unity Units]')
ylabel('Peak-to-Peak Difference [µV]')
ylim([0 28])

hold off

% Get handle of the current axis
ax = gca;

% adjust x-axis label
xlabelHandle = ax.XLabel;
xlabelHandle.Position = xlabelHandle.Position + [0, 0, 0]; % Adjust the second value to move further away

% adjust y-axis label
ylabelHandle = ax.YLabel;
ylabelHandle.Position = ylabelHandle.Position + [0, 0, 0];

% save plot
cd(save)
saveas(gca, 'Distance_peak2peak.jpg')

%% Scatter plot of rotation
figure;

hold on; 

rotation_diff_mean = mean(rotation_diff, 2); % Calculate mean across subjects

p = polyfit(rotation_values, rotation_diff_mean, 1); % Fit linear function to mean values
yfit = polyval(p, rotation_values); % Evaluate the polynomial

% plot scatter plots for all subjects
for i = 1:9
    scatter(rotation_values, rotation_diff(:, i), 'filled', 'HandleVisibility', 'off', 'SizeData',10);
end

plot(rotation_values, yfit, '--', 'Color',['k'], 'LineWidth', 1.5); % Plot the regression line

hold off;

% customize plot
xlabel('Rotation [degree]')
ylabel('Peak-to-Peak Difference [µV]')
xlim([-1 max(rotation_values)+1])

% Get handle of the current axis
ax = gca;

% adjust x-axis label
xlabelHandle = ax.XLabel;
xlabelHandle.Position = xlabelHandle.Position + [0, 0, 0]; % Adjust the second value to move further away

% adjust y-axis label
ylabelHandle = ax.YLabel;
ylabelHandle.Position = ylabelHandle.Position + [0, 0, 0];

% save plot
cd(save)
saveas(gca, 'Rotation_peak2peak.jpg')
