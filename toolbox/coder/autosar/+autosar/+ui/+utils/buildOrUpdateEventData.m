




function eventData=buildOrUpdateEventData(arExplorer,eventObj,oldEventObj)

    mmgr=arExplorer.MappingManager;
    mapping=mmgr.getActiveMappingFor('AutosarTarget');
    eventData=arExplorer.EventData;

    receiversCell={DAStudio.message('RTW:autosar:selectERstr')};
    activationsCell={DAStudio.message('RTW:autosar:selectERstr')};
    modeReceiverPortsCell={DAStudio.message('RTW:autosar:selectERstr')};
    modeDeclarationsCell1={DAStudio.message('RTW:autosar:selectERstr')};
    modeDeclarationsCell2={DAStudio.message('RTW:autosar:selectERstr')};
    eventTriggerPortValue=DAStudio.message('RTW:autosar:selectERstr');
    activationValue=DAStudio.message('RTW:autosar:selectERstr');
    eventModeReceiverPortValue=DAStudio.message('RTW:autosar:selectERstr');
    eventModeDeclarationValue1=DAStudio.message('RTW:autosar:selectERstr');
    eventModeDeclarationValue2=DAStudio.message('RTW:autosar:selectERstr');

    eventName=eventObj.Name;
    if~eventObj.StartOnEvent.isvalid()
        return;
    end
    runnableName=eventObj.StartOnEvent.Name;

    if isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{1})
        eventType=autosar.ui.wizard.PackageString.EventTypes{1};
    elseif isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{2})
        eventType=autosar.ui.wizard.PackageString.EventTypes{2};
    elseif isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{3})
        eventType=autosar.ui.wizard.PackageString.EventTypes{3};
    elseif isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{4})
        eventType=autosar.ui.wizard.PackageString.EventTypes{4};
    elseif isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{5})
        eventType=autosar.ui.wizard.PackageString.EventTypes{5};
    elseif isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{6})
        eventType=autosar.ui.wizard.PackageString.EventTypes{6};
    elseif isa(eventObj,...
        autosar.ui.configuration.PackageString.Events{7})
        eventType=autosar.ui.wizard.PackageString.EventTypes{7};
    elseif(eventObj.MetaClass==Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass)
        eventType='InternalTriggerOccurredEvent';
    else
        assert(false,'Unknown event type');
    end
    if any(strcmp(eventType,{autosar.ui.wizard.PackageString.EventTypes{2},...
        autosar.ui.wizard.PackageString.EventTypes{6}}))

        if length(receiversCell)==1
            m3iComp=eventObj.containerM3I.containerM3I;
            receiversCell=[DAStudio.message('RTW:autosar:selectERstr'),...
            autosar.api.Utils.getDataReceivedEventTriggers(m3iComp,mapping)];
        end
        instanceRefObj=eventObj.instanceRef;
        if~isempty(instanceRefObj)&&...
            ~isempty(instanceRefObj.Port)&&instanceRefObj.Port.isvalid()&&...
            ~isempty(instanceRefObj.DataElements)&&instanceRefObj.DataElements.isvalid()
            eventTriggerPortValue=[instanceRefObj.Port.Name...
            ,'.',instanceRefObj.DataElements(1).Name];
        else
            eventTriggerPortValue=receiversCell{1};
        end
    elseif strcmp(eventType,autosar.ui.wizard.PackageString.EventTypes{4})

        if length(receiversCell)==1
            receiversCell=cell(1,1);
            receiversCell{1}=DAStudio.message('RTW:autosar:selectERstr');
            compObj=eventObj.containerM3I.containerM3I;
            serverPorts=autosar.mm.Model.findChildByTypeName(compObj,...
            autosar.ui.configuration.PackageString.Ports{5},false,false);
            for ii=1:length(serverPorts)
                if serverPorts{ii}.Interface.isvalid()
                    for jj=1:serverPorts{ii}.Interface.Operations.size()
                        receiversCell{end+1}=[serverPorts{ii}.Name,'.'...
                        ,serverPorts{ii}.Interface.Operations.at(jj).Name];%#ok<AGROW>
                    end
                end
            end
            receiversCell=unique(receiversCell,'stable');
        end
        instanceRefObj=eventObj.instanceRef;
        if~isempty(instanceRefObj)&&...
            ~isempty(instanceRefObj.Port)&&instanceRefObj.Port.isvalid()&&...
            ~isempty(instanceRefObj.Operations)&&instanceRefObj.Operations.isvalid()
            eventTriggerPortValue=[instanceRefObj.Port.Name...
            ,'.',instanceRefObj.Operations(1).Name];
        else
            eventTriggerPortValue=receiversCell{1};
        end
    elseif strcmp(eventType,autosar.ui.wizard.PackageString.EventTypes{3})

        if length(activationsCell)==1

            activationsCell=cell(1,1);
            activationsCell{1}=DAStudio.message('RTW:autosar:selectERstr');
            for i=1:length(autosar.ui.wizard.PackageString.TransitionTypes)
                activationsCell{end+1}=autosar.ui.wizard.PackageString.TransitionTypes{i};%#ok<AGROW>
            end
        end
        switch eventObj.activation
        case Simulink.metamodel.arplatform.behavior.ModeActivationKind.OnEntry
            activationValue=autosar.ui.wizard.PackageString.TransitionTypes{1};
        case Simulink.metamodel.arplatform.behavior.ModeActivationKind.OnExit
            activationValue=autosar.ui.wizard.PackageString.TransitionTypes{2};
        case Simulink.metamodel.arplatform.behavior.ModeActivationKind.OnTransition
            activationValue=autosar.ui.wizard.PackageString.TransitionTypes{3};
        end
        modeReceiverPortsCell=autosar.ui.utils.getModeReceiverPorts(mapping,runnableName);
        if eventObj.has('instanceRef')
            instRef=eventObj.instanceRef;
            if instRef.size()>0
                instanceRefObj=instRef.at(1);
                modeDeclarationsCell1=cell(1,1);
                modeDeclarationsCell1{1}=DAStudio.message('RTW:autosar:selectERstr');
                modeGroup=[];
                if isempty(instanceRefObj.Port)||~instanceRefObj.Port.isvalid()
                    eventModeReceiverPortValue=DAStudio.message('RTW:autosar:selectERstr');
                else
                    eventModeReceiverPortValue=instanceRefObj.Port.Name;
                    if isa(instanceRefObj.Port.Interface,...
                        autosar.ui.metamodel.PackageString.InterfacesCell{3})
                        modeGroup=instanceRefObj.Port.Interface.ModeGroup;
                    elseif isa(instanceRefObj.Port.Interface,...
                        autosar.ui.metamodel.PackageString.InterfacesCell{1})
                        if instanceRefObj.Port.Interface.ModeGroup.size()>0
                            modeGroup=instanceRefObj.Port.Interface.ModeGroup.at(1);
                        end
                    end
                end
                if~isempty(modeGroup)
                    for i=1:modeGroup.ModeGroup.Mode.size()
                        modeDeclarationsCell1{end+1}=...
                        modeGroup.ModeGroup.Mode.at(i).Name;%#ok<AGROW>
                    end
                end
                if isempty(instanceRefObj.Mode)||~instanceRefObj.Mode.isvalid()
                    eventModeDeclarationValue1=DAStudio.message('RTW:autosar:selectERstr');
                else
                    eventModeDeclarationValue1=instanceRefObj.Mode.Name;
                end
                if instRef.size()>1
                    instanceRefObj=instRef.at(2);
                    modeDeclarationsCell2=cell(1,1);
                    modeDeclarationsCell2{1}=DAStudio.message('RTW:autosar:selectERstr');
                    if isempty(instanceRefObj.Port)||~instanceRefObj.Port.isvalid()
                        modeGroup=[];
                    else
                        modeGroup=instanceRefObj.Port.Interface.ModeGroup;
                    end
                    if~isempty(modeGroup)
                        for i=1:modeGroup.ModeGroup.Mode.size()
                            modeDeclarationsCell2{end+1}=...
                            modeGroup.ModeGroup.Mode.at(i).Name;%#ok<AGROW>
                        end
                    end
                    if isempty(instanceRefObj.Mode)||~instanceRefObj.Mode.isvalid()
                        eventModeDeclarationValue2=DAStudio.message('RTW:autosar:selectERstr');
                    else
                        eventModeDeclarationValue2=instanceRefObj.Mode.Name;
                    end
                end
            end
        end
    elseif strcmp(eventType,autosar.ui.wizard.PackageString.EventTypes{7})

        if length(receiversCell)==1
            m3iComp=eventObj.containerM3I.containerM3I;
            receiversCell=[DAStudio.message('RTW:autosar:selectERstr'),...
            autosar.api.Utils.getExternalTriggerOccurredEventTriggers(m3iComp)];
        end
        instanceRefObj=eventObj.instanceRef;
        if~isempty(instanceRefObj)&&...
            ~isempty(instanceRefObj.Port)&&instanceRefObj.Port.isvalid()&&...
            ~isempty(instanceRefObj.Trigger)&&instanceRefObj.Trigger.isvalid()
            eventTriggerPortValue=[instanceRefObj.Port.Name...
            ,'.',instanceRefObj.Trigger(1).Name];
        else
            if iscell(receiversCell)
                eventTriggerPortValue=receiversCell{1};
            end
        end
    end


    if~isempty(eventData)&&~strcmp(eventData(1).RunnableName,runnableName)
        eventData=[];
        arExplorer.SelectedEventName='';
    end

    if isempty(eventData)
        eventData=autosar.ui.metamodel.Event.empty(1,0);
    end


    index=-1;
    if~isempty(oldEventObj)&&oldEventObj.isvalid
        oldEventName=oldEventObj.Name;
    else
        oldEventName=eventName;
    end
    for ii=1:length(eventData)
        if strcmp(eventData(ii).RunnableName,runnableName)&&...
            strcmp(eventData(ii).Name,oldEventName)
            index=ii;
            break;
        end
    end
    if index==-1
        eventData(end+1)=autosar.ui.metamodel.Event(eventName,...
        eventType,...
        eventTriggerPortValue,...
        runnableName);
        index=length(eventData);
    else
        eventData(index).setName(eventName);
        eventData(index).setTriggerPort(eventTriggerPortValue);
        eventData(index).setType(eventType);
        eventData(index).setRunnableName(runnableName);
    end


    eventData(index).setReceiverCellValues(receiversCell);
    eventData(index).setActivationCellValues(activationsCell);
    eventData(index).setActivation(activationValue);
    eventData(index).setModeReceiverPort(eventModeReceiverPortValue);
    eventData(index).setModeReceiverPortCellValues(modeReceiverPortsCell);
    eventData(index).setModeDeclaration1(eventModeDeclarationValue1);
    eventData(index).setModeDeclaration2(eventModeDeclarationValue2);
    eventData(index).setModeDeclarationCellValues1(modeDeclarationsCell1);
    eventData(index).setModeDeclarationCellValues2(modeDeclarationsCell2);
    arExplorer.EventData=eventData;
end


