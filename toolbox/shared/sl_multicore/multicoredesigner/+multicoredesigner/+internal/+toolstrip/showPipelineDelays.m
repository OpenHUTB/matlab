function showPipelineDelays(cbinfo)


    showOn=cbinfo.EventData;
    model=cbinfo.model.Name;

    appMgr=multicoredesigner.internal.UIManager.getInstance();
    modelH=get_param(model,'Handle');


    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end

    dataflowUI=get_param(model,'DataflowUI');
    if~isempty(dataflowUI)
        if showOn
            dataflowUI.showLatencyPortAnnotations();
        else
            dataflowUI.hideLatencyPortAnnotations();
        end
    end


