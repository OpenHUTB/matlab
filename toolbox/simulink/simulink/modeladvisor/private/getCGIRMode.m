function IsInCGIRMode=getCGIRMode(modelName)


    IsInCGIRMode=false;
    activeMAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(activeMAObj,'Simulink.ModelAdvisor')&&strcmp(activeMAObj.ModelName,modelName)
        IsInCGIRMode=activeMAObj.HasCGIRed;
    end











end
