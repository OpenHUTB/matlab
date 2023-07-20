function[buildResult,buildStatusMgr]=build_standalone_rtw_target(iMdl,...
    iBuildArgs,...
    parallelBuildContext)







    iBuildState=coder.build.internal.BuildState;
    iBuildArgs.MdlRefsUpdated=false;


    folders=Simulink.filegen.internal.FolderConfiguration(iMdl);

    try
        buildStatusDB=[];
        buildStatusMgr=[];

        minfo=coder.internal.infoMATFileMgr('updateMinfoWithSave','minfo',...
        iMdl,'NONE');
        protectedMdlsNotSupportingCGList=...
        Simulink.ModelReference.ProtectedModel.getModelsSupportingOnlyNormalMode(minfo.protectedModelRefs);

        if~isempty(protectedMdlsNotSupportingCGList)&&~isempty(minfo.protectedModelRefs)
            errId='Simulink:protectedModel:protectedModelNotSupportedInRTW';
            DAStudio.error(errId,locCreateMdlList(protectedMdlsNotSupportingCGList));
        end



        isSimBuild=slprivate('isSimulationBuild',iMdl,'NONE');
        if~isSimBuild
setPortableWordSizes...
            (iBuildArgs.XilInfo,...
            strcmp(get_param(iMdl,'PortableWordSizes'),'on'));
        end


        [createZip,zipName]=i_getZipFileName(isSimBuild,iMdl);



        [createSILPILBlock,isSILBlock,lXilCompInfo,isERTSfunction]=...
i_getXILBlockData...
        (iMdl,iBuildArgs.XilInfo,isSimBuild,...
        iBuildArgs.BaGenerateCodeOnly,iBuildArgs.BaDefaultCompInfo);


        if((~isempty(minfo.modelRefs)||~isempty(minfo.protectedModelRefs))...
            &&~iBuildArgs.LibraryBuild)



            iBuildArgs.hasModelBlocks=1;


            allMdlRefs=[minfo.modelRefs',minfo.protectedModelRefs];
            iBuildArgs.FirstModel=allMdlRefs{1};





            origStoredChecksum=iBuildArgs.StoredChecksum;
            origStoredParameterChecksum=iBuildArgs.StoredParameterChecksum;
            origStoredTFLChecksum=iBuildArgs.StoredTFLChecksum;
            origUseChecksum=iBuildArgs.UseChecksum;
            iBuildArgs.StoredChecksum=[];
            iBuildArgs.StoredParameterChecksum=[];
            iBuildArgs.StoredTFLChecksum=[];
            iBuildArgs.UseChecksum=false;

            if~iBuildArgs.IsSimulinkAccelerator
                if iBuildArgs.IsRapidAccelerator
                    iBuildArgs.ModelReferenceTargetType='SIM';
                    iBuildArgs.UpdateTopModelReferenceTarget=false;
                else
                    iBuildArgs.ModelReferenceTargetType='RTW';
                end

                [topStatus,buildStatusMgr]=update_model_reference_targets(iMdl,iBuildArgs,parallelBuildContext);
                buildStatusDB=buildStatusMgr.BuildStatusDB;
                if topStatus
                    iBuildArgs.MdlRefsUpdated=true;

                    bsCause=DAStudio.message('Simulink:slbuild:bsTopMdlRefsUpdated');
                    iBuildArgs.BuildSummary.updateRebuildReasonIfEmpty(iMdl,'NONE',bsCause);
                end
            end


            iBuildArgs.StoredChecksum=origStoredChecksum;
            iBuildArgs.StoredParameterChecksum=origStoredParameterChecksum;
            iBuildArgs.StoredTFLChecksum=origStoredTFLChecksum;
            iBuildArgs.UseChecksum=origUseChecksum;
        else
            iBuildArgs.hasModelBlocks=0;
        end


        iBuildArgs.UpdateTopModelReferenceTarget=false;
        iBuildArgs.ModelReferenceTargetType='NONE';

        if iBuildArgs.OkayToPushNags

            topModelBuildStage=Simulink.output.Stage(...
            DAStudio.message('Simulink:SLMsgViewer:TopModelBuildStageName'),...
            'ModelName',iMdl,'UIMode',true);%#ok<NASGU>
        end

        build_target('Setup',iMdl,iBuildState,iBuildArgs);
        if~isempty(buildStatusDB)
            buildStatusDB.updateBuildStatusTable({iMdl},'status',...
            DAStudio.message('RTW:buildStatus:Building'));
        end

        isModelTopOfBuild=strcmp(iBuildArgs.TopOfBuildModel,iMdl);
        if~isModelTopOfBuild&&iBuildArgs.XilInfo.IsTopModelSil
            set_param(iMdl,'ModelReferenceXILType','SIL');
        elseif~isModelTopOfBuild&&iBuildArgs.XilInfo.IsTopModelPil
            set_param(iMdl,'ModelReferenceXILType','PIL');
        elseif~strcmp(get_param(iMdl,'ModelReferenceXILType'),'NONE')


            set_param(iMdl,'ModelReferenceXILType','NONE');
        end


        buildResult=build_target('RunBuildCmd',iMdl,iBuildArgs);


        if createSILPILBlock
locCreateSILPILBlock...
            (isSILBlock,iMdl,iBuildArgs.BaDefaultCompInfo,lXilCompInfo,...
            folders.CodeGeneration.ModelCode,iBuildArgs.BaGenerateCodeOnly);
        end


        if isERTSfunction||...
            (isfield(buildResult,'IsSFunctionCodeFormat')&&...
            buildResult.IsSFunctionCodeFormat)

            coder.internal.createSFunctionModel...
            (buildResult.IsSFunctionCodeFormat,...
            iMdl,buildResult.SFunctionCreateModel,...
            buildResult.SFunctionUseParamValues,...
            isERTSfunction,iBuildArgs.BaGenerateCodeOnly);

        end


        if createZip
            buildInfoFile=coder.internal.rte.SDPTypes.getBuildInfoFile(iMdl,folders.CodeGeneration.ModelCode);
            buildInfoFolder=fileparts(buildInfoFile);
            coder.internal.packageCode(buildInfoFolder,zipName);
        end


        bsCause='';
        if isfield(buildResult,'WasCodeGenerated')&&buildResult.WasCodeGenerated
            bsCause=DAStudio.message('Simulink:slbuild:bsTopCodeOutOfDate');
        elseif isfield(buildResult,'WasCodeCompiled')&&buildResult.WasCodeCompiled
            bsCause=DAStudio.message('Simulink:slbuild:bsTopCompileArtifactsOutOfDate');
        end
        iBuildArgs.BuildSummary.updateRebuildReasonIfEmpty(iMdl,'NONE',bsCause);


        if~isempty(buildStatusDB)
            loc_updateBuildStatus(iMdl,buildStatusMgr,false,buildResult);
        end



        binfoFile=coder.internal.infoMATPostBuild('getMatFileName','binfo',...
        iMdl,'NONE',get_param(iMdl,'SystemTargetFile'));
        if Simulink.packagedmodel.toUseSLXC(iBuildArgs)&&isfile(binfoFile)
            PerfTools.Tracer.logSimulinkData('SLbuild',iMdl,'RTW',...
            'Pack Top Model Simulink Cache',true);
            ocPerfTracer=onCleanup(@()PerfTools.Tracer.logSimulinkData('SLbuild',iMdl,'RTW',...
            'Pack Top Model Simulink Cache',false));



            wasCodeUpdated=(isempty(buildResult)||...
            ~isfield(buildResult,'codeWasUpToDate'))||...
            ~buildResult.codeWasUpToDate;
            objExt=Simulink.packagedmodel.getSLXCObjectFileExtension('buildargs',iBuildArgs,iMdl);
            builtin('_packSLCacheCoderTop',iMdl,wasCodeUpdated,objExt);

            ocPerfTracer.delete();
        end

        iBuildState.buildResult=buildResult;
    catch exc
        loc_doCleanup(iBuildState,iBuildArgs);
        if~isempty(buildStatusDB)
            loc_updateBuildStatus(iMdl,buildStatusMgr,true,[]);
        end

        rethrow(exc);
    end

    loc_doCleanup(iBuildState,iBuildArgs);
end

function out=locCreateMdlList(mdlList)
    out=[];
    if length(mdlList)>=1
        out=[mdlList{1}];
        for it=2:length(mdlList)
            out=[out,', ',mdlList{it}];%#ok<AGROW>
        end
    end
end

function loc_updateBuildStatus(iMdl,buildStatusMgr,tHErr,buildResult)
    buildStatusDB=buildStatusMgr.BuildStatusDB;
    if tHErr
        buildStatusDB.updateBuildStatusTable({iMdl},'status',...
        DAStudio.message('RTW:buildStatus:Error'));
        buildStatusMgr.updateToolstrip('cancelBuildButton',false);
        buildStatusMgr.updateToolstrip('openPAButton',false);
    else
        if(~isempty(buildResult)&&isfield(buildResult,'codeWasUpToDate')...
            &&buildResult.codeWasUpToDate)
            buildStatusLastMsg=DAStudio.message('RTW:buildStatus:WasUpToDate');
        else
            buildStatusLastMsg=DAStudio.message('RTW:buildStatus:Completed');
        end
        buildStatusDB.updateBuildStatusTable({iMdl},'status',buildStatusLastMsg);
        buildStatusDB.updateTopProgressBar(buildStatusDB.NumTotalMdls);
        try
            bs=coder.internal.infoMATFileMgr('getBuildStats','binfo',iMdl,'NONE');
            buildTime=bs.buildTime;
        catch


            buildTime=0;
        end
        buildStatusDB.updateBuildStatusTable({iMdl},'buildTime',buildTime);
    end
    buildStatusDB.ctrlTotalElapsedTimer('stopTimer');
    save(fullfile(RTW.getBuildDir(iMdl).ModelRefRelativeRootTgtDir,['buildStatusDB_',iMdl,'.mat']),'buildStatusDB');
end

function loc_doCleanup(iBuildState,iBuildArgs)
    if~iBuildState.isempty()
        if~strcmp(get_param(iBuildState.mModel,'ModelReferenceXILType'),'NONE')


            set_param(iBuildState.mModel,'ModelReferenceXILType','NONE');
        end
        build_target('Cleanup',iBuildState,iBuildArgs);
    end
end



function[createZip,zipName]=i_getZipFileName(isSimBuild,iMdl)
    if~isSimBuild&&...
        strcmp(get_param(iMdl,'PackageGeneratedCodeAndArtifacts'),'on')&&...
        ~strcmp(RTW.getRootConfigsetType(getActiveConfigSet(iMdl)),'RSim')

        zipName=get_param(iMdl,'PackageName');
        coder.internal.verifyPackageName(zipName);
        createZip=true;
    else
        zipName='';
        createZip=false;
    end
end



function i_getConnectivityConfig(lIsSILBlock,lModelName,lXilCompInfo)
    isReadOnly=false;
    if lIsSILBlock
        rtw.pil.ModelBlockPIL.getSilConnectivityConfig...
        (lModelName,lXilCompInfo,isReadOnly);
    else
        lSkipConfigCheck=false;
        rtw.pil.ModelBlockPIL.getPilConnectivityConfig...
        (lModelName,lSkipConfigCheck,lXilCompInfo,isReadOnly);
    end
end



function[createSILPILBlock,isSILBlock,lXilCompInfo,isERTSfunction]=...
i_getXILBlockData...
    (iMdl,xilInfo,isSimulationBuild,baGenerateCodeOnly,baDefaultCompInfo)


    createSILPILBlock=xilInfo.IsXilBlock&&~isSimulationBuild;
    isSILBlock=createSILPILBlock&&xilInfo.IsSilBlock;
    isERTSfunction=xilInfo.IsERTSfunction&&~isSimulationBuild;

    if createSILPILBlock||isERTSfunction


        if slprivate('getIsExportFcnModel',iMdl)
            DAStudio.error(...
            'Connectivity:target:XILBlockNotSupportedForTopModelExportFunctions',...
            iMdl);
        end
    end


    if(isERTSfunction||isSILBlock)&&baGenerateCodeOnly
        MSLDiagnostic('PIL:pil:SILBlockGenCodeOnly',iMdl).reportAsWarning;
    end


    if isERTSfunction

        coder.internal.checkRowMajor(iMdl);


        if strcmp(get_param(iMdl,'GenerateAllocFcn'),'on')
            DAStudio.error('PIL:pil:UnsupportedAllocationFunction');
        end
        if strcmp(get_param(iMdl,'GenerateMakefile'),'off')
            DAStudio.error('PIL:pil:ERTSfunctionNoTmf',iMdl);
        end

        if strcmp(get_param(iMdl,'AutosarCompliant'),'on')
            DAStudio.error('PIL:pil:AUTOSARErtSfunction',iMdl);
        end
    end


    if createSILPILBlock

        lXilCompInfo=...
        coder.internal.utils.XilCompInfo.slCreateXilCompInfo...
        (getActiveConfigSet(iMdl),baDefaultCompInfo,...
        xilInfo.IsSilAndPws);






        hardware=getComponent(getActiveConfigSet(iMdl),'Hardware Implementation');
        isTargetHardwareKnown=strcmp(hardware.TargetUnknown,'off');


        if isTargetHardwareKnown
            i_getConnectivityConfig(isSILBlock,iMdl,lXilCompInfo);
        end
    else
        lXilCompInfo=[];
    end
end



function locCreateSILPILBlock(isSILMode,modelName,lDefaultCompInfo,...
    lXilCompInfo,modelCodeFolder,generateCodeOnly)


    if generateCodeOnly||strcmp(get_param(modelName,'GenerateMakefile'),'off')
        return
    end

    fgCfg=Simulink.fileGenControl('getConfig');
    lAnchorFolder=fgCfg.CodeGenFolder;


    originalFolder=pwd;
    restoreFolder=onCleanup(@()cd(originalFolder));
    cd(lAnchorFolder);









    componentPath=rtwprivate('getSourceSubsystemName',modelName);

    if isempty(componentPath)
        componentPath=modelName;
        isXrelBuild=strcmp(get_param(modelName,'Tag'),'XrelLCTModel');
    else
        isXrelBuild=false;
    end

    if~isXrelBuild


        block=[];


        pil_block_configure(block,...
        componentPath,...
        lAnchorFolder,...
        fullfile(lAnchorFolder,modelCodeFolder),...
        isSILMode,...
        lXilCompInfo,...
        lDefaultCompInfo);
    end
end
