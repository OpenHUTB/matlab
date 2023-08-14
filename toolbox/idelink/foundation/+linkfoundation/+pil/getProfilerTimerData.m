function ret=getProfilerTimerData(componentArgs)





    try
        matfilefolder=componentArgs.getComponentCodePath;
        matfile=fullfile(matfilefolder,'projectBuildInfo.mat');
        buildinfo=load(matfile);
    catch ex
        newExc=MException('ERRORHANDLER:pjtgenerator:MatFileNotFound',...
        'Could not find the file %s. Remove the folder %s and start simulation again.',...
        matfile,matfilefolder);
        newExc=newExc.addCause(ex);
        throw(newExc);
    end

    ret.isDowncounting=buildinfo.ProjectBuildInfo.mIRInfo.profilerIsDownCounting;
    if~isempty(buildinfo.ProjectBuildInfo.mIRInfo.profilerSecondsPerTick)
        ret.ticksPerSecond=1/buildinfo.ProjectBuildInfo.mIRInfo.profilerSecondsPerTick;
    else
        ret.ticksPerSecond=[];
    end