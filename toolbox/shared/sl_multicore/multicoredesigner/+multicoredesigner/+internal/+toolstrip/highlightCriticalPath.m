function highlightCriticalPath(cbinfo)



    isHighlightingOn=cbinfo.EventData;

    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');

    appMgr=multicoredesigner.internal.UIManager.getInstance();

    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end


    uiObj=getMulticoreUI(appMgr,modelH);
    removeCriticalPathHighlighting(uiObj);

    if isHighlightingOn
        th=getCriticalPathHighlighter(uiObj);
        highlightAll(th);
    end


