function protectedInstrumentationStage(topModel,subModels,subModelBuildFolders,...
    subModelTargetTypes,lIsSilAndPws,...
    lDefaultCompInfo)











    for i=1:length(subModels)
        subModel=subModels{i};
        tgt=subModelTargetTypes{i};
        buildDir=subModelBuildFolders{i};


        buildInfoStruct=Simulink.ModelReference.common.loadBuildInfo(buildDir);


        binfoMATFile=coderprivate.getBinfoMATFileAndCodeName(buildDir);
        loadConfigSet=false;
        infoStruct=coder.internal.infoMATFileMgr('loadPostBuild','binfo',...
        subModel,...
        tgt,...
        binfoMATFile,...
        loadConfigSet);

        lBuildOpts=buildInfoStruct.buildOpts;



        cachedDir=pwd;
        restoreDir=onCleanup(@()cd(cachedDir));
        cd(buildDir);


        codeGenerationId=infoStruct.codeGenerationIdentifier;
        assert(~isempty(codeGenerationId),...
        'codeGenerationId should not be empty after a build.');

        if lIsSilAndPws







            lIsTMFBased=lBuildOpts.MakefileBasedBuild&&...
            ~isempty(regexp(buildInfoStruct.buildOpts.BuildMethod,'\.tmf$','once'));

            lXilCompInfo=coder.internal.utils.XilCompInfo.createXilCompInfoForSilAndPws...
            (lDefaultCompInfo,~lIsTMFBased,buildInfoStruct.buildOpts.BuildMethod);
            lToolchainInfo=lXilCompInfo.ToolchainInfo;



            lCodeCoverageSpec=[];
            lCodeExecutionProfilingTop=false;
            lAllModelsWithCodeProfiling={};

            lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
            (subModel,...
            lIsSilAndPws,...
            lCodeCoverageSpec,...
            lCodeExecutionProfilingTop,...
            lAllModelsWithCodeProfiling,...
            infoStruct.modelRefsAll,...
            infoStruct.protectedModelRefs);

            lBuildHookHandles={};


            isIDELinkTarget=false;

            src_exts=coder.internal.getSourceFileExtensions(lToolchainInfo);
            instrObjFolder=getInstrObjFolder(lCodeInstrInfo);
            linkObjsInstr=coder.internal.getInstrLinkObjs...
            (instrObjFolder,src_exts,lIsSilAndPws,isIDELinkTarget,...
            buildInfoStruct.buildInfo);


            instrObjFolderFullPath=fullfile(buildDir,instrObjFolder);
            if~isfolder(instrObjFolderFullPath)
                mkdir(instrObjFolderFullPath);
            end


            lReplacePaths=[];
            lUpdateModelLib=true;
            lBuildInfoInstr=lCodeInstrInfo.ciUpdateBuildInfo...
            (buildInfoStruct.buildInfo,lReplacePaths,lUpdateModelLib);



            setLinkablesDirect(lBuildInfoInstr,linkObjsInstr);


            if strcmp(topModel,subModel)

                [~,~,moduleObjFolders,moduleNames]=getInstrSrcFolder(lCodeInstrInfo);
                coder.internal.updateReferencedModelLinkables...
                (lBuildInfoInstr,buildDir,moduleNames,moduleObjFolders);
            end


            coder.internal.updateBuildInfoForInstr(lBuildInfoInstr,isIDELinkTarget,lIsSilAndPws);


            lIsSILDebuggingEnabled=false;


            lBuildOptsInstr=coder.internal.createBuildOptsCompileInstr...
            (lBuildOpts,lIsSilAndPws,lIsSILDebuggingEnabled,...
            lXilCompInfo.ToolchainOrTMF,buildInfoStruct.buildInfo);
            lBuildOptsInstr.BuildMethod=lXilCompInfo.ToolchainOrTMF;






            lBuildInfoInstr.addDefines('PROFILING_DEFINE_UINT64_TIMER_TYPE','OPTS');


            lInstrObjFolder=getInstrObjFolder(lCodeInstrInfo);



            lBuildInfoInstr.ComponentBuildFolder=fullfile(buildDir,lInstrObjFolder);


            coder.make.internal.saveBuildArtifacts(lBuildInfoInstr,lBuildOptsInstr);


            ignoreMissingSourceFiles=true;


            lCheckGranularity=false;


            slCovEnabled=false;

            [instrumentationUpToDate,lCodeInstrChecksums]=isInstrumentationUpToDate...
            (lCodeInstrInfo,...
            buildInfoStruct.buildInfo,...
            buildInfoStruct.buildInfo.Settings.LocalAnchorDir,...
            buildDir,...
            buildInfoStruct.buildInfo.ComponentName,...
            lBuildHookHandles,...
            codeGenerationId,...
            lCheckGranularity,...
            ignoreMissingSourceFiles,slCovEnabled);
            if~instrumentationUpToDate
                saveInfoFile(lCodeInstrChecksums);
            end

        end


        restoreDir.delete;
    end

