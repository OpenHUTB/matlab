function varargout=constructOutput(parsedInputStruct)





    bdHandle=get_param(parsedInputStruct.ModelName,'Handle');
    validConfigurations=strcmp(parsedInputStruct.Validity,'valid')||...
    strcmp(parsedInputStruct.Validity,'valid-unique');
    uniqueConfigurations=strcmp(parsedInputStruct.Validity,'valid-unique');

    [vcd,configsInfo]=slvariants.internal.manager.configgen.getConfigs(bdHandle,validConfigurations,...
    uniqueConfigurations,parsedInputStruct.AddPreconditionAsConstraint);

    outVcd=removeConfigurationData(parsedInputStruct.ModelName,copy(vcd),parsedInputStruct.ExcludeVariantConfigurationData);
    configsToRemove=setdiff({vcd.Configurations().Name},{outVcd.Configurations().Name},'stable');
    outConfigsInfo=removeConfigsFromConfigsInfo(configsInfo,configsToRemove);
    [outVcd,outConfigsInfo]=renameConfigurations(outVcd,outConfigsInfo);

    varargout{1}=outVcd;
    varargout{2}=outConfigsInfo;
    import slvariants.internal.manager.ui.config.VMgrConstants;
    genConfigsInfo=MException(message('Simulink:VariantManagerUI:AutoGenConfigGeneratedConfigsInfo',numel(outVcd.Configurations)));
    sldiagviewer.reportInfo(genConfigsInfo,'Component',VMgrConstants.DiagComponentName,'Category',VMgrConstants.DiagAutoGenConfigCategory);
end

function newVcd=removeConfigurationData(modelName,vcdOrig,excludeVCDName)
    newVcd=vcdOrig;
    if isempty(excludeVCDName)
        return;
    end

    vcdWrapper=slvariants.internal.manager.ui.config.VariantConfigurationsCacheWrapper(false,modelName,excludeVCDName);
    if vcdWrapper.IsVariantConfigurationMissingInWks


        excep=MException(message("Simulink:VariantManager:AutoGenConfigIgnoreConfigNotExist",...
        excludeVCDName));
        throw(excep);
    end
    vcdToBeRemoved=vcdWrapper.VariantConfigurationCatalog;
    newVcd=removeConfigurations(newVcd,vcdToBeRemoved);
    newVcd=removeConstraints(newVcd,vcdToBeRemoved);
end

function newVcd=removeConfigurations(vcdOrig,vcdToBeRemoved)
    newVcd=vcdOrig;
    configs=newVcd.Configurations;
    configsToBeRemoved=vcdToBeRemoved.Configurations;
    for idx=numel(configs):-1:1
        for idxIn=1:numel(configsToBeRemoved)

            if isControlVariablesEqual(configs(idx).ControlVariables,...
                configsToBeRemoved(idxIn).ControlVariables)
                newVcd.removeConfiguration(configs(idx).Name);
                break;
            end
        end
    end
end

function newVcd=removeConstraints(vcdOrig,vcdToBeRemoved)
    newVcd=vcdOrig;
    constraints=newVcd.Constraints;
    constraintsToBeRemoved=vcdToBeRemoved.Constraints;
    for idx=numel(constraints):-1:1
        for idxIn=1:numel(constraintsToBeRemoved)

            if isequal(constraints(idx).Condition,...
                constraintsToBeRemoved(idxIn).Condition)
                newVcd.removeConstraint(constraints(idx).Name);
                break;
            end
        end
    end
end

function outConfigsInfo=removeConfigsFromConfigsInfo(configsInfo,configsToRemove)
    if isempty(configsToRemove)
        outConfigsInfo=configsInfo;
        return;
    end
    [~,indicesToRetain]=setdiff({configsInfo.Name},configsToRemove,'stable');
    outConfigsInfo=configsInfo(indicesToRetain);
end

function[outVcd,outConfigsInfo]=renameConfigurations(vcd,configsInfo)
    outVcd=vcd;
    outConfigsInfo=configsInfo;

    configs=outVcd.Configurations;
    for idx=1:numel(configs)
        configName=configs(idx).Name;
        newConfigName=['VConfig',num2str(idx)];


        outVcd.setConfigurationName(configName,newConfigName);
        Simulink.variant.utils.assert(isequal(configName,outConfigsInfo(idx).Name),"Config info not found in order");
        outConfigsInfo(idx).Name=newConfigName;
    end
end


function isEqual=isControlVariablesEqual(xArr,yArr)
    xArrSorted=sortStructArr(xArr,"Name");
    yArrSorted=sortStructArr(yArr,"Name");
    isEqual=isequal(xArrSorted,yArrSorted);
end

function sortedStruct=sortStructArr(structArray,fieldName)

    [~,idx]=sort({structArray.(fieldName)});
    sortedStruct=structArray(idx);
end
