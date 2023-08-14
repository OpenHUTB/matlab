



function systemSelectorCB(actionName,cb,cbinfo)
    pinned=cbinfo.EventData;

    if pinned
        obj=SLStudio.toolstrip.internal.getSystemSelectorSelection(cbinfo);
        cbinfo.studio.App.insertPinnedSystem(actionName,obj,Simulink.ID.getSID(obj));
    else
        cbinfo.studio.App.erasePinnedSystem(actionName);
    end

    if~isempty(cb)&&~isempty(cb.functionName)
        if isempty(cb.gatewayName)
            feval(cb.functionName,cb.userdata,cbinfo);
        else
            feval(cb.gatewayName,cb.functionName,cb.userdata,cbinfo);
        end
    end
end
