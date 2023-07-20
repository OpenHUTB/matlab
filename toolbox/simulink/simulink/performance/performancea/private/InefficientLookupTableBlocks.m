function[ResultDescription,ResultDetails]=InefficientLookupTableBlocks(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks');
    quickScan=strcmp(mdladvObj.UserData.Mode,'QuickScan');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableBlocksTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);





    LUT1DBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Lookup');
    LUT2DBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Lookup2D');
    LUTnDBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Lookup_n-D','BeginIndexSearchUsingPreviousIndexResult','off');
    preLUTBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','PreLookup','BeginIndexSearchUsingPreviousIndexResult','off');

    stdLUTBlks=union(LUT1DBlks,LUT2DBlks);
    offBISUPIR=union(LUTnDBlks,preLUTBlks);

    if~(isempty(stdLUTBlks)&&isempty(offBISUPIR))
        Pass=false;
    end


    CompInfo=utilGetCheckCompInfo(currentCheck);

    if~CompInfo.valid
        try

            if~quickScan
                eval([model,'([],[],[], ''compile'')']);
            end

            CompInfo.value=utilGetLookup1D2DInfo(model,quickScan);
            CompInfo.valid=true&&(~quickScan);

            if~quickScan
                eval([model,'([],[],[], ''term'')']);
            end
        catch ME
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
            return;
        end
    end

    CompInfo1D=CompInfo.value(1:length(LUT1DBlks));
    CompInfo2D=CompInfo.value((length(LUT1DBlks)+1):end);



    Lut1DCompInfoYes={};
    Lut1DCompInfoNo={};
    for i=1:numel(CompInfo1D)
        if CompInfo1D{i}.isCompatible
            Lut1DCompInfoYes{end+1}=CompInfo1D{i};
        else
            Lut1DCompInfoNo{end+1}=CompInfo1D{i};
        end
    end

    Lut2DCompInfoYes={};
    Lut2DCompInfoNo={};
    for i=1:numel(CompInfo2D)
        if CompInfo2D{i}.isCompatible
            Lut2DCompInfoYes{end+1}=CompInfo2D{i};
        else
            Lut2DCompInfoNo{end+1}=CompInfo2D{i};
        end
    end

    replaceBlockYes={Lut1DCompInfoYes{:},Lut2DCompInfoYes{:}};
    replaceBlockNo={Lut1DCompInfoNo{:},Lut2DCompInfoNo{:}};


    if~Pass

        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableBlocksAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);


        LutFixInfo={};
        if~isempty(replaceBlockYes)
            tName1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableName1');
            table=cell(length(replaceBlockYes),1);
            for i=1:length(table);
                block=replaceBlockYes{i}.BlockName;
                blockName=mdladvObj.getHiliteHyperlink(block);
                hlink=ModelAdvisor.Text(blockName);

                linked=~strcmp(get_param(block,'LinkStatus'),'none');
                if(linked)
                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LinkedBlocks'),{'bold'});
                    table{i,1}=ModelAdvisor.Text([blockName,'   --> ',text.emitHTML]);
                else
                    table{i,1}=hlink;
                    LutFixInfo{end+1}=replaceBlockYes{i};
                end
            end

            resultTable=utilDrawReportTable(table,tName1,{},{});
            result_paragraph.addItem(resultTable.emitHTML);
        end

        result_paragraph.addItem([ModelAdvisor.LineBreak]);


        if~isempty(replaceBlockNo)
            tName1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableName3');
            table=cell(length(replaceBlockNo),1);
            for i=1:length(table);
                block=replaceBlockNo{i}.BlockName;
                blockName=mdladvObj.getHiliteHyperlink(block);
                hlink=ModelAdvisor.Text(blockName);

                linked=~strcmp(get_param(block,'LinkStatus'),'none');
                if(linked)
                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LinkedBlocks'),{'bold'});
                    table{i,1}=ModelAdvisor.Text([blockName,'   --> ',text.emitHTML]);
                else
                    table{i,1}=hlink;
                end
            end

            resultTable=utilDrawReportTable(table,tName1,{},{});
            result_paragraph.addItem(resultTable.emitHTML);
        end

        result_paragraph.addItem([ModelAdvisor.LineBreak]);


        if~isempty(offBISUPIR)
            tName2=(DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableName2'));
            table=cell(length(offBISUPIR),1);

            for i=1:length(table);
                block=offBISUPIR{i};
                blockName=mdladvObj.getHiliteHyperlink(block);
                hlink=ModelAdvisor.Text(blockName);
                linked=~strcmp(get_param(block,'LinkStatus'),'none');
                if(linked)
                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LinkedBlocks'),{'bold'});
                    table{i,1}=ModelAdvisor.Text([blockName,'   --> ',text.emitHTML]);
                else
                    table{i,1}=hlink;
                end
            end

            resultTable=utilDrawReportTable(table,tName2,{},{});
            result_paragraph.addItem(resultTable.emitHTML);
        end


        if quickScan
            result_paragraph.addItem([ModelAdvisor.LineBreak]);
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:QuickScanWarning1'));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak]);

            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:QuickScanWarningLookupTable'));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak]);

            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:QuickScanWarning2'));
            result_paragraph.addItem(result_text);
        end

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:InefficientLookupTableBlocksAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LookupAdviceAppendPassed',model));
        result_paragraph.addItem(result_text);

    end

    ResultDetails{end+1}='';
    ResultDescription{end+1}=result_paragraph;



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        currentCheck.ResultData.FixInfo=LutFixInfo;


        utilRunFix(mdladvObj,currentCheck,Pass);
    end


    if(Pass)
        baseLineAfter.time=baseLineBefore.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end
    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

end
