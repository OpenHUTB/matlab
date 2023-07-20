function constraintvalue=processConstraint(obj,DesiredValue,inputConstraintVal,ConstraintType,Conflict,DisplayValue,Type)






    if Conflict||isempty(inputConstraintVal)
        constraintvalue=1e6;
    else

        if strcmpi(ConstraintType,'<')
            constraintvalue=inputConstraintVal-DesiredValue;
        else
            constraintvalue=DesiredValue-inputConstraintVal;
        end










    end

end