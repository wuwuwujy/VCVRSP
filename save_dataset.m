EEG = eeg_checkset( EEG );
EEG = pop_editset(EEG, 'setname',name);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',[name '.set'],'filepath',s.subj_data_path);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);