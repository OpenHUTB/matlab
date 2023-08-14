function mustBePositiveNumber(colValue)






    if(colValue~=Inf)
        mustBeInteger(colValue);
        mustBeGreaterThan(colValue,0);
        mlreportgen.utils.validators.mustBeSingleValue(colValue);
    end
end