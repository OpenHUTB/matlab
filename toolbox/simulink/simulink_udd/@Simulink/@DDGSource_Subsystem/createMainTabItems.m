function items=createMainTabItems(source)




    dialogRefresh=true;
    isVisible=true;

    items={};

    thisBlockH=source.getBlock().handle;


    items=addWidget(source,items,'ShowPortLabels',isVisible);


    blockChoiceIsVisible=false;
    if showBlockChoice(thisBlockH)
        blockChoiceIsVisible=true;
    end
    items=addWidget(source,items,'BlockChoice',blockChoiceIsVisible);


    permissionIsVisible=true;
    if hidePermissions(thisBlockH)

        permissionIsVisible=false;
    end
    items=addWidget(source,items,'Permissions',permissionIsVisible);

    errorFcnIsVisible=true;
    if isStateflowBlock(thisBlockH)
        errorFcnIsVisible=false;
    end

    items=addWidget(source,items,'ErrorFcn',errorFcnIsVisible);

    permitIsVisible=true;
    if isStateflowBlock(thisBlockH)
        permitIsVisible=false;
    end

    items=addWidget(source,items,'PermitHierarchicalResolution',permitIsVisible);

    treatAsAtomicUnitIsVisible=false;
    if showTreatAsAtomicUnit(source,source.getBlock)
        treatAsAtomicUnitIsVisible=true;
    end


    items=addWidget(source,items,'TreatAsAtomicUnit',treatAsAtomicUnitIsVisible,dialogRefresh);

    isVirtualSubsystem=treatAsAtomicUnitIsVisible&&getIsVirtualSubsystem(thisBlockH);
    isAtomicSubsystem=treatAsAtomicUnitIsVisible&&getIsAtomicSubsystem(thisBlockH);

    algLoopIsVisible=false;
    if(isAtomicSubsystem||showMinAlgLoopOccurrences(source.getBlock.handle))
        algLoopIsVisible=true;
    end

    if slfeature('SupportResetWithInit')
        showCustomPorts=false;

        if showScopedEventPorts(source,isAtomicSubsystem)
            showCustomPorts=true;
        end


        items=addWidget(source,items,'ShowSubsystemReinitializePorts',showCustomPorts,dialogRefresh);
    end


    items=addWidget(source,items,'MinAlgLoopOccurrences',algLoopIsVisible);

    scheduleAsIsVisible=false;
    if isAtomicSubsystem&&showScheduleAs(source)
        scheduleAsIsVisible=true;
    end


    items=addWidget(source,items,'ScheduleAs',scheduleAsIsVisible,dialogRefresh);


    partitionNameIsVisible=false;
    if isAtomicSubsystem&&~scheduleAsIsSampleTime(source)
        partitionNameIsVisible=true;
    end


    items=addWidget(source,items,'PartitionName',partitionNameIsVisible);

    sampleTimeIsVisible=false;

    if getIsMessagePollingSubsystem(thisBlockH)||...
        (isAtomicSubsystem&&~scheduleAsIsAperiodic(source))
        sampleTimeIsVisible=true;
    end


    item=createSampleTimeWidget(source,sampleTimeIsVisible);
    items=appendWidget(source,items,item);



    variantCondIsVisible=false;
    if isVirtualSubsystem&&~getIsChoiceBlock(source.getBlock.Handle)
        variantCondIsVisible=true;
    end


    items=addWidget(source,items,'TreatAsGroupedWhenPropagatingVariantConditions',variantCondIsVisible);

end


function ret=showBlockChoice(blockH)
    ret=false;
    if~isempty(get_param(blockH,'TemplateBlock'))
        ret=true;
    end
end

function ret=showMinAlgLoopOccurrences(block)





    ret=false;
    ssType=Simulink.SubsystemType(block);
    if ssType.isEnabledSubsystem()||ssType.isTriggeredSubsystem()...
        ||ssType.isForEachSubsystem()||ssType.isEnabledAndTriggeredSubsystem()
        ret=true;
    end
end


function ret=showTreatAsAtomicUnit(source,block)
    ret=false;

    if getIsCondExecSubsystem(source,block)
        return;
    end



    if strcmp(get_param(block.handle,'IsInjectorSS'),'on')
        return;
    end


    if getIsHardwareSubsystem(block)
        return;
    end


    if(strcmp(get_param(block.Handle,'SetExecutionDomain'),'on')&&...
        strcmp(get_param(block.Handle,'ExecutionDomainType'),'Dataflow'))
        return;
    end

    ret=true;
    return;
end

function ret=showScheduleAs(source)
    ret=true;
    model=bdroot(source.getBlock.handle);

    if strcmp(get_param(model,'SolverType'),'Variable-step')
        return;
    end

    if strcmp(get_param(model,'EnableMultiTasking'),'on')
        return;
    end




    prmVal=get_param(source.getBlock.handle,'ScheduleAs');
    if~getStringIsSampleTime(prmVal)
        return;
    end
    ret=false;
end

function ret=scheduleAsIsAperiodic(source)
    ret=false;
    prmVal=Simulink.internal.SlimDialog.getParamValueFromCustomDDGDialog(source,'ScheduleAs');
    if getStringIsAperiodic(prmVal)
        ret=true;
    end
end

function ret=getStringIsSampleTime(str)

    ret=false;

    traSampleTime=DAStudio.message('Simulink:dialog:ScheduleAsOptionsSampleTime');
    engSampleTime='Sample time';
    if strcmp(str,engSampleTime)||strcmp(str,traSampleTime)
        ret=true;
    end
end

function ret=getStringIsAperiodic(str)

    ret=false;

    traAperiodic=DAStudio.message('Simulink:dialog:ScheduleAsOptionsAperiodicPartition');
    engAperiodic='Aperiodic partition';
    if strcmp(str,traAperiodic)||strcmp(str,engAperiodic)
        ret=true;
    end
end

function ret=scheduleAsIsSampleTime(source)
    ret=false;
    prmVal=Simulink.internal.SlimDialog.getParamValueFromCustomDDGDialog(source,'ScheduleAs');
    if getStringIsSampleTime(prmVal)
        ret=true;
    end
end

function ret=getIsVirtualSubsystem(blkH)

    ret=false;
    prmVal=get_param(blkH,'TreatAsAtomicUnit');
    if strcmp(prmVal,'off')
        ret=true;
    end
end

function ret=getIsAtomicSubsystem(blkH)

    ret=~getIsVirtualSubsystem(blkH);
end

function ret=getIsMessagePollingSubsystem(blkH)

    ssType=Simulink.SubsystemType(blkH);

    if(ssType.isMessageTriggeredSampleTime())
        ret=true;
    else
        ret=false;
    end
end


function ret=getIsHardwareSubsystem(block)
    ret=false;
    if(strcmp(get_param(block.Handle,'SystemType'),'Virtual'))
        return;
    end

    if(strcmp(get_param(block.Handle,'SystemType'),'EnabledSynchronous'))

        ret=true;
        return;
    end



    stateControl=find_system(block.Handle,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'BlockType','StateControl',...
    'StateControl','Synchronous');
    if~isempty(stateControl)
        ret=true;
    end
end

function ret=getIsChoiceBlock(blockH)


    parentHandle=get_param(get_param(blockH,'Parent'),'Handle');
    ret=slInternal('isVariantSubsystem',parentHandle);
end

function ret=hidePermissions(blockH)

    ret=false;
    parentHandle=get_param(get_param(blockH,'Parent'),'Handle');
    ssType=Simulink.SubsystemType(parentHandle);
    if ssType.isStateflowSubsystem
        ret=true;
    end
end

function ret=isStateflowBlock(blockH)

    ret=false;
    ssType=Simulink.SubsystemType(blockH);
    if ssType.isStateflowSubsystem
        ret=true;
    end
end


function item=createSampleTimeWidget(source,sampleTimeIsVisible)
    h=source.getBlock;
    SampleTime=Simulink.SampleTimeWidget.getCustomDdgWidget(...
    source,h,'SystemSampleTime','SystemSampleTimeType',1,1,1,true);
    SampleTime.Visible=sampleTimeIsVisible;
    SampleTime.Enabled=sampleTimeIsVisible;
    if source.isSlimDialog
        SampleTime.Source=h;
    end
    item=SampleTime;
end

function ret=showScopedEventPorts(source,isAtomic)
    ret=false;
    block=source.getBlock;
    ssType=Simulink.SubsystemType(block.handle);


    if(ssType.isStateflowSubsystem||ssType.isResettableSubsystem()...
        ||ssType.isSimulinkFunction()||ssType.isForEachSubsystem()...
        ||ssType.isMessageTriggeredFunction())
        return;
    end


    if strcmp(block.Mask,'on')&&strcmp(block.MaskType,'Sigbuilder block')
        return;
    end


    if getIsChoiceBlock(block.handle)
        return;
    end


    if isAtomic||source.getIsCondExecSubsystem(block)
        ret=true;
        return;
    end
end
