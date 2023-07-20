function Result=CheckDelayBlockCircularBufferSettingFix(taskobj)

    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingTitle');

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



    CompInfo=currentCheck.ResultData.FixInfo;



    ch1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BlockPath');
    ch2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Result');

    modelChanged=false;

    if~isempty(CompInfo)
        modelChanged=true;
        table=cell(length(CompInfo),2);
        for i=1:length(CompInfo);
            block=CompInfo{i}.BlockName;
            blockNames=mdladvObj.getHiliteHyperlink(block);
            hlink=ModelAdvisor.Text(blockNames);
            table{i,1}=hlink;
            table{i,2}=utilGetStatusImgLink(1);
        end

        nameN=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingName');

        for i=1:length(CompInfo)
            block=CompInfo{i}.BlockName;
            set_param(block,'UseCircularBuffer','on')
        end

        resultTable=utilDrawReportTable(table,nameN,{},{ch1,ch2});

    end

    if(~modelChanged)
        result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelNotChangedLinkedBlocks')));
        Result=result_paragraph;
        currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
        baseline.check.fixed='n';
        utilUpdateBaseline(mdladvObj,currentCheck,baseline,baseline);
        return;
    end

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

        heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
        heading={heading};

        if baselineOk
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceNotImproved'),{'bold','fail'});

            newBaseline.time=baseline.time;
        else
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaseActionReverted'),{'bold','fail'});
            newBaseline=baseline;
        end

        text=UndoFix(CompInfo,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);

    end

    if needUndo
        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        if~isempty(CompInfo)
            result_paragraph.addItem(resultTable.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end
    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;


    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end



function Result=UndoFix(CompInfo,msg)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    for i=1:length(CompInfo)
        block=CompInfo{i}.BlockName;
        set_param(block,'UseCircularBuffer','off');
    end

    text=ModelAdvisor.Text([msg.emitHTML,lb,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);

    Result=[text.emitHTML,lb,lb];
end


