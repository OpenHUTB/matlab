function[ResultDescription,ResultDetails]=CheckIfNeedDecoupleContDiscRates(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);



    origDecoupleCD=get_param(model,'DecoupledContinuousIntegration');
    CompInfo=utilGetCheckCompInfo(currentCheck);
    if~CompInfo.valid
        try
            eval([model,'([],[],[], ''compile'')']);
            CompInfo.value=utilGetDecoupleInfo(model);
            CompInfo.valid=true;
            eval([model,'([],[],[], ''term'')']);
        catch ME
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
            return;
        end
    end


    newDecoupleCD=CompInfo.value{1};
    compiledHmax=CompInfo.value{2};
    sDiscTs=CompInfo.value{3};
    isVarStepSolver=strcmp(get_param(model,'SolverType'),'Variable-step');

    if isVarStepSolver
        if strcmp(origDecoupleCD,'off')&&newDecoupleCD

            Pass=false;
        else
            Pass=true;
        end
    end



    if~Pass


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesCondition'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesHmax',num2str(compiledHmax)));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        if sDiscTs~=Inf
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesSDiscRates',num2str(sDiscTs)));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesNoDiscRate'));
        end
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        setDecoupleOn=getString(message('SimulinkPerformanceAdvisor:advisor:ManuallySetDecoupleOn'));


        setDecoupleOn_text=ModelAdvisor.Text(['<a href="matlab: set_param(bdroot, ''DecoupledContinuousIntegration'', ''on'') ">'...
        ,setDecoupleOn,'</a>']);
        result_paragraph.addItem(setDecoupleOn_text);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        if~isVarStepSolver
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesPassedFixStep'));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedDecoupleContDiscRatesPassedCorrectSetting'));
        end
        result_paragraph.addItem(result_text);
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        currentCheck.ResultData.FixInfo=newDecoupleCD;


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
