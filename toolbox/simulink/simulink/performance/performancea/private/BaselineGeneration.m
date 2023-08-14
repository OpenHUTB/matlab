function[ResultDescription,ResultDetails]=BaselineGeneration(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);


    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});

    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');



    try
        [~,hasUnsavedChanges]=DefaultPushOldSettings(model);
    catch E
        mdladvObj.UserCancel=true;
        throw(E);
    end


    if hasUnsavedChanges
        mdladvObj.UserCancel=true;
        id='SimulinkPerformanceAdvisor:advisor:UnSavedChanges';
        msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UnSavedChanges');
        throw(MException(id,msg));
    end


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetBaselineBefore(mdladvObj,model,currentCheck);

    baseLineAfter=utilCreateEmptyBaseline();
    baseLineAfter.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CreateBaseline');
    mdladvObj.UserData.Results.currentCheckName=baseLineAfter.check.name;


    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    resetAllBaseLine(mdladvObj);



    inputParams=mdladvObj.getInputParameters('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
    stopTime=inputParams{1}.Value;
    useAutoStopTime=Simulink.ModelReference.Conversion.SimulationTimeUtils.isAutoStopTime(strtrim(stopTime));


    try
        baseline=utilCreateBaseline(mdladvObj,currentCheck,model);
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
        return;
    end


    Result=true;
    statusText=Passed.emitHTML;

    if useAutoStopTime
        stopTime=inputParams{1}.Value;
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AutoStopTime',stopTime));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    end

    result_text=ModelAdvisor.Text([statusText,DAStudio.message('SimulinkPerformanceAdvisor:advisor:BaselineSuccess',baseline.time.displayTime)]);
    result_paragraph.addItem(result_text);
    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';




    mdladvObj.setCheckResultStatus(Result);


    mdladvObj.UserData.Progress.initBaseLine=baseline;


    baseLineAfter.time=baseline.time;
    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    inputParams=mdladvObj.getInputParameters('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
    setTol=inputParams{2}.Value;
    if setTol
        sdiGui=Simulink.sdi.Instance.gui();
        sdiGui.Show();
    end

end


function resetAllBaseLine(mdladvObj)

    rootNode=mdladvObj.getTaskObj('com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor');

    tasks=rootNode.getAllChildren;
    n=length(tasks);

    baseline=utilCreateEmptyBaseline();

    for i=2:n
        task=tasks{i};
        check=mdladvObj.getCheckObj(task.getID);

        baseLine.before=baseline;
        baseLine.after=baseline;
        baseLine.runID=0;

        check.ResultData=baseLine;
    end


    mdladvObj.UserData.Results.baselines=struct([]);


    utilClearSdi(mdladvObj);
end


