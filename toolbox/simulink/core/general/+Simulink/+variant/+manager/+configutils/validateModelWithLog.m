function[valid,validationErrorsForHierarchy,validationLog,createModelInfoLog]=validateModelWithLog(modelName,configName)


    validationLog=[];
    optArgs=struct();
    if~isempty(configName)
        optArgs.ConfigurationName=configName;
    end
    [validationErrorsForHierarchy,validationLog,createModelInfoLog]=Simulink.variant.manager.configutils.validateModelEntry(modelName,validationLog,optArgs);
    valid=isempty(validationErrorsForHierarchy);
end
