



function updateEvents(dae,m3iObj,old)

    eventData=[];
    if~isempty(findprop(dae,'EventData'))
        eventData=dae.EventData;
    end
    if isempty(eventData)
        return;
    end


    oldName=old.Name;
    m3iObj=m3iObj.asMutable;
    if isa(m3iObj,autosar.ui.configuration.PackageString.Runnables)
        for index=1:length(eventData)
            if strcmp(eventData(index).RunnableName,oldName)
                eventData(index).setRunnableName(m3iObj.Name);
                break;
            end
        end
    end

    if~strcmp(oldName,m3iObj.Name)
        portNameChanged=isa(m3iObj,autosar.ui.metamodel.PackageString.PortClass);
        dataElementNameChanged=isa(m3iObj,autosar.ui.configuration.PackageString.DataElement);
        operationChanged=isa(m3iObj,autosar.ui.configuration.PackageString.Operation);
        if portNameChanged||dataElementNameChanged||operationChanged
            for index=1:length(eventData)
                updateEventData(eventData(index),m3iObj,old,...
                portNameChanged,dataElementNameChanged,operationChanged);
            end
        end
    end
end

function updateEventData(event,m3iObj,old,portNameChanged,...
    dataElementNameChanged,operationChanged)
    switch event.EventType

    case{autosar.ui.wizard.PackageString.EventTypes{2},...
        autosar.ui.wizard.PackageString.EventTypes{4},...
        autosar.ui.wizard.PackageString.EventTypes{6}}
        portElement=regexp(event.TriggerPort,'\.','split');
        if length(portElement)==2
            if portNameChanged&&strcmp(portElement{1},old.Name)
                event.setTriggerPort([m3iObj.Name,'.',portElement{2}]);
            elseif(dataElementNameChanged||operationChanged)&&strcmp(portElement{2},old.Name)
                event.setTriggerPort([portElement{1},'.',m3iObj.Name]);
            end
        end
        receiversCell=cell(1,length(event.ReceiverCellValues));
        hasChanged=false;
        for ii=1:length(event.ReceiverCellValues)
            portElement=regexp(event.ReceiverCellValues{ii},'\.','split');
            if length(portElement)==2
                if~portNameChanged
                    if operationChanged
                        portType=autosar.ui.configuration.PackageString.Ports{5};
                    else
                        portType=autosar.ui.configuration.PackageString.Ports{1};
                    end
                    modelM3I=m3iObj.modelM3I;
                    m3iComps=autosar.mm.Model.findObjectByMetaClass(modelM3I,...
                    Simulink.metamodel.arplatform.component.AtomicComponent.MetaClass,true);
                    for compIdx=1:m3iComps.size()
                        m3iComp=m3iComps.at(1);
                        ports=autosar.mm.Model.findChildByTypeName(m3iComp,...
                        portType,false,false);
                        for jj=1:length(ports)
                            if strcmp(ports{jj}.Name,portElement{1})
                                interfaceName=ports{jj}.Interface.Name;
                                break;
                            end
                        end
                        assert(~isempty(interfaceName));
                    end
                end
                if portNameChanged&&strcmp(portElement{1},old.Name)
                    receiversCell{ii}=[m3iObj.Name,'.',portElement{2}];
                    hasChanged=true;
                elseif(dataElementNameChanged||operationChanged)&&...
                    strcmp(portElement{2},old.Name)&&...
                    strcmp(old.containerM3I.Name,interfaceName)
                    receiversCell{ii}=[portElement{1},'.',m3iObj.Name];
                    hasChanged=true;
                else
                    receiversCell{ii}=event.ReceiverCellValues{ii};
                end
            else
                receiversCell{ii}=event.ReceiverCellValues{ii};
            end
        end
        if hasChanged
            event.setReceiverCellValues(receiversCell);
        end

    case autosar.ui.wizard.PackageString.EventTypes{3}
        if portNameChanged&&strcmp(event.ModeReceiverPort,old.Name)
            event.setModeReceiverPort(m3iObj.Name);
        end
        receiversCell=cell(1,length(event.ModeReceiverPortCellValues));
        hasChanged=false;
        for ii=1:length(event.ModeReceiverPortCellValues)
            if portNameChanged&&strcmp(event.ModeReceiverPortCellValues{ii},old.Name)
                receiversCell{ii}=m3iObj.Name;
                hasChanged=true;
            else
                receiversCell{ii}=event.ModeReceiverPortCellValues{ii};
            end
        end
        if hasChanged
            event.setModeReceiverPortCellValues(receiversCell);
        end
    end
end

