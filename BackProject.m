


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
name = ['baseline_no_anxiety_backproject'];
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',name,...
    'savenew',[s.subj_data_path '/' name '.set'],'gui','off','overwrite','on'); 
er

pop_eegplot( EEG, 1, 1, 1);     % check whether (15 < autoscaling < 25 mV) [ideally]
