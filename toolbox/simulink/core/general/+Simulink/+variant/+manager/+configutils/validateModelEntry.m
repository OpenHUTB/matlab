function[validationErrorsForHierarchy,validationLog,createModelInfoLog]=validateModelEntry(modelName,validationLog,optArgs)







    import Simulink.variant.manager.errorutils.*;


    Simulink.variant.utils.reportDiagnosticIfV2Enabled();

    validationErrorsForHierarchy={};
    createModelInfoLog=[];

    if~isfield(optArgs,'CalledFromTool')
        optArgs.CalledFromTool=false;
    end

    if~isfield(optArgs,'RootPathPrefix')
        optArgs.RootPathPrefix=[];
    end

    if~isfield(optArgs,'HotlinkErrors')
        optArgs.HotlinkErrors=true;
    end

    isProtected=isvarname(modelName)&&~bdIsLoaded(modelName)&&Simulink.variant.utils.getIsProtectedModelAndFullFile(modelName);
    if isProtected
        return;
    end

    try
        load_system(modelName);
    catch excepObj


        error=getValidationError(excepObj,'Model',modelName,optArgs.RootPathPrefix);
        validationErrorsForHierarchy={getValidationErrorForModel(modelName,{error})};
        return;
    end




    if~isfield(optArgs,'VariantConfigurationObject')
        optArgs.VariantConfigurationObject=Simulink.variant.utils.getConfigurationDataNoThrow(modelName);
    end
    if~isfield(optArgs,'VariantConfigurationObjectName')
        optArgs.VariantConfigurationObjectName=get_param(modelName,'VariantConfigurationObject');
    end

    if~isfield(optArgs,'ConfigurationName')
        if isempty(optArgs.VariantConfigurationObject)
            optArgs.ConfigurationName='';
        else

            optArgs.ConfigurationName=optArgs.VariantConfigurationObject.DefaultConfigurationName;
        end
    end
    [validationErrorsForHierarchy,validationLog,createModelInfoLog]=Simulink.variant.manager.configutils.validateModelCoreImplementation(modelName,validationLog,optArgs);
end
