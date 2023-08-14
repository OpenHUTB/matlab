function[sharedSourceBuildInfo,sharedSourceBuildInfoFile]=...
    loadSharedSourceBuildInfo(lLocalAnchorDir,lLinkLibPath)










    sharedSrcFolder=strrep(lLinkLibPath,'$(START_DIR)',...
    lLocalAnchorDir);
    sharedSourceBuildInfoFile=fullfile(sharedSrcFolder,'buildInfo.mat');
    if isfile(sharedSourceBuildInfoFile)


        sharedSourceBuildInfo=load(sharedSourceBuildInfoFile);
        sharedSourceBuildInfo=sharedSourceBuildInfo.buildInfo;


        postLoadUpdate(sharedSourceBuildInfo,sharedSrcFolder);


        sharedSourceBuildInfo.updateFilePathsAndExtensions();
    else

        sharedSourceBuildInfo=RTW.BuildInfo.empty;
    end
