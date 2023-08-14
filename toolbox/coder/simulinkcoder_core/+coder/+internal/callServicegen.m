function[buildInfo,buildOpts,servicesHeaderName,servicesHeaderPath]=callServicegen(...
    algBuildInfoFolder,sdpTypes,lCodeWasUpToDate,pluginManager,...
    needInstrBuild,origComponentBuildFolder,origBuildInfoOutputFolder)





    assert(sdpTypes.PlatformType==coder.internal.rte.PlatformType.Function||...
    sdpTypes.PlatformType==coder.internal.rte.PlatformType.ApplicationWithServices);
    assert(sdpTypes.DeploymentType==coder.internal.rte.DeploymentType.Component);
    rteFolders=sdpTypes.getServiceFolders(algBuildInfoFolder);
    [pluginManagerIntGenerators,pluginManagerImpGenerators]=...
    pluginManager.getPluginFunctionsAsCellArrays();
    intGeneratorFcns=pluginManagerIntGenerators;
    switch sdpTypes.PlatformType
    case coder.internal.rte.PlatformType.Function
        buildInfoPath=fullfile(rteFolders.libFolder,'buildInfo.mat');
        impGeneratorFcns={};
    case coder.internal.rte.PlatformType.ApplicationWithServices
        buildInfoPath=fullfile(rteFolders.exeFolder,'buildInfo.mat');
        impGeneratorFcns=pluginManagerImpGenerators;
    end
    buildInfoExists=isfile(buildInfoPath);
    if lCodeWasUpToDate&&buildInfoExists

        validateBuildInfoContent=true;
        [buildInfo,buildOpts]=coder.make.internal.loadBuildInfo(...
        buildInfoPath,validateBuildInfoContent);
    else
        [buildInfo,buildOpts]=coder.internal.rte.servicegen(...
        intGeneratorFcns,impGeneratorFcns,rteFolders,...
        algBuildInfoFolder,pluginManager.CodeDescriptor);
    end

    if needInstrBuild
        buildInfo.ComponentBuildFolder=origComponentBuildFolder;
        buildInfo.setOutputFolder(origBuildInfoOutputFolder);
        coder.make.internal.syncRelativePathToAnchor(buildInfo);
    end


    servicesHeaderPath=rteFolders.intFolder;
    servicesHeaderName=...
    pluginManager.CodeDescriptor.getServices().getServicesHeaderFileName();

end
