function showTaskLegend(cbinfo)



    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');

    appMgr=multicoredesigner.internal.UIManager.getInstance();

    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end


    uiObj=getMulticoreUI(appMgr,modelH);

    taskLegend=getTaskLegend(uiObj);

    if taskLegend.Component.isVisible
        removeTaskHighlighting(uiObj);
        hide(taskLegend);
    else
        show(taskLegend);
        expand(taskLegend);
    end



