





function populateMapping(self,mapping,slPort2RefBiMap,slPort2AccessMap,...
    slIrvRef2RunnableMap,slParam2RefMap,slParamMap,dsmBlockMap,m3iComponent,userInitRunnable,...
    userResetRunnables,userTerminateRunnable,...
    sampleTimes,componentHasBehavior,m3iSwcTiming)




    excludeRunnableNames=m3i.mapcell(@(x)x.Name,m3iComponent.Behavior.Runnables);
    excludeEventNames=m3i.mapcell(@(x)x.Name,m3iComponent.Behavior.Events);

    maxShortNameLength=get_param(self.MdlName,'AutosarMaxShortNameLength');
    stepRunnableName=arxml.arxml_private('p_create_aridentifier',...
    matlab.lang.makeUniqueStrings(...
    [m3iComponent.Name,'_Step'],...
    excludeRunnableNames),maxShortNameLength);
    stepEventName=arxml.arxml_private('p_create_aridentifier',...
    matlab.lang.makeUniqueStrings(...
    ['Evt_',m3iComponent.Name,'_Step'],...
    excludeEventNames),maxShortNameLength);

    transaction=M3I.Transaction(m3iComponent.rootModel);


    isAdaptiveApplication=isa(m3iComponent,'Simulink.metamodel.arplatform.component.AdaptiveApplication');
    componentId=m3iComponent.qualifiedName;
    if isAdaptiveApplication
        appObj=Simulink.AutosarTarget.Application(componentId,m3iComponent.Name);
        mapping.mapApplication(appObj);
    else
        compObj=Simulink.AutosarTarget.Component(componentId,m3iComponent.Name);
        mapping.mapComponent(compObj);
    end


    supportedRunnables=[];
    supportedEvents={};
    assert(~isempty(userInitRunnable),'m3iComp should always have an init runnable at this point.');
    initRunnable=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
    m3iComponent.Behavior,m3iComponent.Behavior.Runnables,...
    userInitRunnable,'Simulink.metamodel.arplatform.behavior.Runnable');


    if isempty(userResetRunnables)
        resetRunnables={};
    else
        resetRunnables=cellfun(@(lRunnable)Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
        m3iComponent.Behavior,m3iComponent.Behavior.Runnables,...
        lRunnable,'Simulink.metamodel.arplatform.behavior.Runnable'),...
        userResetRunnables,...
        'UniformOutput',false);
    end

    if isempty(userTerminateRunnable)
        terminateRunnable=[];
    else
        terminateRunnable=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
        m3iComponent.Behavior,m3iComponent.Behavior.Runnables,...
        userTerminateRunnable,'Simulink.metamodel.arplatform.behavior.Runnable');
    end


    runnableToTimingEventsMap=containers.Map;
    for rIndex=1:m3iComponent.Behavior.Runnables.size()
        m3iRunnable=m3iComponent.Behavior.Runnables.at(rIndex);

        if initRunnable==m3iRunnable

            continue
        end

        supportedRunnables=[supportedRunnables,m3iRunnable];%#ok<AGROW>

        hasModeSwitchEvent=false;
        hasInitEvent=false;
        hasOpInvokedEvent=false;
        for eIndex=1:m3iRunnable.Events.size()
            m3iEvent=m3iRunnable.Events.at(eIndex);
            if m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass&&...
                ~runnableToTimingEventsMap.isKey(m3iRunnable.Name)

                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
                runnableToTimingEventsMap(m3iRunnable.Name)=m3iEvent.Name;
            elseif m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.DataReceivedEvent.MetaClass

                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            elseif m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent.MetaClass

                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            elseif~hasModeSwitchEvent&&m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.ModeSwitchEvent.MetaClass

                hasModeSwitchEvent=true;
                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            elseif~hasInitEvent&&m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.InitEvent.MetaClass

                hasInitEvent=true;
                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            elseif~hasOpInvokedEvent&&m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass

                hasOpInvokedEvent=true;
                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            elseif m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.ExternalTriggerOccurredEvent.MetaClass

                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            elseif m3iEvent.MetaClass==Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass
                supportedEvents{end+1}=m3iEvent;%#ok<AGROW>
            else

            end
        end
    end



    addedDefaultTimingEvent=false;
    if~componentHasBehavior
        addedDefaultTimingEvent=true;
        assert(isempty(sampleTimes),'sampleTimes should be empty if model has no timing events');

        periodicRunnable=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
        m3iComponent.Behavior,m3iComponent.Behavior.Runnables,...
        stepRunnableName,'Simulink.metamodel.arplatform.behavior.Runnable');
        periodicRunnable.symbol=periodicRunnable.Name;
        supportedRunnables=[supportedRunnables,periodicRunnable];


        timeEvt=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
        m3iComponent.Behavior,m3iComponent.Behavior.Events,...
        stepEventName,'Simulink.metamodel.arplatform.behavior.TimingEvent');
        timeEvt.StartOnEvent=periodicRunnable;
        timeEvt.Period=0.2;
        supportedEvents{end+1}=timeEvt;

        sampleTimes=timeEvt.Period;
    end


    for eIndex=1:initRunnable.Events.size()
        initEvent=initRunnable.Events.at(eIndex);
        if autosar.mm.mm2sl.InitRunnableFinder.supportedEvent(initEvent)&&...
            ~((initEvent.getMetaClass==Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass)&&...
            (initEvent.Period==0))
            supportedEvents{end+1}=initEvent;%#ok<AGROW>
            break
        end
    end


    rIndex=1;
    while rIndex<=m3iComponent.Behavior.Runnables.size()
        doNotDeleteRunnable=false;
        for ii=1:length(supportedRunnables)
            if supportedRunnables(ii)==m3iComponent.Behavior.Runnables.at(rIndex)
                doNotDeleteRunnable=true;
                break;
            end
        end
        if~doNotDeleteRunnable
            if initRunnable==m3iComponent.Behavior.Runnables.at(rIndex)
                doNotDeleteRunnable=true;
            end
        end
        if~doNotDeleteRunnable
            m3iComponent.Behavior.Runnables.at(rIndex).destroy();
            rIndex=1;
            continue;
        end
        rIndex=rIndex+1;
    end


    eIndex=1;
    while eIndex<=m3iComponent.Behavior.Events.size()
        foundEvent=false;
        for ii=1:length(supportedEvents)
            if supportedEvents{ii}==m3iComponent.Behavior.Events.at(eIndex)
                foundEvent=true;
                break;
            end
        end
        if~foundEvent
            m3iComponent.Behavior.Events.at(eIndex).destroy();
            eIndex=1;
            continue;
        end
        eIndex=eIndex+1;
    end


    isExportFunctionsModelingStyle=isequal(self.ModelPeriodicRunnablesAs,'FunctionCallSubsystem');
    if~isExportFunctionsModelingStyle&&(length(unique(sampleTimes))>1)
        autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,self.MdlName,'EnableMultiTasking','on');
    end




    if~isExportFunctionsModelingStyle
        loc_configureRunnablesAsPartitions(self);
    end




    if isprop(mapping,'InitializeFunctions')&&~isempty(mapping.InitializeFunctions)
        autosar.api.Utils.mapFunction(self.MdlName,...
        mapping.InitializeFunctions,initRunnable.Name);
    end



    mappingObj=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
    if~self.UpdateMode&&~isAdaptiveApplication


        mappedRunnables=[];
        for ssHandles=self.slRunnableFcnCallInport2RefBiMap.getLeftKeys()
            fcnCallPortName=get_param(ssHandles{1},'Name');
            runnableName=self.slRunnableFcnCallInport2RefBiMap.getLeft(ssHandles{1}).Runnables.Name;
            mappingObj.mapFunction(['ExportedFunction:',fcnCallPortName],runnableName);
            mappedRunnables{end+1}=runnableName;%#ok<AGROW>
        end


        stepFcnsCount=0;
        for ii=1:m3iComponent.Behavior.Runnables.size()
            m3iRun=m3iComponent.Behavior.Runnables.at(ii);
            isRunnableMapped=any(strcmp(m3iRun.Name,mappedRunnables));
            if~isRunnableMapped
                if autosar.mm.mm2sl.RunnableHelper.isServerRunnable(m3iRun)||...
                    autosar.mm.mm2sl.RunnableHelper.isInternallyTriggeredRunnable(m3iRun)
                    mappingObj.mapFunction(['SimulinkFunction:',m3iRun.symbol],m3iRun.Name);
                else
                    [isPeriodicRun,m3iEvent]=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                    Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
                    if isPeriodicRun
                        stepFcnsCount=stepFcnsCount+1;
                        period=m3iEvent.Period;
                        if length(mapping.StepFunctions)>=stepFcnsCount
                            mapping.StepFunctions(stepFcnsCount).setPeriod(period);
                        else
                            mapping.addStepFunction(m3iRun.Name,period,0);
                        end
                        blkMapping=mapping.StepFunctions(stepFcnsCount);
                        if~isempty(blkMapping)
                            autosar.api.Utils.mapFunction(self.MdlName,...
                            blkMapping,m3iRun.Name);
                        end
                    end
                end
            end
        end
    end


    if~isAdaptiveApplication&&~isempty(sampleTimes)
        period=mapping.computeBasePeriod(sampleTimes);
        periodStr=Simulink.metamodel.arplatform.getRealStringCompact(period);


        if~(self.UpdateMode&&strcmp(get_param(self.MdlName,'FixedStep'),'auto'))
            autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,self.MdlName,...
            'FixedStep',periodStr);
        end


        if~isExportFunctionsModelingStyle||~componentHasBehavior
            if strcmp(get_param(self.MdlName,'SampleTimeConstraint'),'Specified')
                stProp=struct('SampleTime','','Offset','','Priority',0);
                for i=1:length(sampleTimes)
                    stProp(i).SampleTime=...
                    Simulink.metamodel.arplatform.getRealStringCompact(sampleTimes(i));
                    stProp(i).Offset='0';








                    if strcmp(get_param(self.MdlName,'PositivePriorityOrder'),'off')
                        stProp(i).Priority=i+39;
                    else
                        stProp(i).Priority=41-i;
                    end
                end
                autosar.mm.mm2sl.SLModelBuilder.set_param(...
                self.ChangeLogger,self.MdlName,'SampleTimeConstraint',...
                'Specified');
                autosar.mm.mm2sl.SLModelBuilder.set_param(...
                self.ChangeLogger,self.MdlName,'SampleTimeProperty',...
                stProp);
            end
        end
    end


    if~isAdaptiveApplication&&isempty(mapping.FcnCallInports)&&isempty(mapping.ServerFunctions)
        if addedDefaultTimingEvent&&~self.UpdateMode



            rootOutports=find_system(self.MdlName,'SearchDepth',1,...
            'Type','block','BlockType','Outport');

            for i=1:length(rootOutports)
                outBlkH=get_param(rootOutports(i),'Handle');
                isBusElementPort=strcmp(get_param(outBlkH{1},'IsBusElementPort'),'on');
                if~isBusElementPort
                    autosar.mm.mm2sl.SLModelBuilder.set_param(...
                    self.ChangeLogger,outBlkH{1},'SampleTime',periodStr);
                end
            end


            rootFcnCallerSrcs=find_system(self.MdlName,'SearchDepth',1,...
            'Type','block','BlockType','FunctionCaller',...
            'InputArgumentSpecifications','');
            for i=1:length(rootFcnCallerSrcs)
                fcnBlkH=get_param(rootFcnCallerSrcs(i),'Handle');
                if autosar.bsw.BasicSoftwareCaller.isBSWCallerBlock(fcnBlkH{1})
                    sampleTimeVar='st';
                else
                    sampleTimeVar='SampleTime';
                end
                autosar.mm.mm2sl.SLModelBuilder.set_param(...
                self.ChangeLogger,...
                fcnBlkH{1},...
                sampleTimeVar,...
                periodStr);
            end
        end
    end


    self.populatePortsMapping(slPort2RefBiMap,slPort2AccessMap);
    if isAdaptiveApplication
        autosar.internal.adaptive.manifest.ManifestUtilities.syncManifestMetaModelWithAutosarDictionary(self.MdlName,m3iComponent);
    end
    transaction.commit();

    modelMapping=autosar.api.Utils.modelMapping(self.MdlName);
    if~isAdaptiveApplication
        modelMapping.syncFunctionCallers();
    end

    opKeys=self.slCallerOp2PortNameMap.getKeys();
    if isAdaptiveApplication

    else
        for ii=1:numel(opKeys)

            slFcnBlkH=opKeys{ii};
            portName=self.slCallerOp2PortNameMap(slFcnBlkH);
            opName=regexprep(slFcnBlkH,[portName,'/'],'');
            functionName=autosar.mm.util.FcnCallerHelper.getDefaultFunctionName(portName,opName);
            slMapping=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
            slMapping.mapFunctionCaller(functionName,portName,opName);
        end
    end


    internalTrigBlocks=self.InternalTrigBlk2TriggeringRunMap.getKeys();
    for ii=1:numel(internalTrigBlocks)
        internalTrigBlock=internalTrigBlocks{ii};
        triggeringRunName=self.InternalTrigBlk2TriggeringRunMap(internalTrigBlock);
        autosar.blocks.InternalTriggerBlock.mapInternalTriggerBlock(...
        internalTrigBlock,triggeringRunName);
    end

    paramKeys=slParam2RefMap.keys();
    for ii=1:numel(paramKeys)
        paramName=paramKeys{ii};
        instanceRef=slParam2RefMap(paramName);
        modelMapping=autosar.api.Utils.modelMapping(self.MdlName);
        if isa(instanceRef,'Simulink.metamodel.arplatform.instance.ParameterDataCompInstanceRef')
            switch instanceRef.DataElements.Kind
            case Simulink.metamodel.arplatform.behavior.ParameterKind.Const
                paramAccessMode='ConstantMemory';
            case Simulink.metamodel.arplatform.behavior.ParameterKind.Pim
                paramAccessMode='PerInstance';
            case Simulink.metamodel.arplatform.behavior.ParameterKind.Shared
                paramAccessMode='Shared';
            otherwise
                continue;
            end
            modelMapping.mapLookupTable(paramName,paramAccessMode,'',instanceRef.DataElements.Name,'');
        elseif isa(instanceRef,'Simulink.metamodel.arplatform.instance.ParameterDataPortInstanceRef')
            modelMapping.mapLookupTable(paramName,'PortParameter',instanceRef.Port.Name,instanceRef.DataElements.Name,'');
        end
    end

    if~isa(modelMapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
        self.setEndToEndProtectionMethod(m3iComponent.Behavior);

        slMapping=autosar.api.getSimulinkMapping(self.MdlName);
        loc_mapDataStores(self.MdlName,dsmBlockMap,slMapping);
        loc_mapParameters(self.MdlName,slParamMap,slMapping);



        loc_updateMapping(self,mapping,slIrvRef2RunnableMap,resetRunnables,terminateRunnable,m3iSwcTiming);
    end

end


function[slIrvNames,arIrvNames,irvAccessModes]=loc_getDataTransfers(self,mapping,slIrvRef2RunnableMap)

    slIrvNames={};
    arIrvNames={};
    irvAccessModes={};
    if~slIrvRef2RunnableMap.isempty()
        isExportFunctionsModelingStyle=strcmp(self.ModelPeriodicRunnablesAs,'FunctionCallSubsystem');
        for irvRefs=slIrvRef2RunnableMap.getKeys()
            connectedRunnables=slIrvRef2RunnableMap(irvRefs{1});
            isConnected=~isempty(connectedRunnables)&&...
            ~isempty(connectedRunnables.src)&&~isempty(connectedRunnables.dst);
            if isConnected
                irvName=irvRefs{1}.DataElements.Name;
                irvAccessMode=irvRefs{1}.DataElements.Kind.toString();





                isMapped=false;
                if self.UpdateMode&&isExportFunctionsModelingStyle
                    for ii=1:length(mapping.DataTransfers)
                        dataTransfer=mapping.DataTransfers(ii);
                        if strcmp(irvName,dataTransfer.MappedTo.IrvName)
                            isMapped=true;
                            sLIrvName=dataTransfer.SignalName;
                            break
                        end
                    end
                end


                if~isMapped
                    if isExportFunctionsModelingStyle
                        sLIrvName=irvName;
                    else
                        sLIrvName=[get(connectedRunnables.dst,'Path'),'/',irvName];
                    end
                end
                slIrvNames{end+1}=sLIrvName;%#ok<AGROW>
                arIrvNames{end+1}=irvName;%#ok<AGROW>
                irvAccessModes{end+1}=irvAccessMode;%#ok<AGROW>
            end
        end
    end
end

function loc_updateMapping(self,mapping,slIrvRef2RunnableMap,resetRunnables,terminateRunnable,m3iSwcTiming)







    lNeedsUpdateToMapReset=~isempty(resetRunnables);
    lNeedsUpdateToMapTerminate=~isempty(terminateRunnable);
    lHasIrvsToMap=~slIrvRef2RunnableMap.isempty();
    lHasEOC=autosar.timing.mm2sl.SwcViewBuilder.hasExecutionOrderConstraints(m3iSwcTiming);
    lHasPartitions=...
    (~isempty(Simulink.findBlocks(self.MdlName,'BlockType','SubSystem','ScheduleAs','Periodic partition'))||...
    ~isempty(Simulink.findBlocks(self.MdlName,'BlockType','SubSystem','ScheduleAs','Aperiodic partition')));

    if lNeedsUpdateToMapReset||lNeedsUpdateToMapTerminate||lHasIrvsToMap||lHasEOC||lHasPartitions

        [cleanupObj,restoreModelParameters,lCompileSuccess]=loc_SetCompileState(self.MdlName,self.UpdateMode);

        if~lCompileSuccess



            return;
        end


        [slIrvNames,arIrvNames,irvAccessModes]=loc_getDataTransfers(self,...
        mapping,slIrvRef2RunnableMap);


        if lHasIrvsToMap
            mappingObj=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
            for idx=1:length(slIrvNames)
                try
                    mappingObj.mapDataTransfer(slIrvNames{idx},arIrvNames{idx},irvAccessModes{idx});
                catch ME
                    if self.UpdateMode





                        MSLDiagnostic('autosarstandard:importer:UpdateModelFailedToMapDataTransfer',...
                        self.MdlName,ME.getReport()).reportAsWarning;
                    else

                        rethrow(ME)
                    end
                end
            end
        end


        for kRst=1:numel(mapping.ResetFunctions)
            autosar.api.Utils.mapFunction(self.MdlName,...
            mapping.ResetFunctions(kRst),resetRunnables{kRst}.Name);
        end
        if~isempty(mapping.TerminateFunctions)&&~isempty(terminateRunnable)
            autosar.api.Utils.mapFunction(self.MdlName,...
            mapping.TerminateFunctions,terminateRunnable.Name);
        end


        if lHasPartitions
            mappingObj=autosar.api.getSimulinkMapping(self.MdlName);
            for ssHandles=self.slRunnableSubSystem2RefBiMap.getLeftKeys()
                partitionName=get_param(ssHandles{1},'PartitionName');
                if isempty(partitionName)
                    continue
                end

                runnableName=self.slRunnableSubSystem2RefBiMap.getLeft(ssHandles{1}).Runnables.Name;
                mappingObj.mapFunction(['Partition:',partitionName],runnableName);
            end
        end

        cleanupObj.delete();
        if~isempty(restoreModelParameters)
            restoreModelParameters.delete();
        end


        if lHasEOC
            swcViewBuilder=autosar.timing.mm2sl.SwcViewBuilder(self.MdlName,self.UpdateMode,m3iSwcTiming);
            swcViewBuilder.build();
        end
    end
end

function[cleanupObj,restoreModelParameters,lSuccess]=loc_SetCompileState(lModelName,lUpdateMode)

    assert(strcmp(get_param(lModelName,'SimulationStatus'),'stopped'),'Model should be stopped');


    restoreModelParameters=loc_beforeCompileDisableModelParameters(lModelName);
    lSuccess=false;
    try
        cleanupObj=autosar.validation.CompiledModelUtils.forceCompiledModel(lModelName);
        lSuccess=true;
    catch ME
        if lUpdateMode


            autosar.mm.util.MessageReporter.createWarning(...
            'autosarstandard:importer:UpdateModelFailedToMapDataTransfer',...
            lModelName,ME.getReport());
            cleanupObj=onCleanup.empty;
            return;
        else

            rethrow(ME);
        end
    end
end


function restoreModelParameters=loc_beforeCompileDisableModelParameters(modelName)



    restoreModelParameters=[];

    isConfigSetRef=isa(getActiveConfigSet(modelName),'Simulink.ConfigSetRef');
    if~isConfigSetRef
        loadExternalInput=get_param(modelName,'LoadExternalInput');
        set_param(modelName,'LoadExternalInput','off');
        restoreModelParameters=onCleanup(@()set_param(modelName,'LoadExternalInput',loadExternalInput));
    end
end

function loc_mapDataStores(modelName,dsmBlockMap,slMapping)
    dsmNames=dsmBlockMap.keys;
    for dsmIdx=1:numel(dsmNames)
        dsmName=dsmNames{dsmIdx};
        dsmContext=dsmBlockMap(dsmName);
        dsmBlk=dsmContext.blkH;
        codeProps=dsmContext.codeProperties;
        variableRole=codeProps.VariableRole;

        signalName=get_param(dsmBlk,'DataStoreName');
        [doesExist,signalObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,signalName);
        if(doesExist&&autosar.mm.mm2sl.SignalBuilder.isLegacyPIMSignalObject(signalObj))

            continue;
        end

        extraArgs={};

        switch codeProps.VariableRole
        case 'ArTypedPerInstanceMemory'
            if~isempty(codeProps.NeedsNVRAMAccess)
                if codeProps.NeedsNVRAMAccess
                    extraArgs=[extraArgs,{'NeedsNVRAMAccess','true'}];%#ok<AGROW>

                    nvBlockNeedsFieldNames=fieldnames(codeProps.NvBlockNeeds);
                    for i=1:length(nvBlockNeedsFieldNames)
                        nvBlockNeedsValue=codeProps.NvBlockNeeds.(nvBlockNeedsFieldNames{i});
                        if islogical(nvBlockNeedsValue)
                            nvBlockNeedsValue=autosar.mm.util.NvBlockNeedsCodePropsHelper.convertNvBlockNeedFromLogicalToString(nvBlockNeedsValue);
                        end
                        extraArgs=[extraArgs,{nvBlockNeedsFieldNames{i},nvBlockNeedsValue}];%#ok<AGROW>
                    end
                else
                    extraArgs=[extraArgs,{'NeedsNVRAMAccess','false'}];%#ok<AGROW>
                end
            end
        case 'StaticMemory'

            if~isempty(codeProps.AdditionalNativeTypeQualifier)
                extraArgs=[extraArgs,{'Qualifier',codeProps.AdditionalNativeTypeQualifier}];%#ok<AGROW>
            end

            if~isempty(codeProps.Volatile)
                if codeProps.Volatile
                    extraArgs=[extraArgs,{'IsVolatile','true'}];%#ok<AGROW>
                else
                    extraArgs=[extraArgs,{'IsVolatile','false'}];%#ok<AGROW>
                end
            end

        otherwise
            assert(false,'parameter type is expected to be either ArTypedPerInstanceMemory or StaticMemory');
        end

        if~isempty(codeProps.SwAddrMethod)
            extraArgs=[extraArgs,{'SwAddrMethod',codeProps.SwAddrMethod}];%#ok<AGROW>
        end

        if~isempty(codeProps.SwCalibAccess)
            extraArgs=[extraArgs,{'SwCalibrationAccess',codeProps.SwCalibAccess}];%#ok<AGROW>
        end

        if~isempty(codeProps.DisplayFormat)
            extraArgs=[extraArgs,{'DisplayFormat',codeProps.DisplayFormat}];%#ok<AGROW>
        end

        if slfeature('AUTOSARLongNameAuthoring')
            if~isempty(codeProps.LongName)
                extraArgs=[extraArgs,{'LongName',codeProps.LongName}];%#ok<AGROW>
            end
        end

        slMapping.mapDataStore(dsmBlk,variableRole,...
        'ShortName',dsmName,...
        extraArgs{:});
    end
end

function loc_mapParameters(modelName,paramMap,slMapping)

    paramKeys=paramMap.keys;
    for ii=1:numel(paramKeys)
        paramName=paramKeys{ii};
        codeProps=paramMap(paramName);

        if isempty(codeProps.paramType)
            continue
        end

        extraArgs={};

        switch codeProps.paramType
        case 'ConstantMemory'
            if~isempty(codeProps.Const)
                extraArgs=[extraArgs,{'IsConst',codeProps.Const}];%#ok<AGROW>
            end

            if~isempty(codeProps.Volatile)
                extraArgs=[extraArgs,{'IsVolatile',codeProps.Volatile}];%#ok<AGROW>
            end

            if~isempty(codeProps.AdditionalNativeTypeQualifier)
                extraArgs=[extraArgs,{'Qualifier',codeProps.AdditionalNativeTypeQualifier}];%#ok<AGROW>
            end
        case 'SharedParameter'

        case 'PerInstanceParameter'

            mm=autosar.api.Utils.modelMapping(modelName);
            idx=strcmp(paramName,{mm.ModelScopedParameters.Parameter});
            assert(mm.ModelScopedParameters(idx).InstanceSpecific,'Parameter needs to be instance specific');
        case 'PortParameter'
            extraArgs=[extraArgs,{'Port',codeProps.Port,'DataElement',codeProps.DataElement}];%#ok<AGROW>
        otherwise
            assert(false,'parameter type is expected to be either SharedParameter, ConstantMemory, PerInstanceParameter or PortParameter');
        end

        if~isempty(codeProps.SwAddrMethod)
            extraArgs=[extraArgs,{'SwAddrMethod',codeProps.SwAddrMethod}];%#ok<AGROW>
        end

        if~isempty(codeProps.SwCalibAccess)
            extraArgs=[extraArgs,{'SwCalibrationAccess',codeProps.SwCalibAccess}];%#ok<AGROW>
        end

        if~isempty(codeProps.DisplayFormat)
            extraArgs=[extraArgs,{'DisplayFormat',codeProps.DisplayFormat}];%#ok<AGROW>
        end

        if slfeature('AUTOSARLongNameAuthoring')
            if~isempty(codeProps.LongName)
                extraArgs=[extraArgs,{'LongName',codeProps.LongName}];%#ok<AGROW>
            end
        end

        slMapping.mapParameter(paramName,codeProps.paramType,extraArgs{:});
    end
end

function loc_configureRunnablesAsPartitions(self)



    m3iComponent=autosar.api.Utils.m3iMappedComponent(self.MdlName);
    periodicRunnablesSampleTimes=autosar.mm.mm2sl.PeriodicRunnablesModelingStyleDeterminer.collectPeriodicRunnableSampleTimes(m3iComponent.Behavior.Runnables);
    anyRepeated=(length(periodicRunnablesSampleTimes)~=length(unique(periodicRunnablesSampleTimes)));
    hasAperiodicSS=any(arrayfun(@(x)strcmp(get_param(x{1},'SystemSampleTime'),'-1'),self.slRunnableSubSystem2RefBiMap.getLeftKeys()));
    if~anyRepeated&&~hasAperiodicSS
        return
    end



    set_param(self.MdlName,'EnableMultiTasking','on');


    [~,ind]=unique(periodicRunnablesSampleTimes);
    duplicatedIndices=setdiff(1:size(periodicRunnablesSampleTimes),ind);
    duplicatedValues=unique(periodicRunnablesSampleTimes(duplicatedIndices));


    for ssHandles=self.slRunnableSubSystem2RefBiMap.getLeftKeys()
        sampleTime=get_param(ssHandles{1},'SystemSampleTime');
        if strcmp(sampleTime,'-1')

            subsystemName=get_param(ssHandles{1},'Name');
            set_param(ssHandles{1},...
            'ScheduleAs','Aperiodic partition',...
            'PartitionName',subsystemName);
        elseif sum(ismember(string(duplicatedValues),sampleTime))>0

            subsystemName=get_param(ssHandles{1},'Name');
            set_param(ssHandles{1},...
            'ScheduleAs','Periodic partition',...
            'PartitionName',subsystemName);
        end
    end
end



