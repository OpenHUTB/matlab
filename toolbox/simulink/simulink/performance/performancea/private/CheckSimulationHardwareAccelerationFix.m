function Result=CheckSimulationHardwareAccelerationFix(taskobj)






    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationHardwareAcceleration');


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
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelCheckTitle');

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


    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;


    fixDataSet=mdladvObj.UserData.SimHardwareAcceleration.ResultData;

    actText=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelSetToNew',fixDataSet.simHardAccel_oldLabel,fixDataSet.simHardAccel_label));

    configSet.set_param('SimHardwareAcceleration',fixDataSet.simHardAccel);




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

        if needUndo
            needUndo=baseline.time.timeBreakdown.Execution<newBaseline.time.timeBreakdown.Execution;
        end
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
            tempBaseLine=baseline;
            tempNewBaseline=newBaseline;
            tempBaseLine.time.total=baseline.time.timeBreakdown.Execution;
            tempNewBaseline.time.total=newBaseline.time.timeBreakdown.Execution;
            tempBaseLine.time.displayTime=datestr(datenum(0,0,0,0,0,baseline.time.timeBreakdown.Execution*100),'HH:MM:SS.FFF');
            tempNewBaseline.time.displayTime=datestr(datenum(0,0,0,0,0,newBaseline.time.timeBreakdown.Execution*100),'HH:MM:SS.FFF');
            summaryTable=utilCreateActionSummaryTable(tableName,needUndo,tempNewBaseline,tempBaseLine,validated,compare_result);
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
    oldSettings.originalSimHardAccel=get_param(model,'SimHardwareAcceleration');
end


function Result=UndoFix(model,oldSettings,Failed)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    configSet.set_param('SimHardwareAcceleration',oldSettings.originalSimHardAccel);

    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);
    Result=[text.emitHTML,lb,lb];
end
