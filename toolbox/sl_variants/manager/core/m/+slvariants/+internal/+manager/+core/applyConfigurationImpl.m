function applyConfigurationImpl(modelNameOrHandle,configName)









    modelName=get_param(modelNameOrHandle,'Name');

    try

        vcdoObj=Simulink.VariantConfigurationData.getFor(modelName);
    catch ME

        throwAsCaller(ME);
    end

    if~strcmp(configName,{vcdoObj.Configurations.Name})

        variantConfigurationObjectName=get_param(modelName,'VariantConfigurationObject');
        messageId='Simulink:Variants:ConfigNotFoundinVCDOForModel';
        excepObj=MSLException(get_param(modelName,'Handle'),message(messageId,...
        configName,variantConfigurationObjectName,modelName));

        throw(excepObj)
    end


    ctrlVars=vcdoObj.Configurations(strcmp({vcdoObj.Configurations.Name},configName)).ControlVariables;


    slvariants.internal.manager.core.pushControlVariables(modelName,modelName,ctrlVars);
end
