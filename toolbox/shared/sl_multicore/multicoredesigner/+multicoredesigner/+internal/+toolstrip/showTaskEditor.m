function showTaskEditor(cbinfo)



    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');


    appMgr=multicoredesigner.internal.UIManager.getInstance();

    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end


    uiObj=getMulticoreUI(appMgr,modelH);

    taskEditor=getTaskEditor(uiObj);


    if taskEditor.Component.isVisible
        hide(taskEditor);
    else
        show(taskEditor);
        expand(taskEditor);
    end


