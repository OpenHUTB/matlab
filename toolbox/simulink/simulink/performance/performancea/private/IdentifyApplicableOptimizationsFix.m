function Result=IdentifyApplicableOptimizationsFix(taskobj)



    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyApplicableOptimizations');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end

    dParam={'BlockReduction','ConditionallyExecuteInputs','OptimizeBlockIOStorage'};
    oldSettings=PushOldSettings(model,dParam);


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyApplicableOptimizationsTitle');

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



    rv1='on';
    rv2='on';
    rv3='on';

    str1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BlockReductionEnabled');
    str2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CECEnabled');
    str3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SignalReuseEnabled');


    fixStr={str1,str2,str3};

    recommendValue={rv1,rv2,rv3};





    table=cell(length(recommendValue),1);


    heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
    heading={heading};


    j=0;
    for i=1:length(dParam);
        if~strcmp(get_param(model,dParam{i}),recommendValue{i})
            configSet.set_param(dParam{i},recommendValue{i});
            j=j+1;
            result_text=ModelAdvisor.Text(fixStr{i});
            table{j,1}=result_text;
        end
    end

    tName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionTableName');
    actionTable=utilDrawReportTable(table(1:j,1),tName,'',heading);
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

        text=UndoFix(model,oldSettings,dParam,Failed);
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


function oldSettings=PushOldSettings(model,dParam)
    oldSettings.BlockReduction=get_param(model,dParam{1});
    oldSettings.ConditionallyExecuteInputs=get_param(model,dParam{2});
    oldSettings.OptimizeBlockIOStorage=get_param(model,dParam{3});
end


function Result=UndoFix(model,oldSettings,dParam,Failed)





    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    configSet.set_param(dParam{1},oldSettings.BlockReduction);
    configSet.set_param(dParam{2},oldSettings.ConditionallyExecuteInputs);
    configSet.set_param(dParam{3},oldSettings.OptimizeBlockIOStorage);

    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);
    Result=text;
end


