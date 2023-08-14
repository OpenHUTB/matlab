function saveFor(modelName,nameOfVariantConfigDataObj,varConfigDataObj)








    isModelLoaded=bdIsLoaded(modelName);

    if~isModelLoaded
        try
            load_system(modelName);
        catch excep
            throwAsCaller(excep)
        end
    end

    currentNameOfVariantConfigDataObj=get_param(modelName,'VariantConfigurationObject');
    if~strcmp(nameOfVariantConfigDataObj,currentNameOfVariantConfigDataObj)
        set_param(modelName,'VariantConfigurationObject',nameOfVariantConfigDataObj);
    end

    if~isempty(nameOfVariantConfigDataObj)
        varConfigDataObj=copy(varConfigDataObj);
        Simulink.variant.utils.slddaccess.assignInConfigurationsSection(...
        modelName,nameOfVariantConfigDataObj,varConfigDataObj);
    end
end
