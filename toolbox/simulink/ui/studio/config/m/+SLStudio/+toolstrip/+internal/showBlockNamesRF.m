



function showBlockNamesRF(userdata,cbinfo,action)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    len=length(blockHandles);
    checkedValue='';
    if(len<1)
        action.enabled=false;
    elseif sum(strcmpi(get_param(blockHandles,'ShowName'),'off'))...
        >len/2
        checkedValue='off';
    elseif sum(strcmpi(get_param(blockHandles,'HideAutomaticName'),'on'))...
        >len/2
        checkedValue='auto';
    else
        checkedValue='on';
    end


    if SLStudio.Utils.isWebBlockInPanel(cbinfo)
        action.enabled=false;
    end

    type=userdata;
    if strcmpi(type,'choice')
        switch checkedValue
        case 'auto'
            action.text='simulink_ui:studio:resources:AutoBlockNameActionText';
            action.description='simulink_ui:studio:resources:AutoBlockNameActionDescription';
        case 'on'
            action.text='simulink_ui:studio:resources:ShowBlockNameActionText';
            action.description='simulink_ui:studio:resources:ShowBlockNameActionDescription';
        case 'off'
            action.text='simulink_ui:studio:resources:HideBlockNameActionText';
            action.description='simulink_ui:studio:resources:HideBlockNameActionDescription';
        end
        return;
    end
    isSelected=false;
    if strcmpi(type,checkedValue)
        isSelected=true;
    end
    action.selected=isSelected;
end

