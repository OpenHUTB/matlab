function[err,config]=checkConfigAndTrimValues(config)




    err=slvariants.internal.config.utils.checkValidVarNameString(config.Name);

    if isempty(err)
        config.Name=strtrim(config.Name);
    end

    if isempty(err)&&~isempty(config.Description)
        err=slvariants.internal.config.utils.checkString(config.Description);
        if isempty(err)
            config.Description=strtrim(config.Description);
        end
    end

    if isempty(err)&&~isempty(config.ControlVariables)
        [err,controlVars]=slvariants.internal.config.utils.checkVectorOfControlVarsAndTrimValues(config.ControlVariables);
        if isempty(err)
            config.ControlVariables=controlVars;
        end
    end

    if isempty(err)&&~isempty(config.SubModelConfigurations)
        [err,subModelConfigurations]=slvariants.internal.config.utils.checkVectorOfSubModelConfigsAndTrimValues(config.SubModelConfigurations);
        if isempty(err)
            config.SubModelConfigurations=subModelConfigurations;
        end
    end
end
