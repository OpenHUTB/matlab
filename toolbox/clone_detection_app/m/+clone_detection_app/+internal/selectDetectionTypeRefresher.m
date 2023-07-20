function selectDetectionTypeRefresher(cbinfo,action)



    folderRadioActionName='selectFolderRadioButtonAction';
    systemRadioActionName='selectSystemRadioButtonAction';

    cloneDetectionUIObj=get_param(cbinfo.model.handle,'CloneDetectionUIObj');
    if isempty(cloneDetectionUIObj)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    if cloneDetectionUIObj.isAcrossModel
        setActionSelected(cbinfo,folderRadioActionName,true);
        setActionSelected(cbinfo,systemRadioActionName,false);


    elseif~cloneDetectionUIObj.isAcrossModel
        setActionSelected(cbinfo,systemRadioActionName,true);
        setActionSelected(cbinfo,folderRadioActionName,false);
    end
end

function setActionSelected(cbinfo,actionName,state)
    toolstrip=cbinfo.studio.getToolStrip;
    action=toolstrip.getAction(actionName);
    if~isempty(action)
        action.selected=state;
    end
end
