function str=setupBackupFile(mdl)

    [~,name,~]=fileparts(which(mdl));



    pathstr=Simulink.fileGenControl('get','CacheFolder');

    backupPath=fullfile(pathstr,'slprj','configset');
    str=fullfile(backupPath,strcat(name,'_csbackup.mat'));
