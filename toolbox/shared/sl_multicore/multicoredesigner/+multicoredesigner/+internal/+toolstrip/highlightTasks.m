function highlightTasks(cbinfo)



    isHighlightingOn=cbinfo.EventData;

    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');

    appMgr=multicoredesigner.internal.UIManager.getInstance();


    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end


    uiObj=getMulticoreUI(appMgr,modelH);

    removeTaskHighlighting(uiObj);

    if isHighlightingOn
        th=getTaskHighlighter(uiObj);
        highlightAll(th);
    end

    taskLegend=getTaskLegend(uiObj);
    show(taskLegend);
    expand(taskLegend);



