function Result=IdentifyExpensiveDiagnosticsFix(taskobj)





    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyExpensiveDiagnostics');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end

    dParam={'ConsistencyChecking','SignalResolutionControl','CheckMatrixSingularityMsg','SignalInfNanChecking','SignalRangeChecking','ArrayBoundsChecking','ReadBeforeWriteMsg','WriteAfterReadMsg','WriteAfterWriteMsg','MultiTaskDSMMsg','UniqueDataStoreMsg'};


    oldSettings=PushOldSettings(model,dParam);


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyExpensiveDiagnosticsTitle');

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



    rv1='none';
    rv2='UseLocalSettings';
    rv3='none';
    rv4='none';
    rv5='none';
    rv6='none';
    rv7='DisableAll';
    rv8='DisableAll';
    rv9='DisableAll';
    rv10='none';
    rv11='none';

    str1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataConsistencyDisabled');
    str2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SignalResolutionSetToLocal');
    str3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DivisionBySingularDisabled');
    str4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SignalInfNanCheckingDisabled');
    str5=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SignalInfNanCheckingDisabled');
    str6=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ArrayBoundsCheckingDisabled');
    str7=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ReadBeforeWriteMsgDisabled');
    str8=DAStudio.message('SimulinkPerformanceAdvisor:advisor:WriteAfterReadMsgDisabled');
    str9=DAStudio.message('SimulinkPerformanceAdvisor:advisor:WriteAfterWriteMsgDisabled');
    str10=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MultiTaskDSMMsgDisabled');
    str11=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UniqueDataStoreMsgDisabled');

    fixStr={str1,str2,str3,str4,str5,str6,str7,str8,str9,str10,str11};

    recommendValue={rv1,rv2,rv3,rv4,rv5,rv6,rv7,rv8,rv9,rv10,rv11};




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
    oldSettings.ConsistencyChecking=get_param(model,dParam{1});
    oldSettings.SignalResolutionControl=get_param(model,dParam{2});
    oldSettings.CheckMatrixSingularityMsg=get_param(model,dParam{3});
    oldSettings.SignalInfNanChecking=get_param(model,dParam{4});
    oldSettings.SignalRangeChecking=get_param(model,dParam{5});
    oldSettings.ArrayBoundsChecking=get_param(model,dParam{6});
    oldSettings.ReadBeforeWriteMsg=get_param(model,dParam{7});
    oldSettings.WriteAfterReadMsg=get_param(model,dParam{8});
    oldSettings.WriteAfterWriteMsg=get_param(model,dParam{9});
    oldSettings.MultiTaskDSMMsg=get_param(model,dParam{10});
    oldSettings.UniqueDataStoreMsg=get_param(model,dParam{11});
end



function Result=UndoFix(model,oldSettings,dParam,Failed)






    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    configSet.set_param(dParam{1},oldSettings.ConsistencyChecking);
    configSet.set_param(dParam{2},oldSettings.SignalResolutionControl');
    configSet.set_param(dParam{3},oldSettings.CheckMatrixSingularityMsg);
    configSet.set_param(dParam{4},oldSettings.SignalInfNanChecking);
    configSet.set_param(dParam{5},oldSettings.SignalRangeChecking);
    configSet.set_param(dParam{6},oldSettings.ArrayBoundsChecking);
    configSet.set_param(dParam{7},oldSettings.ReadBeforeWriteMsg);
    configSet.set_param(dParam{8},oldSettings.WriteAfterReadMsg);
    configSet.set_param(dParam{9},oldSettings.WriteAfterWriteMsg);
    configSet.set_param(dParam{10},oldSettings.MultiTaskDSMMsg);
    configSet.set_param(dParam{11},oldSettings.UniqueDataStoreMsg);

    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);
    Result=text;
end



