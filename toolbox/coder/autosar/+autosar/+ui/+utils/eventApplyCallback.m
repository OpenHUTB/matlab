




function[status,errmsg]=eventApplyCallback(~,m3iObj)
    status=0;
    errmsg='';

    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));

    arPkg='Simulink.metamodel.arplatform';
    dataCls=[arPkg,'.interface.FlowData'];
    opCls=[arPkg,'.interface.Operation'];
    rPortCls=[arPkg,'.port.DataReceiverPort'];
    sPortCls=[arPkg,'.port.ServerPort'];
    trPortCls=[arPkg,'.port.TriggerReceiverPort'];
    triggersCls=[arPkg,'.interface.Trigger'];

    eventsObj=m3iObj.containerM3I.Events;
    eventData=arExplorer.EventData;
    modelM3I=m3iObj.modelM3I;
    assert(modelM3I.RootPackage.size==1);
    compObj=m3iObj.containerM3I.containerM3I;
    behaviorObj=compObj.Behavior;
    eventList={};
    mapping=arExplorer.MappingManager.getActiveMappingFor('AutosarTarget');
    modelName=autosar.api.Utils.getModelNameFromMapping(mapping);
    schemaVersion=get_param(modelName,'AutosarSchemaVersion');
    mappedToSLinport=false;

    for index=1:length(eventData)


        if any(strcmp(eventData(index).EventType,...
            {autosar.ui.wizard.PackageString.EventTypes{2},...
            autosar.ui.wizard.PackageString.EventTypes{4},...
            autosar.ui.wizard.PackageString.EventTypes{6},...
            autosar.ui.wizard.PackageString.EventTypes{7}}))
            if strcmp(eventData(index).TriggerPort,...
                DAStudio.message('RTW:autosar:selectERstr'))
                errordlg(DAStudio.message('RTW:autosar:portNotFound',eventData(index).Name),...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                return;
            end
        elseif strcmp(eventData(index).EventType,...
            autosar.ui.wizard.PackageString.EventTypes{3})

            if strcmp(eventData(index).Activation,...
                DAStudio.message('RTW:autosar:selectERstr'))
                errordlg(DAStudio.message('RTW:autosar:eventElementNotFound',...
                DAStudio.message('autosarstandard:ui:uiModeActivationStr'),...
                eventData(index).Name,DAStudio.message('autosarstandard:ui:uiModeActivationStr')),...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                return;
            end

            if strcmp(eventData(index).ModeReceiverPort,...
                DAStudio.message('RTW:autosar:selectERstr'))
                errordlg(DAStudio.message('RTW:autosar:eventElementNotFound',...
                DAStudio.message('autosarstandard:ui:uiModeReceiverPortStr'),...
                eventData(index).Name,DAStudio.message('autosarstandard:ui:uiModeReceiverPortStr')),...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                return;
            end
            for ii=1:length(mapping.Inports)
                if strcmp(mapping.Inports(ii).MappedTo.DataAccessMode,'ModeReceive')&&...
                    strcmp(mapping.Inports(ii).MappedTo.Port,eventData(index).ModeReceiverPort)
                    mappedToSLinport=true;
                    break;
                end
            end
            if mappedToSLinport
                [dataType,slInport,~]=getDataTypeFromModeReceiverPort(mapping,eventData(index).ModeReceiverPort);
                [modeNames,~,~,~,~,~]=autosar.mm.sl2mm.ModelBuilder.getMdgDataFromEnum(modelName,dataType);
                if isempty(modeNames)
                    errordlg(DAStudio.message('autosarstandard:validation:invalidDataTypeForMode',slInport),...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    return;
                end
                maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
                for ii=1:length(modeNames)
                    idcheckmessage=autosar.ui.utils.isValidARIdentifier(modeNames(ii),'shortName',maxShortNameLength);
                    if~isempty(idcheckmessage)
                        errordlg(DAStudio.message('RTW:autosar:errorInvalidEvent',[dataType,'.',modeNames{ii}],...
                        maxShortNameLength),...
                        autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                        return;
                    end
                end
            end
            switch eventData(index).Activation
            case{autosar.ui.wizard.PackageString.TransitionTypes{1},...
                autosar.ui.wizard.PackageString.TransitionTypes{2}}

                if strcmp(eventData(index).ModeDeclaration1,...
                    DAStudio.message('RTW:autosar:selectERstr'))
                    errordlg(DAStudio.message('RTW:autosar:eventElementNotFound',...
                    autosar.ui.metamodel.PackageString.ModeDeclarationStr,...
                    eventData(index).Name,DAStudio.message('autosarstandard:ui:uiModeDeclarationStr')),...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    return;
                end
            case autosar.ui.wizard.PackageString.TransitionTypes{3}

                if strcmp(eventData(index).ModeDeclaration1,...
                    DAStudio.message('RTW:autosar:selectERstr'))
                    errordlg(DAStudio.message('RTW:autosar:eventElementNotFoundSubsidiary',...
                    DAStudio.message('autosarstandard:ui:uiTransitionFromStr'),...
                    DAStudio.message('autosarstandard:ui:uiModeDeclarationStr'),...
                    eventData(index).Name,DAStudio.message('autosarstandard:ui:uiModeDeclarationStr')),...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    return;
                end

                if strcmp(eventData(index).ModeDeclaration2,...
                    DAStudio.message('RTW:autosar:selectERstr'))
                    errordlg(DAStudio.message('RTW:autosar:eventElementNotFoundSubsidiary',...
                    DAStudio.message('autosarstandard:ui:uiTransitionIntoStr'),...
                    autosar.ui.metamodel.PackageString.ModeDeclarationStr,...
                    eventData(index).Name,DAStudio.message('autosarstandard:ui:uiModeDeclarationStr')),...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    return;
                end
            end
        end
    end

    if isempty(eventData)
        proxyNode=arExplorer.getListSelection();
        assert(~isempty(proxyNode));

        if~isempty(mapping.StepFunctions)&&...
            strcmp(proxyNode.getDisplayLabel,mapping.StepFunctions(1).MappedTo.Runnable)
            errordlg(DAStudio.message('RTW:autosar:validateEventForStepFunction',...
            proxyNode.getDisplayLabel),autosar.ui.metamodel.PackageString.ErrorTitle,...
            'replace');

            arExplorer.getDialog().refresh();
            arExplorer.EventData=[];
            return;
        end
    else
        eventNames=[];
        for index=1:length(eventData)
            eventNames=[eventNames,{eventData(index).Name}];%#ok<AGROW>
        end
        [~,unique_event_indices]=unique(eventNames);
        duplicates=unique(eventNames(setdiff(1:length(eventData),unique_event_indices)));
        if~isempty(duplicates)
            errordlg(DAStudio.message('RTW:autosar:internalBehavShortNameClash',...
            duplicates{1}),...
            autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            return;
        end

        for evtIndex=1:length(eventData)
            propValue=eventData(evtIndex).Name;
            for ii=1:m3iObj.containerM3I.Events.size()
                m3iEvent=m3iObj.containerM3I.Events.at(ii);
                if strcmp(propValue,m3iEvent.Name)
                    if~isempty(m3iEvent.StartOnEvent)
                        isValid=strcmp(m3iEvent.StartOnEvent.Name,...
                        eventData(evtIndex).RunnableName);
                        if~isValid
                            errordlg(DAStudio.message('RTW:autosar:internalBehavShortNameClash',...
                            propValue),autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                            return;
                        end
                    end
                end
            end
        end

        for evtIndex=1:length(eventData)
            propValue=eventData(evtIndex).Name;
            isValid=autosar.ui.utils.checkDuplicateInSequence(m3iObj.containerM3I.Runnables,propValue)&&...
            autosar.ui.utils.checkDuplicateInSequence(m3iObj.containerM3I.IRV,propValue);
            if~isValid
                errordlg(DAStudio.message('RTW:autosar:internalBehavShortNameClash',...
                propValue),autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                return;
            end
        end
    end
    t=autosar.utils.M3ITransaction(modelM3I);
    m3iEventArray={};
    for index=1:length(eventData)
        if strcmp(eventData(index).RunnableName,m3iObj.Name)
            switch eventData(index).EventType
            case autosar.ui.wizard.PackageString.EventTypes{1}
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                autosar.ui.configuration.PackageString.Events{1});

                m3iEvent.Period=0;
            case{autosar.ui.wizard.PackageString.EventTypes{2},autosar.ui.wizard.PackageString.EventTypes{6}}
                portElement=regexp(eventData(index).TriggerPort,'([^ .][^.]*)','match');
                assert(length(portElement)==2);
                port=portElement{1};
                element=portElement{2};
                m3iPort=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                compObj,compObj.ReceiverPorts,port,rPortCls);
                assert(~isempty(m3iPort)&&m3iPort.isvalid());
                m3iInterface=m3iPort.Interface;
                m3iData=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iInterface,m3iInterface.DataElements,element,dataCls);
                assert(~isempty(m3iData)&&m3iData.isvalid());
                metaClass=autosar.api.getAUTOSARProperties.getMetaClassFromCategory(eventData(index).EventType).qualifiedName;
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                metaClass);
                m3iInstanceRef=Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef(modelM3I);
                if isempty(compObj.instanceMapping)
                    compObj.instanceMapping=...
                    Simulink.metamodel.arplatform.instance.ComponentInstanceRef(modelM3I);
                end

                if~isempty(m3iEvent.instanceRef)
                    for ii=compObj.instanceMapping.instance.size():-1:1
                        if compObj.instanceMapping.instance.at(ii)==m3iEvent.instanceRef
                            compObj.instanceMapping.instance.at(ii).destroy();
                            break;
                        end
                    end
                end
                compObj.instanceMapping.instance.append(m3iInstanceRef);
                m3iEvent.instanceRef=m3iInstanceRef;
                m3iInstanceRef.Port=m3iPort;
                m3iInstanceRef.DataElements=m3iData;
            case autosar.ui.wizard.PackageString.EventTypes{3}
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                autosar.ui.configuration.PackageString.Events{3});


                if mappedToSLinport
                    [dataType,~,modeGroupName]=getDataTypeFromModeReceiverPort(mapping,eventData(index).ModeReceiverPort);
                    [modeNames,modeValues,defaultModeIndex,~,~,~]=autosar.mm.sl2mm.ModelBuilder.getMdgDataFromEnum(modelName,dataType);
                    if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(modelM3I)
                        m3iModelShared=autosar.dictionary.Utils.getUniqueReferencedModel(modelM3I);
                    else
                        m3iModelShared=modelM3I;
                    end
                    m3iMdg=autosar.mm.sl2mm.TypeBuilder.findOrCreateModeDeclarationGroup(m3iModelShared,dataType,modeNames,...
                    modeValues,defaultModeIndex);
                    [m3iPort,~,m3iModeGroup]=autosar.mm.sl2mm.ModelBuilder.findModeGroup(...
                    compObj,eventData(index).ModeReceiverPort,modeGroupName);
                    m3iModeGroup.ModeGroup=m3iMdg;
                else
                    m3iPort=[];
                    m3iModeGroup=[];
                    for ii=1:compObj.ModeReceiverPorts.size()
                        mrPort=compObj.ModeReceiverPorts.at(ii);
                        if strcmp(eventData(index).ModeReceiverPort,mrPort.Name)
                            m3iPort=mrPort;
                            m3iModeGroup=mrPort.Interface.ModeGroup;
                            break;
                        end
                    end



                    if isempty(m3iPort)
                        for ii=1:compObj.ReceiverPorts.size()
                            rPort=compObj.ReceiverPorts.at(ii);
                            if strcmp(eventData(index).ModeReceiverPort,rPort.Name)
                                m3iPort=rPort;
                                if rPort.Interface.ModeGroup.size()>0
                                    m3iModeGroup=rPort.Interface.ModeGroup.at(1);
                                    break;
                                end
                            end
                        end
                    end
                end
                switch eventData(index).Activation
                case autosar.ui.wizard.PackageString.TransitionTypes{1}
                    m3iEvent.activation=Simulink.metamodel.arplatform.behavior.ModeActivationKind.OnEntry;
                    updateModeSwitchEvent(modelM3I,compObj,m3iEvent,...
                    m3iPort,m3iModeGroup,...
                    eventData(index).ModeDeclaration1,1);
                case autosar.ui.wizard.PackageString.TransitionTypes{2}
                    m3iEvent.activation=Simulink.metamodel.arplatform.behavior.ModeActivationKind.OnExit;
                    updateModeSwitchEvent(modelM3I,compObj,m3iEvent,...
                    m3iPort,m3iModeGroup,...
                    eventData(index).ModeDeclaration1,2);
                case autosar.ui.wizard.PackageString.TransitionTypes{3}
                    m3iEvent.activation=Simulink.metamodel.arplatform.behavior.ModeActivationKind.OnTransition;
                    updateModeSwitchEvent(modelM3I,compObj,m3iEvent,...
                    m3iPort,m3iModeGroup,...
                    eventData(index).ModeDeclaration1,3);
                    updateModeSwitchEvent(modelM3I,compObj,m3iEvent,...
                    m3iPort,m3iModeGroup,...
                    eventData(index).ModeDeclaration2,4);
                end
            case autosar.ui.wizard.PackageString.EventTypes{4}
                portOperation=regexp(eventData(index).TriggerPort,'([^ .][^.]*)','match');
                assert(length(portOperation)==2);
                port=portOperation{1};
                operation=portOperation{2};
                m3iPort=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                compObj,compObj.ServerPorts,port,sPortCls);
                assert(~isempty(m3iPort)&&m3iPort.isvalid());
                m3iInterface=m3iPort.Interface;
                m3iOperation=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iInterface,m3iInterface.Operations,operation,opCls);
                assert(~isempty(m3iOperation)&&m3iOperation.isvalid());
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                autosar.ui.configuration.PackageString.Events{4});
                m3iInstanceRef=Simulink.metamodel.arplatform.instance.OperationPortInstanceRef(modelM3I);
                if isempty(compObj.instanceMapping)
                    compObj.instanceMapping=...
                    Simulink.metamodel.arplatform.instance.ComponentInstanceRef(modelM3I);
                end

                if~isempty(m3iEvent.instanceRef)
                    for ii=compObj.instanceMapping.instance.size():-1:1
                        if compObj.instanceMapping.instance.at(ii)==m3iEvent.instanceRef
                            compObj.instanceMapping.instance.at(ii).destroy();
                            break;
                        end
                    end
                end
                compObj.instanceMapping.instance.append(m3iInstanceRef);
                m3iEvent.instanceRef=m3iInstanceRef;
                m3iInstanceRef.Port=m3iPort;
                m3iInstanceRef.Operations=m3iOperation;
            case autosar.ui.wizard.PackageString.EventTypes{7}
                portElement=regexp(eventData(index).TriggerPort,'([^ .][^.]*)','match');
                assert(length(portElement)==2);
                port=portElement{1};
                element=portElement{2};
                m3iPort=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                compObj,compObj.TriggerReceiverPorts,port,trPortCls);
                assert(~isempty(m3iPort)&&m3iPort.isvalid());
                m3iInterface=m3iPort.Interface;
                m3iData=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iInterface,m3iInterface.Triggers,element,triggersCls);
                assert(~isempty(m3iData)&&m3iData.isvalid());
                metaClass=autosar.api.getAUTOSARProperties.getMetaClassFromCategory(eventData(index).EventType).qualifiedName;
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                metaClass);
                m3iInstanceRef=Simulink.metamodel.arplatform.instance.TriggerInstanceRef(modelM3I);
                if isempty(compObj.instanceMapping)
                    compObj.instanceMapping=...
                    Simulink.metamodel.arplatform.instance.ComponentInstanceRef(modelM3I);
                end

                if~isempty(m3iEvent.instanceRef)
                    for ii=compObj.instanceMapping.instance.size():-1:1
                        if compObj.instanceMapping.instance.at(ii)==m3iEvent.instanceRef
                            compObj.instanceMapping.instance.at(ii).destroy();
                            break;
                        end
                    end
                end
                compObj.instanceMapping.instance.append(m3iInstanceRef);
                m3iEvent.instanceRef=m3iInstanceRef;
                m3iInstanceRef.Port=m3iPort;
                m3iInstanceRef.Trigger=m3iData;
            case autosar.ui.wizard.PackageString.EventTypes{5}
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                autosar.ui.configuration.PackageString.Events{5});
            case 'InternalTriggerOccurredEvent'
                m3iEvent=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                behaviorObj,behaviorObj.Events,eventData(index).Name,...
                'Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent');
            otherwise
                assert(false,'Unknown event type');
            end
            m3iEvent.Name=eventData(index).Name;
            m3iEvent.StartOnEvent=m3iObj;
            eventList{end+1}=[eventData(index).Name,'.',eventData(index).EventType];%#ok<AGROW>
            m3iEventArray{end+1}=m3iEvent;%#ok<AGROW>
        end
    end
    if~isempty(eventData)
        [~,message]=autosar.validation.ClassicMetaModelValidator.verifyEventsForRunnable(...
        get_param(modelName,'handle'),...
        eventData(1).RunnableName,m3iEventArray,mapping,schemaVersion);
        if~isempty(message)
            t.cancel();
            errordlg(message,autosar.ui.metamodel.PackageString.ErrorTitle,...
            'replace');
            return;
        else
            t.commit();
        end
    else
        arExplorer.EventData=[];
    end
    t.delete();



    deletedEvents=Simulink.metamodel.arplatform.behavior.Event.empty(1,0);
    for eventIndex=1:eventsObj.size()
        if~isempty(eventsObj.at(eventIndex).StartOnEvent)&&...
            strcmp(eventsObj.at(eventIndex).StartOnEvent.Name,m3iObj.Name)
            if isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{1})
                eventType=autosar.ui.wizard.PackageString.EventTypes{1};
            elseif isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{2})
                eventType=autosar.ui.wizard.PackageString.EventTypes{2};
            elseif isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{3})
                eventType=autosar.ui.wizard.PackageString.EventTypes{3};
            elseif isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{4})
                eventType=autosar.ui.wizard.PackageString.EventTypes{4};
            elseif isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{5})
                eventType=autosar.ui.wizard.PackageString.EventTypes{5};
            elseif isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{6})
                eventType=autosar.ui.wizard.PackageString.EventTypes{6};
            elseif isa(eventsObj.at(eventIndex),...
                autosar.ui.configuration.PackageString.Events{7})
                eventType=autosar.ui.wizard.PackageString.EventTypes{7};
            elseif isa(eventsObj.at(eventIndex),...
                'Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent')
                eventType='InternalTriggerOccurredEvent';
            else
                assert(false,'Unknown event type');
            end
            if~any(ismember(eventList,[eventsObj.at(eventIndex).Name,'.',eventType]))
                deletedEvents{end+1}=eventsObj.at(eventIndex);%#ok<AGROW>
            end
        end
    end


    if~isempty(deletedEvents)
        t=M3I.Transaction(modelM3I);
        for ii=1:length(deletedEvents)
            deletedEvents{ii}.destroy();
        end
        t.commit();
    end

    status=1;

end

function updateModeSwitchEvent(modelM3I,compObj,m3iEvent,m3iPort,...
    m3iModeGroup,modeDeclaration,operationIndex)
    m3iModeDeclarationGroup=m3iModeGroup.ModeGroup;
    m3iMode=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
    m3iModeDeclarationGroup,m3iModeDeclarationGroup.Mode,modeDeclaration,...
    autosar.ui.metamodel.PackageString.ModeDeclarationClass);

    m3iInstanceRef=Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef(modelM3I);
    if isempty(compObj.instanceMapping)
        compObj.instanceMapping=...
        Simulink.metamodel.arplatform.instance.ComponentInstanceRef(modelM3I);
    end


    switch operationIndex
    case{1,2,3}
        for ii=m3iEvent.instanceRef.size():-1:1
            for jj=compObj.instanceMapping.instance.size():-1:1
                if compObj.instanceMapping.instance.at(jj)==m3iEvent.instanceRef.at(ii)
                    compObj.instanceMapping.instance.at(jj).destroy();
                    break;
                end
            end
        end
        m3iEvent.instanceRef.clear();
    case 4
        if m3iEvent.instanceRef.size()>1
            for jj=compObj.instanceMapping.instance.size():-1:1
                if compObj.instanceMapping.instance.at(jj)==m3iEvent.instanceRef.at(2)
                    compObj.instanceMapping.instance.at(jj).destroy();
                    break;
                end
            end
        end
    end
    compObj.instanceMapping.instance.append(m3iInstanceRef);
    m3iInstanceRef.Port=m3iPort;
    m3iInstanceRef.groupElement=m3iModeGroup;
    m3iInstanceRef.Mode=m3iMode;
    m3iEvent.instanceRef.append(m3iInstanceRef);
end

function[dataType,slInport,modeGroup]=getDataTypeFromModeReceiverPort(mapping,modeReceiverPort)
    dataType='';
    slInport='';
    modeGroup='';
    for ii=1:length(mapping.Inports)
        if strcmp(mapping.Inports(ii).MappedTo.DataAccessMode,'ModeReceive')&&...
            strcmp(mapping.Inports(ii).MappedTo.Port,modeReceiverPort)
            modeGroup=mapping.Inports(ii).MappedTo.Element;
            [~,slInport]=fileparts(mapping.Inports(ii).Block);
            blkHdl=get_param(mapping.Inports(ii).Block,'Handle');
            dataType=get_param(blkHdl,'OutDataTypeStr');
            dataType=autosar.utils.StripPrefix(dataType);
            break;
        end
    end
    assert(~isempty(dataType));
end


