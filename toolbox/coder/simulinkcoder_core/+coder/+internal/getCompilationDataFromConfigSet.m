function[lToolchainOrTMF,lBuildConfiguration,lTargetLibSuffix,...
    lCustomToolchainOptions,lMexCompilerKey]=...
    getCompilationDataFromConfigSet(lConfigSet,mexCompInfo)




    [lMexCompilerKey,lToolchainInfo,~,lTMFProperties,isToolchainApproach]=...
    coder.internal.getMexCompilerForModel(lConfigSet,mexCompInfo);

    [lBuildConfiguration,lCustomToolchainOptions]=...
    coder.internal.getCompileConfigurationFromConfigSet...
    (lConfigSet,~isToolchainApproach,lToolchainInfo);

    if isToolchainApproach
        lToolchainOrTMF=lToolchainInfo;
        lTargetLibSuffix='';
    else
        lToolchainOrTMF=lTMFProperties;
        lTargetLibSuffix=get_param(lConfigSet,'TargetLibSuffix');
    end
