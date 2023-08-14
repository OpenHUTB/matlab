function[ResultDescription,ResultDetails]=CheckIfNeedOptimalSolverResetCausedByZc(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedOptimalSolverResetCausedByZc');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);



    origMinimizedZC=get_param(model,'OptimalSolverResetCausedByZc');
    CompInfo=utilGetCheckCompInfo(currentCheck);
    if~CompInfo.valid
        try
            origDebugF=slfeature('DebugContinuousBdSearch',2);
            set_param(model,'OptimalSolverResetCausedByZc','on');
            debugText=evalc([model,'([],[],[], ''compile'')']);
            CompInfo.value=utilGetOptimalSolverResetCausedByZcInfo(model,debugText);
            CompInfo.valid=true;
            eval([model,'([],[],[], ''term'')']);
            slfeature('DebugContinuousBdSearch',origDebugF);
            set_param(model,'OptimalSolverResetCausedByZc',origMinimizedZC);
        catch ME
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
            return;
        end
    end


    newMinimizedZC=CompInfo.value{1};
    totalZCBlkNum=CompInfo.value{2};
    totalZCBlkAffectStateNum=CompInfo.value{3};
    isVarStepSolver=strcmp(get_param(model,'SolverType'),'Variable-step');

    if isVarStepSolver
        if strcmp(origMinimizedZC,'off')&&newMinimizedZC

            Pass=false;
        else
            Pass=true;
        end
    end



    if~Pass


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcCondition'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        if totalZCBlkNum~=0
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcNumZcBlock',num2str(totalZCBlkNum)));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcNumZcBlockAffectingState',num2str(totalZCBlkAffectStateNum)));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcNoZcBlock'));
        end
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        setMinimizedZCOn=getString(message('SimulinkPerformanceAdvisor:advisor:ManuallySetMinimizedZCOn'));
        setMinimizedZCOn_text=ModelAdvisor.Text(['<a href="matlab: set_param(bdroot, ''OptimalSolverResetCausedByZc'', ''on'') ">'...
        ,setMinimizedZCOn,'</a>']);
        result_paragraph.addItem(setMinimizedZCOn_text);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        if~isVarStepSolver
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcPassedFixStep'));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckIfNeedOptimalSolverResetCausedByZcPassedCorrectSetting'));
        end
        result_paragraph.addItem(result_text);
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        currentCheck.ResultData.FixInfo=newMinimizedZC;


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
