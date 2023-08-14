function value=getConstraintValue(constraint)













    if~isfield(constraint,'outValue')
        value='';
    else
        value=constraint.outValue;
    end
end
