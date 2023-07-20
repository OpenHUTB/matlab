function err=getValidationErrorForConfiguration(excep,type,source,sourceConfiguration,sourceModel)






    err=Simulink.variant.manager.errorutils.getValidationError(excep,type,source,'');
    err.SourceConfiguration=sourceConfiguration;
    err.SourceModel=sourceModel;
end
