function buildResult=tlc_c(h,...
    modelName,systemTargetFile,...
    lTemplateMakefile,...
    dispOpts,buildDir,codeFormat,...
    lMexCompilerKey,...
    iMdlRefBuildArgs,anchorDir,iChecksum,...
    lBuildArgs,lBuildIsTMFBased,lDispHook,...
    mexSrcFileName,lCompilingAccelerator,lCompilingRTWSFunction,...
    lRunningForExternalMode,sdpTypes)%#ok




























































    profileOn=iMdlRefBuildArgs.SlbuildProfileIsOn;
    mdlRefTgtType=iMdlRefBuildArgs.ModelReferenceTargetType;
    rtwCtx=[];




    stf=get_param(modelName,'SystemTargetFile');
    isRapidAccel=isequal(stf,'raccel.tlc');

    targetName=slprivate('perf_logger_target_resolution',mdlRefTgtType,modelName,false,false);

    PerfTools.Tracer.logSimulinkData('SLbuild',modelName,...
    targetName,'tlc_c',true);

    if isempty(buildDir)


        assertMsg='Fatal error, buildDir passed to tlc_c is empty';
        assert(false,assertMsg);
    end








    PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
    'Reset function implementation counts',...
    true);
    hRtwFcnLib=get_param(modelName,'TargetFcnLibHandle');

    TflStr=get_param(modelName,'CodeReplacementLibrary');
    HwStr=get_param(modelName,'TargetHWDeviceType');
    validateTflHw(hRtwFcnLib,TflStr,HwStr);
    PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
    'Reset function implementation counts',...
    false);

    PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
    'RTWgen',true);



    storedTFLChecksum=iMdlRefBuildArgs.StoredTFLChecksum;
    if~isempty(storedTFLChecksum)
        temp_result=hRtwFcnLib.getIncrBuildNum();
        currentTflChecksum=[temp_result.NUM1,...
        temp_result.NUM2,...
        temp_result.NUM3,...
        temp_result.NUM4];
        if all(storedTFLChecksum==currentTflChecksum)
            tflChecksumIsUpToDate=true;
        else

            iMdlRefBuildArgs.StoredParameterChecksum=[];
            iMdlRefBuildArgs.StoredChecksum=[];
        end
    end


    targetType=iMdlRefBuildArgs.ModelReferenceTargetType;




    try

        preBuildDir=pwd;





        set_param(modelName,'RTWCGKeepContext','on');





        mAnchorDir=coder.internal.infoMATFileMgr('getParallelAnchorDir',...
        h.MdlRefBuildArgs.ModelReferenceTargetType);

        isSimBuild=rtwprivate('isSimulationBuild',modelName,targetType);
        folders=Simulink.filegen.internal.FolderConfiguration(modelName);

        if isSimBuild
            folders=folders.Simulation;
        else
            folders=folders.CodeGeneration;
        end

        localSuDir=folders.absolutePath('SharedUtilityCode');

        if~isempty(mAnchorDir)
            suDir=fullfile(mAnchorDir,folders.SharedUtilityCode);
        else
            suDir=localSuDir;
        end

        relativePathForSCM=getRelativePathForSCM(mdlRefTgtType,...
        suDir,...
        anchorDir,...
        mAnchorDir);

        relativePathToAnchorFromBuildDir=rtwprivate('rtwGetRelativePath',anchorDir,buildDir);


        rtwroot=fullfile(matlabroot,'rtw');

        postponeTerm=coder.internal.getPostponeTermination(modelName);


        cleanupFcn=coder.internal.CompInfoCacheForRtwgen...
        .setRtwgenCompInfoCache(h.MdlRefBuildArgs.BaDefaultCompInfo,lMexCompilerKey);



        h.BuildInfo=RTW.BuildInfo(get_param(h.ModelName,'handle'));
        h.BuildInfo.setStartDir(anchorDir);


        Stateflow.SeqDiagram.generatingCodeFlagForSLSF(true);

        tlcOptions=getTLCOptions(modelName,iMdlRefBuildArgs.ModelReferenceTargetType);


        onOffCell={'off','on'};
        preCodeGenTLCExec=slfeature('SLCGPreCodeGenTLCExec')>0;

        if slfeature('EnableCodeGenStatusBarUpdates')~=0
            rtw.util.resetStatusBar(get_param(modelName,'Handle'));
        end

        if~strcmp(iMdlRefBuildArgs.ModelReferenceTargetType,'SIM')&&...
            strcmp(get_param(modelName,'UseModelRefSolver'),'on')&&...
            ~isRapidAccel

            DAStudio.error('Simulink:modelReference:LocalSolverNotSupportCodeGen',...
            modelName);
        end


        i_checkIdLengthForReplacementLimitSymbols(modelName);




        GenerateJSONFileForNamespace(anchorDir,buildDir);

        [sfcnsCell,buildInfo,modelrefInfo]=...
        rtwgen(modelName,...
        'PostponeTerm',postponeTerm,...
        'WriteDataRefs','on',...
        'CaseSensitivity','on',...
        'Language','C',...
        'OutputDirectory',buildDir,...
        'SharedUtilsFolder',suDir,...
        'LocalSharedUtilsFolder',localSuDir,...
        'RelativeSharedUtilsPath',relativePathForSCM,...
        'MdlRefBuildArgs',iMdlRefBuildArgs,...
        'TLCIncludePaths',getCommonTLCIncludePaths(rtwroot,systemTargetFile),...
        'SystemTargetFile',systemTargetFile,...
        'TLCOptions',tlcOptions,...
        'PreCodeGenTLCExec',onOffCell{1+preCodeGenTLCExec});


        delete(cleanupFcn);

        Stateflow.SeqDiagram.generatingCodeFlagForSLSF(false);

        Simulink.DistributedTarget.DistributedTargetUtils.generateCode(...
        modelName,codeFormat,mdlRefTgtType);

        currentChecksum=buildInfo.modelChecksum;
        buildResult.codeWasUpToDate=buildInfo.allRequestedChecksumsMatch;
        buildResult.interfaceResaveInfo={};
        buildResult.runTimeParameters=buildInfo.runTimeParameters;

        if isfield(buildInfo,'aggregateSFcnInfo')
            buildResult.aggregateSFcnInfo=buildInfo.aggregateSFcnInfo;
        end

        if isfield(buildInfo,'aggregateEnumInfo')
            buildResult.aggregateEnumInfo=buildInfo.aggregateEnumInfo;
        end

        if isfield(buildInfo,'initialState')
            buildResult.initialState=buildInfo.initialState;
        end

        if isfield(buildInfo,'maskTree')
            buildResult.maskTree=buildInfo.maskTree;
        end

        if isfield(buildInfo,'interfaceResaveInfo')
            buildResult.interfaceResaveInfo=buildInfo.interfaceResaveInfo;
        end

        parameterChecksum=buildInfo.parameterChecksum;
        parameterChecksumIsUpToDate=buildInfo.sameParameterChecksum;
        modelHasTunableStructParams=buildInfo.modelHasTunableStructParams;

        coder.internal.infoMATFileMgr('addChecksum','binfo',modelName,...
        targetType,currentChecksum,parameterChecksum);

        coder.internal.infoMATFileMgr('addTunableStructParamInfo','binfo',...
        modelName,targetType,...
        modelHasTunableStructParams);

        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'RTWgen',false);






        if buildResult.codeWasUpToDate
            dh=dispOpts.DispHook;

            if strcmpi(targetType,'NONE')
                dispMsg=true;
                if(isRapidAccel)
                    try
                        dispMsg=...
                        (evalin('base',...
                        'rapidAcceleratorOptions.verbose')...
                        ~=0);
                    catch E %#ok
                        dispMsg=false;
                    end
                end

                if(get_param(modelName,'ObfuscateCode')>0)
                    dispMsg=false;
                end
                if dispMsg
                    if(~parameterChecksumIsUpToDate)
                        msg=DAStudio.message(...
                        'RTW:buildProcess:targetIsUpToDate',modelName);
                    else
                        assert(tflChecksumIsUpToDate&&parameterChecksumIsUpToDate);
                        msg=DAStudio.message(...
                        'RTW:buildProcess:targetIsUpToDate1',modelName);

                    end
                    feval(dh{:},['### ',msg]);
                end
            elseif iMdlRefBuildArgs.Verbose
                msg=sl('construct_modelref_message',...
                'Simulink:slbuild:modelRefCoderTargetNoCodeGenNeeded',...
                'Simulink:slbuild:modelRefSIMTargetNoCodeGenNeeded',...
                upper(targetType),modelName);
                feval(dh{:},['### ',msg]);

                if~isempty(buildResult.interfaceResaveInfo)
                    regenMsg=DAStudio.message('Simulink:slbuild:compileInfoRegenMsg');
                    feval(dh{:},['### ',regenMsg]);
                    for i=1:length(buildResult.interfaceResaveInfo)
                        reasonMsg=buildResult.interfaceResaveInfo{i};
                        feval(dh{:},['###     ',reasonMsg]);
                    end
                end
            end
        end

        if buildResult.codeWasUpToDate
            set_param(h.ModelName,'RTWCodeWasUptodate','on');


            if rtw.report.ReportInfo.featureReportV2&&...
                strcmpi(get_param(h.ModelName,'GenerateReport'),'on')
                folders=Simulink.filegen.internal.FolderConfiguration(h.ModelName);
                secondDir=fileparts(folders.CodeGeneration.ModelReferenceCode);
                rptInfo=rtw.report.getLatestReportInfo(h.ModelName);
                parentPath=fullfile(rptInfo.StartDir,secondDir);
                dstLibFolder=fullfile(parentPath,'_htmllib');
                if~isfolder(dstLibFolder)
                    libFolder=fullfile(matlabroot,'toolbox','coder','simulinkcoder_app','slcoderRpt',...
                    'resources','lib');
                    copyfile(libFolder,dstLibFolder,'f');
                end
            end
        else
            set_param(h.ModelName,'RTWCodeWasUptodate','off');
        end

        if lRunningForExternalMode||buildResult.codeWasUpToDate

            set_param(modelName,'RTWCGKeepContext','off');

            DoTermRTWgen(modelName,preBuildDir,rtwCtx);
            PerfTools.Tracer.logSimulinkData('SLbuild',modelName,...
            targetName,'tlc_c',false);

            return;
        end



        if iMdlRefBuildArgs.UseChecksum&&~strcmpi(targetType,'NONE')&&...
            iMdlRefBuildArgs.Verbose
            msg1=sl('construct_modelref_message','RTW:makertw:enterMdlRefCoderTarget',...
            'RTW:makertw:enterMdlRefSIMTarget',upper(targetType),...
            modelName);
            msg2=DAStudio.message('RTW:makertw:generatingCode',h.BuildDirectory);
            feval(dispOpts.DispHook{:},msg1);
            feval(dispOpts.DispHook{:},msg2);
        end

        if isRapidAccel

            statusMsg=DAStudio.message('Simulink:tools:rapidAccelBuilding');
            set_param(modelName,'StatusString',statusMsg);

            msg=DAStudio.message('Simulink:tools:rapidAccelBuildStart',...
            modelName);
            feval(dispOpts.DispHook{:},['### ',msg]);
        end


        rtwprivate('initializeRTWContext',modelName);
        rtwCtx=get_param(modelName,'RTWCodeGenerationContext');
        set_param(modelName,'RTWCodeGenerationContext',[]);
        set_param(modelName,'RTWCGKeepContext','off');

        hRtwFcnLib=get_param(modelName,'TargetFcnLibHandle');

        hasOpenMPHeader=rtwcgtlc('generateOpenMP',rtwCtx);
        if hasOpenMPHeader
            h.BuildInfo.setCompilerRequirements('supportOpenMP',true);
        end

        buildResult.rtwFile=[modelName,'.rtw'];
        buildResult.listSFcns=sfcnsCell;
        buildResult.modelrefInfo=modelrefInfo;
        buildResult.targetName=targetName;



        tlcOptions=getTLCOptions(modelName,iMdlRefBuildArgs.ModelReferenceTargetType);








        buildResult.sFcnBuildInfo=buildInfo.sFcnBuildInfo;
        buildResult.noninlinedSFcns={};
        buildResult.noninlinednonSFcns={};
        sfcnsIncCell={};
        sFcnNames={};

        if~isempty(buildResult.sFcnBuildInfo)
            sFcnNames={buildResult.sFcnBuildInfo.name};

            noninlinedSFcnIndices=find(~[buildResult.sFcnBuildInfo(:).isInlined]);
            buildResult.noninlinedSFcns=...
            {buildResult.sFcnBuildInfo(noninlinedSFcnIndices).name};
            moduleList={};

            for i=1:length(buildResult.sFcnBuildInfo)
                if~isempty(buildResult.sFcnBuildInfo(i).modules)
                    moduleList=[moduleList,buildResult.sFcnBuildInfo(i).modules];%#ok
                end
                if~isempty(buildResult.sFcnBuildInfo(i).tlcIncPath)
                    sfcnsIncCell=[sfcnsIncCell,buildResult.sFcnBuildInfo(i).tlcIncPath];%#ok
                end
            end

            if~isempty(moduleList)
                moduleList=unique(moduleList,'stable');
                buildResult.noninlinednonSFcns=moduleList;
            end

            if~isempty(sfcnsIncCell)
                sfcnsIncCell=sfcnsIncCell(cellfun(@(x)~isempty(x),sfcnsIncCell));
            end
        end


        haveStateflowSFcns=buildInfo.numStateflowSFcns>0;






        temp_result=hRtwFcnLib.getIncrBuildNum();
        currentTflChecksum=[temp_result.NUM1,...
        temp_result.NUM2,...
        temp_result.NUM3,...
        temp_result.NUM4];

        coder.internal.infoMATFileMgr('addTflChecksum','binfo',modelName,...
        targetType,currentTflChecksum);









        sfcnInfo=[];
        idx=0;
        mlTbxDir=[matlabroot,filesep,'toolbox'];

        for i=1:length(sfcnsCell)
            if sfcnsCell(i).isSkipped
                continue;
            end

            sfcn=sfcnsCell(i).sFcnName;

            sFcnIdx=strcmp(sFcnNames,sfcn);
            assert(sum(sFcnIdx,'double')==1);

            sFcnFcnInfo=buildResult.sFcnBuildInfo(sFcnIdx);
            assert(~isempty(sFcnFcnInfo));

            sfcnFile=sFcnFcnInfo.path;

            sfcnDir=fileparts(sfcnFile);
            isSynthesized=sfcnsCell(i).isSynthesized;
            if(isSynthesized||contains(sfcnFile,mlTbxDir))
                continue;
            end

            isRTWCG=sfcnsCell(i).isRTWCG;

            modules=sFcnFcnInfo.modules;

            tlcDir={};
            if sFcnFcnInfo.isInlined
                tlcDir=sFcnFcnInfo.tlcIncPath;

                if isempty(tlcDir)

                    if(~isRTWCG)
                        tlcDir={pwd};
                    end
                else
                    tlcDir=strrep(tlcDir,sfcnDir,'<SFCNDIR>');
                end
            end





            matches=[];
            if~isempty(sfcnInfo)
                sfcns={sfcnInfo(:).FunctionName};
                matches=strcmp(sfcn,sfcns);
                if(any(matches)&&(~isempty(sfcnInfo(matches).TLCDir)))

                    continue;
                end

            end

            if(any(matches))
                idxToUse=matches;
            else
                idx=idx+1;
                idxToUse=idx;
            end

            sfcnInfo(idxToUse).Block=getfullname(sfcnsCell(i).blockHandle);%#ok<AGROW>
            sfcnInfo(idxToUse).FunctionName=sfcn;%#ok<AGROW>
            sfcnInfo(idxToUse).TLCDir=tlcDir;%#ok<AGROW>
            sfcnInfo(idxToUse).Modules=modules;%#ok<AGROW>
            sfcnInfo(idxToUse).isRTWCG=isRTWCG;%#ok<AGROW>
            sfcnInfo(idxToUse).willBeDynamicallyLoaded=...
            sFcnFcnInfo.willBeDynamicallyLoaded;%#ok<AGROW>
        end

        coder.internal.infoMATFileMgr('saveSfcnInfo','binfo',...
        modelName,targetType,sfcnInfo);




        isDebugBuild=IsDebugBuild(h,modelName,lBuildIsTMFBased);

        fileRepository=get_param(modelName,'SLCGFileRepository');
        if slfeature('SharedTypesInIR')
            keptFiles=fileRepository.getCustomFileList('DNN');
        else
            keptFiles=[];
        end

        isGpuCodeGen=...
        strcmp(get_param(modelName,'GenerateGPUCode'),'CUDA')&&...
        strcmp(get_param(modelName,'TargetLang'),'C++');

        if isGpuCodeGen
            keptFiles=[keptFiles;fileRepository.getCustomFileList('GpuCoderCustomFile')];
        end

        CleanupBuildDir(buildDir,modelName,isDebugBuild,keptFiles);




        coder.internal.connectivity.TgtConnMgr.setupBeforeTLC(modelName);




        lBuildOptsBeforeTlc=struct('codeWasUpToDate',{false});
        coder.internal.callMakeHook('before_tlc',lBuildArgs,lBuildOptsBeforeTlc,...
        'ModelReferenceTargetType',h.MdlRefBuildArgs.ModelReferenceTargetType,...
        'BuildDirectory',h.BuildDirectory,...
        'ModelName',h.ModelName,...
        'BuildInfo',h.BuildInfo,...
        'TemplateMakefile',lTemplateMakefile,...
        'MakeRTWHookFile',h.MakeRTWHookFile,...
        'Verbose',h.MdlRefBuildArgs.Verbose,...
        'DispHook',lDispHook,...
        'SlBuildProfileIsOn',h.MdlRefBuildArgs.SlbuildProfileIsOn,...
        'GeneratedTLCSubDir',h.GeneratedTLCSubDir);

        usingTimerService=coder.internal.rte.util.getUsingTimerService(sdpTypes,modelName);


        directEmit=slfeature('SLCGDirectEmit');
        if directEmit>1
            try
                t=coder.TargetObject(buildDir);
                t.setModelObject;
                t.setFileRepository;
                t.emitFiles(usingTimerService);
            catch exc
                exc.message
            end
        end





        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'RTWGenSerialize phase',true);

        cg=get_param(modelName,'CGModel');
        if~strcmp(mdlRefTgtType,'NONE')&&~isempty(mAnchorDir)



            relativePath=[rtwprivate('rtwGetRelativePath',anchorDir,buildDir),filesep...
            ,rtwprivate('rtwGetRelativePath',suDir,mAnchorDir)];
        else
            relativePath=[rtwprivate('rtwGetRelativePath',suDir,buildDir)];
        end
        cg.SharedCodeManagerPath=relativePath;
        cg.RelativePathToAnchorFromBuildDir=rtwprivate('rtwGetRelativePath',anchorDir,buildDir);
        cg.RelativePathToAnchorFromBuildDir=relativePathToAnchorFromBuildDir;
        cg.serializeModel(buildDir);

        buildResult.IsUsingLanguageStandardTypes=cg.IsUsingLanguageStandardTypes;
        buildResult.RtwtypesStyle=cg.RtwtypesStyle;

        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'RTWGenSerialize phase',false);





        addModelDataToSCM(modelName,buildDir,currentChecksum,...
        iMdlRefBuildArgs,suDir,anchorDir);


        i_checkPortableWordSizeMappings(modelName,cg.RtwtypesStyle)


        i_checkHalfType(modelName,cg.HalfPrecisionUsed)





        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,...
        targetName,'TLC phase',true);
        mdlRefTargetType=iMdlRefBuildArgs.ModelReferenceTargetType;






        CDirectEmitDebuggingForVM=...
        isequal(get_param(modelName,'VmBasedExecution'),'on')&&...
        slfeature('DirectEmitCExecution')>0;

        if directEmit<2&&~CDirectEmitDebuggingForVM

            InvokeTLC(dispOpts,buildDir,modelName,rtwroot,...
            systemTargetFile,tlcOptions,sfcnsIncCell,...
            targetName,haveStateflowSFcns,...
            h.GeneratedTLCSubDir,profileOn,...
            iMdlRefBuildArgs.ProtectedModelReferenceTarget,...
            usingTimerService);
        end


        sourceFilesFromCGModel=cg.getSourceFilesForBuildInfo;

        if CDirectEmitDebuggingForVM
            processForAccelCDirectEmit(modelName,buildDir);
        end


        rtwprivate('destroyRTWContext',modelName);



        rtwcgtlc('DestroyRTWContext',rtwCtx);
        rtwCtx=[];
        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'TLC phase',false);





        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'RTWGenSerializeAfterTLC phase',true);

        try
            cg=get_param(modelName,'CGModel');
            if~strcmp(mdlRefTgtType,'NONE')&&~isempty(mAnchorDir)



                relativePath=[rtwprivate('rtwGetRelativePath',anchorDir,buildDir),filesep...
                ,rtwprivate('rtwGetRelativePath',suDir,mAnchorDir)];
            else
                relativePath=[rtwprivate('rtwGetRelativePath',suDir,buildDir)];
            end
            cg.SharedCodeManagerPath=relativePath;
            cg.RelativePathToAnchorFromBuildDir=rtwprivate('rtwGetRelativePath',anchorDir,buildDir);
            cg.serializeModelAfterTLC(buildDir);
        catch exc
            exc.message
        end


        i_satisfyEmxArrayDependency(cg,buildDir,targetName,modelName)

        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'RTWGenSerializeAfterTLC phase',false);


        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        'tlc_c',false);




        coder.internal.connectivity.TgtConnMgr.cleanupAfterTLC(modelName);




        cd(buildDir);




        filePath=[buildDir,filesep,'writeCodeInfoFcn'];
        if(exist([filePath,'.m'],'file'))
            try


                cgModel=get_param(modelName,'CGModel');
                cgModel.finishSerialization();
                writeCodeInfoFcn;
            catch codeInfoEx
                ciMsg=DAStudio.message('RTW:buildProcess:CodeInfoInternalError');
                ciExc=MException('RTW:buildProcess:CodeInfoInternalError',ciMsg);
                ciExc=ciExc.addCause(codeInfoEx);
                throw(ciExc);
            end
            deleteRTWFile=strcmp(get_param(bdroot,'RTWRetainRTWFile'),'off');
            if(deleteRTWFile)
                rtw_delete_file([filePath,'.m']);
            end
        end




        sfprivate('auxInfoAddToBuildInfo',h,modelName,buildDir)

        if strcmp(mdlRefTargetType,'SIM')
            coder.internal.modelreference.SIMTargetSfunction.generate(modelName);
        end

        if strcmp(get_param(modelName,'UseModelRefSolver'),'on')...
            &&strcmp(mdlRefTargetType,'SIM')
            coder.internal.modelreference.LocalSolver.LocalSolverSfunction.generate(modelName);
        end







        if(strcmp(mdlRefTargetType,'SIM')&&iMdlRefBuildArgs.ProtectedModelReferenceTarget)
            codeIRInfoName=fullfile(buildDir,'tmwinternal','tlc','codeIRInfo.mat');
            if exist(codeIRInfoName,'file')==2
                dstFileName=fullfile(buildDir,'codeInfo.mat');
                rtw_copy_file(codeIRInfoName,dstFileName);
            end
        end


        mexCompInfoForCRL=coder.make.internal.getMexCompInfoFromKey(lMexCompilerKey);
        cleanupFcn=coder.internal.CompInfoCacheForCRL...
        .setMexCompInfoCache(mexCompInfoForCRL);




        AddCRLUsageInfoToBuildInfo(h,modelName,hRtwFcnLib,mdlRefTargetType,...
        systemTargetFile);
        delete(cleanupFcn);




        coder.internal.rteproxy.generate(modelName,sdpTypes,usingTimerService);

        if slfeature('SchedulingService')>0
            switch sdpTypes.PlatformType
            case coder.internal.rte.PlatformType.Function
                assert(strcmpi(get_param(modelName,'GenerateSampleERTMain'),'off'),...
                'RTW:SoftwareDeploymentPlatform:NoSchedulingServiceForSDPFC',...
                'For function platform, set model configuration parameter GenerateSampleERTMain to off.');
            case coder.internal.rte.PlatformType.ApplicationWithServices
                switch sdpTypes.DeploymentType
                case coder.internal.rte.DeploymentType.Component






















                    if~h.MdlRefBuildArgs.IsExtModeXCP
                        coder.internal.rte.generateRTEMain(modelName,buildDir);
                    end
                case coder.internal.rte.DeploymentType.Subcomponent

                otherwise
                    assert(false,'Unexpected deployment type encountered.');
                end
            case coder.internal.rte.PlatformType.Application


            case coder.internal.rte.PlatformType.Invalid

            otherwise
                assert(false,'Unexpected platform type encountered.');
            end
        end

        if slfeature('CPP11ConcurrentMain')>0

            if strcmp(get_param(modelName,'GenerateSampleERTMain'),'on')&&...
                strcmp(get_param(modelName,'TargetLang'),'C++')&&...
                strcmp(get_param(modelName,'TargetLangStandard'),'C++11 (ISO)')&&...
                strcmp(get_param(modelName,'ConcurrentTasks'),'on')&&...
                strcmp(get_param(modelName,'ExplicitPartitioning'),'off')&&...
                strcmp(get_param(modelName,'ExtMode'),'off')&&...
                strcmp(get_param(modelName,'CombineOutputUpdateFcns'),'on')

                coder.internal.rte.generateCPPConcurrentMain(h,modelName,buildDir);
            end
        end


        [userList,modelSources]=GetModulesFromBuildDir(h,modelName,hRtwFcnLib,...
        mexSrcFileName,lCompilingAccelerator,lCompilingRTWSFunction,...
        sourceFilesFromCGModel);
        GetBuildModuleList(h,userList,codeFormat,modelSources,anchorDir);




        try
            cg=get_param(modelName,'CGModel');
            cg.GetErrorStatus;
        catch slddexe
            rethrow(slddexe);
        end


        DoTermRTWgen(modelName,preBuildDir,rtwCtx);
    catch exc


        DoTermRTWgen(modelName,preBuildDir,rtwCtx);
        rethrow(exc);
    end























    function CleanupBuildDir(buildDir,modelName,isDebugBuild,keptFiles)
        cWd=pwd;



        if ispc&&~isDebugBuild
            fname=fullfile(pwd,[modelName,'.pdb']);
            if(exist(fname,'file')==2)
                builtin('delete',fname);
            end
        end

        cd(buildDir);


        refMdlIncDir=fullfile(pwd,'referenced_model_includes');
        if isfolder(refMdlIncDir)
            locRmDir(refMdlIncDir);
        end





        DeleteBuildDirFiles('*.c',true,keptFiles)
        DeleteBuildDirFiles('*.cu',true,keptFiles)
        DeleteBuildDirFiles('*.cpp',true,keptFiles)
        DeleteBuildDirFiles('*.h',true,keptFiles)
        DeleteBuildDirFiles('*.hpp',true,keptFiles)
        DeleteBuildDirFiles('*.txt',true,keptFiles)
        DeleteBuildDirFiles('*.a2l')
        if~isDebugBuild

            DeleteBuildDirFiles('*.pdb')
        end


        coder.internal.rte.SDPTypes.cleanServiceInterfaceFolder(buildDir);




        reportDir=fullfile(buildDir,'html');
        if isfolder(reportDir)
            locRmDir('html');
        end



        rtw.connectivity.Utils.deleteSILPILFiles(buildDir);



        if ispc
            ext='.obj';
        else
            ext='.o';
        end
        mainObjFile=['*rt*_main',ext];
        DeleteBuildDirFiles(mainObjFile);
        mainObjFile=['classic_main',ext];
        DeleteBuildDirFiles(mainObjFile);

        rtSimObjFile=['rt_sim',ext];
        DeleteBuildDirFiles(rtSimObjFile);

        clear('writeCodeInfoFcn')
        DeleteBuildDirFiles('writeCodeInfoFcn.m')
        DeleteBuildDirFiles('codeInfo.mat')
        DeleteBuildDirFiles('profiling_info.mat')

        DeleteCodeDescriptor(buildDir,'codedescriptor.dmr')

        cd(cWd);







        function DeleteBuildDirFiles(specifiedFiles,varargin)
            files=dir(specifiedFiles);
            files={files(:).name};

            if(nargin==1)
                doTargetSpecificCheck=false;
            else
                doTargetSpecificCheck=varargin{1};
            end

            if doTargetSpecificCheck

                isTargetSpecific=i_isTargetSpecific(files);
                files=files(~isTargetSpecific);
            end

            if nargin==3
                keptFiles=varargin{2};
                if~isempty(keptFiles)
                    files=files(~ismember(files,keptFiles));
                end
            end

            for fileIdx=1:length(files)
                rtw_delete_file(files{fileIdx});
            end







            function DeleteCodeDescriptor(buildDir,codeDescFileName)

                if~exist(fullfile(cd,codeDescFileName),'file')
                    return;
                end

                if coder.codedescriptor.CodeDescriptor.getCodeDescriptorHandleCount(buildDir)>0
                    DAStudio.error('RTW:utility:CodeDescriptorOpenHandleError');
                end

                retryCount=5;
                pauseTime=0.5;

                for i=1:retryCount
                    rtw_delete_file(codeDescFileName);
                    if~exist(codeDescFileName,'file')
                        break;
                    end
                    pause(pauseTime);


                    pauseTime=pauseTime*2;
                end


                if exist(fullfile(cd,codeDescFileName),'file')
                    DAStudio.error('RTW:utility:fileIOErrorPermission','codedescriptor.dmr');
                end











                function isSFcnFmt=IsSFcnOrAcceleratorOrModelrefSimTarget(modelName,...
                    codeFormat,mdlRefTargetType)%#ok
                    isSFcnFmt=contains(codeFormat,'S-Function')||...
                    strcmpi(mdlRefTargetType,'SIM');







                    function incDir=GetTLCIncludePath(rtwroot,systemTargetFile,sfcnsIncCell,...
                        buildDir,generatedTLCSubDir,...
                        haveStateflowSFcns)%#ok
                        incDir={};

                        tlcIncludes=getCommonTLCIncludePaths(rtwroot,systemTargetFile);
                        for i=1:length(tlcIncludes)
                            incDir{end+1}=['-I',tlcIncludes{i}];%#ok<AGROW>
                        end

                        for i=1:length(sfcnsIncCell)
                            incDir{end+1}=['-I',sfcnsIncCell{i}];%#ok<AGROW>
                        end
                        scriptDir=buildDir;

                        incDir{end+1}=['-I',fullfile(buildDir,generatedTLCSubDir)];

                        mlscriptDir=fullfile(scriptDir,'mlscript');

                        if isfolder(mlscriptDir)
                            incDir{end+1}=['-I',mlscriptDir];
                        end

                        incDir{end+1}=['-I',fullfile(rtwroot,'c','tlc','mw')];
                        incDir{end+1}=['-I',fullfile(rtwroot,'c','tlc','lib')];









                        function tlcCmd=GetTLCcmd(buildDir,generatedTLCSubDir,modelName,...
                            systemTargetFile,tlcOptions,rtwroot,sfcnsIncCell,haveStateflowSFcns)




                            incDir=GetTLCIncludePath(rtwroot,systemTargetFile,sfcnsIncCell,...
                            buildDir,generatedTLCSubDir,haveStateflowSFcns);

                            tlcCmd={'tlc'};
                            tlcCmd{end+1}='-r';
                            tlcCmd{end+1}=[buildDir,filesep,modelName,'.rtw'];
                            tlcCmd{end+1}=systemTargetFile;
                            tlcCmd{end+1}=['-O',buildDir];

                            tlcDebugOn=strcmp(get_param({modelName},'TLCDebug'),'on');
                            if tlcDebugOn

                                if isempty(sldebugui('GetHandle'))
                                    set_param(0,'SlDebugEnable','off');
                                    tlcCmd{end+1}='-dc';
                                else
                                    MSLDiagnostic('Simulink:tools:NoTLCDebugWithSLDebug').reportAsWarning;
                                end
                            end

                            tlcCoverageOn=strcmp(get_param({modelName},'TLCCoverage'),'on');
                            if tlcCoverageOn
                                tlcCmd{end+1}='-dg';
                            end

                            tlcAssertionOn=strcmp(get_param({modelName},'TLCAssertion'),'on');
                            if tlcAssertionOn
                                tlcCmd{end+1}='-da';
                            end

                            tlcCmd=[tlcCmd,incDir,tlcOptions];









                            function InvokeTLC(dispOpts,buildDir,modelName,rtwroot,...
                                systemTargetFile,tlcOptions,sfcnsIncCell,...
                                targetName,haveStateflowSFcns,...
                                generatedTLCSubDir,compilerStatsOn,...
                                protectedModelReferenceTarget,usingTimerService)
                                dh=dispOpts.DispHook;
                                if dispOpts.rtwVerbose
                                    feval(dh{:},['### Invoking Target Language Compiler on ',modelName,'.rtw']);
                                end





                                cgModel=get_param(modelName,'CGModel');
                                cgModel.TLC.CodeGenEntryFileName='mainentry.tlc';




                                tlcCmd=GetTLCcmd(buildDir,generatedTLCSubDir,modelName,...
                                systemTargetFile,tlcOptions,rtwroot,sfcnsIncCell,...
                                haveStateflowSFcns);



                                if compilerStatsOn||PerfTools.Tracer.enable('TLC')
                                    assert(cgModel.TLC.PerfTracerEnabled);
                                    assert(strcmp(cgModel.TLC.PerfTracerTargetName,targetName));
                                else
                                    assert(~cgModel.TLC.PerfTracerEnabled);
                                end

                                tlcCmd{end+1}=sprintf('-aProtectedModelReferenceTarget=%d',...
                                protectedModelReferenceTarget);
                                tlcCmd{end+1}=sprintf('-aUsingTimerService=%d',...
                                usingTimerService);

                                tlcCmd=strrep(tlcCmd,'-p0','-p10000000');

                                if dispOpts.rtwVerbose
                                    if~any(strncmp('-p',tlcCmd,2))
                                        tlcCmd{end+1}='-p10000';
                                    end
                                    feval(dh{:},['### Using System Target File: ',systemTargetFile]);
                                end

                                if~isunix
                                    bufstate=cmd_window_buffering('off');
                                end

                                tlcProfilerOn=strcmp(get_param({modelName},'TLCProfiler'),'on');
                                if tlcProfilerOn



                                    htmlFile=[modelName,'.html'];
                                    htmlFile=[buildDir,filesep,htmlFile];
                                    feval(dh{:},['### Generating TLC profile: ',htmlFile]);
                                end




                                if evalin('base','builtin(''exist'',(''rtw_mathworks_tlc_logs_dir__''));')
                                    tlcLogsSaveDir=evalin('base','rtw_mathworks_tlc_logs_dir__');
                                else
                                    tlcLogsSaveDir='';
                                end
                                if~isempty(tlcLogsSaveDir)
                                    tlcCmd=strrep(tlcCmd,'-aGenerateReport=1','-aGenerateReport=0');
                                    tlcCmd{end+1}='-dg';
                                end

                                if rtwprivate('checkForTLCShadowVariable')
                                    tlcCmd{end+1}='-shadow1';
                                end




                                tlcCmd{end+1}='-aSLCGUseRTWContext=1';

                                action='ProvideTLCService';
                                callTLCService(action,tlcCmd,tlcProfilerOn,buildDir,...
                                modelName,tlcLogsSaveDir);

                                argStr='-aCompactFilePackaging=1';
                                if any(strncmp(argStr,tlcCmd,length(argStr)))
                                    rtw_delete_file(fullfile(buildDir,[modelName,'_prm.h']));
                                    rtw_delete_file(fullfile(buildDir,[modelName,'_reg.h']));
                                    rtw_delete_file(fullfile(buildDir,[modelName,'_common.h']));
                                    rtw_delete_file(fullfile(buildDir,[modelName,'_export.h']));
                                end


                                if~isunix
                                    cmd_window_buffering(bufstate);
                                end

                                set_param(0,'SlDebugEnable','on');





                                function isTargetSpecific=i_isTargetSpecific(files)


                                    isTargetSpecific=false(size(files));
                                    for i=1:length(files)
                                        file=files{i};
                                        fid=fopen(file,'rt');
                                        if fid==-1
                                            DAStudio.error('RTW:utility:fileIOError',file,'open');
                                        end
                                        line=fgetl(fid);
                                        fclose(fid);

                                        if ischar(line)&&contains(line,'target specific file')
                                            isTargetSpecific(i)=true;
                                        end
                                    end





                                    function[userList,modelSources]=GetModulesFromBuildDir...
                                        (h,modelName,hRtwFcnLib,mexSrcFileName,lCompilingAccelerator,lCompilingRTWSFunction,...
                                        sourceFilesNoExtFromCGModel)



                                        if lCompilingAccelerator||lCompilingRTWSFunction



                                            buildDirGroup=coder.make.internal.BuildInfoGroup.MexSourceGroup;
                                        else
                                            buildDirGroup='BuildDir';
                                        end
                                        legacyGroup='Legacy';


                                        standardDirs=h.BuildDirectory;
                                        standardGroups='BuildDir';
                                        h.BuildInfo.addSourcePaths(standardDirs,standardGroups);
                                        h.BuildInfo.addIncludePaths(standardDirs,standardGroups);




                                        user_files=hRtwFcnLib.getFilesCopiedToBldDir;
                                        [~,langExt]=rtw_is_cpp_build(modelName);


                                        cfiles=dir('*.c');
                                        cppfiles=dir('*.cpp');
                                        cufiles=dir('*.cu');
                                        cfiles=[cfiles;cppfiles;cufiles];
                                        src_files={cfiles.name};





                                        isTargetSpecific=i_isTargetSpecific(src_files);
                                        src_files=src_files(~isTargetSpecific);

                                        modelSources=setdiff(sourceFilesNoExtFromCGModel,src_files,'stable');


                                        userList=intersect(src_files,user_files,'stable');


                                        isLegacy=strcmp(src_files,['rt_main.',langExt])|...
                                        strcmp(src_files,['classic_main.',langExt]);


                                        src_files_group=repmat({buildDirGroup},size(src_files));
                                        src_files_group(isLegacy)={legacyGroup};






                                        if strcmp(get_param(modelName,'SystemTargetFile'),'rtwsfcn.tlc')

                                            idxTmp=ismember(src_files,['rt_nonfinite.',langExt]);
                                            if any(idxTmp)
                                                src_files(idxTmp)=[];
                                                src_files_group(idxTmp)=[];
                                            end
                                        end

                                        src_paths(1:length(src_files))={h.BuildDirectory};
                                        locSplitIncAndSrcFiles(h.BuildInfo,...
                                        modelName,...
                                        langExt,...
                                        src_files,...
                                        src_paths,...
                                        src_files_group,mexSrcFileName);




                                        hfiles=dir('*.h');
                                        inc_files=cell(size(hfiles));
                                        inc_files_group=cell(size(hfiles));
                                        for fileIdx=1:length(hfiles)
                                            file=hfiles(fileIdx).name;

                                            inc_files{fileIdx}=file;
                                            inc_files_group{fileIdx}=buildDirGroup;
                                        end


                                        h.BuildInfo.addIncludeFiles(inc_files,h.BuildDirectory,inc_files_group);


                                        cs=getActiveConfigSet(modelName);
                                        if cs.isValidParam('GenerateASAP2')&&...
                                            strcmp(cs.get_param('GenerateASAP2'),'on')
                                            a2lFiles=dir('*.a2l');
                                            listFiles=dir('*.list');
                                            asap2Files=[a2lFiles;listFiles];
                                            asap2_files(1:length(asap2Files))={asap2Files.name};
                                            asap2_paths(1:length(asap2Files))={h.BuildDirectory};
                                            asap2_files_group(1:length(asap2Files))={buildDirGroup};

                                            h.BuildInfo.addNonBuildFiles(asap2_files,asap2_paths,asap2_files_group);
                                        end











                                        function AddCRLUsageInfoToBuildInfo(h,modelName,hRtwFcnLib,mdlRefTargetType,...
                                            lSystemTargetFile)

                                            isCompactFormat=false;

                                            isSimBuild=rtwprivate('isSimulationBuild',modelName,mdlRefTargetType);

                                            folders=Simulink.filegen.internal.FolderConfiguration(modelName);
                                            if isSimBuild
                                                suDir=folders.Simulation.absolutePath('SharedUtilityCode');
                                            else
                                                suDir=folders.CodeGeneration.absolutePath('SharedUtilityCode');
                                            end

                                            genDirForTFL=rtwprivate('rtwattic','AtticData','genDirForTFL');






                                            isSharedLoc=~isempty(strfind(genDirForTFL,suDir));%#ok<STREMP>

                                            if~isSimBuild
                                                isERT=strcmp(get_param(modelName,'IsERTTarget'),'on');
                                                if isERT
                                                    ERTFilePackagingFormat=get_param(modelName,'ERTFilePackagingFormat');
                                                    isCompactFormat=(strcmp(ERTFilePackagingFormat,'Compact')||...
                                                    strcmp(ERTFilePackagingFormat,'CompactWithDataFile'));
                                                end
                                            end


                                            tflGenerateSharedUtilsError=CrlRequiresGenSharedUtilsError(hRtwFcnLib.LoadedLibrary);
                                            if tflGenerateSharedUtilsError
                                                utilInfo=rtwprivate('getUtilityInformation',[suDir,filesep,'shared_file.dmr']);
                                                if~isempty(utilInfo)
                                                    listOfBlocks={};
                                                    numBlks=0;
                                                    addedMore=false;
                                                    for idx=1:length(utilInfo)
                                                        if~isempty(find(ismember(utilInfo{idx}.ModelNames,modelName),1))
                                                            if numBlks>4


                                                                if~addedMore
                                                                    listOfBlocks=[listOfBlocks,'<more>'];%#ok<AGROW>
                                                                end
                                                                break;
                                                            end
                                                            traceInfo=utilInfo{idx}.getTraceabilityForModel(modelName);
                                                            for traceIdx=1:length(traceInfo)
                                                                if numBlks>4


                                                                    listOfBlocks=[listOfBlocks,'<more>'];%#ok<AGROW>
                                                                    addedMore=true;
                                                                    break;
                                                                end
                                                                aSid=traceInfo{traceIdx};
                                                                name=Simulink.ID.getFullName(aSid);
                                                                listOfBlocks=[listOfBlocks,name];%#ok<AGROW>
                                                                numBlks=numBlks+1;
                                                            end
                                                        end
                                                    end
                                                    if~isempty(listOfBlocks)
                                                        msg=listOfBlocks{1};
                                                        for idx=2:length(listOfBlocks)
                                                            msg=[msg,', ',listOfBlocks{idx}];%#ok<AGROW>
                                                        end
                                                        DAStudio.error('RTW:utility:SharedUtilGenerated',msg);
                                                    end
                                                end
                                            end

                                            excludeHdrs={};
                                            if contains(lSystemTargetFile,'autosar.tlc')
                                                excludeHdrs={'Mfl.h','Mfx.h','Ifl.h','Ifx.h','Efx.h','Bfx.h'};
                                            end


                                            [sharedHdrFiles,sharedSrcFiles,hdrPaths,addHdrPaths]=...
                                            coder.internal.addCRLUsageInfoToBuildInfo(h.BuildInfo,...
                                            hRtwFcnLib,...
                                            genDirForTFL,...
                                            excludeHdrs,...
                                            isSharedLoc,...
                                            isCompactFormat);
                                            addIncludePaths(h.BuildInfo,[hdrPaths,addHdrPaths],'TFL');


                                            for fileIdx=1:length(sharedHdrFiles)
                                                coder.internal.slcoderReport('addFileInfo',...
                                                modelName,...
                                                sharedHdrFiles{fileIdx},...
                                                'utility',...
                                                'header',...
                                                genDirForTFL);
                                            end
                                            for fileIdx=1:length(sharedSrcFiles)
                                                coder.internal.slcoderReport('addFileInfo',...
                                                modelName,...
                                                sharedSrcFiles{fileIdx},...
                                                'utility',...
                                                'source',...
                                                genDirForTFL);
                                            end






                                            function GetBuildModuleList(h,userList,codeFormat,modelSources,anchorDir)
                                                modelName=h.ModelName;



                                                modelSrcsGroup='ModelSources';
                                                customCodeGroup='CustomCode';



                                                depSrcFiles={};
                                                depSrcFilesPaths={};
                                                depSrcFilesGroups={};


                                                buildModuleCell=setdiff(modelSources(:),userList(:),'stable');

                                                numDepSrcFiles=length(buildModuleCell);
                                                depSrcFiles=[depSrcFiles,buildModuleCell{:}];
                                                depSrcFilesPaths(1:numDepSrcFiles)={''};
                                                depSrcFilesGroups(1:numDepSrcFiles)={modelSrcsGroup};


                                                cs=getActiveConfigSet(modelName);
                                                rtwSettings=cs.getComponent('any','Code Generation');


                                                custCodeFiles=rtw_resolve_custom_code...
                                                (modelName,codeFormat,...
                                                anchorDir,...
                                                h.BuildDirectory,...
                                                rtwSettings.CustomInclude,...
                                                rtwSettings.CustomSource,...
                                                rtwSettings.CustomLibrary);




                                                h.BuildInfo.addIncludePaths(custCodeFiles.parsedIncludePaths,...
                                                customCodeGroup);
                                                h.BuildInfo.addSourcePaths(custCodeFiles.parsedSrcPaths,customCodeGroup);








                                                pathRegexp='(.*?)[\\/]?[^\\/]*$';
                                                fileRegexp='.*?[\\/]?([^\\/]*)$';

                                                if~isempty(custCodeFiles.parsedSrcFiles)

                                                    [~,tok]=regexp(custCodeFiles.parsedSrcFiles,pathRegexp,...
                                                    'match','tokens');
                                                    tmp=[tok{:}];
                                                    custCodeFilesPaths=[tmp{:}];


                                                    [~,tok]=regexp(custCodeFiles.parsedSrcFiles,fileRegexp,...
                                                    'match','tokens');
                                                    tmp=[tok{:}];
                                                    custCodeFileNames=[tmp{:}];


                                                    custCodeFilesGroups(1:length(custCodeFileNames))={customCodeGroup};

                                                    depSrcFiles=[depSrcFiles,custCodeFileNames];
                                                    depSrcFilesPaths=[depSrcFilesPaths,custCodeFilesPaths];
                                                    depSrcFilesGroups=[depSrcFilesGroups,custCodeFilesGroups];
                                                end


                                                if~isempty(custCodeFiles.parsedLibFiles)

                                                    [~,tok]=regexp(custCodeFiles.parsedLibFiles,pathRegexp,...
                                                    'match','tokens');
                                                    tmp=[tok{:}];
                                                    depLibsPaths=[tmp{:}];


                                                    [~,tok]=regexp(custCodeFiles.parsedLibFiles,fileRegexp,...
                                                    'match','tokens');
                                                    tmp=[tok{:}];
                                                    depLibs=[tmp{:}];


                                                    h.BuildInfo.addLibraries(depLibs,depLibsPaths,1000,...
                                                    false,true,customCodeGroup);
                                                end

                                                [~,langExt]=rtw_is_cpp_build(modelName);


                                                mexSrcFileName='';

                                                locSplitIncAndSrcFiles(h.BuildInfo,...
                                                modelName,...
                                                langExt,...
                                                depSrcFiles,...
                                                depSrcFilesPaths,...
                                                depSrcFilesGroups,...
                                                mexSrcFileName);







                                                function DoTermRTWgen(modelName,preBuildDir,rtwCtx)


                                                    rtDir=cd(preBuildDir);
                                                    rtwgen(modelName,'TerminateCompile','on');
                                                    if~isempty(rtwCtx)
                                                        rtwcgtlc('DestroyRTWContext',rtwCtx);
                                                    else
                                                        set_param(modelName,'RTWCGKeepContext','off');
                                                    end
                                                    rtwprivate('destroyRTWContext',modelName);
                                                    Stateflow.SeqDiagram.generatingCodeFlagForSLSF(false);
                                                    cd(rtDir);




                                                    function locSplitIncAndSrcFiles(buildInfo,modelName,langExt,...
                                                        inFiles,inPaths,inGroups,mexSrcFileName)

                                                        incMods={[modelName,'_pt.',langExt],...
                                                        [modelName,'_bio.',langExt]};



                                                        incIdx=ismember(inFiles,incMods);
                                                        srcIdx=~incIdx;

                                                        if~isempty(inFiles(incIdx))
                                                            buildInfo.addIncludeFiles(inFiles(incIdx),...
                                                            inPaths(incIdx),...
                                                            inGroups(incIdx));
                                                        end


                                                        srcFiles=inFiles(srcIdx);
                                                        srcPaths=inPaths(srcIdx);
                                                        srcGroups=inGroups(srcIdx);

                                                        [sPaths,sNames,sExts]=cellfun(@fileparts,srcFiles,'UniformOutput',false);

                                                        fpIdx=~cellfun(@isempty,sPaths);

                                                        if any(fpIdx)
                                                            srcFiles(fpIdx)=strcat(sNames(fpIdx),sExts(fpIdx));
                                                            srcPaths(fpIdx)=strcat(srcPaths(fpIdx),sPaths(fpIdx));
                                                        end



                                                        sd=buildInfo.getSourcePaths(1,'StartDir');
                                                        sd=sd{1};

                                                        uSrcPaths=unique(srcPaths,'stable');

                                                        for i=1:length(uSrcPaths)
                                                            if isempty(uSrcPaths{i})
                                                                continue;
                                                            end
                                                            if isfolder(uSrcPaths{i})
                                                                continue;
                                                            end
                                                            newPath=fullfile(sd,uSrcPaths{i});
                                                            if isfolder(newPath)
                                                                idx=strcmp(uSrcPaths{i},srcPaths);
                                                                srcPaths(idx)={newPath};
                                                            end


                                                        end




                                                        incPaths=buildInfo.getIncludePaths(true);
                                                        for i=1:length(srcFiles)
                                                            if isempty(srcPaths{i})



                                                                foundMatch=false;
                                                                for j=1:length(incPaths)
                                                                    if isfile(fullfile(incPaths{j},srcFiles{i}))
                                                                        if foundMatch
                                                                            srcPaths{i}='';
                                                                            break;
                                                                        else
                                                                            srcPaths{i}=incPaths{j};
                                                                            foundMatch=true;
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end


                                                        mexIdx=strcmp(srcFiles,mexSrcFileName);
                                                        if any(mexIdx)
                                                            srcGroups{mexIdx}=coder.make.internal.BuildInfoGroup.MexSourceGroup;



                                                            sortIdx=[find(mexIdx),find(~mexIdx)];
                                                            srcFiles=srcFiles(sortIdx);
                                                            srcPaths=srcPaths(sortIdx);
                                                            srcGroups=srcGroups(sortIdx);
                                                        end

                                                        buildInfo.addSourceFiles(srcFiles,srcPaths,srcGroups);





                                                        buildInfo.addSourcePaths(srcPaths,srcGroups);





                                                        function addModelDataToSCM(modelName,buildDir,modelChecksum,...
                                                            mdlReferenceBuildArgs,suDir,startDir)
                                                            scm=SharedCodeManager.SharedCodeManagerInterface(fullfile(...
                                                            suDir,'shared_file.dmr'));




                                                            buildType='SLBUILD';





                                                            if strcmp(mdlReferenceBuildArgs.ModelReferenceTargetType,'NONE')

                                                                if mdlReferenceBuildArgs.IsSimulinkAccelerator
                                                                    buildType='SimAccel';
                                                                elseif mdlReferenceBuildArgs.IsRapidAccelerator
                                                                    buildType='SimRapidAccel';
                                                                end
                                                            else
                                                                buildType='ModelReference';
                                                                buildType=[buildType,...
                                                                mdlReferenceBuildArgs.ModelReferenceTargetType];
                                                            end
                                                            buildType=upper(buildType);

                                                            initialDir='.';

                                                            relativeDir=[initialDir,buildDir(length(startDir)+1:end)];


                                                            modelIdentity=SharedCodeManager.ModelIdentity(modelName,buildType);

                                                            pathVector=string(strsplit(relativeDir,filesep));

                                                            modelData=SharedCodeManager.ModelData(modelName,pathVector,...
                                                            buildType,modelChecksum);
                                                            scm.registerDataUsingCaching(modelIdentity,modelData);


                                                            function locRmDir(dname)

                                                                maxCount=100;

                                                                for i=1:maxCount
                                                                    try
                                                                        builtin('rmdir',dname,'s');
                                                                        return;
                                                                    catch exc














                                                                        if~ismember(exc.identifier,...
                                                                            {'MATLAB:RMDIR:NoDirectoriesRemoved'...
                                                                            ,'MATLAB:RMDIR:NotADirectory'...
                                                                            ,'MATLAB:RMDIR:SomeDirectoriesNotRemoved'})
                                                                            rethrow(exc);
                                                                        end


                                                                        if strcmp(exc.identifier,'MATLAB:RMDIR:NotADirectory')
                                                                            return;
                                                                        end

                                                                        if(i==maxCount)
                                                                            return;
                                                                        end

                                                                        pause(0.1);

                                                                    end
                                                                end






                                                                function isDebugBuild=IsDebugBuild(h,modelName,lBuildIsTMFBased)






                                                                    isSimBuild=slprivate('isSimulationBuild',h.ModelName,...
                                                                    h.MdlRefBuildArgs.ModelReferenceTargetType);
                                                                    isSILDebuggingEnabled=~isSimBuild&&...
                                                                    h.MdlRefBuildArgs.XilInfo.IsSILDebuggingEnabled;

                                                                    isExtModeXCP=h.MdlRefBuildArgs.IsExtModeXCP;

                                                                    if lBuildIsTMFBased
                                                                        makeCommand=get_param(modelName,'MakeCommand');
                                                                        isDebugEnabled=coder.internal.isDebugFromMakeCommand(makeCommand);
                                                                    else
                                                                        isDebugEnabled=strcmp(...
                                                                        get_param(modelName,'BuildConfiguration'),'Debug');
                                                                    end

                                                                    isDebugBuild=isSILDebuggingEnabled||isExtModeXCP||isDebugEnabled;


                                                                    function crlRequireSharedUtilErr=CrlRequiresGenSharedUtilsError(crlName)


                                                                        crlRequireSharedUtilErr=false;
                                                                        crls=coder.internal.getCRLs(RTW.TargetRegistry.get,crlName);
                                                                        if~isempty(crls)
                                                                            n=length(crls);
                                                                            for i=1:n
                                                                                if~isempty(crls(i))&&crls(i).GenerateSharedUtilsError
                                                                                    crlRequireSharedUtilErr=true;
                                                                                    break;
                                                                                end
                                                                            end
                                                                        end




                                                                        function i_checkIdLengthForReplacementLimitSymbols(modelName)

                                                                            if rtwprivate('rtwattic','AtticData','isLimitsReplacementOn')

                                                                                limitParameters=coder.internal.getReplacementLimitParams;
                                                                                maxIdLength=get_param(modelName,'MaxIdLength');
                                                                                for i=1:length(limitParameters)
                                                                                    paramVal=get_param(modelName,limitParameters{i});
                                                                                    if length(paramVal)>maxIdLength
                                                                                        DAStudio.error('RTW:buildProcess:TypeIdReplacementExceededMaxLength',...
                                                                                        num2str(maxIdLength),paramVal);
                                                                                    end
                                                                                end
                                                                            end




                                                                            function i_checkHalfType(modelName,halfPrecisionUsed)
                                                                                if~halfPrecisionUsed
                                                                                    return
                                                                                end
                                                                                if~any(16==...
                                                                                    [get_param(modelName,'TargetBitPerChar')...
                                                                                    ,get_param(modelName,'TargetBitPerShort')...
                                                                                    ,get_param(modelName,'TargetBitPerInt')])

                                                                                    DAStudio.error('RTW:buildProcess:HalfPrecisionRequires16DataType');
                                                                                end





                                                                                function i_checkPortableWordSizeMappings(mdl,rtwtypesStyle)

                                                                                    if strcmp(rtwtypesStyle,'full')||...
                                                                                        strcmp(get_param(mdl,'PortableWordSizes'),'off')
                                                                                        return
                                                                                    end

                                                                                    hostWordLengths=rtwhostwordlengths;


                                                                                    targetBitPerInt=get_param(mdl,'TargetBitPerInt');
                                                                                    prodIntMapping=(hostWordLengths.LongNumBits==targetBitPerInt)||...
                                                                                    (hostWordLengths.IntNumBits==targetBitPerInt)||...
                                                                                    (hostWordLengths.ShortNumBits==targetBitPerInt)||...
                                                                                    (hostWordLengths.CharNumBits==targetBitPerInt);


                                                                                    targetBitPerLong=get_param(mdl,'TargetBitPerLong');
                                                                                    prodLongMapping=(hostWordLengths.LongNumBits==targetBitPerLong)||...
                                                                                    (hostWordLengths.IntNumBits==targetBitPerLong);

                                                                                    if~prodLongMapping

                                                                                        prodLongMapping=hostWordLengths.LongLongNumBits==targetBitPerLong;
                                                                                        if prodLongMapping




                                                                                            DAStudio.error('RTW:buildProcess:InvalidProdLongToHostLongLongMapping',...
                                                                                            int2str(targetBitPerLong));
                                                                                        end
                                                                                    end


                                                                                    targetLongLongMode=strcmp(get_param(mdl,'TargetLongLongMode'),'on');
                                                                                    if targetLongLongMode

                                                                                        targetBitPerLongLong=get_param(mdl,'TargetBitPerLongLong');
                                                                                        prodLongLongMapping=hostWordLengths.LongNumBits==targetBitPerLongLong;
                                                                                        if~prodLongLongMapping&&hostWordLengths.LongLongMode
                                                                                            prodLongLongMapping=hostWordLengths.LongLongNumBits==targetBitPerLongLong;
                                                                                        end
                                                                                    else

                                                                                        prodLongLongMapping=true;
                                                                                    end

                                                                                    if~prodLongLongMapping||~prodLongMapping||~prodIntMapping
                                                                                        DAStudio.error('RTW:buildProcess:missingTargetIntOrLongDataTypeForPortableWordSizes');
                                                                                    end



                                                                                    function relativePathForSCM=getRelativePathForSCM(mdlRefTgtType,...
                                                                                        suDir,...
                                                                                        anchorDir,...
                                                                                        mAnchorDir)
                                                                                        cacheFolder=Simulink.fileGenControl('get','CacheFolder');
                                                                                        codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');

                                                                                        if~strcmp(mdlRefTgtType,'NONE')&&~isempty(mAnchorDir)



                                                                                            relativePathForSCM=[rtwprivate('rtwGetRelativePath',suDir,mAnchorDir),filesep,'shared_file.dmr'];
                                                                                        else
                                                                                            relativePathForSCM=[rtwprivate('rtwGetRelativePath',suDir,anchorDir),filesep,'shared_file.dmr'];
                                                                                        end

                                                                                        if~isempty(mAnchorDir)
                                                                                            relativePathForSCM=[mAnchorDir,filesep,relativePathForSCM];
                                                                                        else
                                                                                            if strcmp(mdlRefTgtType,'NONE')
                                                                                                relativePathForSCM=[codeGenFolder,filesep,relativePathForSCM];
                                                                                            else
                                                                                                relativePathForSCM=[cacheFolder,filesep,relativePathForSCM];
                                                                                            end
                                                                                        end



                                                                                        function i_satisfyEmxArrayDependency(cgModel,buildDir,targetName,...
                                                                                            modelName)

                                                                                            if slfeature('SLDynamicArrays')==0||~rtw_is_cpp_build(modelName)
                                                                                                return
                                                                                            end

                                                                                            needCoderArray=false;
                                                                                            for k=10:length(cgModel.CGTypes)
                                                                                                cgType=cgModel.CGTypes(k);
                                                                                                if cgType.IsEmxArray
                                                                                                    needCoderArray=true;
                                                                                                    break
                                                                                                end
                                                                                            end

                                                                                            if~needCoderArray
                                                                                                return
                                                                                            end

                                                                                            srcDir=fullfile(matlabroot,'extern','include','coder','coder_array');
                                                                                            srcName='coder_array_rtw.h';
                                                                                            srcFile=fullfile(srcDir,srcName);
                                                                                            dstFile=fullfile(buildDir,'coder_array.h');


                                                                                            fileUpdater=coder.make.internal.FileUpdater(dstFile);
                                                                                            fid=fopen(srcFile,'rt');
                                                                                            content=fread(fid,[1,Inf],'*char');
                                                                                            fclose(fid);
                                                                                            fileUpdater.setUpdatedContent(content);












