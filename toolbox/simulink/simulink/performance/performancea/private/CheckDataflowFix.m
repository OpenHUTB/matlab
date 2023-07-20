function Result=CheckDataflowFix(taskobj)





    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDataflow');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    fixData=mdladvObj.UserData.Dataflow;
    oldSettings=PushOldSettings(model,fixData);


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTitle');

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



    fixMsg={};
    fixedSS={};
    if isfield(fixData,'OptimalLatency')
        for i=1:numel(fixData.OptimalLatency)

            hSS=getSimulinkBlockHandle(fixData.OptimalLatency{i}.Subsys);
            if(hSS~=-1)
                oldLat=get_param(hSS,'Latency');
                optLatStr=num2str(fixData.OptimalLatency{i}.OptLat);
                set_param(hSS,'Latency',optLatStr);

                blkName=getfullname(hSS);
                ssBlkSID=Simulink.ID.getSID(blkName);
                hlink=ModelAdvisor.Text(blkName);
                hlink.setHyperlink(['matlab: utilOpenDataflowSubsystemPI(''',ssBlkSID,''');']);
                fixMsg{end+1}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowLatencyFix',oldLat,optLatStr,hlink.emitHTML);
                fixedSS{end+1}=hSS;
            end
        end


        if~isempty(fixMsg)
            if strcmpi(get_param(model,'SimulationMode'),'rapid-accelerator')
                Simulink.BlockDiagram.buildRapidAcceleratorTarget(model);
            else
                eval([model,'([],[],[], ''compile'')']);
                eval([model,'([],[],[], ''term'')']);
            end

        end

    end



    if isempty(fixMsg)
        fixMsg{1}=ModelAdvisor.Text('None');
    end


    table=cell(numel(fixMsg),1);


    heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
    heading={heading};


    for i=1:numel(fixMsg)
        table{i,1}=fixMsg{i};
    end
    tName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionTableName');
    actionTable=utilDrawReportTable(table,tName,'',heading);

    if~isempty(fixedSS)

        ui=get_param(model,'DataflowUI');

        fixedMappingData=cell(numel(fixedSS),1);
        for i=1:numel(fixedSS)
            fixedMappingData{i}=ui.getBlkMappingData(fixedSS{i});
        end

        resultTable=utilDataflowResultsTable(mdladvObj,[fixedMappingData{:}],DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowModifedTableTitle'));
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    end





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
        if~isempty(fixedSS)
            result_paragraph.addItem(resultTable.emitHTML);
        end
    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;


    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end


function oldSettings=PushOldSettings(model,fixData)
    oldSettings.OptimalLatency={};
    if isfield(fixData,'OptimalLatency')
        for i=1:numel(fixData.OptimalLatency)

            hSS=getSimulinkBlockHandle(fixData.OptimalLatency{i}.Subsys);
            if(hSS~=-1)
                oldSettings.OptimalLatency{end+1}.hSS=hSS;
                oldSettings.OptimalLatency{end}.Latency=get_param(hSS,'Latency');
            end
        end
    end
end

function Result=UndoFix(model,oldSettings,Failed)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    for i=1:numel(oldSettings.OptimalLatency)
        set_param(oldSettings.OptimalLatency{i}.hSS,'Latency',oldSettings.OptimalLatency{i}.Latency);
    end

    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowUndo')]);
    Result=[text.emitHTML,lb,lb];
end
