function Result=CheckSimulationModesComparisonFix(taskobj)






    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationModesComparison');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    oldSettings=PushOldSettings(model);


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationModesComparisonTitle');

    try
        baseline=utilGenerateBaselineIfNeeded(baseline,mdladvObj,model,currentCheck);
    catch ME

        text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:OldBaselineFailed');
        Result=publishActionFailedMessage(ME,text);
        baseline.check.fixed='n';
        utilUpdateBaseline(mdladvObj,currentCheck,baseline,baseline);
        currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
        return;
    end



    simMode=get_param(model,'SimulationMode');
    isNormal=strcmpi(simMode,'normal');
    isAccelerator=strcmpi(simMode,'accelerator');
    bestDataSet=mdladvObj.UserData.SimTargetTestsData.SimulationMode.ResultData.bestDataSet;

    if isNormal
        oldMode=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode');
    elseif(isAccelerator)
        oldMode=DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode');
    else
        oldMode=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorMode');
    end
    newMode=bestDataSet.simulationmode_fordisplay;
    actText=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SetToNewMode',oldMode,newMode));
    set_param(model,'SimulationMode',bestDataSet.simulationmode);




    table=cell(1,1);


    heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
    heading={heading};


    table{1,1}=actText;
    tName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionTableName');
    actionTable=utilDrawReportTable(table,tName,'',heading);
    baseline.check.fixed='y';



    baselineOk=true;
    try

        [~,newBaseline,needUndo,validated,compare_result]=utilCheckActionResult(mdladvObj,currentCheck,baseline);
    catch ME

        baseText1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaselineFailed');
        baseText2=publishActionFailedMessage(ME,baseText1);
        result_paragraph.addItem(baseText2);
        baselineOk=false;
    end




    if baselineOk
        [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);
        if(validateTime||validateAccuracy)
            tableName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationTableName');
            summaryTable=utilCreateActionSummaryTable(tableName,needUndo,newBaseline,baseline,validated,compare_result);
            result_paragraph.addItem(summaryTable.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end
    else
        needUndo=true;
    end

    if needUndo

        if baselineOk
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceNotImproved'),{'bold','fail'});

            newBaseline.time=baseline.time;
        else
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaseActionReverted'),{'bold','fail'});
            newBaseline=baseline;
        end

        text=UndoFix(model,oldSettings,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);

    end

    if needUndo
        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        result_paragraph.addItem(actionTable.emitHTML);
    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;


    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end





function oldSettings=PushOldSettings(model)
    oldSettings.simulationMode=get_param(model,'SimulationMode');
end


function Result=UndoFix(model,oldSettings,Failed)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    set_param(model,'SimulationMode',oldSettings.simulationMode);

    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);
    Result=[text.emitHTML,lb,lb];
end



