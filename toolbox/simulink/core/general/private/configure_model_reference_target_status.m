function[oRebuild,oReason,oUseChecksum,oNeedToInvokeCompile]=...
    configure_model_reference_target_status(iMdl,...
    iTargetType,...
    iVerbose,...
    iRebuiltChild,...
    iUpdateControl,...
    iTopTflChecksum,...
    iBuildArgs)





































    targetType=perf_logger_target_resolution(iTargetType,iMdl,false,true);

    PerfTools.Tracer.logSimulinkData(...
    'SLbuild',iMdl,targetType,...
    'configure_model_reference_target_status',true);

    onCleanupTracer=onCleanup(@()PerfTools.Tracer.logSimulinkData(...
    'SLbuild',iMdl,targetType,...
    'configure_model_reference_target_status',false));

    oRebuild=false;%#ok
    oReason='';%#ok
    bsCause='';%#ok
    oUseChecksum=false;%#ok





    oNeedToInvokeCompile=true;

    if isequal(iUpdateControl,'Force')
        oRebuild=true;
        oUseChecksum=false;
        oReason=DAStudio.message('Simulink:slbuild:rebuildSetToAlways');
        bsCause=oReason;
    else








        [locStatus,oReason,bsCause,oNeedToInvokeCompile]=...
        configure_model_reference_target_status_helper(iMdl,...
        iTargetType,...
        iVerbose,...
        iRebuiltChild,...
        iTopTflChecksum,...
        iBuildArgs);

        switch locStatus
        case 0

            if isequal(iUpdateControl,'IfOutOfDateOrStructuralChange')


                oRebuild=true;
                oUseChecksum=true;
                oReason=sl('construct_modelref_message',...
                'Simulink:slbuild:checkingForStructuralChangesCoder',...
                'Simulink:slbuild:checkingForStructuralChangesSIM',...
                iTargetType,iMdl);
            else
                oRebuild=false;
                oUseChecksum=false;
                oReason=sl('construct_modelref_message',...
                'Simulink:slbuild:modelReferenceCoderTargetUpToDate',...
                'Simulink:slbuild:modelReferenceSIMTargetUpToDate',...
                iTargetType,iMdl);
            end

        case{1,2}

            oRebuild=true;
            oUseChecksum=true;

        case 3

            oRebuild=true;
            oUseChecksum=false;

        otherwise
            DAStudio.error('Simulink:slbuild:invalidMdlRefStatus');
        end
    end

    iBuildArgs.BuildSummary.updateRebuildReason(iMdl,iTargetType,bsCause);
end















































































function[oStatus,oReason,oBSCause,oNeedToInvokeCompile]=...
    configure_model_reference_target_status_helper(iMdl,...
    iTargetType,...
    iVerbose,...
    iRebuiltChild,...
    iTopTflChecksum,...
    iBuildArgs)

    oStatus=-1;%#ok


    oNeedToInvokeCompile=true;
    protected=iBuildArgs.ProtectedModelReferenceTarget;



    anchorDir=pwd;
    minfo_cache=coder.internal.infoMATFileMgr('load','minfo',iMdl,iTargetType);


    oStatus=3;
    try
        binfo_cache=coder.internal.infoMATFileMgr('loadNoConfigSet',...
        'binfo',iMdl,iTargetType);
    catch Exc %#ok<NASGU>
        binfo_cache=[];


        sllasterror('');
    end

    [tgtShortName,tgtLongName]=mdlRefGetTargetName(iMdl,...
    iTargetType,...
    anchorDir,...
    minfo_cache,...
    protected);
    tgtInfo=dir(tgtLongName);



    if isempty(tgtInfo)
        oReason=construct_modelref_message(...
        'Simulink:slbuild:targetCoderDoesNotExist',...
        'Simulink:slbuild:targetSIMDoesNotExist',...
        iTargetType,tgtShortName,iMdl,tgtShortName);
        oBSCause=DAStudio.message(...
        'Simulink:slbuild:bs3MissingTarget',tgtShortName);
        return;
    end




    if isempty(binfo_cache)
        oReason=construct_modelref_message(...
        'Simulink:slbuild:binfoDoesNotExistCoder',...
        'Simulink:slbuild:binfoDoesNotExistSIM',...
        iTargetType,tgtShortName,iMdl);
        oBSCause=DAStudio.message('Simulink:slbuild:bs3MissingBinfo');
        return;
    end




    if isempty(binfo_cache.modelInterface)||...
        (~binfo_cache.buildSucceeded)
        oReason=construct_modelref_message(...
        'Simulink:slbuild:binfoNotHaveNecessaryInformationCoder',...
        'Simulink:slbuild:binfoNotHaveNecessaryInformationSIM',...
        iTargetType,tgtShortName,iMdl);
        oBSCause=DAStudio.message('Simulink:slbuild:bs3InvalidBinfo');
        return;
    end


    clientAnchorFolder=coder.internal.infoMATFileMgr...
    ('getParallelAnchorDir',iTargetType);
    if~isempty(clientAnchorFolder)
        compileAnchorFolder=clientAnchorFolder;
    else
        compileAnchorFolder=anchorDir;
    end




    if~isfile(fullfile(compileAnchorFolder,binfo_cache.BuildDir,'buildInfo.mat'))
        oReason=construct_modelref_message(...
        'Simulink:slbuild:buildInfoDotMatMissingCoder',...
        'Simulink:slbuild:buildInfoDotMatMissingSIM',...
        iTargetType,tgtShortName,iMdl);
        oBSCause=DAStudio.message('Simulink:slbuild:bs3MissingBuildInfoDotMat');
        return;
    end







    if~bdIsLoaded(iMdl)&&~isempty(minfo_cache.designDataLocation)&&...
        ~strcmp(minfo_cache.designDataLocation,'base')
        dictObj=Simulink.data.dictionary.open(minfo_cache.designDataLocation);
        ocDD=onCleanup(@()close(dictObj));
    end

    mdlDeps=minfo_cache.mdlDeps;
    previousUserDepChecksums=binfo_cache.rebuildChecksums.userDepChecksums;
    newDep=checkForChangedDependencies(iMdl,mdlDeps,previousUserDepChecksums,iVerbose,false);
    if~isempty(newDep)
        oReason=construct_modelref_message(...
        'Simulink:slbuild:userDependencyUpdatedSinceLastBuildCoder',...
        'Simulink:slbuild:userDependencyUpdatedSinceLastBuildSIM',...
        iTargetType,tgtShortName,iMdl,newDep,iMdl);
        oBSCause=DAStudio.message('Simulink:slbuild:bs3UserDependencyChange',newDep);
        return;
    end





    mdlDeps=binfo_cache.internalMdlDeps;
    previousInternalDepChecksums=binfo_cache.rebuildChecksums.internalMdlDepChecksums;
    [newDep,newType]=checkForChangedDependencies(iMdl,mdlDeps,previousInternalDepChecksums,false,true);
    if~isempty(newDep)
        [oReason,oBSCause]=get_model_dependency_type_message(newType,iTargetType,tgtShortName,iMdl,newDep);
        return;
    end



    [forceRebuild,oReason]=...
    rebuild_check_globalvars_csc(binfo_cache,iTargetType,iMdl,tgtShortName);

    if forceRebuild
        oBSCause=DAStudio.message('Simulink:slbuild:bs3CSCChange');
        return;
    end




    mdlRefs=minfo_cache.modelRefs;
    nMdlRefs=length(mdlRefs);

    for j=1:nMdlRefs
        mdlRef=mdlRefs{j};




        submdl_minfo=coder.internal.infoMATFileMgr('load',...
        'minfo',mdlRef,iTargetType);
        [mdlRefTgtShort,mdlRefTgtLong]=mdlRefGetTargetName(...
        mdlRef,iTargetType,anchorDir,submdl_minfo,false);



        mdlRefInfo=dir(mdlRefTgtLong);

        if isempty(mdlRefInfo)


            oReason=sl('construct_modelref_message',...
            'Simulink:slbuild:referencedModelCoderTargetDoesNotExist',...
            'Simulink:slbuild:referencedModelSIMTargetDoesNotExist',...
            iTargetType,tgtShortName,iMdl,mdlRef,mdlRefTgtShort);
            oBSCause=DAStudio.message('Simulink:slbuild:bs3MissingSubModelTarget',mdlRefTgtShort,mdlRef);
            return;
        end
    end




    [forceRebuild,oReason,oBSCause]=...
    rebuild_check_sfun_deps(binfo_cache,iTargetType,...
    tgtShortName,iMdl,iVerbose,iBuildArgs);

    if forceRebuild
        return;
    end




    if~((iTopTflChecksum.NUM1==binfo_cache.tflCheckSum(1))&&...
        (iTopTflChecksum.NUM2==binfo_cache.tflCheckSum(2))&&...
        (iTopTflChecksum.NUM3==binfo_cache.tflCheckSum(3))&&...
        (iTopTflChecksum.NUM4==binfo_cache.tflCheckSum(4)))
        oReason=sl('construct_modelref_message',...
        'Simulink:slbuild:targetFunctionLibraryChangedCoder',...
        'Simulink:slbuild:targetFunctionLibraryChangedSIM',...
        iTargetType,tgtShortName,iMdl,iMdl);
        oBSCause=DAStudio.message('Simulink:slbuild:bs3CRLChange');
        return;
    end




    if strcmp(iBuildArgs.ModelReferenceTargetType,'RTW')
        previousSILDebugSetting=binfo_cache.IsSILDebuggingEnabled;
        currentSILDebugSetting=iBuildArgs.XilInfo.IsSILDebuggingEnabled;
        if~isequal(currentSILDebugSetting,previousSILDebugSetting)
            oReason=DAStudio.message('Simulink:slbuild:debugSILBuildMismatch',...
            tgtShortName,iMdl);
            logicalStr={'false','true'};
            oBSCause=DAStudio.message('Simulink:slbuild:bs3SILChange',...
            logicalStr{previousSILDebugSetting+1},logicalStr{currentSILDebugSetting+1});
            return;
        end
    end





    sfRebuildInfo=binfo_cache.stateflowRebuildInfoForMATLABFiles;
    if(~isempty(sfRebuildInfo))
        sfUpToDate=sfprivate('checkRebuildInfoForMFiles',sfRebuildInfo);
        if(~sfUpToDate)
            oReason=construct_modelref_message(...
            'Simulink:slbuild:stateflowExternalFileChangedCoder',...
            'Simulink:slbuild:stateflowExternalFileChangedSIM',...
            iTargetType,tgtShortName,iMdl);
            oBSCause=DAStudio.message('Simulink:slbuild:bs3MFileChange');
            return;
        end
    end




    mlsysblockRebuildInfo=binfo_cache.mlsysblockRebuildInfoForMATLABSystemDeps;
    if(~isempty(mlsysblockRebuildInfo))
        mlsysUpToDate=cgxeprivate('checkRebuildInfoForMATLABSystemDeps',...
        mlsysblockRebuildInfo);
        if(~mlsysUpToDate)
            oReason=sl('construct_modelref_message',...
            'Simulink:slbuild:matlabSystemExternalFileChangedCoder',...
            'Simulink:slbuild:matlabSystemExternalFileChangedSIM',...
            iTargetType,tgtShortName,iMdl);
            oBSCause=DAStudio.message('Simulink:slbuild:bs3MFileChange');
            return;
        end
    end





    if strcmp(iBuildArgs.ModelReferenceTargetType,'RTW')
        previousExtModeXCPSetting=binfo_cache.IsExtModeXCP;
        currentExtModeXCPSetting=iBuildArgs.IsExtModeXCP;
        logicalStr={'false','true'};
        if~isequal(currentExtModeXCPSetting,previousExtModeXCPSetting)
            oReason=DAStudio.message('Simulink:slbuild:extModeXCPBuildMismatch',...
            tgtShortName,iMdl);
            oBSCause=DAStudio.message('Simulink:slbuild:bs3ExtModeChange',...
            logicalStr{previousExtModeXCPSetting+1},...
            logicalStr{currentExtModeXCPSetting+1});
            return;
        end
    end





    if isfield(binfo_cache,'CCDepInfoStructs')&&~isempty(binfo_cache.CCDepInfoStructs)
        extensionsToCheck={'.mdl','.slx'};
        for idx=1:length(binfo_cache.CCDepInfoStructs)
            isRebuildRequiredForCustomCode=true;
            CCDepInfoStruct=binfo_cache.CCDepInfoStructs{idx};

            [modelFullPath,foundModel]=slprivate('sl_get_file_ignoring_builtins',CCDepInfoStruct.ccInfo.cachedForModelRefRebuild.modelName,extensionsToCheck);
            if foundModel
                [modelRootDir,~,~]=fileparts(modelFullPath);
                assert(~isempty(modelRootDir));
                CCDepInfoStruct.ccInfo.cachedForModelRefRebuild.modelRootDir=modelRootDir;
                useCachedChecksumInfo=true;
                isRefRebuild=true;
                [~,~,fullCheckSum,~]=cgxeprivate('computeCCChecksumfromCCInfo',CCDepInfoStruct.ccInfo,useCachedChecksumInfo,isRefRebuild);
                isRebuildRequiredForCustomCode=~strcmp(fullCheckSum,CCDepInfoStruct.fullCheckSum);
            end

            if isRebuildRequiredForCustomCode
                oReason=construct_modelref_message(...
                'Simulink:slbuild:customCodeFileChangedCoder',...
                'Simulink:slbuild:customCodeFileChangedSIM',...
                iTargetType,tgtShortName,iMdl);
                oBSCause=DAStudio.message('Simulink:slbuild:bs3CustomCodeChange');
                return;
            end
        end
    end



    if strcmpi(iTargetType,'SIM')
        dataflowRebuildInfo=binfo_cache.dataflowRebuildInfo;
        if(~isempty(dataflowRebuildInfo))
            [dfUpToDate,dfRebuildReason]=Simulink.ModelReference.internal.checkDataflowRebuildInfo(...
            dataflowRebuildInfo,tgtShortName,iMdl,binfo_cache.mdlRefSimDir,iBuildArgs);
            if(~dfUpToDate)
                oReason=dfRebuildReason;
                oBSCause=DAStudio.message('Simulink:slbuild:bs3DataflowChange');
                return;
            end
        end
    end



    if strcmpi(iTargetType,'SIM')
        simHardwareAccelerationInfo=binfo_cache.simHardwareAccelerationInfo;
        if(~isempty(simHardwareAccelerationInfo))
            [shaUpToDate,shaRebuildReason]=Simulink.ModelReference.internal.checkSimHardwareAccelerationInfo(...
            simHardwareAccelerationInfo,tgtShortName,iMdl,iBuildArgs);
            if(~shaUpToDate)
                oReason=shaRebuildReason;
                oBSCause=DAStudio.message('Simulink:slbuild:bs3SimHardwareAccelerationCPU');
                return;
            end
        end
    end


    oStatus=2;














    if~minfo_cache.matFileSavedWhenMdlWasDirty
        matFile=fullfile(anchorDir,minfo_cache.matFileName);
        minfoMd5=binfo_cache.rebuildChecksums.minfoChecksum;

        [matFileExists,checksumSame]=sl_compare_file_checksum(matFile,minfoMd5);


        assert(matFileExists,...
        'Internal Error:  Information mat file ''%s''does not exist',...
        matFile);

        if~checksumSame
            oReason=construct_modelref_message(...
            'Simulink:slbuild:modelInformationCacheUpdatedCoder',...
            'Simulink:slbuild:modelInformationCacheUpdatedSIM',...
            iTargetType,tgtShortName,iMdl,minfo_cache.minfoResaveReason);
            oBSCause=minfo_cache.minfoResaveShortReason;







            generateCodeOnly=logical(iBuildArgs.BaGenerateCodeOnly)&&...
            ~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM');

            oNeedToInvokeCompile=locNeedToInvokeCompile...
            (iMdl,iTargetType,...
            iBuildArgs.CodeCoverageSpec,...
            iBuildArgs.XilInfo.IsSilAndPws,...
            iBuildArgs.CodeExecutionProfilingTop,...
            iBuildArgs.TopOfBuildModel,...
            iBuildArgs.BuildHooks,...
            compileAnchorFolder,binfo_cache.BuildDir,...
            binfo_cache.codeGenerationIdentifier,...
            generateCodeOnly,...
            binfo_cache.allModelsWithCodeProfiling,...
            iBuildArgs.BaGenerateMakefile,...
            iBuildArgs.XilInfo,...
            iBuildArgs.XilTopModel,...
            tgtLongName);

            return;
        end
    end





    [modelWasChangedUsingSimInput,reason,bsCause]=checkIfModelWasChangedUsingSimInput(iMdl,tgtShortName,iBuildArgs,binfo_cache);
    if modelWasChangedUsingSimInput
        oReason=reason;
        oBSCause=bsCause;
        return;
    end





    mdlWkspaceDeps=binfo_cache.modelWorkspaceDeps;
    previousModelWkspaceDepChecksums=binfo_cache.rebuildChecksums.modelWorkspaceDepChecksums;
    [newDep,newType]=checkForChangedDependencies(iMdl,mdlWkspaceDeps,previousModelWkspaceDepChecksums,false,true);
    if~isempty(newDep)
        [oReason,oBSCause]=get_model_dependency_type_message(newType,iTargetType,tgtShortName,iMdl,newDep);
        return;
    end


    oStatus=1;













    if minfo_cache.matFileSavedWhenMdlWasDirty





        oReason=construct_modelref_message(...
        'Simulink:slbuild:buildDueToUnsavedChangesCoder',...
        'Simulink:slbuild:buildDueToUnsavedChangesSIM',...
        iTargetType,tgtShortName,iMdl,minfo_cache.minfoResaveReason);
        oBSCause=minfo_cache.minfoResaveShortReason;








        generateCodeOnly=logical(iBuildArgs.BaGenerateCodeOnly)&&...
        ~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM');
        oNeedToInvokeCompile=locNeedToInvokeCompile...
        (iMdl,iTargetType,...
        iBuildArgs.CodeCoverageSpec,...
        iBuildArgs.XilInfo.IsSilAndPws,...
        iBuildArgs.CodeExecutionProfilingTop,...
        iBuildArgs.TopOfBuildModel,...
        iBuildArgs.BuildHooks,...
        compileAnchorFolder,binfo_cache.BuildDir,...
        binfo_cache.codeGenerationIdentifier,...
        generateCodeOnly,...
        binfo_cache.allModelsWithCodeProfiling,...
        iBuildArgs.BaGenerateMakefile,...
        iBuildArgs.XilInfo,...
        iBuildArgs.XilTopModel,...
        tgtLongName);

        return;
    end



    [forceRebuild,oReason,changedVar]=...
    rebuild_check_globalvars(binfo_cache,iTargetType,iMdl,tgtShortName);

    if forceRebuild
        oBSCause=DAStudio.message('Simulink:slbuild:bs1GlobalVarChange',changedVar);
        return;
    end







    if~isempty(iRebuiltChild)

        oReason=construct_modelref_message(...
        'Simulink:slbuild:referencedModelOutOfDateCoder',...
        'Simulink:slbuild:referencedModelOutOfDateSIM',...
        iTargetType,tgtShortName,iMdl,iRebuiltChild);
        oBSCause=DAStudio.message('Simulink:slbuild:bs1ModelRefOutOfDate',iRebuiltChild);
        oNeedToInvokeCompile=true;
        return;
    end


    for j=1:nMdlRefs
        mdlRef=mdlRefs{j};




        submdl_minfo=coder.internal.infoMATFileMgr('load',...
        'minfo',mdlRef,iTargetType);
        [mdlRefTgtShort,mdlRefTgtLong]=mdlRefGetTargetName(...
        mdlRef,iTargetType,anchorDir,submdl_minfo,false);



        if(isfield(binfo_cache.rebuildChecksums.childModelTargetChecksums,mdlRef))
            prevChecksum=binfo_cache.rebuildChecksums.childModelTargetChecksums.(mdlRef);
            currChecksum=file2hash(mdlRefTgtLong);

            outOfDate=~isequal(prevChecksum,currChecksum);
        else
            outOfDate=true;
        end

        if(outOfDate)
            oReason=construct_modelref_message(...
            'Simulink:slbuild:referencedModelCoderTargetUpdated',...
            'Simulink:slbuild:referencedModelSIMTargetUpdated',...
            iTargetType,tgtShortName,iMdl,mdlRef,mdlRefTgtShort);
            oBSCause=DAStudio.message('Simulink:slbuild:bs1ModelRefOutOfDate',mdlRef);
            oNeedToInvokeCompile=true;
            return;
        end
    end




    if~isempty(strfind(minfo_cache.signalResolutionControl,'TryResolveAll'))
        oReason=construct_modelref_message(...
        'Simulink:slbuild:resolveSignalsForAllNamedCoder',...
        'Simulink:slbuild:resolveSignalsForAllNamedSIM',...
        iTargetType,tgtShortName,iMdl);
        oBSCause=DAStudio.message('Simulink:slbuild:bs1UnresolvedSignals');







        generateCodeOnly=logical(iBuildArgs.BaGenerateCodeOnly)&&...
        ~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM');
        oNeedToInvokeCompile=locNeedToInvokeCompile...
        (iMdl,iTargetType,...
        iBuildArgs.CodeCoverageSpec,...
        iBuildArgs.XilInfo.IsSilAndPws,...
        iBuildArgs.CodeExecutionProfilingTop,...
        iBuildArgs.TopOfBuildModel,...
        iBuildArgs.BuildHooks,...
        compileAnchorFolder,binfo_cache.BuildDir,...
        binfo_cache.codeGenerationIdentifier,...
        generateCodeOnly,...
        binfo_cache.allModelsWithCodeProfiling,...
        iBuildArgs.BaGenerateMakefile,...
        iBuildArgs.XilInfo,...
        iBuildArgs.XilTopModel,...
        tgtLongName);


        return;
    end








    if~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM')
        if(binfo_cache.genCodeOnly~=iBuildArgs.BaGenerateCodeOnly)
            oNeedToInvokeCompile=true;
            oReason=DAStudio.message('Simulink:slbuild:genCodeOnlyChanged',...
            tgtShortName,iMdl);
            values={'off','on'};
            oBSCause=DAStudio.message('Simulink:slbuild:bs1GenCodeOnlyChange',...
            values{binfo_cache.genCodeOnly+1},...
            values{iBuildArgs.BaGenerateCodeOnly+1});
            return;
        end
    end










    generateCodeOnly=logical(iBuildArgs.BaGenerateCodeOnly)&&...
    ~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM');

    oNeedToInvokeCompile=locNeedToInvokeCompile...
    (iMdl,iTargetType,...
    iBuildArgs.CodeCoverageSpec,...
    iBuildArgs.XilInfo.IsSilAndPws,...
    iBuildArgs.CodeExecutionProfilingTop,...
    iBuildArgs.TopOfBuildModel,...
    iBuildArgs.BuildHooks,...
    compileAnchorFolder,binfo_cache.BuildDir,...
    binfo_cache.codeGenerationIdentifier,...
    generateCodeOnly,...
    binfo_cache.allModelsWithCodeProfiling,...
    iBuildArgs.BaGenerateMakefile,...
    iBuildArgs.XilInfo,...
    iBuildArgs.XilTopModel,...
    tgtLongName);

    if oNeedToInvokeCompile
        oReason=construct_modelref_message(...
        'Simulink:slbuild:ModelReferenceCoderTargetNeedsCompiling',...
        'Simulink:slbuild:ModelReferenceSIMTargetNeedsCompiling',...
        iTargetType,tgtShortName,iMdl,tgtShortName);
        oBSCause=DAStudio.message('Simulink:slbuild:bs1CodeInstrChange');
        return;
    end






    [forceRebuild,oReason,changedType]=...
    rebuild_check_dynamic_enum_type(binfo_cache,iTargetType,iMdl,tgtShortName);

    if forceRebuild
        oBSCause=DAStudio.message('Simulink:slbuild:bs1DynamicEnumTypeChange',changedType);
        return;
    end



    oStatus=0;
end


function needToInvokeCompile=locNeedToInvokeCompile...
    (iMdl,iTargetType,...
    lCodeCoverageSpec,iIsSilAndPws,...
    lCodeExecutionProfilingTop,lTopOfBuildModel,lBuildHooks,...
    compileAnchorFolder,iBuildDir,...
    lCodeGenerationId,...
    generateCodeOnly,...
    modelsWithProfiling,...
    lGenerateMakefile,...
    lXilInfo,xilTopModel,tgtLongName)


    [compileInfoFolder,instrSubFolder,lCodeInstrInfo]=...
locGetCompileInfo...
    (iMdl,iTargetType,...
    lCodeCoverageSpec,iIsSilAndPws,...
    lCodeExecutionProfilingTop,compileAnchorFolder,iBuildDir,...
    modelsWithProfiling);

    compileInfo=coder.make.internal.CompileInfoFile(compileInfoFolder);



    if strcmp(iTargetType,'RTW')
        storedChecksumExists=hasStoredChecksum(compileInfo);
        if~storedChecksumExists
            needToInvokeCompile=lGenerateMakefile;
            return
        end
    end



    codebuildClientInfo=getStoredClientInfo(compileInfo);
    buildSharedLibsThisTime=coder.internal.buildSharedLibraries...
    (iTargetType,lTopOfBuildModel,iMdl,xilTopModel);
    buildSharedLibsLastTime=~isempty(codebuildClientInfo)&&...
    codebuildClientInfo.BuildSharedLibs;
    if buildSharedLibsThisTime&&~buildSharedLibsLastTime



        needToInvokeCompile=true;
        return
    end

    if strcmp(iTargetType,'RTW')
        lBuildHookHandles=coder.coverage.createHooks...
        (iMdl,lBuildHooks,lTopOfBuildModel);
        if~isempty(lBuildHookHandles)


            coder.coverage.BuildHook.setXilInfo...
            (lBuildHookHandles,lXilInfo);
        end

        profGranularityUpToDate=i_isGranularityUpToDate...
        (iMdl,modelsWithProfiling,lCodeInstrInfo,lCodeExecutionProfilingTop,...
        fullfile(compileAnchorFolder,iBuildDir),instrSubFolder,...
        lCodeGenerationId,lBuildHookHandles);
    else
        lBuildHookHandles={};
        profGranularityUpToDate=true;
    end

    lClientChecksum=coder.internal.getClientChecksumForCompile...
    (lBuildHookHandles,lCodeGenerationId);


    [clientChecksumsMatch,runMakefileMatches,...
    includeChecksumsMatch]=...
locCompileChecksumsMatch...
    (compileInfo,lClientChecksum,generateCodeOnly,compileAnchorFolder);

    if strcmp(iTargetType,'SIM')

        mexCompileInfo=coder.make.internal.CompileInfoFile(fullfile(compileInfoFolder,'mex'));
        tgtMexFileChecksum=builtin('_getFileChecksum',tgtLongName);
        mexFileValid=isequal(tgtMexFileChecksum,...
        mexCompileInfo.getStoredMexFileChecksum);
    else
        mexFileValid=true;
    end

    needToInvokeCompile=~includeChecksumsMatch||...
    ~all(clientChecksumsMatch)...
    ||~runMakefileMatches||~profGranularityUpToDate||~mexFileValid;
end

function[compileInfoFolder,instrSubFolder,lCodeInstrInfo]=...
locGetCompileInfo...
    (iMdl,iTargetType,...
    lCodeCoverageSpec,iIsSilAndPws,...
    lCodeExecutionProfilingTop,compileAnchorFolder,iBuildDir,...
    modelsWithProfiling)

    lCodeInstrInfo=[];
    if strcmp(iTargetType,'RTW')

        modelRefsAll={};
        protectedModelRefs={};
        lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
        (iMdl,iIsSilAndPws,...
        lCodeCoverageSpec,...
        lCodeExecutionProfilingTop,...
        modelsWithProfiling,...
        modelRefsAll,...
        protectedModelRefs);
    end


    instrSubFolder='';
    if~isempty(lCodeInstrInfo)
        instrSubFolder=lCodeInstrInfo.getInstrObjFolder;
    end

    compileInfoFolder=fullfile...
    (compileAnchorFolder,iBuildDir,instrSubFolder);

end

function[lClientChecksumsMatch,runMakefileMatches,...
    includesChecksumsMatch]=...
    locCompileChecksumsMatch(compileInfo,lClientChecksum,...
    generateCodeOnly,compileAnchorFolder)











    includesChecksumsMatch=includesMatch(compileInfo,compileAnchorFolder);

    setClientChecksum(compileInfo,lClientChecksum);
    lClientChecksumsMatch=clientChecksumsMatch(compileInfo);

    setRunMakefile(compileInfo,~generateCodeOnly);
    runMakefileMatches=getMakefileWasRunMatches(compileInfo);

end


function profGranularityUpToDate=i_isGranularityUpToDate...
    (iMdl,modelsWithProfiling,lCodeInstrInfo,lCodeExecutionProfilingTop,...
    compileAnchorFolder,instrSubFolder,lCodeGenerationId,lBuildHookHandles)


    if~isempty(lCodeInstrInfo)&&lCodeExecutionProfilingTop&&...
        any(strcmp(iMdl,modelsWithProfiling))
        lBuildInfo=fullfile(compileAnchorFolder,instrSubFolder,'buildInfo.mat');
        if isfile(lBuildInfo)
            isModelLoaded=bdIsLoaded(iMdl);
            if~isModelLoaded
                load_system(iMdl);
            end
            lBuildInfo=load(lBuildInfo);
            lBuildInfo=lBuildInfo.buildInfo;
            profGranularityUpToDate=lCodeInstrInfo.isGranularityUpToDate(...
            lBuildInfo,compileAnchorFolder,lBuildHookHandles,lCodeGenerationId);
            if~isModelLoaded
                close_system(iMdl);
            end
        else
            profGranularityUpToDate=false;
        end
    else
        profGranularityUpToDate=true;
    end

end






