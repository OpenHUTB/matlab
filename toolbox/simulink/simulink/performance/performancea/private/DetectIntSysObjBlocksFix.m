function Result=DetectIntSysObjBlocksFix(taskobj)











    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.DetectIntSysObjBlocks');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntSysObjBlocksTitle');

    try

        runCompileFor1stRunIfNeeded(baseline,mdladvObj,model,currentCheck);
        baseline=utilGenerateBaselineIfNeeded(baseline,mdladvObj,model,currentCheck);
    catch ME

        text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:OldBaselineFailed');
        Result=publishActionFailedMessage(ME,text);
        baseline.check.fixed='n';
        utilUpdateBaseline(mdladvObj,currentCheck,baseline,baseline);
        currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
        return;
    end



    mlSysObjBlks=currentCheck.resultData.FixInfo;
    mlSysObjSwithcedBlks=cell(0);switchedBlks=0;
    modelChanged=false;

    for idx=1:length(mlSysObjBlks)
        if mlSysObjBlks(idx).screenerPass
            switchedBlks=switchedBlks+1;
            mlSysObjSwithcedBlks{switchedBlks}=mlSysObjBlks(idx).block;

            set_param(mlSysObjBlks(idx).block,'SimulateUsing','Code generation');
        end
    end


    oldSettings.changedBlocks=mlSysObjSwithcedBlks;

    if(switchedBlks)
        modelChanged=true;
        baseline.check.fixed='y';
    end


    if modelChanged
        baselineOk=true;
        try

            runCompileFor1stRunIfNeeded(baseline,mdladvObj,model,currentCheck);
            runCompileFor1stRunIfNeeded(baseline,mdladvObj,model,currentCheck);

            [~,newBaseline,needUndo,validated,compare_result]=utilCheckActionResult(mdladvObj,currentCheck,baseline);
        catch ME

            baseText1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaselineFailed');
            baseText2=publishActionFailedMessage(ME,baseText1);
            result_paragraph.addItem(baseText2);
            baselineOk=false;

            needUndo=true;
        end
    else

        needUndo=false;
        validated=false;
        compare_result.Time=false;
        compare_result.Accuracy=false;
        baseline.check.fixed='n';
        newBaseline=baseline;
    end



    if~modelChanged
        result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NoSysObjsChanged'),{'bold','fail'}));
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
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

        text=UndoFix(oldSettings,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);

    end

    if needUndo
        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        if(modelChanged)
            table=cell(length(mlSysObjSwithcedBlks),1);

            for idx=1:length(mlSysObjSwithcedBlks)
                blockName=mdladvObj.getHiliteHyperlink(mlSysObjSwithcedBlks{idx});
                hlink=ModelAdvisor.Text(blockName);
                table{idx,1}=hlink;
            end
            ch1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BlockPath');

            resultTable=utilDrawReportTable(table,'List of blocks modified',{},{ch1});
            result_paragraph.addItem(resultTable.emitHTML);

            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

        end
    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;

    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
end


function Result=UndoFix(oldSettings,msg)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    text=ModelAdvisor.Text([msg.emitHTML,lb,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;
    Result=[text.emitHTML,lb];


    for idx=1:length(oldSettings.changedBlocks)
        set_param(oldSettings.changedBlocks{idx},'SimulateUsing','Interpreted execution');
    end
end


function T=runCompileFor1stRunIfNeeded(~,mdladvObj,model,currentCheck)


    [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);
    if(validateTime||validateAccuracy)
        cond1=strcmp(currentCheck.getID,'com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
        if(~cond1)
            tic;
            evalc([model,'([],[],[],''compile'')']);
            evalc([model,'([],[],[],''term'')']);
            T=toc;
        end
    end


end


