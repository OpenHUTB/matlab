function[ResultDescription,ResultDetails]=CheckDelayBlockCircularBufferSetting(system)



    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);



    CompInfo=utilGetCheckCompInfo(currentCheck);
    if~CompInfo.valid
        try
            eval([model,'([],[],[], ''compile'')']);
            CompInfo.value=utilGetDelayBlocks(model);
            CompInfo.valid=true;
            eval([model,'([],[],[], ''term'')']);
        catch ME
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
            return;
        end
    end

    DelayCompInfo=CompInfo.value;

    if~isempty(DelayCompInfo)
        Pass=false;
    end



    if~Pass

        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        DelayFixInfo={};
        if~isempty(DelayCompInfo)
            tName1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingName');
            table=cell(length(DelayCompInfo),1);
            for i=1:length(DelayCompInfo);
                block=DelayCompInfo{i}.BlockName;
                blockName=mdladvObj.getHiliteHyperlink(block);
                hlink=ModelAdvisor.Text(blockName);
                linked=~strcmp(get_param(block,'LinkStatus'),'none');
                if(linked)
                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LinkedBlocks'),{'bold'});
                    table{i,1}=ModelAdvisor.Text([blockName,'   --> ',text.emitHTML]);
                else
                    table{i,1}=hlink;
                    DelayFixInfo{end+1}=DelayCompInfo{i};
                end
            end

            resultTable=utilDrawReportTable(table,tName1,{},{});
            result_paragraph.addItem(resultTable.emitHTML);
        end

        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDelayBlockCircularBufferSettingPassed',model));
        result_paragraph.addItem(result_text);

    end

    ResultDetails{end+1}='';
    ResultDescription{end+1}=result_paragraph;



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        currentCheck.ResultData.FixInfo=DelayFixInfo;


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



