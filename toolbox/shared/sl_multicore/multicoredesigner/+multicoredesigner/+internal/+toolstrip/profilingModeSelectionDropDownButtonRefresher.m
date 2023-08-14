function profilingModeSelectionDropDownButtonRefresher(cbinfo,action)




    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return
    end
    action.selectedItem=appContext.ProfilingMode;
end