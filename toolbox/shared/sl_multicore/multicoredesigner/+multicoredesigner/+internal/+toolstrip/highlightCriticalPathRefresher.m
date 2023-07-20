function highlightCriticalPathRefresher(cbinfo,action)



    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return;
    end
    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');



    appMgr=multicoredesigner.internal.UIManager.getInstance();
    uiObj=getMulticoreUI(appMgr,modelH);
    if isempty(uiObj)
        return;
    end

    if~uiObj.MappingData.CriticalPathInfoAvailable
        action.enabled=false;
    else
        action.enabled=true;
        if appContext.isCriticalPathHighlightingOn
            action.selected=true;
        else
            action.selected=false;
        end
    end


