function slxcData=populateSLCacheData(mdl,...
    iBuildArgs,...
    updatePackagedArtifacts,...
    runningForExternalMode,...
    targetType,...
    parBDir)




    slxcData={};



    if Simulink.ModelReference.ProtectedModel.protectingModel(iBuildArgs.TopOfBuildModel)||...
        runningForExternalMode||...
        internal.fmudialog.export.IsFMUTarget(iBuildArgs.TopOfBuildModel)||...
        iBuildArgs.IsXILSubsystemHiddenModelBuild
        return;
    end


    packSIM=strcmp(iBuildArgs.ModelReferenceTargetType,'SIM');
    packCoder=(strcmp(iBuildArgs.ModelReferenceTargetType,'RTW')&&...
    ~iBuildArgs.XilInfo.UpdatingRTWTargetsForXil);
    if~(packSIM||packCoder)
        return;
    end


    simTargetWithCoverageEnabled=...
    slfeature('SlCovAccelSimSupport')>0&&...
    slfeature('SlCovAccelCompileSupport')>0&&...
    strcmp(iBuildArgs.ModelReferenceTargetType,'SIM')&&...
    SlCov.CoverageAPI.isModelRefEnabledFromTop(mdl);

    if simTargetWithCoverageEnabled
        return;
    end


    setCompileType=~strcmp(iBuildArgs.TopOfBuildModel,mdl);
    targetName=slprivate('perf_logger_target_resolution',targetType,mdl,false,setCompileType);


    slxcData.updatePackagedArtifacts=updatePackagedArtifacts;
    slxcData.model=mdl;
    slxcData.topModel=iBuildArgs.TopOfBuildModel;
    slxcData.targetType=iBuildArgs.ModelReferenceTargetType;
    slxcData.targetName=targetName;
    slxcData.objExt={};
    if packCoder
        slxcData.objExt=Simulink.packagedmodel.getSLXCObjectFileExtension('buildargs',iBuildArgs,mdl);
    end

    slxcData.modelInstances={};
    if~isempty(parBDir)&&builtin('_hasSLCacheModelInfo',mdl,slcache.Modes.VARCACHE)


        info=builtin('_getSLCacheModelInfo',mdl,slcache.Modes.VARCACHE);
        info.cacheFolder=coder.internal.infoMATFileMgr('getParallelAnchorDir','SIM');
        slxcData.modelInstances{1}={slcache.Modes.VARCACHE,...
        builtin('_getSLCacheSerializedModel',mdl,slcache.Modes.VARCACHE),...
        'VarCachePreparer'};
    end
end


