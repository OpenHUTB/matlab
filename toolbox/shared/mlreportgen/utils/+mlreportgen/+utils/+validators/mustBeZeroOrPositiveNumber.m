function mustBeZeroOrPositiveNumber(colValue)






    if(colValue~=Inf)
        mustBeInteger(colValue);
        mustBeGreaterThan(colValue,-1);
        mlreportgen.utils.validators.mustBeSingleValue(colValue);
    end
end