function simProfileSuccess=analyzeCost(cbinfo)





    simProfileSuccess=false;

    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        return;
    end

    model=cbinfo.model.Name;
    modelH=get_param(model,'Handle');

    appMgr=multicoredesigner.internal.UIManager.getInstance();


    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end

    appContext.setStatus(multicoredesigner.internal.AnalysisPhase.Analyzing);


    selection=appContext.Mode;
    switch(selection)
    case 'CostEstimation'
        multicoredesigner.internal.toolstrip.estimateCost(cbinfo);
    case 'SILPILProfiling'
        multicoredesigner.internal.toolstrip.tuneModel(cbinfo);
    case 'SimulationProfiling'
        simProfileSuccess=multicoredesigner.internal.toolstrip.autotuneModel(cbinfo);
    end

    appContext.refreshCostValidStatus();
    appContext.setStatus(multicoredesigner.internal.AnalysisPhase.CostComplete);


    if~strcmpi(selection,'SimulationProfiling')


        uiObj=getMulticoreUI(appMgr,modelH);
        updateAnalysisResults(uiObj);


        costEditor=getCostEditor(uiObj);
        show(costEditor);
        expand(costEditor);

    end


