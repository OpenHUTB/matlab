function protectedCompile(modelName,subModels,subModelBuildFolders,...
    subModelTargetTypes,lXilInfo,...
    lGenerateCodeOnly,lInstrObjFolder,lVerbose)






    topModelIdx=find(strcmp(modelName,subModels));
    tgt=subModelTargetTypes{topModelIdx};
    buildDir=subModelBuildFolders{topModelIdx};

    if~isempty(lInstrObjFolder)

        buildDir=fullfile(buildDir,lInstrObjFolder);
    end



    [lBuildInfo,lBuildOpts]=coder.make.internal.loadBuildInfo(buildDir);


    if lBuildOpts.MakefileBasedBuild






        lBuildOpts.CompileProfileFcn=coder.internal.getCompileProfileFcn...
        (lBuildOpts.BuildVariant,lBuildOpts.BuildName,lBuildInfo);

        lBuildOpts.DispHook=@Simulink.output.info;
        lBuildOpts.generateCodeOnly=lGenerateCodeOnly;
        lBuildOpts.SuppressExe=buildObjsOnly(lXilInfo,tgt);
        lBuildOpts.RTWVerbose=lVerbose;



        warnStruct=warning('off','coder_compile:CoderCompile:legacyTMFToken');
        warnGuard=onCleanup(@()warning(warnStruct));


        codebuild(lBuildInfo,lBuildOpts);

        warnGuard.delete;
    end
