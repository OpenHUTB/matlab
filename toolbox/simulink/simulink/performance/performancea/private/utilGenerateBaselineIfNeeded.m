function newBaseline=utilGenerateBaselineIfNeeded(baseline,mdladvObj,model,currentCheck)




    newBaseline=baseline;
    [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);


    if isempty(baseline.time.total)&&(validateTime||validateAccuracy)
        cond1=strcmp(currentCheck.getID,'com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
        if(~cond1)
            baseLineCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
            baseline2=utilCreateBaseline(mdladvObj,baseLineCheck,model);
            newBaseline.time=baseline2.time;

            mdladvObj.UserData.Progress.initBaseLine=baseline2;
        end
    end
