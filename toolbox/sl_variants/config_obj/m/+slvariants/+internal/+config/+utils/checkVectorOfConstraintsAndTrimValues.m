function[err,constraints]=checkVectorOfConstraintsAndTrimValues(constraints)



    import slvariants.internal.config.utils.*;
    fields={'Name','Condition','Description'};
    checkFunctions={@checkValidVarNameString,@checkString,@checkString};
    err=checkFieldsOfStructVector(constraints,fields,checkFunctions);

    if~isempty(err)
        cerr=MException(message('Simulink:Variants:InvalidVectorOfConstraints'));
        err=cerr.addCause(err);
        return;
    end
    constraints=transpose(constraints(:));
    constraints=trimFieldsOf1DArrayofConstraints(constraints);
    err=checkUniqueValuesOfFieldInStructVector(constraints,'Name');
    if~isempty(err)
        err=MException(message('Simulink:Variants:ConstraintsMustBeUnique'));
    end
end
