function buildInfoStruct=updateBuildInfo...
    (buildInfoStruct,...
    topModel,...
    modelName,...
    tgt,...
    relativePathToAnchor)



    topModel=convertStringsToChars(topModel);
    modelName=convertStringsToChars(modelName);
    tgt=convertStringsToChars(tgt);
    relativePathToAnchor=convertStringsToChars(relativePathToAnchor);

    import Simulink.ModelReference.ProtectedModel.*;

    assert(any(strcmp(tgt,{'NONE','RTW'})),'unexpected tgt %s.',tgt);


    rootDirBase=getRTWBuildDir();
    buildDirs=RTW.getBuildDir(topModel);
    if strcmp(tgt,'NONE')
        buildDir=fullfile(rootDirBase,buildDirs.RelativeBuildDir);
    else
        buildDir=fullfile(rootDirBase,buildDirs.ModelRefRelativeRootTgtDir,modelName);
    end



    buildInfoStruct.buildInfo.Settings.updateMatlabRoot();
    anchorDir=RTW.reduceRelativePath(fullfile(buildDir,relativePathToAnchor));
    buildInfoStruct.buildInfo.Settings.LocalAnchorDir=anchorDir;



