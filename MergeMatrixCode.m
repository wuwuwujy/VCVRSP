eeglab
% baseline data set
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Walking_Baseline_epoch.set','filepath','C:\\Users\\Public\\Documents\\VRCodesMain\\');
EEG = eeg_checkset( EEG );
EEG.event(end).latency
EEG.event(end).type %Code = 11
myfirstEEGdata = EEG.data;
myfirstEEGevent = EEG.event;
myfirstEEGepoch = EEG.epoch;

% anxiety data set
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Walking_Anxiety_epoch.set','filepath','C:\\Users\\Public\\Documents\\VRCodesMain\\');
EEG = eeg_checkset( EEG );

%EEG.event(end).latency
EEG.event(end).type %Code = 22

% save second dataset
mysecondEEGdata = EEG.data;
mysecondEEGevent = EEG.event;
mysecondEEGepoch = EEG.epoch;
[a1, b1, c1]= size(myfirstEEGdata);
[a2, b2, c2]= size(mysecondEEGdata);

% third dimension is sum of third dimensions for both matrices
tempdata = zeros(a1,b1,c1+c2);
for i = 1:a1
   tempdata(i,:,:) = horzcat(squeeze(myfirstEEGdata(i,:,:)),squeeze(mysecondEEGdata(i,:,:)));    
end
EEG.data = tempdata;
EEG.trials = c1+c2;

for j = 1:size(mysecondEEGevent,2)
    mysecondEEGevent(j).epoch = mysecondEEGevent(j).epoch + myfirstEEGevent(end).epoch;
    mysecondEEGevent(j).viztick = mysecondEEGevent(j).viztick + myfirstEEGevent(end).viztick;
    mysecondEEGevent(j).latency = 500+mysecondEEGevent(j).latency-1 + myfirstEEGevent(end).latency;
end
tempevent = horzcat(myfirstEEGevent, mysecondEEGevent);
EEG.event=tempevent;

% modify epoch latency, and also epoch number
for j = 1:size(mysecondEEGepoch,2)-1
    mysecondEEGepoch(j).event = mysecondEEGepoch(j).event + myfirstEEGepoch(end).event;
    mysecondEEGepoch(j).eventviztick{1} = mysecondEEGepoch(j).eventviztick{1} + myfirstEEGepoch(end).eventviztick{1};
    mysecondEEGepoch(j).eventviztick{2} = mysecondEEGepoch(j).eventviztick{2} + myfirstEEGepoch(end).eventviztick{1};
end

% concatenate epochs
tempepoch = horzcat(myfirstEEGepoch, mysecondEEGepoch);
tempepoch(end).event = mysecondEEGepoch(end).event + myfirstEEGepoch(end).event;
tempepoch(end).eventviztick{1} = mysecondEEGepoch(end).eventviztick{1} + myfirstEEGepoch(end).eventviztick{1};
EEG.epoch = tempepoch;
% save dataset using GUI
s.subj_data_path = 'C:\Users\Public\Documents\VRCodesMain'; % Path of the file
name = 'MergedMatrix';
save_dataset;