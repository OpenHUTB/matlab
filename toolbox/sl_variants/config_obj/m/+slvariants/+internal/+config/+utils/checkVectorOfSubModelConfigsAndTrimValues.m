function[err,subModelConfigs]=checkVectorOfSubModelConfigsAndTrimValues(subModelConfigs)



    import slvariants.internal.config.utils.*;
    fields={'ModelName','ConfigurationName'};
    checkFunctions={@checkValidVarNameString,@checkValidVarNameString};
    err=checkFieldsOfStructVector(subModelConfigs,fields,checkFunctions);

    if~isempty(err)
        cerr=MException(message('Simulink:Variants:InvalidVectorOfSubModelConfigs'));
        err=cerr.addCause(err);
        return;
    end
    subModelConfigs=transpose(subModelConfigs(:));
    subModelConfigs=trimFieldsOf1DArrayofSubModelConfigs(subModelConfigs);
    err=checkUniqueValuesOfFieldInStructVector(subModelConfigs,'ModelName');
    if~isempty(err)
        err=MException(message('Simulink:Variants:SubModelEntriesMustBeUnique'));
    end
end
