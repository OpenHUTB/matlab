function[projDirPath,...
    projDirArray,...
    projDirRelPath,...
    projDirReverseRelPath]=getProjDir()



    fileGenCfg=Simulink.fileGenControl('getConfig');
    startDir=fileGenCfg.CacheFolder;

    projDirArray={startDir,'slprj','_cprj'};

    projDirPath=fullfile(projDirArray{:});
    projDirRelPath=fullfile(projDirArray{2:end});

    projDirReverseRelPath='';
    for i=1:length(projDirArray)-1
        projDirReverseRelPath=[projDirReverseRelPath,'..',filesep];%#ok<AGROW>
    end