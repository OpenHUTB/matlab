





function updateEventsForAddRemove(dae,cur,old)
    assert(~isempty(dae),'explorer UI handle is empty but observer still called!');


    if cur.isvalid
        m3iObj=cur;
    else
        m3iObj=old;
    end
    m3iObj=m3iObj.asMutable;

    if isa(m3iObj,autosar.ui.metamodel.PackageString.PortClass)

        if~isa(m3iObj,autosar.ui.configuration.PackageString.Ports{1})&&...
            ~isa(m3iObj,autosar.ui.configuration.PackageString.Ports{4})&&...
            ~isa(m3iObj,autosar.ui.configuration.PackageString.Ports{5})
            return
        end

        if isa(m3iObj,autosar.ui.configuration.PackageString.Ports{5})
            updateEventForServerPort(dae,m3iObj,cur.isvalid);
        else
            updateEventForPort(dae,m3iObj);
        end
    elseif isa(m3iObj,autosar.ui.configuration.PackageString.Operation)

        updateEventForServerOperation(dae,m3iObj,cur.isvalid);
    end
end



function updateEventForPort(dae,old)
    if~isempty(findprop(dae,'EventData'))
        eventData=dae.EventData;
        if~isempty(eventData)
            for index=1:length(eventData)
                updateEventData(eventData(index),old.Name,'');
            end
        end
    end
end


function updateEventForServerOperation(dae,m3iObj,isAdding)
    if~isempty(findprop(dae,'EventData'))
        eventData=dae.EventData;
        if~isempty(eventData)
            modelM3I=dae.TraversedRoot.getM3iObject;
            m3iComps=autosar.mm.Model.findObjectByMetaClass(modelM3I,...
            Simulink.metamodel.arplatform.component.AtomicComponent.MetaClass,true);
            for compIdx=1:m3iComps.size()
                m3iComp=m3iComps.at(1);
                serverPorts=autosar.mm.Model.findChildByTypeName(m3iComp,...
                autosar.ui.configuration.PackageString.Ports{5},false,false);
                for ii=1:length(serverPorts)
                    if isequal(serverPorts{ii}.Interface,m3iObj.containerM3I)
                        for index=1:length(eventData)
                            if isAdding
                                receiversCell=eventData(index).ReceiverCellValues;
                                receiversCell{end+1}=[serverPorts{ii}.Name,'.'...
                                ,m3iObj.Name];%#ok<AGROW>
                                eventData(index).setReceiverCellValues(receiversCell);
                            else
                                updateEventData(eventData(index),...
                                serverPorts{ii}.Name,...
                                m3iObj.Name);
                            end
                        end
                    end
                end
            end
        end
    end
end


function updateEventForServerPort(dae,m3iObj,isAdding)
    if~isempty(findprop(dae,'EventData'))
        eventData=dae.EventData;
        if~isempty(eventData)
            if isAdding
                for jj=1:m3iObj.Interface.Operations.size()
                    for index=1:length(eventData)
                        receiversCell=eventData(index).ReceiverCellValues;
                        receiversCell{end+1}=[m3iObj.Name,'.'...
                        ,m3iObj.Interface.Operations.at(jj).Name];%#ok<AGROW>
                        eventData(index).setReceiverCellValues(receiversCell);
                    end
                end
            else
                for jj=1:m3iObj.Interface.Operations.size()
                    for index=1:length(eventData)
                        updateEventData(eventData(index),...
                        m3iObj.Name,...
                        m3iObj.Interface.Operations.at(jj).Name);
                    end
                end
            end
        end
    end
end

function updateEventData(event,portName,dataElement)
    switch event.EventType

    case{autosar.ui.wizard.PackageString.EventTypes{2},...
        autosar.ui.wizard.PackageString.EventTypes{4}}
        if strcmp(event.TriggerPort,[portName,'.',dataElement])
            event.setTriggerPort(DAStudio.message('RTW:autosar:selectERstr'));
        end
        receiversCell=cell(1,length(event.ReceiverCellValues)-1);
        jj=1;
        for ii=1:length(event.ReceiverCellValues)
            portElement=regexp(event.ReceiverCellValues{ii},'([^ .][^.]*)','match');
            if~(length(portElement)==2&&strcmp(portName,portElement{1})&&...
                strcmp(dataElement,portElement{2}))
                receiversCell{jj}=event.ReceiverCellValues{ii};
                jj=jj+1;
            end
        end
        event.setReceiverCellValues(receiversCell);

    case autosar.ui.wizard.PackageString.EventTypes{3}
        if strcmp(event.ModeReceiverPort,portName)
            event.setModeReceiverPort(DAStudio.message('RTW:autosar:selectERstr'));
            event.setActivation(DAStudio.message('RTW:autosar:selectERstr'));
            event.setModeDeclaration1(DAStudio.message('RTW:autosar:selectERstr'));
            event.setModeDeclaration2(DAStudio.message('RTW:autosar:selectERstr'));
        end
        receiversCell=cell(1,length(event.ModeReceiverPortCellValues)-1);
        jj=1;
        for ii=1:length(event.ModeReceiverPortCellValues)
            if~strcmp(event.ModeReceiverPortCellValues{ii},portName)
                receiversCell{jj}=event.ModeReceiverPortCellValues{ii};
                jj=jj+1;
            end
        end
        event.setModeReceiverPortCellValues(receiversCell);
    end
end


