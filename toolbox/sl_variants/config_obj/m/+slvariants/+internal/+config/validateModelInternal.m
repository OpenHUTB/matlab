function[valid,errors]=validateModelInternal(modelName,configName)






























    errors=[];


    Simulink.variant.utils.reportDiagnosticIfV2Enabled();

    if~isvarname(modelName)


        throwAsCaller(MException(message('Simulink:Variants:InvalidModelName')));
    end

    if nargin==2&&isempty(configName)



        valid=false;
        messageId='Simulink:Variants:EmptyConfigurationName';
        error=Simulink.variant.manager.errorutils.getValidationError(...
        MException(message(messageId)),'Model',modelName,modelName);
        errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
        processErrors();
        return;
    end

    if nargin<2
        configName='';
    else
        err=Simulink.variant.manager.configutils.checkValidVarNameString(configName);
        if~isempty(err)


            throwAsCaller(err);
        end
    end
    [valid,errors]=Simulink.variant.manager.configutils.validateModelWithLog(modelName,configName);

    processErrors();

    function processErrors()
        for topErrIdx=1:numel(errors)
            lowLevelErrors=errors{topErrIdx}.Errors;
            for lowErrIdx=1:numel(lowLevelErrors)
                tmpErr=lowLevelErrors{lowErrIdx};
                tmpExcep=tmpErr.Exception;
                tmpErr=rmfield(tmpErr,'Exception');
                tmpErr.Message=Simulink.variant.utils.i_convertMExceptionHierarchyToMessage(tmpExcep);
                tmpErr.MessageID=tmpExcep.identifier;
                lowLevelErrors{lowErrIdx}=tmpErr;
            end
            errors{topErrIdx}.Errors=lowLevelErrors;
        end
    end

end