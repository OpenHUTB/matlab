function cdType=getCoderDataTypeForFunctionCategory(modelMapping,defaultsCategory)




    isFunctionPlatform=isa(modelMapping,'Simulink.CoderDictionary.ModelMapping')&&...
    modelMapping.isFunctionPlatform;
    if~isFunctionPlatform
        cdType='FunctionClass';
    else
        deploymentType=modelMapping.DeploymentType;
        if isequal(deploymentType,'Component')
            if isequal(defaultsCategory,'InitializeTerminate')
                cdType='IRTFunction';
            elseif isequal(defaultsCategory,'Execution')
                cdType='PeriodicAperiodicFunction';
            else
                assert(false);
            end
        elseif isequal(deploymentType,'Subcomponent')
            if isequal(defaultsCategory,'InitializeTerminate')
                cdType='SubcomponentEntryFunction';
            elseif isequal(defaultsCategory,'Execution')
                cdType='SubcomponentEntryFunction';
            else
                assert(false);
            end
        end
    end
end
