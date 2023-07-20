function[lBuildInfoInstr,mainObjFolder,compileBuildOptsInstr]=...
instrumentationStage...
    (lModelName,...
    mainCompileFolder,...
    lCodeCoverageSpec,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lCodeProfilingWCETAnalysis,...
    lAllModelsWithCodeProfiling,...
    lModelRefsAll,...
    lProtectedModelRefs,...
    lAnchorDir,...
    lTargetType,...
    lDispHook,...
    lCodeGenerationId,...
    lBuildHookHandles,...
    lBuildInfo,...
    lXilInfo,...
    lTopOfBuildModel,...
    compileBuildOpts,...
    lXilCompInfo,...
    lBuildSharedLibs)





    if lXilInfo.IsSilAndPws


        lToolchainInfoInstr=lXilCompInfo.ToolchainInfo;
        lTMFPropertiesInstr=lXilCompInfo.TMFProperties;
    else


        [lToolchainInfoInstr,lTMFPropertiesInstr]=...
        coder.make.internal.resolveToolchainOrTMF(compileBuildOpts.BuildMethod);
    end

    if~isempty(lTMFPropertiesInstr)
        lTemplateMakefileInstr=lTMFPropertiesInstr.TemplateMakefile;
    else
        lTemplateMakefileInstr='';
    end


    profilingInstrumentationEnabled=any(strcmp(lAllModelsWithCodeProfiling,lModelName));
    assert(~lCodeStackProfilingTop||profilingInstrumentationEnabled,...
    'If stack profiling is on, function instrumentation must be performed');
    assert(~lCodeProfilingWCETAnalysis||profilingInstrumentationEnabled,...
    'If WCET profiling is on, function instrumentation must be performed');


    timeProfilingInstrumentationEnabled=profilingInstrumentationEnabled&&...
    ~lCodeStackProfilingTop&&~lCodeProfilingWCETAnalysis;




    lCheckProfilingGranularity=lCodeExecutionProfilingTop&&~lCodeProfilingWCETAnalysis;

    lTaskLevelProfiling=lCodeStackProfilingTop||lCodeExecutionProfilingTop||lCodeProfilingWCETAnalysis;



    lIsSilAndPws=lXilInfo.IsSilAndPws;
    lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
    (lModelName,...
    lIsSilAndPws,...
    lCodeCoverageSpec,...
    lTaskLevelProfiling,...
    lAllModelsWithCodeProfiling,...
    lModelRefsAll,...
    lProtectedModelRefs);


    [slCoverageHook,slCoverageHookIdx]=i_getSlCoverageHook(lBuildHookHandles);

    sourceFileSpecs=coder.internal.CodeInstrBuildArgs.getCodeInstrSourceFileTypes;


    [~,fTmp,eTmp]=fileparts(compileBuildOpts.sysTargetFile);
    lSystemTargetFileNoPath=[fTmp,eTmp];
    isIDELinkTarget=any(strcmp(lSystemTargetFileNoPath,{'idelink_ert.tlc','idelink_grt.tlc'}));


    src_exts=coder.internal.getSourceFileExtensions(lToolchainInfoInstr);

    slCovEnabled=i_slCovEnabled(slCoverageHook,lModelName);


    if slCovEnabled

        if lXilInfo.IsSil
            covMode=char(SlCov.CovMode.SIL);
        else
            covMode=char(SlCov.CovMode.PIL);
        end


        hookChecksum=getHookChecksum(slCoverageHook);

        [instrumOptions,modelModuleName]=getInstrumentForCoverageArgs(slCoverageHook);

        if~slCovEnabled
            instrumOptions=[];
        end
    end



    lBuildInfo.updateFilePathsAndExtensions;





    instrObjFolder=getInstrObjFolder(lCodeInstrInfo);
    mainObjFolder=fullfile(mainCompileFolder,instrObjFolder);
    if~isfolder(mainObjFolder)
        mkdir(mainObjFolder);
    end




    ignoreMissingSourceFiles=true;


    [instrumentationUpToDate,lCodeInstrChecksums]=isInstrumentationUpToDate...
    (lCodeInstrInfo,lBuildInfo,lAnchorDir,mainCompileFolder,lModelName,...
    lBuildHookHandles,...
    lCodeGenerationId,lCheckProfilingGranularity,ignoreMissingSourceFiles,...
    slCovEnabled);

    if slCovEnabled


        sourceFilesToInstrument=coder.coverage.getFilesToInstrument(lBuildInfo);
        foldersToInstrument=unique...
        (coder.make.internal.fileparts(sourceFilesToInstrument,filesep),'stable');

        if instrumentationUpToDate&&~isempty(sourceFilesToInstrument)



            instrumentationUpToDate=SlCov.coder.EmbeddedCoder.setupInstrumentForCoverage...
            (lModelName,instrumentationUpToDate,...
            modelModuleName,lAnchorDir,instrumOptions);
        end

    else
        foldersToInstrument=coder.internal.CodeInstrBuildArgs...
        .getSrcFoldersToInstrument(lBuildInfo,mainCompileFolder);

        sourceFilesToInstrument=coder.internal.getSourceFilesToInstrument...
        (foldersToInstrument,sourceFileSpecs);
    end

    instrSrcFolder=getInstrSrcFolder(lCodeInstrInfo);
    lCodeInstrRegistry=[];


    if~instrumentationUpToDate

        lReplacePaths=[];
        lUpdateModelLib=true;
        lBuildInfoInstr=ciUpdateBuildInfo(lCodeInstrInfo,lBuildInfo,...
        lReplacePaths,lUpdateModelLib);


        coder.internal.removeInstrumentedSource...
        (instrSrcFolder,instrObjFolder,foldersToInstrument);


        [~,lRelativePathToAnchor]=findBuildArg...
        (lBuildInfoInstr,'RELATIVE_PATH_TO_ANCHOR');
        if~isempty(lTMFPropertiesInstr)
            lTemplateMakefile=lTMFPropertiesInstr.TemplateMakefile;
        else
            lTemplateMakefile='';
        end
        coder.internal.generateRtwProjFile...
        (lModelName,lTemplateMakefile,...
        mainObjFolder,...
        lBuildInfoInstr.Settings.LocalAnchorDir,...
        lRelativePathToAnchor);


        i_copyExtrasToObjFolder(instrObjFolder,instrSrcFolder);
    else



        lBuildInfoInstr=coder.make.internal.loadBuildInfo(instrObjFolder);
    end



    srcFilesToSkip=coder.internal.updateBuildInfoForInstr(lBuildInfoInstr,...
    isIDELinkTarget,lIsSilAndPws);
    for i=1:length(srcFilesToSkip)
        [~,f,e]=fileparts(srcFilesToSkip{i});
        removeSourceFiles(lBuildInfoInstr,[f,e]);
    end
    sourceFilesToInstrument=sourceFilesToInstrument...
    (~ismember(sourceFilesToInstrument,srcFilesToSkip));






    if lBuildSharedLibs
        if lCodeExecutionProfilingTop&&...
            any(strcmp(lModelName,lAllModelsWithCodeProfiling))


            linkObjsInstr=lBuildInfo.LinkObj;
        else


            linkObjsInstr=coder.internal.getInstrLinkObjs...
            (instrObjFolder,src_exts,lIsSilAndPws,isIDELinkTarget,...
            lBuildInfo);
        end
    else

        linkObjsInstr=RTW.BuildInfoLinkObj.empty;
    end
    setLinkablesDirect(lBuildInfoInstr,linkObjsInstr);




    if lBuildSharedLibs&&~lXilInfo.IsXil



        [~,~,moduleObjFolders,moduleNames]=getInstrSrcFolder(lCodeInstrInfo);
        coder.internal.updateReferencedModelLinkables(lBuildInfoInstr,...
        mainCompileFolder,moduleNames,moduleObjFolders);
    end

    coder.coverage.BuildHook.initializeCommonHookData...
    (lBuildHookHandles,getActiveConfigSet(lModelName),...
    lXilInfo.IsSilAndPws,...
    lXilInfo.IsSil,...
    lXilInfo.IsPil,...
    lDispHook{1},lDispHook{1});

    coder.coverage.BuildHook.initializeHookData...
    (lBuildHookHandles,lAnchorDir,...
    fullfile(mainCompileFolder,instrObjFolder),...
    instrObjFolder,...
    lBuildInfo,lBuildInfoInstr,...
    mainCompileFolder);


    lBuildHookHandlesNoSlCov=lBuildHookHandles(~slCoverageHookIdx);


    [lBuildHookEnvVars,lBuildHookPathPrepends]=i_runAfterCodeGenHooks...
    (lBuildHookHandlesNoSlCov,mainCompileFolder,lTemplateMakefileInstr,...
    lCodeGenerationId,lToolchainInfoInstr);



    compileBuildOptsInstr=i_createBuildOptsInstr...
    (compileBuildOpts,lXilInfo,lBuildInfoInstr,...
    lToolchainInfoInstr,lTMFPropertiesInstr,lBuildHookEnvVars,...
    lBuildHookPathPrepends);

    if lXilInfo.IsSilAndPws

        rtw.pil.BuildInfoHelpers.updateBuildInfoToSkipFiles...
        (lBuildInfoInstr,compileBuildOpts.TargetLangExt);

        if isempty(lTMFPropertiesInstr)



            if strcmp(compileBuildOpts.BuildConfiguration,'Specify')
                preprocessorFlagsForSILPWS=...
                coder.internal.getToolchainCustomDefines...
                (coder.make.internal.resolveToolchainOrTMF(compileBuildOpts.BuildMethod),...
                compileBuildOpts.CustomToolchainOptions,compileBuildOpts.isCpp);
                if~isempty(preprocessorFlagsForSILPWS)
                    addDefines(lBuildInfoInstr,preprocessorFlagsForSILPWS)
                end
            end
        end
    end

    lMakeCommand=get_param(lModelName,'MakeCommand');

    if slCovEnabled
        if~instrumentationUpToDate

            mainModuleInstrumentationUpToDate=repmat(instrumentationUpToDate,...
            size(sourceFilesToInstrument));

            componentPathRelative=lBuildInfo.ComponentBuildFolder;
            i_snifferBuildAndCoverageInstr(lXilInfo.IsSil,lModelName,...
            lBuildInfoInstr,lBuildInfo,...
            compileBuildOptsInstr,lMakeCommand,...
            lToolchainInfoInstr,componentPathRelative,sourceFilesToInstrument,...
            mainModuleInstrumentationUpToDate,lModelName,modelModuleName,...
            lXilInfo.IsTopModelSil,instrumOptions,hookChecksum,...
            instrObjFolder,lXilInfo.IsSilAndPws)
        end
    end

    if slCovEnabled





i_coverageInstrumentation...
        (slCoverageHook,lToolchainInfoInstr,...
        compileBuildOptsInstr,instrObjFolder,...
        lMakeCommand,lModelName,lXilInfo.IsSilAndPws,...
        lAnchorDir,covMode,...
        instrumOptions,lXilInfo.IsSil,...
        lXilInfo.IsTopModelSil,hookChecksum,lBuildInfo,slCovEnabled,...
        linkObjsInstr);


        for i=1:length(linkObjsInstr)
            if linkObjsInstr(i).BuildInfoDirty
                linkables=lBuildInfoInstr.Linkables;
                linkable=linkables(strcmp({linkables.Name},linkObjsInstr(i).Name));
                linkable.BuildInfoDirty=true;
            end
        end
    end


    if timeProfilingInstrumentationEnabled&&~instrumentationUpToDate
        if coder.profile.private.edgCodeInstrumentation



            optGetFcn=@(x)get_param(lModelName,x);
            snifferDefaultOpts=coder.internal.getSnifferDefaultOpts(optGetFcn);
            lFrontEndOptions=coder.internal.doSnifferBuild...
            (lBuildInfoInstr,...
            compileBuildOptsInstr.isCpp,...
            compileBuildOptsInstr.sysTargetFile,...
            compileBuildOptsInstr.BuildMethod,...
            compileBuildOptsInstr.BuildVariant,...
            compileBuildOptsInstr.BuildConfiguration,...
            compileBuildOptsInstr.CustomToolchainOptions,...
            lMakeCommand,...
            compileBuildOptsInstr.BuildName,...
            snifferDefaultOpts,...
            'CompileErrorDiagnosticFunctions',compileBuildOptsInstr.CompileErrorDiagnosticFunctions,...
            'CoderTargetAuxMakeContent',compileBuildOptsInstr.CoderTargetAuxMakeContent);
        else

            lFrontEndOptions=[];
        end




        copiedSourceFiles=coder.internal.initializeInstrumentedSource...
        (instrSrcFolder,foldersToInstrument,...
        'FileSpecsToCopy',sourceFileSpecs);




        coder.internal.updateBuildInfoWithInstrumentedFiles...
        (lBuildInfoInstr,instrSrcFolder,foldersToInstrument,...
        copiedSourceFiles);

        instrSrcFolder=fullfile(mainCompileFolder,...
        getInstrSrcFolder(lCodeInstrInfo));
        [lChecksumGranularityOn,lChecksumGranularityOff]=...
        lCodeInstrChecksums.getGranularityChecksums();

        lCodeInstrRegistry=coder.internal.doCodeInstrumentation(...
        lModelName,...
        mainCompileFolder,...
        lCodeGenerationId,...
        lFrontEndOptions,instrSrcFolder,...
        lChecksumGranularityOn,lChecksumGranularityOff);


        if~isempty(lCodeInstrRegistry)
            coder.internal.findUnregisteredProfilingSections...
            (lBuildInfoInstr.getSourceFiles(true,true),...
            lBuildInfoInstr.getIncludeFiles(true,true),...
            lCodeInstrRegistry);
        end
    elseif lCodeProfilingWCETAnalysis



        copiedSourceFiles=coder.internal.initializeInstrumentedSource...
        (instrSrcFolder,foldersToInstrument,...
        'FileSpecsToCopy',sourceFileSpecs);



        coder.internal.updateBuildInfoWithInstrumentedFiles...
        (lBuildInfoInstr,instrSrcFolder,foldersToInstrument,...
        copiedSourceFiles);

        instrSrcFolderFullPath=fullfile(mainCompileFolder,...
        getInstrSrcFolder(lCodeInstrInfo));

        lCodeInstrRegistry=coder.internal.doWCETInstrumentation(...
        lModelName,...
        mainCompileFolder,...
        lCodeGenerationId,...
        instrSrcFolderFullPath);
    end

    lCodeInstrRegistry=i_stackProfilingInstrumentation...
    (lBuildInfoInstr,compileBuildOptsInstr,instrObjFolder,...
    lMakeCommand,lModelName,lCodeStackProfilingTop,...
    mainCompileFolder,instrumentationUpToDate,lBuildSharedLibs,...
    lCodeGenerationId,lIsSilAndPws,lCodeInstrRegistry,...
    foldersToInstrument,instrSrcFolder);

    if(~isempty(lCodeInstrRegistry)||lTaskLevelProfiling)&&...
        ~Simulink.ModelReference.ProtectedModel.protectingModel(lModelName)
        refModelsWithProfiling=setdiff(lAllModelsWithCodeProfiling,lModelName);

        [~,lRelativePathToAnchor]=...
        findBuildArg(lBuildInfoInstr,'RELATIVE_PATH_TO_ANCHOR');

        coder.internal.codeInstrPostCodeGen...
        (lXilInfo,...
        lTargetType,...
        lCodeExecutionProfilingTop,...
        lCodeStackProfilingTop,...
        lTopOfBuildModel,...
        lModelName,...
        lBuildInfoInstr,lBuildInfo,...
        lRelativePathToAnchor,...
        lAnchorDir,...
        isIDELinkTarget,...
        instrumentationUpToDate,...
        lCodeInstrRegistry,...
        lCodeGenerationId,...
        instrObjFolder,...
        mainCompileFolder,...
        lCodeInstrInfo,...
        profilingInstrumentationEnabled,...
        refModelsWithProfiling);




        [instrumentationUpToDate,lCodeInstrChecksums]=isInstrumentationUpToDate...
        (lCodeInstrInfo,lBuildInfo,lAnchorDir,mainCompileFolder,...
        lModelName,lBuildHookHandles,...
        lCodeGenerationId,lCheckProfilingGranularity,ignoreMissingSourceFiles,...
        slCovEnabled);
    end

    for i=1:length(lBuildHookHandles)
        xilCompatibilityCheck(lBuildHookHandles{i},isIDELinkTarget);
    end


    if~instrumentationUpToDate
        instrObjFolderFullPath=fullfile(mainCompileFolder,instrObjFolder);
        if~isfolder(instrObjFolderFullPath)
            mkdir(instrObjFolderFullPath)
        end
        saveInfoFile(lCodeInstrChecksums);
    end



    coder.make.internal.saveBuildArtifacts(lBuildInfoInstr,compileBuildOptsInstr);



    function slCovEnabled=i_slCovEnabled(slCoverageHook,lModelName)


        if isempty(slCoverageHook)
            slCovEnabled=false;
        else
            topModelName=getTopModelName(slCoverageHook);
            lIsSilBuild=isSilBuild(slCoverageHook);
            lIsTopModelSil=isTopModelSil(slCoverageHook);
            slCovEnabled=getCoverageEnabledForThisComponent(slCoverageHook)&&...
            SlCov.CodeCovUtils.isXILCoverageEnabled(topModelName,lModelName,lIsSilBuild,lIsTopModelSil);
        end


        function compileBuildOptsInstr=i_createBuildOptsInstr...
            (compileBuildOpts,lXilInfo,lBuildInfoInstr,...
            lToolchainInfoInstr,lTMFPropertiesInstr,lBuildHookEnvVars,...
            lBuildHookPathPrepends)


            if~isempty(lTMFPropertiesInstr)
                lToolchainOrTMFInstr=lTMFPropertiesInstr;
            else
                lToolchainOrTMFInstr=lToolchainInfoInstr;
            end

            compileBuildOptsInstr=coder.internal.createBuildOptsCompileInstr...
            (compileBuildOpts,lXilInfo.IsSilAndPws,lXilInfo.IsSILDebuggingEnabled,...
            lToolchainOrTMFInstr,lBuildInfoInstr);
            compileBuildOptsInstr.BuildMethod=lToolchainOrTMFInstr;


            if~isempty(lTMFPropertiesInstr)



                lBuildInfoInstr.TargetLibSuffix=compileBuildOpts.LegacyTargetLibSuffix;
            end



            compileBuildOptsInstr.buildHookEnvVars=lBuildHookEnvVars;
            compileBuildOptsInstr.buildHookPathPrepends=lBuildHookPathPrepends;


            function lCodeInstrRegistry=i_stackProfilingInstrumentation...
                (lBuildInfoInstr,compileBuildOptsInstr,lInstrObjFolder,...
                lMakeCommand,lModelName,lCodeStackProfilingTop,...
                mainCompileFolder,instrumentationUpToDate,lBuildSharedLibs,...
                lCodeGenerationId,lIsSilAndPws,lCodeInstrRegistry,...
                foldersToInstrument,instrSrcFolder)

                if lCodeStackProfilingTop&&isempty(lCodeInstrRegistry)&&~instrumentationUpToDate

                    lInstrSrcFolder=fullfile(mainCompileFolder,lInstrObjFolder);
                    lCodeInstrRegistry=coder.internal.doStackInstrumentation(...
                    lModelName,lModelName,lBuildInfoInstr,compileBuildOptsInstr,...
                    lMakeCommand,mainCompileFolder,lInstrSrcFolder,...
                    foldersToInstrument,instrSrcFolder);
                end

                if lBuildSharedLibs&&coder.profile.private.stackProfiling()
                    if lCodeStackProfilingTop

                        coder.internal.doSharedUtilsStackInstrumentation(...
                        lModelName,lBuildInfoInstr,compileBuildOptsInstr,...
                        lMakeCommand,lIsSilAndPws,lCodeGenerationId);
                    end
                end



                function i_snifferBuildAndCoverageInstr(lIsSilBuild,modelName,...
                    buildInfoInstr,buildInfoOriginal,...
                    compileBuildOptsInstr,lMakeCommand,...
                    lToolchainInfoInstr,componentPathRelative,filesToInstrument,...
                    instrumentationUpToDate,componentName,moduleName,...
                    lIsTopModelSil,instrumOptions,hookChecksum,...
                    lInstrObjFolder,lIsSilAndPws)



                    lEnableSnifferBuild=codeinstrumprivate('feature','useSnifferInSIL')||~lIsSilBuild;
                    if lEnableSnifferBuild

                        optGetFcn=@(x)get_param(modelName,x);
                        snifferDefaultOpts=coder.internal.getSnifferDefaultOpts(optGetFcn);

                        lFrontEndOptions=coder.internal.doSnifferBuild...
                        (buildInfoInstr,...
                        compileBuildOptsInstr.isCpp,...
                        compileBuildOptsInstr.sysTargetFile,...
                        compileBuildOptsInstr.BuildMethod,...
                        compileBuildOptsInstr.BuildVariant,...
                        compileBuildOptsInstr.BuildConfiguration,...
                        compileBuildOptsInstr.CustomToolchainOptions,...
                        lMakeCommand,...
                        compileBuildOptsInstr.BuildName,...
                        snifferDefaultOpts,...
                        'CompileErrorDiagnosticFunctions',compileBuildOptsInstr.CompileErrorDiagnosticFunctions,...
                        'CoderTargetAuxMakeContent',compileBuildOptsInstr.CoderTargetAuxMakeContent);
                    else
                        lFrontEndOptions=[];
                    end



                    forEDG=true;





                    lInstrSrcFolder=fullfile(buildInfoInstr.Settings.LocalAnchorDir,...
                    buildInfoInstr.ComponentBuildFolder);
                    coder.internal.updateBuildInfoWithInstrumentedFiles...
                    (buildInfoInstr,lInstrSrcFolder,{},filesToInstrument,forEDG);


                    SlCov.coder.EmbeddedCoder.instrumentForCoverage...
                    (lToolchainInfoInstr,compileBuildOptsInstr,lFrontEndOptions,...
                    modelName,...
                    componentPathRelative,filesToInstrument,instrumentationUpToDate,...
                    componentName,moduleName,buildInfoInstr,buildInfoOriginal,lIsSilBuild,...
                    lIsTopModelSil,lIsSilAndPws,instrumOptions,hookChecksum,...
                    lInstrObjFolder)



                    function[instrumentationUpToDate,missingProfilingInfo]=i_coverageFilesToInstrument...
                        (rootFolder,componentPathRelative,...
                        lInstrObjFolder,modelName,moduleName,instrumOptions,filesToInstrument)

                        instrumentationUpToDate=coder.coverage.originalSourceFilesUnchanged...
                        (filesToInstrument,fullfile(rootFolder,componentPathRelative,lInstrObjFolder));

                        if any(instrumentationUpToDate)&&...
                            ~isfile(fullfile(rootFolder,componentPathRelative,'profiling_info.mat'))






                            instrumentationUpToDate=false(size(instrumentationUpToDate));
                            missingProfilingInfo=true;
                        else
                            missingProfilingInfo=false;
                        end

                        if~isempty(filesToInstrument)&&any(instrumentationUpToDate)
                            instrumentationConfigUpToDate=SlCov.coder.EmbeddedCoder.setupInstrumentForCoverage...
                            (modelName,instrumentationUpToDate,...
                            moduleName,rootFolder,instrumOptions);
                            if~instrumentationConfigUpToDate
                                instrumentationUpToDate=false(size(instrumentationUpToDate));
                            end
                        end




                        function i_coverageInstrumentation...
                            (hookHandle,lToolchainInfoInstr,...
                            compileBuildOptsInstr,lInstrObjFolder,lMakeCommand,modelName,lIsSilAndPws,...
                            rootFolder,covMode,instrumOptions,...
                            lIsSilBuild,lIsTopModelSil,hookChecksum,lBuildInfo,slCovEnabled,...
                            linkObjsInstr)



                            buildSharedUtils=hookHandle.BuildSharedUtils;
                            if~buildSharedUtils


                                return
                            end
                            [sharedBuildInfosInstr,~,lSharedLibPathsOriginalRelative,lSharedComponentNames,linkObjsInstr]=...
                            coder.coverage.getSharedBuildInfos(linkObjsInstr,lInstrObjFolder);

                            includeIndirect=true;

                            sharedBuildInfos=...
                            coder.coverage.getSharedBuildInfos(lBuildInfo,lInstrObjFolder,includeIndirect);


                            componentPathsRelative=lSharedLibPathsOriginalRelative;
                            componentNames=lSharedComponentNames;
                            moduleNames=SlCov.coder.EmbeddedCoder.getSharedModuleName(covMode,lSharedLibPathsOriginalRelative);


                            for i=1:length(componentPathsRelative)


                                filesToInstrument=coder.coverage.getFilesToInstrument(sharedBuildInfos(i));

                                instrumentationUpToDate=i_coverageFilesToInstrument...
                                (rootFolder,componentPathsRelative{i},...
                                lInstrObjFolder,modelName,moduleNames{i},instrumOptions,filesToInstrument);

                                if isempty(filesToInstrument)
                                    continue
                                end

                                if~all(instrumentationUpToDate)
                                    if slCovEnabled
                                        i_snifferBuildAndCoverageInstr(lIsSilBuild,modelName,...
                                        sharedBuildInfosInstr(i),sharedBuildInfos(i),...
                                        compileBuildOptsInstr,lMakeCommand,...
                                        lToolchainInfoInstr,componentPathsRelative{i},filesToInstrument,...
                                        instrumentationUpToDate,componentNames{i},moduleNames{i},...
                                        lIsTopModelSil,instrumOptions,hookChecksum,...
                                        lInstrObjFolder,lIsSilAndPws);
                                    end


                                    linkObjsInstr(i).BuildInfoDirty=true;
                                end
                            end




                            function[lBuildHookEnvVars,lBuildHookPathPrepends]=i_runAfterCodeGenHooks...
                                (lBuildHookHandles,mainCompileFolder,lTemplateMakefileInstr,...
                                lCodeGenerationId,lToolchainInfoInstr)
                                if~isempty(lBuildHookHandles)
                                    [lBuildHookEnvVars,lBuildHookPathPrepends]=...
                                    coder.coverage.BuildHook.dispatch_after_code_generation...
                                    (lBuildHookHandles,mainCompileFolder,lTemplateMakefileInstr,lCodeGenerationId,...
                                    lToolchainInfoInstr);
                                else
                                    lBuildHookEnvVars={};
                                    lBuildHookPathPrepends={};
                                end



                                function[slCoverageHook,slCoverageHookIdx]=i_getSlCoverageHook(lBuildHookHandles)
                                    slCoverageHookIdx=false(size(lBuildHookHandles));
                                    for i=1:length(lBuildHookHandles)
                                        if isa(lBuildHookHandles{i},'SlCov.coder.EmbeddedCoder')
                                            slCoverageHookIdx(i)=true;
                                            slCoverageHook=lBuildHookHandles{i};
                                            break;
                                        end
                                    end
                                    if~any(slCoverageHookIdx)
                                        slCoverageHook=[];
                                    end



                                    function i_copyExtrasToObjFolder(instrObjFolder,instrSrcFolder)

                                        filesToCopy={};


                                        defFiles=dir('*.def');
                                        for i=1:length(defFiles)
                                            filesToCopy{end+1}=defFiles(i).name;%#ok
                                        end


                                        ldfFiles=dir('*.ldf');
                                        for i=1:length(ldfFiles)
                                            filesToCopy{end+1}=ldfFiles(i).name;%#ok
                                        end

                                        if~strcmp(instrObjFolder,instrSrcFolder)


                                            slrtOptions=dir('xpcoptions.h');
                                            for i=1:length(slrtOptions)
                                                filesToCopy{end+1}=slrtOptions(i).name;%#ok
                                            end
                                        end

                                        for i=1:length(filesToCopy)
                                            src=filesToCopy{i};
                                            dst=fullfile(instrObjFolder,src);
                                            copyfile(src,dst);
                                        end
