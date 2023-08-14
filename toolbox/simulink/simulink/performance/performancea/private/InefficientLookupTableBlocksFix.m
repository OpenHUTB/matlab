function Result=InefficientLookupTableBlocksFix(taskobj)




    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    [~]=PushOldSettings(model);


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableBlocksTitle');

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




    LUTnDBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','off','BlockType','Lookup_n-D','BeginIndexSearchUsingPreviousIndexResult','off');
    preLUTBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','off','BlockType','PreLookup','BeginIndexSearchUsingPreviousIndexResult','off');
    offBISUPIR=union(LUTnDBlks,preLUTBlks);

    loadLib=false;


    CompInfo=currentCheck.ResultData.FixInfo;


    Lut1DCompInfo={};
    Lut2DCompInfo={};
    for i=1:numel(CompInfo)
        block=CompInfo{i}.BlockName;
        if strcmp(get_param(block,'BlockType'),'Lookup')
            Lut1DCompInfo{end+1}=CompInfo{i};
        else
            Lut2DCompInfo{end+1}=CompInfo{i};
        end
    end



    ch1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BlockPath');
    ch2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Result');

    modelChanged=false;

    if~isempty(Lut1DCompInfo)

        modelChanged=true;

        table1D=cell(length(Lut1DCompInfo),2);
        for i=1:length(Lut1DCompInfo);
            block=Lut1DCompInfo{i}.BlockName;
            blockNames=mdladvObj.getHiliteHyperlink(block);
            hlink=ModelAdvisor.Text(blockNames);
            table1D{i,1}=hlink;
            table1D{i,2}=utilGetStatusImgLink(1);
        end

        name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:LookUpTable1D');


        for i=1:length(Lut1DCompInfo)
            block=Lut1DCompInfo{i}.BlockName;

            name=get_param(block,'Name');
            parent=get_param(block,'Parent');
            inputValues=get_param(block,'InputValues');
            table=get_param(block,'Table');
            lookUpMeth=get_param(block,'LookUpMeth');
            outMin=get_param(block,'OutMin');
            outMax=get_param(block,'OutMax');
            outDataTypeStr=get_param(block,'OutDataTypeStr');
            if strcmp(outDataTypeStr,'Inherit: Same as input')
                outDataTypeStr='Inherit: Same as first input';
            end
            bpDataTypeStr='Inherit: Same as corresponding input';
            if Lut1DCompInfo{i}.useBpEditType
                bpDataTypeStr='Inherit: Inherit from ''Breakpoint data''';
            end
            indexSearchMeth='Binary search';
            if Lut1DCompInfo{i}.isBpEvenSpacing
                indexSearchMeth='Evenly spaced points';
            end
            lockScale=get_param(block,'LockScale');
            rndMeth=get_param(block,'RndMeth');
            sampleTime=get_param(block,'SampleTime');

            if strcmp(get_param(parent,'Type'),'block')
                libBlk=parent;
                while(strcmp(get_param(libBlk,'LinkStatus'),'implicit'))
                    libBlk=get_param(libBlk,'Parent');
                end
                if(strcmp(get_param(libBlk,'LinkStatus'),'resolved'))

                    ref=get_param(libBlk,'ReferenceBlock');
                    lib=ref(1:find(ref=='/',1)-1);
                    if(~bdIsLoaded(lib))
                        load_system(lib);
                        loadLib=true;
                    end
                    set_param(libBlk,'LinkStatus','inactive');
                    table1D{i,2}=utilGetStatusImgLink(0);
                    result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LookUpWarnLibrary'),{'bold','warn'});
                    table1D{i,2}=[table1D{i,2},result_text];
                end
            end
            tmpBlk=add_block('built-in/Lookup_n-D',[parent,'/tmp'],'MakeNameUnique','on');
            tmpBlkName=get_param(tmpBlk,'Name');
            set_param(tmpBlk,'NumberOfTableDimensions','1');
            replacedBlkName=replace_block(parent,'Parent',parent,'Name',name,[parent,'/',tmpBlkName],'noprompt');
            delete_block(tmpBlk);

            set_param(replacedBlkName{1},'BreakpointsForDimension1',inputValues);
            set_param(replacedBlkName{1},'Table',table);
            switch lookUpMeth
            case 'Interpolation-Extrapolation'
                set_param(replacedBlkName{1},'InterpMethod','Linear');
                if Lut1DCompInfo{i}.hasUnsupportedExtrapMeth
                    set_param(replacedBlkName{1},'ExtrapMethod','Clip');
                else
                    set_param(replacedBlkName{1},'ExtrapMethod','Linear');
                end
            case 'Interpolation-Use End Values'
                set_param(replacedBlkName{1},'InterpMethod','Linear');
                set_param(replacedBlkName{1},'ExtrapMethod','Clip');
            case 'Use Input Nearest'
                set_param(replacedBlkName{1},'InterpMethod','Nearest');
                set_param(replacedBlkName{1},'ExtrapMethod','Clip');
            otherwise
                set_param(replacedBlkName{1},'InterpMethod','Flat');
                set_param(replacedBlkName{1},'ExtrapMethod','Clip');
            end
            set_param(replacedBlkName{1},'OutMin',outMin);
            set_param(replacedBlkName{1},'OutMax',outMax);
            set_param(replacedBlkName{1},'OutDataTypeStr',outDataTypeStr);
            set_param(replacedBlkName{1},'LockScale',lockScale);
            set_param(replacedBlkName{1},'RndMeth',rndMeth);
            set_param(replacedBlkName{1},'SampleTime',sampleTime);
            set_param(replacedBlkName{1},'BeginIndexSearchUsingPreviousIndexResult','on');
            set_param(replacedBlkName{1},'IndexSearchMethod',indexSearchMeth);
            set_param(replacedBlkName{1},'BreakpointsForDimension1DataTypeStr',bpDataTypeStr);
            set_param(replacedBlkName{1},'InternalRulePriority','Speed');
        end
        resultTable1=utilDrawReportTable(table1D,name1,{},{ch1,ch2});
    end

    if(loadLib)
        close_system(lib);
        loadLib=false;
    end


    if~isempty(Lut2DCompInfo)

        modelChanged=true;

        table2D=cell(length(Lut2DCompInfo),2);
        for i=1:length(Lut2DCompInfo);
            block=Lut2DCompInfo{i}.BlockName;
            blockNames=mdladvObj.getHiliteHyperlink(block);
            hlink=ModelAdvisor.Text(blockNames);
            table2D{i,1}=hlink;
            table2D{i,2}=utilGetStatusImgLink(1);
        end

        name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:LookUpTable2D');

        for i=1:length(Lut2DCompInfo)
            block=Lut2DCompInfo{i}.BlockName;

            name=get_param(block,'Name');
            parent=get_param(block,'Parent');
            rowIndex=get_param(block,'RowIndex');
            columnIndex=get_param(block,'ColumnIndex');
            table=get_param(block,'Table');
            lookUpMeth=get_param(block,'LookUpMeth');
            outMin=get_param(block,'OutMin');
            outMax=get_param(block,'OutMax');
            inputSameDT=get_param(block,'InputSameDT');
            outDataTypeStr=get_param(block,'OutDataTypeStr');
            bpDataTypeStr='Inherit: Same as corresponding input';
            if Lut2DCompInfo{i}.useBpEditType
                bpDataTypeStr='Inherit: Inherit from ''Breakpoint data''';
            end
            indexSearchMeth='Binary search';
            if Lut2DCompInfo{i}.isBpEvenSpacing
                indexSearchMeth='Evenly spaced points';
            end

            lockScale=get_param(block,'LockScale');
            rndMeth=get_param(block,'RndMeth');
            sampleTime=get_param(block,'SampleTime');

            if strcmp(get_param(parent,'Type'),'block')
                libBlk=parent;
                while(strcmp(get_param(libBlk,'LinkStatus'),'implicit'))
                    libBlk=get_param(libBlk,'Parent');
                end
                if(strcmp(get_param(libBlk,'LinkStatus'),'resolved'))

                    ref=get_param(libBlk,'ReferenceBlock');
                    lib=ref(1:find(ref=='/',1)-1);
                    if(~bdIsLoaded(lib))
                        load_system(lib);
                        loadLib=true;
                    end
                    set_param(libBlk,'LinkStatus','inactive');
                    table2D{i,2}=utilGetStatusImgLink(0);
                    result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LookUpWarnLibrary'),{'bold','warn'});
                    table2D{i,2}=[table2D{i,2},result_text];
                end
            end
            tmpBlk=add_block('built-in/Lookup_n-D',[parent,'/tmp'],'MakeNameUnique','on');
            tmpBlkName=get_param(tmpBlk,'Name');
            set_param(tmpBlk,'NumberOfTableDimensions','2');
            replacedBlkName=replace_block(parent,'Parent',parent,'Name',name,[parent,'/',tmpBlkName],'noprompt');
            delete_block(tmpBlk);

            set_param(replacedBlkName{1},'BreakpointsForDimension1',rowIndex);
            set_param(replacedBlkName{1},'BreakpointsForDimension2',columnIndex);
            set_param(replacedBlkName{1},'Table',table);
            switch lookUpMeth
            case 'Interpolation-Extrapolation'
                set_param(replacedBlkName{1},'InterpMethod','Linear');
                if Lut2DCompInfo{i}.hasUnsupportedExtrapMeth
                    set_param(replacedBlkName{1},'ExtrapMethod','Clip');
                else
                    set_param(replacedBlkName{1},'ExtrapMethod','Linear');
                end
            case 'Interpolation-Use End Values'
                set_param(replacedBlkName{1},'InterpMethod','Linear');
                set_param(replacedBlkName{1},'ExtrapMethod','Clip');
            case 'Use Input Nearest'
                set_param(replacedBlkName{1},'InterpMethod','Nearest');
                set_param(replacedBlkName{1},'ExtrapMethod','Clip');
            otherwise
                set_param(replacedBlkName{1},'InterpMethod','Flat');
                set_param(replacedBlkName{1},'ExtrapMethod','Clip');
            end
            set_param(replacedBlkName{1},'OutMin',outMin);
            set_param(replacedBlkName{1},'OutMax',outMax);
            set_param(replacedBlkName{1},'OutDataTypeStr',outDataTypeStr);
            set_param(replacedBlkName{1},'LockScale',lockScale);
            set_param(replacedBlkName{1},'RndMeth',rndMeth);
            set_param(replacedBlkName{1},'SampleTime',sampleTime);
            set_param(replacedBlkName{1},'InputSameDT',inputSameDT);
            set_param(replacedBlkName{1},'BeginIndexSearchUsingPreviousIndexResult','on');
            set_param(replacedBlkName{1},'IndexSearchMethod',indexSearchMeth);
            set_param(replacedBlkName{1},'InternalRulePriority','Speed');
            set_param(replacedBlkName{1},'BreakpointsForDimension1DataTypeStr',bpDataTypeStr);
            set_param(replacedBlkName{1},'BreakpointsForDimension2DataTypeStr',bpDataTypeStr);
        end

        resultTable2=utilDrawReportTable(table2D,name2,{},{ch1,ch2});

    end

    if(loadLib)
        close_system(lib);
    end

    if~isempty(offBISUPIR)
        modelChanged=true;
        tableND=cell(length(offBISUPIR),2);
        for i=1:length(offBISUPIR);
            blockNames=mdladvObj.getHiliteHyperlink(offBISUPIR{i});
            hlink=ModelAdvisor.Text(blockNames);
            tableND{i,1}=hlink;
            tableND{i,2}=utilGetStatusImgLink(1);
        end

        nameN=DAStudio.message('SimulinkPerformanceAdvisor:advisor:LookUpTableND');

        for i=1:length(offBISUPIR)
            set_param(offBISUPIR{i},'BeginIndexSearchUsingPreviousIndexResult','on')
        end

        resultTableN=utilDrawReportTable(tableND,nameN,{},{ch1,ch2});

    end

    if(~modelChanged)
        result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelNotChangedLinkedBlocks')));
        Result=result_paragraph;
        currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
        baseline.check.fixed='n';
        utilUpdateBaseline(mdladvObj,currentCheck,baseline,baseline);
        return;
    end



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

        text=UndoFix(model,currentCheck,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);
    end

    if needUndo
        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        if~isempty(Lut1DCompInfo)
            result_paragraph.addItem(resultTable1.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end

        if~isempty(Lut2DCompInfo)
            result_paragraph.addItem(resultTable2.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end

        if~isempty(offBISUPIR)
            result_paragraph.addItem(resultTableN.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end
    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;


    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end



function oldSettings=PushOldSettings(model)
    oldSettings=DefaultPushOldSettings(model);
end


function Result=UndoFix(model,currentCheck,msg)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    text=ModelAdvisor.Text([msg.emitHTML,lb,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);

    Result=DefaultUndo(model,currentCheck,text);
end


