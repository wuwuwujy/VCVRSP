eeglab
% baseline
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Walking_Baseline_epoch.set','filepath','C:\\Users\\Public\\Documents\\Walking_Baseline\\');
EEG = eeg_checkset( EEG );

EEG.event(end).latency
EEG.event(end).type

myfirstEEGdata = EEG.data;
myfirstEEGevent = EEG.event;
myfirstEEGepoch = EEG.epoch;


% open second data set using GUI

% anxiety
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Walking_Anxiety_epoch.set','filepath','C:\\Users\\Public\\Documents\\Walking_Anxiety_Vivek\\');
EEG = eeg_checkset( EEG );

%EEG.event(end).latency
EEG.event(end).type

% save second dataset
mysecondEEGdata = EEG.data;
mysecondEEGevent = EEG.event;
mysecondEEGepoch = EEG.epoch;
 

% cycle through epochs - and 

% trials needs to be updated

size(myfirstEEGdata)
size(mysecondEEGdata)

% third dimension is sum of third dimensions for both matrices
tempdata = zeros(63,500,125);

for i = 1:63
   tempdata(i,:,:) = horzcat(squeeze(myfirstEEGdata(i,:,:)),squeeze(mysecondEEGdata(i,:,:)));    
end

EEG.data = tempdata;
EEG.trials = 125;

% modify epoch latency, and also epoch number
for j = 1:size(mysecondEEGepoch,2)-1
    mysecondEEGepoch(j).event = mysecondEEGepoch(j).event + myfirstEEGepoch(end).event;
end

% concatenate epochs
tempepoch = horzcat(myfirstEEGepoch, mysecondEEGepoch);
tempepoch(end).event = mysecondEEGepoch(end).event + myfirstEEGepoch(end).event;

EEG.epoch = tempepoch;

% save dataset using GUI



