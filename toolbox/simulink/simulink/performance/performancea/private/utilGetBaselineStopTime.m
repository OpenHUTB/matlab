function t=utilGetBaselineStopTime(mdladvObj,model)



    inputParams=mdladvObj.getInputParameters('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');
    stopTime=inputParams{1}.Value;
    t=Simulink.SDIInterface.calculateStopTime(model,stopTime);
    inputParams{1}.Value=num2str(t);
end

