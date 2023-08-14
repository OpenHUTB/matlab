function highlightTasksRefresher(cbinfo,action)



    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return
    end
    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');


    appMgr=multicoredesigner.internal.UIManager.getInstance();
    uiObj=getMulticoreUI(appMgr,modelH);
    if isempty(uiObj)
        if~appContext.isAnalysisRestored
            action.enabled=false;
        end
        return
    end

    if~uiObj.MappingData.TaskInfoAvailable||...
        appContext.getStatus~=multicoredesigner.internal.AnalysisPhase.AnalysisComplete
        action.enabled=false;
    else
        action.enabled=true;
        if appContext.isHighlightingOn
            action.selected=true;
        else
            action.selected=false;
        end
    end


