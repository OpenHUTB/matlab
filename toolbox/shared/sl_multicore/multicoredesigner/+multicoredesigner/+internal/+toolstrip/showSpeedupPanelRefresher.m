function showSpeedupPanelRefresher(cbinfo,action)


    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');
    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return
    end


    appMgr=multicoredesigner.internal.UIManager.getInstance();
    uiObj=getMulticoreUI(appMgr,modelH);
    if isempty(uiObj)
        if~appContext.isAnalysisRestored
            action.enabled=false;
        end
        return
    end

    speedupPanel=getSpeedupPanel(uiObj);

    if speedupPanel.Component.isVisible
        action.selected=true;
    else
        action.selected=false;
    end
end



