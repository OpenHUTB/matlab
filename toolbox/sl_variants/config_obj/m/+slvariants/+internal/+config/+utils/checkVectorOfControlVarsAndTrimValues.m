function[err,controlVars]=checkVectorOfControlVarsAndTrimValues(controlVars)




    if isa(controlVars,'struct')&&~isfield(controlVars,'Source')
        for i=1:numel(controlVars)
            controlVars(i).Source='';
        end
    end

    fields={'Name','Value','Source'};
    import slvariants.internal.config.utils.*;
    checkFunctions={@checkValidVarNameStringExtended,@checkValidControlVarValue,@checkValidControlVarSource};

    err=checkFieldsOfStructVector(controlVars,fields,checkFunctions);
    if~isempty(err)
        cerr=MException(message('Simulink:Variants:InvalidVectorOfControlVars'));
        err=cerr.addCause(err);
        return;
    end
    controlVars=transpose(controlVars(:));
    controlVars=trimFieldsOf1DArrayofControlVars(controlVars);
    controlVarSources=unique(string({controlVars(:).Source}));
    for i=1:numel(controlVarSources)
        err=checkUniqueValuesOfFieldInStructVector(controlVars(strcmp({controlVars().Source},controlVarSources{i})),'Name');
        if~isempty(err)


            err=MException(message('Simulink:Variants:ControlVarsMustBeUnique'));
            break;
        end
    end
end
