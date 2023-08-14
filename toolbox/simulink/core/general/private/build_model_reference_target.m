

function[oRTWCodeWasUptodate,oInfoStructChanged,oWasCodeCompiled,...
    oWasInterfaceResaved,mainObjFolder]=...
    build_model_reference_target(iMdl,iBuildArgs,lMdlRefSimModes,varargin)



    [oRTWCodeWasUptodate,oInfoStructChanged,oWasCodeCompiled,...
    oWasInterfaceResaved,mainObjFolder]=cpp_feval_wrapper(@loc_build_model_reference_target,iMdl,iBuildArgs,lMdlRefSimModes,varargin{:});
end

function[oRTWCodeWasUptodate,oInfoStructChanged,oWasCodeCompiled,...
    oWasInterfaceResaved,mainObjFolder]=...
    loc_build_model_reference_target(iMdl,iBuildArgs,lMdlRefSimModes,varargin)
    myException=[];
    iBuildState=coder.build.internal.BuildState;

    profileOn=iBuildArgs.SlbuildProfileIsOn;
    mdlRefTgtType=iBuildArgs.ModelReferenceTargetType;


    if profileOn
        targetName=perf_logger_target_resolution(mdlRefTgtType,iMdl,false,true);
    else
        targetName=mdlRefTgtType;
    end

    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,...
    targetName,...
    'Build Model Reference Target',true);

    PerfTools.Tracer.logSimulinkData('SLbuild',iMdl,targetName,...
    'Build Model Reference Target',true);








    modelCAPIMgr=coder.internal.ModelCAPIMgr(iMdl);

    try
        PerfTools.Tracer.logSimulinkData('SLbuild',iMdl,targetName,...
        'Setup',true);

        ocLocCleanup=onCleanup(@()LocCleanup(iBuildState,iBuildArgs));
        LocSetup(iMdl,iBuildState,iBuildArgs,lMdlRefSimModes);

        PerfTools.Tracer.logSimulinkData('SLbuild',iMdl,targetName,...
        'Setup',false);

        xtester_emulate_ctrl_c('sim_accel_modelref_1');




        if iBuildArgs.XilInfo.UpdatingRTWTargetsForXil
            oldVerbose=iBuildArgs.Verbose;
            iBuildArgs.Verbose=isequal(get_param(iMdl,'RTWVerbose'),'on');
        end



        modelCAPIMgr.cacheAndSetCAPIValues();

        if(bdIsLoaded(iBuildArgs.TopOfBuildModel)&&bdIsLoaded(iMdl))
            h=Simulink.PluginMgr();
            h.enableRefMdlPlugin(iBuildArgs.TopOfBuildModel,iMdl);
        end

        if any(ismember({'Accelerator','accelerator'},lMdlRefSimModes))
            lPrioritizedMdlRefSimMode='Accelerator';
        elseif ismember('rapid-accelerator',lMdlRefSimModes)
            lPrioritizedMdlRefSimMode='rapid-accelerator';
        elseif ismember(Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL,lMdlRefSimModes)
            lPrioritizedMdlRefSimMode=Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL;
        elseif ismember(Simulink.ModelReference.internal.SimulationMode.SimulationModePIL,lMdlRefSimModes)
            lPrioritizedMdlRefSimMode=Simulink.ModelReference.internal.SimulationMode.SimulationModePIL;
        else
            lPrioritizedMdlRefSimMode='normal';
        end

        [iBuildState.buildResult,mainObjFolder]=...
        build_target('RunBuildCmd',iMdl,iBuildArgs,...
        'MdlRefSimMode',lPrioritizedMdlRefSimMode,...
        varargin{:});

        PerfTools.Tracer.logSimulinkData('SLbuild',iMdl,targetName,...
        'Build Model Reference Target',...
        false);

        PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,...
        targetName,...
        'Build Model Reference Target',false);


        if iBuildArgs.XilInfo.UpdatingRTWTargetsForXil
            iBuildArgs.Verbose=oldVerbose;
        end

        if profileOn
            SLPerfLogData('cacheMdlRefInfo',iBuildArgs.TopOfBuildModel,...
            iMdl,mdlRefTgtType);
        end

    catch myException

    end


    modelCAPIMgr.restoreCAPIValues();


    oRTWCodeWasUptodate=isequal(get_param(iMdl,'RTWCodeWasUptodate'),'on');
    oInfoStructChanged=true;
    oWasCodeCompiled=false;
    oWasInterfaceResaved=false;
    if~isempty(iBuildState.buildResult)
        if isfield(iBuildState.buildResult,'InfoStructChanged')
            oInfoStructChanged=iBuildState.buildResult.InfoStructChanged;
        end
        if isfield(iBuildState.buildResult,'WasCodeCompiled')
            oWasCodeCompiled=iBuildState.buildResult.WasCodeCompiled;
        end
        if isfield(iBuildState.buildResult,'interfaceResaveInfo')
            oWasInterfaceResaved=~isempty(iBuildState.buildResult.interfaceResaveInfo);
        end
    end

    if~iBuildState.isempty()
        if(~isempty(myException))
            isParallelBuild=~isempty(coder.internal.infoMATFileMgr('getParallelAnchorDir',iBuildArgs.ModelReferenceTargetType));
            if(~isParallelBuild)



                iBuildState.mMdlsToClose=setdiff(iBuildState.mMdlsToClose,iMdl);
            end
        end
    end

    if(~isempty(myException))
        rethrow(myException);
    end
end


function LocSetup(iMdl,iBuildState,iBuildArgs,lMdlRefSimModes)

    build_target('Setup',iMdl,iBuildState,iBuildArgs);
    iBuildState.mMdlRefPrms={};
    iBuildState.configSet=[];
    iBuildState.preserve_dirty=Simulink.PreserveDirtyFlag(iMdl,'blockDiagram');
    iBuildState.RTWGenSettings=get_param(iMdl,'RTWGenSettings');
    targetType=iBuildArgs.ModelReferenceTargetType;



    origConfigSet=getActiveConfigSet(iMdl);
    if isa(origConfigSet,'Simulink.ConfigSetRef')
        origConfigSet.refresh;
    end

    iBuildState.origConfigSet=origConfigSet;
    iBuildState.tmpConfigSet=origConfigSet;

    tmpConfigSet=switchConfigSet('ReplaceConfigSetRef',iMdl,origConfigSet);
    iBuildState.tmpConfigSet=tmpConfigSet;




    build_target('protectedModelCreatorSetup',iBuildState,iBuildArgs.TopOfBuildModel);

    set_param(iMdl,'ModelReferenceTargetType',targetType);


    if~strcmp(get_param(iMdl,'ModelReferenceSimTargetType'),'None')
        DAStudio.error('Simulink:modelReference:modelAlreadyCompiled',iMdl);
    end

    isSIMTarget=strcmp(targetType,'SIM');

    import Simulink.ModelReference.internal.SimulationMode
    lModelReferenceXILType='NONE';
    hasSIL=ismember(lMdlRefSimModes,SimulationMode.SimulationModeSIL);
    hasPIL=ismember(lMdlRefSimModes,SimulationMode.SimulationModePIL);
    if~isSIMTarget
        if hasSIL
            lModelReferenceXILType='SIL';
        elseif hasPIL
            lModelReferenceXILType='PIL';
        end
    end
    set_param(iMdl,'ModelReferenceXILType',lModelReferenceXILType);

    if isSIMTarget
        set_param(iMdl,'ModelReferenceSimTargetType','Accelerator');
        hTflControl=get_param(iMdl,'SimTargetFcnLibHandle');
        set_param(iMdl,'TargetFcnLibHandle',hTflControl);


        if strcmp(get_param(iMdl,'MulticoreDesignerActive'),'on')
            set_param(iMdl,'DataflowSimMaxThreads',iBuildArgs.DataflowMaxThreads);
        end

        set_param(iMdl,'ModelRefAnchorCPUInfo',iBuildArgs.ModelRefAnchorCPUInfo);
    end














    if strcmp(get_param(iMdl,'SystemTargetFile'),'raccel.tlc')

        hTflControl=get_param(iMdl,'SimTargetFcnLibHandle');
        set_param(iMdl,'TargetFcnLibHandle',hTflControl);
    end

end


function LocCleanup(iBuildState,iBuildArgs)

    set_param(iBuildState.mModel,'ModelReferenceSimTargetType','None');
    set_param(iBuildState.mModel,'ModelReferenceTargetType','NONE');
    set_param(iBuildState.mModel,'ModelReferenceXILType','NONE');
    set_param(iBuildState.mModel,'RTWGenSettings',iBuildState.RTWGenSettings);


    build_target('protectedModelCreatorCleanup',iBuildState,iBuildArgs.TopOfBuildModel);


    switchConfigSet('RestoreOrigConfigSet',iBuildState.mModel,...
    iBuildState.origConfigSet,iBuildState.tmpConfigSet,...
    iBuildState.ConfiguredForProtectedModel);

    delete(iBuildState.preserve_dirty);
    build_target('Cleanup',iBuildState,iBuildArgs);

end



