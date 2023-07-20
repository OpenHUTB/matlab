function analyzeModel(cbinfo)



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

    if appContext.SimulationProfilingModeEnabled
        simAnalysis(cbinfo,appContext,appMgr,modelH);
        return;
    end

    appContext.setStatus(multicoredesigner.internal.AnalysisPhase.Analyzing);

    diagStage=sldiagviewer.createStage(getString(message('dataflow:Spreadsheet:AnalyzingStageName')),'ModelName',model);


    [allMdls,~]=multicoredesigner.internal.MappingData.updateDataModelHierarchy(modelH);



    for i=length(allMdls):-1:1

        modelToAnalyze=allMdls{i};
        tempSettings={{'MulticoreDesignerAction','PartitionTasks'}};
        if slfeature('SLMulticore')==2


            tempSettings{end+1}={'EnableMultiTasking','on'};
        end
        orig=setParamTemp(modelToAnalyze,tempSettings);
        restoreSettings=onCleanup(@()recoverParam(modelToAnalyze,orig));


        multicoredesigner.internal.toolstrip.updateModelForAnalysis(modelToAnalyze,false);
    end

    appContext.setStatus(multicoredesigner.internal.AnalysisPhase.AnalysisComplete);


    locPostAnalysisTasks(modelH,appMgr,appContext);
end


function simAnalysis(cbinfo,appContext,appMgr,modelH)

    appContext.setStatus(multicoredesigner.internal.AnalysisPhase.Analyzing);

    multicoredesigner.internal.toolstrip.updateModelForAnalysis(modelH,true);

    appContext.refreshCostValidStatus();


    needsProfiling=true;
    simProfileSuccess=true;
    dataflowUI=get_param(modelH,'DataflowUI');
    if~isempty(dataflowUI)
        needsProfiling=dataflowUI.NeedsProfiling;
    end


    if~appContext.IsCostValid||needsProfiling
        simProfileSuccess=multicoredesigner.internal.toolstrip.analyzeCost(cbinfo);
    end


    if simProfileSuccess
        multicoredesigner.internal.toolstrip.updateModelForAnalysis(modelH,true);
        appContext.setStatus(multicoredesigner.internal.AnalysisPhase.AnalysisComplete);
    else

        appContext.setStatus(multicoredesigner.internal.AnalysisPhase.Initial);
    end


    locPostAnalysisTasks(modelH,appMgr,appContext);
end

function locPostAnalysisTasks(modelH,appMgr,appContext)
    uiObj=getMulticoreUI(appMgr,modelH);


    updateAnalysisResults(uiObj);


    dataflowUI=get_param(modelH,'DataflowUI');
    if~isempty(dataflowUI)&&uiObj.MappingData.HasPipelineDelays
        dataflowUI.showLatencyPortAnnotations();
        appContext.IsPipeliningAnnotationOn=true;
    end


    highlightAllTasks(uiObj);
    taskLegend=getTaskLegend(uiObj);
    show(taskLegend);
    expand(taskLegend);

    speedupPanel=getSpeedupPanel(uiObj);
    show(speedupPanel);
end

function org=setParamTemp(system,params)
    org=[];
    for i=1:length(params)
        p=params{i};
        org{end+1}={p{1},get_param(system,p{1})};
        set_param(system,p{1},p{2});
    end
end

function recoverParam(system,params)
    for i=1:length(params)
        p=params{i};
        set_param(system,p{1},p{2});
    end
end


