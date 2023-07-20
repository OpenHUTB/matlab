function ret=getProjectBuildInfoModelName(componentArgs)





    try
        matfilefolder=componentArgs.getComponentCodePath;
        matfile=fullfile(matfilefolder,'projectBuildInfo.mat');
        buildinfo=load(matfile);
    catch ex
        newExc=MException('ERRORHANDLER:utils:MatFileNotFound',...
        'Could not find the file %s. Remove the folder %s and start simulation again.',...
        matfile,matfilefolder);
        newExc=newExc.addCause(ex);
        throw(newExc);
    end

    ret=buildinfo.ProjectBuildInfo.mModelName;