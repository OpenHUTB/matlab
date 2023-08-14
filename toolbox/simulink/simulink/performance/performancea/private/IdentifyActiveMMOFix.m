function Result=IdentifyActiveMMOFix(taskobj)


    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyActiveMMO');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name='Identify active instrumentation settings';

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


    system=mdladvObj.UserData.FixedPoint.Instrumentation.System;
    settings=mdladvObj.UserData.FixedPoint.Instrumentation.Setting;
    for i=1:length(system)
        set_param(system{i},'MinMaxOverflowLogging','UseLocalSettings');
    end




    table=cell(length(system),3);


    for i=1:length(system)
        text=ModelAdvisor.Text(system{i});
        text.setHyperlink(['matlab:open_system(','''',system{i},'''',')']);
        table{i,1}=text;
        table{i,2}=settings{i};
        table{i,3}='UseLocalSettings';

    end

    tableName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionTableName');
    h1='Path';
    h2='Original setting';
    h3='New setting';

    heading={h1,h2,h3};
    actionTable=utilDrawReportTable(table,tableName,{},heading);






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
        else
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaseActionReverted'),{'bold','fail'});
        end

        text=UndoFix(system,settings,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','','');

        newBaseline.time=baseline.time;
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


    function Result=UndoFix(system,oldSettings,Failed)




        for i=1:numel(system)
            set_param(system{i},'MinMaxOverflowLogging',oldSettings{i});
        end
        text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);
        Result=text;

