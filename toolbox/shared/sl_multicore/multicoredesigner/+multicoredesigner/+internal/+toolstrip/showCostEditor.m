function showCostEditor(cbinfo)




    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');


    appMgr=multicoredesigner.internal.UIManager.getInstance();

    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end


    uiObj=getMulticoreUI(appMgr,modelH);
    costEditor=getCostEditor(uiObj);


    if costEditor.Component.isVisible
        hide(costEditor);
    else
        show(costEditor);
        expand(costEditor);
    end


