function Result=CheckIfNeedDecoupleContDiscRatesFix(taskobj)


    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesTitle');

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


    oldSettings=get_param(model,'DecoupledContinuousIntegration');
    newSetting=currentCheck.ResultData.FixInfo;
    if newSetting
        newSettings='on';
    else
        newSettings='off';
    end
    set_param(model,'DecoupledContinuousIntegration',newSettings);
    result_text1=ModelAdvisor.LineBreak;
    result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesChangeConfirmed',oldSettings,newSettings));
    result_text=[result_text,result_text1];



    table=cell(1,1);

    heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
    heading={heading};


    table{1,1}=result_text;
    tName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionTableName');
    actionTable=utilDrawReportTable(table(1,1),tName,'',heading);
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


function Result=UndoFix(model,oldSettings,Failed)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    set_param(model,'DecoupledContinuousIntegration',oldSettings);

    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesNotChanged',oldSettings)]);
    Result=[text.emitHTML,lb,lb];
end



