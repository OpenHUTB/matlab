

function psSystemSelectorRF(userdata,cbinfo,action)
    action.enabled=false;

    if isempty(cbinfo.model),return;end
    if isempty(userdata),return;end
    if strcmp(userdata,''),return;end

    [obj,name,path,selected,state,message]=nGetSystemSelectorInfo(userdata,cbinfo,action);

    if selected
        icon='pinVertical';
    else
        icon='pinHorizontal';
    end

    switch state
    case 'supported'
        enabled=true;
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

    action.setCallbackFromArray({'pslink.toolstrip.psSystemSelectorCB',action.name},dig.model.FunctionType.Action);
    action.validateAndSetEntries({name});
    action.enabled=enabled;
    action.selectedItem=name;
    action.description=path;
    action.selected=selected;
    action.icon=icon;
    action.errorText=string(message);
    action.validationState=validationState;

    function[obj,name,path,selected,state,message]=nGetSystemSelectorInfo(userdata,cbinfo,action)
        selection=cbinfo.getSelection();
        pinnedSystem=cbinfo.studio.App.getPinnedSystem(action.name);

        if isempty(pinnedSystem)
            selected=false;

            if size(selection)==1
                obj=selection;
            else
                obj=cbinfo.uiObject;
            end
        else
            selected=true;
            obj=pinnedSystem;
        end

        name=obj.name;
        path=obj.getFullName;

        [state,message]=feval(userdata,obj);
    end
end

