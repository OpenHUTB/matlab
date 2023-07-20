function[errors,specialVarsInfoManager]=setupWorkspaceForVariantConfig(modelHandle,configName,controlVariables,optArgs)







    if nargin<4
        optArgs=struct();
    end

    errors={};



    slInternal('setupTempWS',modelHandle);


    modelName=get_param(modelHandle,'Name');
    skipAssigninGlobalWkspce=isfield(optArgs,'SkipAssigninGlobalWkspce')&&optArgs.SkipAssigninGlobalWkspce;
    usedByDefaultConfig=isfield(optArgs,'UsedByDefaultConfig')&&optArgs.UsedByDefaultConfig;
    errorsWithExportControlVars=Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS(...
    modelName,configName,controlVariables,true,true,skipAssigninGlobalWkspce,usedByDefaultConfig);

    specialVarsInfoManager=Simulink.variant.manager.SpecialVarsInfoManager(modelName);

    if isfield(optArgs,'RootPathPrefix')&&~isempty(optArgs.RootPathPrefix)
        pathInHierarchy=optArgs.RootPathPrefix;
    else
        pathInHierarchy=modelName;
    end






    variantObjsInGlobalScope=specialVarsInfoManager.getSimulinkVariants();
    try
        slInternal('pushObjectsToTempWS',modelHandle,variantObjsInGlobalScope);
    catch excep
        errors={Simulink.variant.manager.errorutils.getValidationError(excep,'Model',modelName,excep.identifier,pathInHierarchy)};
        return;
    end



    aliasTypesInGlobalScope=specialVarsInfoManager.getSimulinkAliasType();
    try

        slInternal('pushObjectsToTempWS',modelHandle,aliasTypesInGlobalScope);
    catch excep
        errors={Simulink.variant.manager.errorutils.getValidationError(...
        excep,'Model',modelName,pathInHierarchy)};
        return;
    end



    numericTypesInGlobalScope=specialVarsInfoManager.getSimulinkNumericType();
    try

        slInternal('pushObjectsToTempWS',modelHandle,numericTypesInGlobalScope);
    catch excep
        errors={Simulink.variant.manager.errorutils.getValidationError(excep,'Model',modelName,excep.identifier,pathInHierarchy)};
        return;
    end

    errors=horzcat(errors,errorsWithExportControlVars);
end


