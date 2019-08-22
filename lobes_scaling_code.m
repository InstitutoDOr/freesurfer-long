dotenv('.env');
LS_code = getenv('LobesScalingCodeDIR');
subjrootfolder = getenv('PREPROC_DIR');
POSname='h.pial-outer-smoothed';

subjs = dir( fullfile(subjrootfolder, 'SUBJ*') );

for t=1:length(subjs)
    ID = subjs(t).name;
    subjdir = fullfile(subjrootfolder, ID); 
    targetpath = fullfile(subjdir, 'LobesScaling/');
    
    sess = dir( fullfile(subjdir, '*_ses-*') );
    for ns = 1:length(sess)
        %try
            %sess(ns).name
            LobeExtract(sess(ns).name, LS_code, subjdir, POSname, targetpath);
        %catch e
        %    disp('erro');
        %end
    end
end;

