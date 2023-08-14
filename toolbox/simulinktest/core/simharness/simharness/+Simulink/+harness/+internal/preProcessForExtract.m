function[tsInfo,cleanupObjs,error_occ,extractSubsysExc]=preProcessForExtract(modelH,subsysH)





    featureOn=slsvTestingHook('UnifiedHarnessBackendMode')>0;
    assert(featureOn,'UnifiedHarnessBackendMode feature should be on when calling preProcessForExtract');

    modelName=get_param(modelH,'Name');

    tsInfo.bSetFixedStepAuto=true;
    cleanupObjs=[];

    extractSubsysExc=validateSSForExtract(subsysH);
    error_occ=~isempty(extractSubsysExc);
    if error_occ
        return;
    end





    if~any(strcmp(get_param(modelName,'SimulationStatus'),{'paused','compiled'}))
        clear cleanupObjs;
        needStrictBusCleanup=false;
        mdlObj=get_param(modelH,'Object');
        origCS=mdlObj.getActiveConfigSet();
        srcCS=origCS;
        while(isa(srcCS,'Simulink.ConfigSetRef'))
            srcCS=srcCS.getRefConfigSet();
        end
        newCS=attachConfigSetCopy(modelH,srcCS,true);
        setActiveConfigSet(modelH,newCS.Name)
        origStrictBusMsg=get_param(modelName,'StrictBusMsg');
        if~strcmp(origStrictBusMsg,'ErrorLevel1')&&...
            ~strcmp(origStrictBusMsg,'ErrorOnBusTreatedAsVector')
            set_param(modelName,'StrictBusMsg','ErrorOnBusTreatedAsVector');
            needStrictBusCleanup=true;
        end
        feval(modelName,[],[],[],'compileForSizes');
        cleanupObjs(1)=onCleanup(@()feval(modelName,[],[],[],'term'));
        cleanupObjs(2)=onCleanup(@()setActiveConfigSet(modelH,origCS.Name));
        cleanupObjs(3)=onCleanup(@()detachConfigSet(modelH,newCS.Name));
        if needStrictBusCleanup
            cleanupObjs(4)=onCleanup(@()set_param(modelName,'StrictBusMsg',origStrictBusMsg));
        end



        if strcmp(get_param(subsysH,'CompiledIsActive'),'off')
            extractSubsysExc=MException(message('RTW:buildProcess:InactiveSubsystem'));
            error_occ=true;
            return;
        end
    end








    tsInfo.fixedStepPrm=get_param(modelH,'FixedStep');

    tsInfo.bUseFundStepSize=false;
    tsInfo.bFundStepSize=str2double(get_param(modelH,'CompiledStepSize'));
    tsInfo.blkSampleTime=get_param(subsysH,'CompiledSampleTime');
    if~strcmpi(tsInfo.fixedStepPrm,'auto')
        tsInfo.bSetFixedStepAuto=coder.internal.SampleTimeChecks.loc_shouldUseAutoFixedStep(subsysH,tsInfo.bFundStepSize,tsInfo.blkSampleTime);
    else




        tsInfo.bUseFundStepSize=~coder.internal.SampleTimeChecks.loc_shouldUseAutoFixedStep(subsysH,tsInfo.bFundStepSize,tsInfo.blkSampleTime);
    end

    tsInfo.actualDataTypeOverride=get_param(subsysH,'DataTypeOverride_Compiled');

end




function mExc=validateSSForExtract(subsysH)
    ssType=Simulink.SubsystemType(subsysH);
    mExc=[];
    if ssType.isStateflowSubsystem
        chartHandle=sf('IdToHandle',sfprivate('block2chart',subsysH));

        p=chartHandle.find('-isa','Stateflow.Port');

        for i=1:length(p)
            if p(i).getParent()==chartHandle
                mExc=MException(message('RTW:buildProcess:PortInSubsystem'));
                break;
            end
        end
    end
    if~strcmp(get_param(subsysH,'Commented'),'off')
        mExc=MException(message('RTW:buildProcess:CommentedSubsystem'));
    end
end
