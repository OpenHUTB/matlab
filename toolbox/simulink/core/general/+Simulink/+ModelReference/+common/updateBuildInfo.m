function updateBuildInfo(binfo,buildDir,regenerateMakefile)





    buildInfoStruct=Simulink.ModelReference.common.loadBuildInfo(buildDir);
    newMATLABRoot=coder.make.internal.transformPaths(matlabroot,'pathType','full');
    anchorDir=RTW.reduceRelativePath(fullfile(buildDir,binfo.relativePathToAnchor));


    oldMATLABRoot=buildInfoStruct.buildInfo.Settings.Matlabroot;
    oldAnchorDir=buildInfoStruct.buildInfo.Settings.LocalAnchorDir;


    buildInfoStruct.buildInfo.Settings.updateMatlabRoot();
    buildInfoStruct.buildInfo.Settings.LocalAnchorDir=anchorDir;


    lReportInfo=detachReportInfo(buildInfoStruct.buildInfo);
    if~isempty(lReportInfo)
        lReportInfo.updateCodeGenFolderAndBInfoMat(anchorDir);
    end


    reportInfoCleanup=attachReportInfoPriorToSerialize(buildInfoStruct.buildInfo,lReportInfo);


    save(fullfile(buildDir,'buildInfo.mat'),'-v7',...
    '-struct','buildInfoStruct');
    delete(reportInfoCleanup);

    isAnchorDirChanged=~strcmp(oldAnchorDir,anchorDir);
    isMATLABRootChanged=~strcmp(oldMATLABRoot,newMATLABRoot);

    if(isMATLABRootChanged||isAnchorDirChanged)&&regenerateMakefile...
        &&buildInfoStruct.buildOpts.MakefileBasedBuild

        makefile=fullfile(buildDir,[buildInfoStruct.buildInfo.ModelName,'.mk']);
        if isfile(makefile)
            delete(makefile);
        end
    end
end


