function hRunning=attachAssessmentEvalParamCb(modelToRun,Mode,cbFunc)




    modelSimMode=get_param(modelToRun,'SimulationMode');
    isRapidAccelOrSILPIL=strcmpi(modelSimMode,'rapid-accelerator')||...
    strcmpi(Mode,'Rapid Accelerator')||...
    strcmpi(modelSimMode,'software-in-the-loop (sil)')||...
    strcmpi(Mode,'Software-in-the-Loop (SIL)')||...
    strcmpi(modelSimMode,'processor-in-the-loop (pil)')||...
    strcmpi(Mode,'Processor-in-the-Loop (PIL)');
    callback=stm.internal.RunTestConfiguration.getCallbackForAssessments(isRapidAccelOrSILPIL);

    mdlObj=get_param(modelToRun,'object');
    if isa(mdlObj,'handle.handle')
        hRunning=handle.listener(mdlObj,callback,cbFunc);
    else
        hRunning=listener(mdlObj,callback,cbFunc);
    end

end
