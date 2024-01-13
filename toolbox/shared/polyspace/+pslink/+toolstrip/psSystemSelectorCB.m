function psSystemSelectorCB(actionName,cbinfo)
    pinned=cbinfo.EventData;

    if pinned
        selection=cbinfo.getSelection;

        if size(selection)==1
            obj=selection;
        else
            obj=cbinfo.uiObject;
        end

        cbinfo.studio.App.insertPinnedSystem(actionName,obj,Simulink.ID.getSID(obj));
    else
        cbinfo.studio.App.erasePinnedSystem(actionName);
    end
end