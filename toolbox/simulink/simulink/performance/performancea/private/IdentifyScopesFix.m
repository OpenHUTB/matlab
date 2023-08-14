function Result=IdentifyScopesFix(taskobj)









    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyScopes');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesTitle');

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


    scopeBlks=find_system(system,...
    'IncludeCommented','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'AllBlocks','on',...
    'BlockType','Scope');

    numScopes=length(scopeBlks);

    oldSettings=struct('ReduceUpdates',true(1,numScopes),'Visible',false(1,numScopes),...
    'OpenAtSimulationStart',false(1,numScopes));

    for indx=1:numScopes
        s=get_param(scopeBlks{indx},'ScopeConfiguration');
        oldSettings.ReduceUpdates(indx)=s.ReduceUpdates;
        if~oldSettings.ReduceUpdates(indx)
            s.ReduceUpdates=true;
        end
        oldSettings.Visible(indx)=s.Visible;
        if oldSettings.Visible(indx)
            s.Visible=false;
        end
        oldSettings.OpentAtSimulationStart(indx)=s.OpenAtSimulationStart;
        if oldSettings.OpentAtSimulationStart(indx)
            s.OpenAtSimulationStart=false;
        end
    end

    reduceUpdatesChanged=any((oldSettings.ReduceUpdates==false));
    openAtSimStartChanged=any((oldSettings.OpentAtSimulationStart==true));


    if~isempty(scopeBlks)

        tableFix=cell(length(scopeBlks),2);
        for i=1:length(scopeBlks);
            if strcmpi('viewer',get_param(scopeBlks{i},'IOType'))
                blockNames=['<a href="matlab: sigandscopemgr Create ',model,'">',scopeBlks{i},'</a>'];
            else
                blockNames=mdladvObj.getHiliteHyperlink(scopeBlks{i});
            end
            hlink=ModelAdvisor.Text(blockNames);
            tableFix{i,1}=hlink;
            tableFix{i,2}=utilGetStatusImgLink(1);
        end

        if reduceUpdatesChanged&&openAtSimStartChanged
            nameFix=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesResultReduceUpdatesAndOpenAtSim');
        elseif openAtSimStartChanged
            nameFix=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesResultOpenAtSim');
        elseif reduceUpdatesChanged
            nameFix=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesResultReduceUpdates');
        else
            nameFix=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesResult');
        end
        resultTableFix=utilDrawReportTable(tableFix,nameFix,{},{});
        baseline.check.fixed='y';
    end

    heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
    heading={heading};


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

        text=UndoFix(scopeBlks,oldSettings,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);
    end

    if needUndo
        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        result_paragraph.addItem(resultTableFix.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;

    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end



function Result=UndoFix(scopeBlks,oldSettings,Failed)
    for indx=1:length(scopeBlks)
        s=get_param(scopeBlks{indx},'ScopeConfiguration');
        s.ReduceUpdates=oldSettings.ReduceUpdates(indx);
        s.Visible=oldSettings.Visible(indx);
        s.OpenAtSimulationStart=oldSettings.OpenAtSimulationStart(indx);
    end

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;
    text=ModelAdvisor.Text([Failed.emitHTML,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);
    Result=[text.emitHTML,lb];
end


