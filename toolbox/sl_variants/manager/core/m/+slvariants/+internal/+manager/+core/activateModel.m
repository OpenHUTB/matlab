function[valid,errors]=activateModel(modelName,configName)









    valid=true;
    errors=[];

    if~ischar(modelName)&&~(isstring(modelName)&&isscalar(modelName))
        valid=false;
        messageId='Simulink:Variants:InvalidModelName';
        error=slvariants.internal.manager.core.getActivationError(MException(message(messageId)));
        errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
        return;
    end

    if~isvarname(modelName)


        valid=false;
        messageId='Simulink:LoadSave:InvalidBlockDiagramName';
        error=slvariants.internal.manager.core.getActivationError(MException(message(messageId,modelName)));
        errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
        return;
    end

    if nargin==2&&isempty(configName)



        valid=false;
        messageId='Simulink:Variants:EmptyConfigurationName';

        error=slvariants.internal.manager.core.getActivationError(MException(message(messageId)));
        errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
        return;
    end

    isProtected=isvarname(modelName)&&~bdIsLoaded(modelName)&&Simulink.variant.utils.getIsProtectedModelAndFullFile(modelName);
    if isProtected
        return;
    end

    if~bdIsLoaded(modelName)


        valid=false;
        messageId='Simulink:VariantManager:ModelNotLoaded';
        error=slvariants.internal.manager.core.getActivationError(MException(message(messageId,modelName)));
        errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
        return;
    end

    if nargin<2
        configName='';
    else
        err=Simulink.variant.manager.configutils.checkValidVarNameString(configName);
        if~isempty(err)


            valid=false;
            exp=MException(message('Simulink:Variants:InvalidConfigForModel',configName,modelName));
            exp=exp.addCause(err);
            error=slvariants.internal.manager.core.getActivationError(exp);
            errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
            return;
        end
    end

    try
        slvariants.internal.manager.core.activateModelImpl(get_param(modelName,'handle'),configName);
    catch ME
        valid=false;
        if strcmp(ME.identifier,'Simulink:VariantManager:ActivationFailed')
            for i=1:numel(ME.cause)
                allErrors={};
                currModelName='';
                if numel(ME.cause{i}.handles)>0
                    currModelName=get_param(ME.cause{i}.handles{1},'Name');
                end
                for j=1:numel(ME.cause{i}.cause)
                    allErrors{end+1}=slvariants.internal.manager.core.getActivationError(ME.cause{i}.cause{j});%#ok<AGROW>
                end
                errors=[errors,{Simulink.variant.manager.errorutils.getValidationErrorForModel(currModelName,allErrors)}];%#ok<AGROW>
            end
        else
            error=slvariants.internal.manager.core.getActivationError(ME);
            errors={Simulink.variant.manager.errorutils.getValidationErrorForModel(modelName,{error})};
        end
        return;
    end
end
