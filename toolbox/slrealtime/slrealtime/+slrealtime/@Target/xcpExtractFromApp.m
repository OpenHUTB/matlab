function xcpExtractFromApp(this,appName)





    this.slrtApp=slrealtime.Application(this.getAppFile(appName));
    wd=this.slrtApp.getWorkingDir();
    this.slrtApp.extract('/host/dmr/');
    RTWDirStruct=load(fullfile(wd,'host','dmr','RTWDirStruct.mat'));
    this.mldatxCodeDescFolder=fullfile(wd,'host','dmr',RTWDirStruct.dirStruct.RelativeBuildDir);
    this.slrtApp.extract('/misc/');
    this.mldatxMiscFolder=fullfile(wd,'misc');
end
