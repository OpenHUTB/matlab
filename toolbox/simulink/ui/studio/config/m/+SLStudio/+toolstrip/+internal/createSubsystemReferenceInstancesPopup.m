







function gw=createSubsystemReferenceInstancesPopup(graphHandle,eventDataNamespace,eventDataType,type)

    displayList=SLStudio.Utils.internal.createSSRefInstanceDisplayList(graphHandle);
    instanceCount=length(displayList);
    gw=dig.GeneratedWidget(eventDataNamespace,eventDataType);

    if(instanceCount>0)
        switch(type)
        case 'subsystemFile'
            header=gw.Widget.addChild('PopupListHeader','instances');
            header.Label='simulink_ui:studio:resources:instancesHeaderLabel';
            for k=1:instanceCount
                createListItem(gw,k,displayList{k},'Instance');
            end
        case 'subsystemBlock'
            header=gw.Widget.addChild('PopupListHeader','subsystemFile');
            header.Label='simulink_ui:studio:resources:subsystemFileHeaderLabel';
            createListItem(gw,1,displayList{1},'SubsystemFile');
            if(instanceCount>1)
                header=gw.Widget.addChild('PopupListHeader','instances');
                header.Label='simulink_ui:studio:resources:instancesHeaderLabel';
                for k=2:instanceCount
                    createListItem(gw,k,displayList{k},'Instance');
                end
            end
        end
    end

    editedInstance=slInternal('getMasterSRGraph',graphHandle);
    if(~isempty(editedInstance))
        header=gw.Widget.addChild('PopupListHeader','editedInstances');
        header.Label='simulink_ui:studio:resources:editedInstancesHeaderLabel';
        createListItem(gw,1,editedInstance,'EditedInstance');
    end

end

function[item,action]=createListItem(gw,index,text,type)

    actionName=['Action',type,num2str(index)];
    action=gw.createAction(actionName);
    action.text=text;
    action.enabled=true;
    action.setCallbackFromArray({@openActiveInstances,text},dig.model.FunctionType.Action);
    action.optOutBusy=true;
    action.optOutLocked=true;
    switch(type)
    case 'Instance'
        action.icon='goToInstance';
    case 'SubsystemFile'
        action.icon='goToInstance';
    case 'EditedInstance'
        action.icon='goToEditedInstance';
    end

    itemName=['Item',type,num2str(index)];
    item=gw.Widget.addChild('ListItem',itemName);
    item.ActionId=[gw.Namespace,':',actionName];
    switch(type)
    case 'Instance'
        item.IconOverride='goToInstance_16';
    case 'SubsystemFile'
        item.IconOverride='goToInstance_16';
    case 'EditedInstance'
        item.IconOverride='goToEditedInstance_16';
    end
end

function openActiveInstances(instanceName,~)
    SLStudio.Utils.internal.ssRefOpenInstance(instanceName);
end