eeglab
%Continous Backprojected Data Merging
% baseline data set
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Walking_Baseline_backproject_continous.set','filepath','C:\\Users\\Zeno\\Desktop\\VRCodesMain\\');
EEG = eeg_checkset( EEG );
EEG.event(end).latency
EEG.event(end).type %Code = 11
myfirstEEGdata = EEG.data;
myfirstEEGevent = EEG.event;
myfirstEEGepoch = EEG.epoch;

% anxiety data set
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Walking_Anxiety_backproject_continous.set','filepath','C:\\Users\\Zeno\\Desktop\\VRCodesMain\\');
EEG = eeg_checkset( EEG );

%EEG.event(end).latency
EEG.event(end).type %Code = 22

% save second dataset
mysecondEEGdata = EEG.data;
mysecondEEGevent = EEG.event;
mysecondEEGepoch = EEG.epoch;
[a1, b1]= size(myfirstEEGdata);
[a2, b2]= size(mysecondEEGdata);

% second dimension is sum of second dimensions for both matrices
tempdata = horzcat(myfirstEEGdata,mysecondEEGdata);
temptime=0:2:((b1+b2-1)*2);
EEG.data = tempdata;
EEG.times= temptime;
EEG.pnts = b1+b2;
for j = 1:size(mysecondEEGevent,2)
    mysecondEEGevent(j).viztick = mysecondEEGevent(j).viztick + myfirstEEGevent(end).viztick;
    mysecondEEGevent(j).latency = 500+mysecondEEGevent(j).latency+ myfirstEEGevent(end).latency;
end
tempevent = horzcat(myfirstEEGevent, mysecondEEGevent);
EEG.event=tempevent;

% save dataset using GUI
s.subj_data_path = 'C:\Users\Zeno\Desktop\VRCodesMain'; % Path of the file
name = 'MergedMatrixBackproject';
EEG = eeg_checkset( EEG );
EEG = pop_editset(EEG, 'setname',name);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',[name '.set'],'filepath',s.subj_data_path);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);