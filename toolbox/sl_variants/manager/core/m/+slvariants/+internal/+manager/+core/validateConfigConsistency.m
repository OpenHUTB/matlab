function validateConfigConsistency(modelHandle)












    modelName=getfullname(modelHandle);


    pluginManager=Simulink.PluginMgr;
    if pluginManager.isAttached(modelName,'sl_variants_reducer_slplugin')
        return;
    end

    configSet=getActiveConfigSet(modelName);
    notUsedByTopModel=configSet.get_param('VariantConfigNotUsedByTopModel');
    if strcmp(notUsedByTopModel,'none')
        return;
    end
    vcdo=Simulink.variant.utils.getConfigurationDataNoThrow(modelName);
    if isempty(vcdo)
        return;
    end

    modelSource=get_param(modelName,'DataDictionary');
    referencedDDsOfModel=Simulink.variant.utils.slddaccess.getAllReferencedDataDictionaries(modelName);

    cvNameMap=containers.Map;
    sourceAccessibleMap=containers.Map;

    ctrlVarsMatch=true;
    for modelConfig=vcdo.Configurations
        ctrlVarsMatch=true;
        for cv=modelConfig.ControlVariables
            if~cacheExistsInGlobalScope(cv.Name)
                continue;
            end

            if~cacheSourceAccessibleForModel(cv.Source)
                continue;
            end

            if~isequal(cv.Value,evalinGlobalScope(modelName,cv.Name))
                ctrlVarsMatch=false;
                break;
            end
        end

        if ctrlVarsMatch
            break;
        end
    end

    if ctrlVarsMatch
        return;
    end

    MSLE=MSLException(modelHandle,message('Simulink:VariantManager:CtrlVarNotUsedByTopModelMessage',modelName));

    if strcmp(notUsedByTopModel,'warning')
        sldiagviewer.reportWarning(MSLE);
    else
        sldiagviewer.reportError(MSLE);
    end

    function ret=cacheExistsInGlobalScope(cvName)
        if~isKey(cvNameMap,cvName)
            ret=existsInGlobalScope(modelName,cvName);
            cvNameMap(cvName)=ret;
            return;
        end

        ret=cvNameMap(cv.Name);
    end

    function ret=cacheSourceAccessibleForModel(cvSource)
        if~isKey(sourceAccessibleMap,cvSource)
            ret=Simulink.variant.utils.slddaccess.isSourceAccessibleForModel(modelName,...
            modelSource,...
            cvSource,...
            referencedDDsOfModel);
            sourceAccessibleMap(cvSource)=ret;
            return;
        end

        ret=sourceAccessibleMap(cvSource);
    end
end


