function[validationErrorsForHierarchy,validationLog]=validateModelRefEntry(modelRefBlockPath,modelName,validationLog,optArgsStruct)







    validationErrorsForHierarchy={};
    try
        load_system(modelName);
    catch
        messageId='Simulink:modelReference:InvalidModelrefName';
        excepObj=MException(message(messageId,modelName,modelRefBlockPath));
        error=Simulink.variant.manager.errorutils.getValidationError(...
        excepObj,'Model',modelRefBlockPath,'');
        validationErrorsForHierarchy{end+1}=Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error});
        return;
    end
    [validationErrorsForHierarchy,validationLog]=Simulink.variant.manager.configutils.validateModelEntry(modelName,validationLog,optArgsStruct);
end
