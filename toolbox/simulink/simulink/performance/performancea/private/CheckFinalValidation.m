function[ResultDescription,ResultDetails]=CheckFinalValidation(system)



    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.FinalValidation');


    Pass=true;

    requireValidation=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);


    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationTitle'));


    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);



    initBaseline=mdladvObj.UserData.Progress.initBaseLine;

    if isempty(initBaseline.time.runID)
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationNoBaseline'));
        result_paragraph.addItem(result_text);

        ResultDescription{end+1}=result_paragraph;
        ResultDetails{end+1}='';
        return;
    end




    baselineOk=true;

    try

        [~,newBaseline,needUndo,validated,compare_result]=utilCheckActionResult(mdladvObj,currentCheck,initBaseline);
    catch ME

        baseText1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaselineFailed');
        baselineOk=false;
    end

    if baselineOk
        [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);
        if~isempty(initBaseline.time.runID)
            if(validateTime||validateAccuracy)
                tableName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationTableName');
                summaryTable=utilCreateActionSummaryTable(tableName,needUndo,newBaseline,initBaseline,validated,compare_result);
                result_paragraph.addItem(summaryTable.emitHTML);
                result_paragraph.addItem(ModelAdvisor.LineBreak);
            end
        end
    else
        needUndo=true;
    end

    if needUndo
        Pass=false;
    end

    if~Pass

        if~baselineOk
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationFaliedSim'));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            baseText2=publishActionFailedMessage(ME,baseText1);
            result_paragraph.addItem(baseText2);
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationFaliedPerformance'));
            result_paragraph.addItem(result_text);
        end


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

    else
        if(validateTime||validateAccuracy)

            result_paragraph.addItem(Passed);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationPassed'));
            result_paragraph.addItem(result_text);
        else

            requireValidation=false;
            Pass=false;
            noValidation=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceUnknown'),{'bold','warn'});
            result_paragraph.addItem(noValidation);
        end
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass
        if requireValidation

            mdladvObj.setCheckErrorSeverity(1);

            utilRunFix(mdladvObj,currentCheck,Pass);
        else

            mdladvObj.setCheckErrorSeverity(0);
        end
    end


    if(Pass)
        baseLineAfter.time=newBaseline.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

end
