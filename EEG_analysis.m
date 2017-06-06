function EEG_analysis()
%Loading dataset
addpath('C:\Users\Public\Documents\eeglab14_0_0b\')  %Path to the EEG Toolbox
eeglab                 % To start EEGLab
s.subj_data_path = 'C:\Users\Public\Documents\Walking_Baseline'; % Path of the file
fname = 'eeg_walking'; %File name
EEG = pop_loadbv('C:\Users\Public\Documents\Walking_Baseline', [fname '.vhdr'], [], [1:20,22:64]); %Loading .vhdr the file  
%Ignoring the ground channel 21
ALLEEG=[]
[ALLEEG EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',fname,'gui','off'); 
redraw()

%Filtering
name = 'Walking_Baseline';
EEG = pop_eegfilt(EEG,1,0,[],0,'fir1'); %Filtering data using FIR Least Squares filter
EEG = eeg_checkset(EEG); %Checks the consistecy of fields of EEG Data Set
EEG = pop_eegfilt(EEG,0,55,[],0,'fir1');
redraw()

%Epoch Events
name = 'Walking_Baseline_eventchan';
epoch_no = floor(EEG.pnts/EEG.srate); %Latency rate/Sampling rate
eventRecAll = [];

% Looping through EC trials
for event_i = 1:(epoch_no-1)
    eventRecTemp = [1 event_i-1 (event_i-1)*500];
    eventRecAll = [eventRecAll; eventRecTemp]; %Matrix with 3 columns, all 1s, Event No., Latency 
end

%New Event Structure values as matrix 'eventRecAll' values 
 for nx = 1:length(eventRecAll)
      EEG.newevent(nx) = struct('latency',eventRecAll(nx,3),'type',eventRecAll(nx,1),'viztick',eventRecAll(nx,2));
 end

%Saving new event
EEG.oldevent = EEG.event;
EEG.event = [];
EEG.event = EEG.newevent;
redraw()

%Epoching
name = 'Walking_Baseline_epoch';
codes = {'1'};
epochend = 1.0; %Time window = 0 to 1 sec = 1000 millisec
EEG = pop_epoch( EEG, codes, [0  epochend],'newname', name, 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[s.subj_data_path '/' name '.set'],'gui','off'); 
EEG = eeg_checkset( EEG ); %Checking consistency
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); %Storing
EEG = eeg_checkset( EEG ); %Again check for consistency
redraw()

% Epoch rejection 
REJECTION_CRITERION = 6;    % 6 standard deviations, both within and across channels
REJECTION_CHANNELS  = 1:61; % only EEG data channels, not viztick!
EEG = pop_jointprob(EEG,1,REJECTION_CHANNELS, REJECTION_CRITERION, REJECTION_CRITERION, 1, 0);
%Rejects artifacts based on Joint probability of component activities at each time point
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%Stores EEG dataset to ALLEEG variable containg all current datasets after checking consistency
EEG = pop_rejkurt(EEG,1,REJECTION_CHANNELS , REJECTION_CRITERION, REJECTION_CRITERION, 1, 0);
%Rejects Outliers using Kurtosis
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
save_dataset;
redraw()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MANUAL EPOCH REJECTION
%       GUI: tools --> Reject data epochs --> reject data (all methods)
%       Run the manual rejection (Mark trials by appearance: Scroll data)
%       --> Close (keep marks)
% be sure to delete last few epochs if noisy.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Collecting all 3 Epoch rejections and sorting in one
rejected.kurtos = find(EEG.reject.rejkurt    ~= 0); %Kurtosis Rejections
rejected.prob   = find(EEG.reject.rejjp      ~= 0); %Joint Probability Rejections
rejected.manual = find(EEG.reject.rejmanual  ~= 0); %Manual Rejections
rejected.all = sort([rejected.kurtos, rejected.manual, rejected.prob],'ascend');
EEG.rejected = rejected;
str = ['save ' s.subj_data_path 'rejected.mat rejected']; eval(str);

%Saving the Pre ICA file with rejections being removed
name = 'Walking_Baseline_preICA';
EEG.saved = 'no';
EEG = eeg_checkset( EEG ); %Checking consistency of dataset
EEG.comments = pop_comments('', '', strvcat(['Parent dataset: ' name], 'epochs selected', ' '));
EEG = pop_saveset( EEG, 'savemode', 'resave');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
save_dataset;

%Removing all rejected componenets and saving the dataset as Pre ICA dataset
EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
% Superpose rejections of dataset using all parameters
EEG = pop_rejepoch( EEG, EEG.rejected.all ,0);
% Reject pre labelled trails (i.e the sorted array of all rejected components)
name = 'Walking_Baseline_preICA';
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', name, 'savenew', [name '.set'], ...
    'overwrite','on','gui','off'); 
redraw()

%Loading Electrodes file
s.elocs_file = [s.subj_data_path '/MFPRL_default.sfp'];

%From MFPRL_default.sfp file, changing the channel names to channel no.s
EEG=pop_chanedit(EEG,'changefield',{1 'labels' 'Fp1'},'changefield',{2 'labels' 'Fz'},...
    'changefield',{3 'labels' 'F3'},'changefield',{4 'labels' 'F7'},...
    'changefield',{5 'labels' 'LHEye'},'changefield',{6 'labels' 'FC5'},...
    'changefield',{7 'labels' 'FC1'},'changefield',{8 'labels' 'C3'},...
    'changefield',{9 'labels' 'T7'},'changefield',{10 'labels' 'GND'},... % CHANGE GND TO FPZ
    'changefield',{11 'labels' 'CP5'},'changefield',{12 'labels' 'CP1'},...
    'changefield',{13 'labels' 'Pz'},'changefield',{14 'labels' 'P3'},...
    'changefield',{15 'labels' 'P7'},'changefield',{16 'labels' 'O1'},...
    'changefield',{17 'labels' 'Oz'},'changefield',{18 'labels' 'O2'},...
    'changefield',{19 'labels' 'P4'},'changefield',{20 'labels' 'P8'},...
    'changefield',{21 'labels' 'CP6'},'changefield',{22 'labels' 'CP2'},...
    'changefield',{23 'labels' 'Cz'},'changefield',{24 'labels' 'C4'},...
    'changefield',{25 'labels' 'T8'},'changefield',{26 'labels' 'RHEye'},...
    'changefield',{27 'labels' 'FC6'},'changefield',{28 'labels' 'FC2'},...
    'changefield',{29 'labels' 'F4'},'changefield',{30 'labels' 'F8'},...
    'changefield',{31 'labels' 'Fp2'},'changefield',{32 'labels' 'AF7'},...
    'changefield',{33 'labels' 'AF3'},'changefield',{34 'labels' 'AFz'},...
    'changefield',{35 'labels' 'F1'},'changefield',{36 'labels' 'F5'},...
    'changefield',{37 'labels' 'FT7'},'changefield',{38 'labels' 'FC3'},...
    'changefield',{39 'labels' 'FCz'},'changefield',{40 'labels' 'C1'},...
    'changefield',{41 'labels' 'C5'},'changefield',{42 'labels' 'TP7'},...
    'changefield',{43 'labels' 'CP3'},'changefield',{44 'labels' 'P1'},...
    'changefield',{45 'labels' 'P5'},'changefield',{46 'labels' 'Lneck'},...
    'changefield',{47 'labels' 'PO3'},'changefield',{48 'labels' 'POz'},...
    'changefield',{49 'labels' 'PO4'},'changefield',{50 'labels' 'Rneck'},...
    'changefield',{51 'labels' 'P6'},'changefield',{52 'labels' 'P2'},...
    'changefield',{53 'labels' 'CPz'},'changefield',{54 'labels' 'CP4'},...
    'changefield',{55 'labels' 'TP8'},'changefield',{56 'labels' 'C6'},...
    'changefield',{57 'labels' 'C2'},'changefield',{58 'labels' 'FC4'},...
    'changefield',{59 'labels' 'FT8'},'changefield',{60 'labels' 'F6'},...
    'changefield',{61 'labels' 'F2'},'changefield',{62 'labels' 'AF4'},...
    'changefield',{63 'labels' 'RVEye'});

%Changing channel location structure in EEG dataset using the file <MFPRL_default.sfp>
EEG=pop_chanedit(EEG, 'lookup', s.elocs_file);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
redraw()
eeg_checkset(EEG);
%Checking consistency and saving the data
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',name,...
    'savenew',[s.subj_data_path '/' name '.set'],'overwrite','on','gui','off'); 
redraw()

%Run ICA on EEG dataset
name = 'Walking_Baseline_runica';
EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',1:63);
save_dataset;

% Plotting the independent components
pop_topoplot(EEG,0, 1:size(EEG.icawinv,2) ,name,[3 10] ,0,'electrodes','on');

%Plotting the power spectrum plots for Independent components
for i = size(EEG.icawinv,2):-1:1
    pop_prop( EEG, 0, i, NaN, {'freqrange' [2 65],'electrodes','on' });
    set(gcf, 'Position', [48 480 500 500]);
end

% Manual Selection of good Independent Components
%by eyeballing: (1) topographies, and (2) component specs
good   = [7,8,9,10,14,15,16,17,18,19,20,21,22,25,26,44];
eyes   = [5,24,42];
bad   = setdiff(1:length(EEG.icawinv),good); %Substarcting good components from all componenets

%Incorporating good and bad componenets inside EEG data
EEG.good = good;  
EEG.eyes = eyes;
EEG.bad  = bad;  

%plot the good components
close all
pop_topoplot(EEG, 0, EEG.good ,sprintf('%s good ICs %s', name, date),[3 8] ,0,'electrodes','on');
print(1, '-dpng', [name '_all_ic']); % Prints Figure
close;

save_dataset;

%% Export data
icaact = EEG.icaact;
icawinv = EEG.icawinv;
icasphere = EEG.icasphere;
icaweights = EEG.icaweights;
icachansind = EEG.icachansind;

pathname= [s.subj_data_path, '/' name , '_IC.mat' ];

save(pathname,'icaact','icawinv','icasphere','icaweights','icachansind','good','eyes','bad');

%% [6] CLEAN DATA BY BAD COMPS
EEG = pop_subcomp( EEG, EEG.bad, 0);
name = ['Walking_Baseline_backproject'];
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',name,...
    'savenew',[s.subj_data_path '/' name '.set'],'gui','off','overwrite','on'); 
redraw()

pop_eegplot( EEG, 1, 1, 1);     % check whether (15 < autoscaling < 25 mV) [ideally]
name = 'Final_Plot_Walking_Baseline_Data';
print(1, '-dpng', name); % Prints Figure
close;
%% [7] POWER SPECTRUM DENSITY (ROI?)
% carry out a later date.
% redo for eyes closed

%% carry out IC analysis on EC trials next:
end
function redraw()
eeglab redraw
end