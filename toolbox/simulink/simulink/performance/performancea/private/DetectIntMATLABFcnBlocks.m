function[ResultDescription,ResultDetails]=DetectIntMATLABFcnBlocks(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.DetectIntMATLABFcnBlocks');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);




    mlFcnBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','MATLABFcn');

    if~isempty(mlFcnBlks)
        Pass=false;
    end


    if~Pass

        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);


        if~isempty(mlFcnBlks)
            table=mlFcnBlks;

            for i=1:length(table);
                block=mlFcnBlks{i};
                blockName=mdladvObj.getHiliteHyperlink(table{i,1});
                hlink=ModelAdvisor.Text(blockName);
                linked=~strcmp(get_param(block,'LinkStatus'),'none');
                if(linked)
                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LinkedBlocks'),{'bold'});
                    table{i,1}=ModelAdvisor.Text([blockName,'   --> ',text.emitHTML]);
                else
                    table{i,1}=hlink;
                end
            end

            tName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksTableName');
            resultTable=utilDrawReportTable(table,tName,{},{});
            result_paragraph.addItem(resultTable.emitHTML);
        end

        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IntMATLABFcnAdviceAppendPassed',model));
        result_paragraph.addItem(result_text);

    end


    ResultDetails{end+1}='';
    ResultDescription{end+1}=result_paragraph;


    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


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
