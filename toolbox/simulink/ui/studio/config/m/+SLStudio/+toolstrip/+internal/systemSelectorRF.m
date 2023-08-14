



function systemSelectorRF(userdata,cbinfo,action)
    action.enabled=false;

    if isempty(cbinfo.model),return;end
    if isempty(userdata),return;end
    if strcmp(userdata,''),return;end

    [~,name,path,selected,state,message]=SLStudio.toolstrip.internal.getSystemSelectorInfo(userdata,cbinfo,action);

    if selected
        icon='pinVertical';
    else
        icon='pinHorizontal';
    end

    switch state
    case 'supported'
        enabled=true;
    case 'convertible'
        enabled=false;
    case 'nonsupported'
        enabled=false;
    otherwise
        enabled=true;
    end

    if strcmp(message,'')
        validationState='normal';
    else
        validationState='error';
    end

    ts=cbinfo.studio.getToolStrip();
    as=ts.getActionService();
    cfg_action=as.Configuration.getAction(action.name);
    cb=cfg_action.callback;

    cbcopy=[];

    if~isempty(cb)
        cbcopy.functionName=cb.functionName;
        cbcopy.gatewayName=cb.gatewayName;
        cbcopy.userdata=cb.userdata;
    end

    action.setCallbackFromArray({'SLStudio.toolstrip.internal.systemSelectorCB',action.name,cbcopy},dig.model.FunctionType.Action);
    action.validateAndSetEntries({name});
    action.enabled=enabled;
    action.selectedItem=name;
    action.description=path;
    action.selected=selected;
    action.icon=icon;



    action.errorText=string(message);
    action.validationState=validationState;

    if(isempty(action.text)||isempty(action.text.getUntranslatedString()))
        action.text='simulink_ui:studio:resources:systemSelectorLabelText';
    end
end