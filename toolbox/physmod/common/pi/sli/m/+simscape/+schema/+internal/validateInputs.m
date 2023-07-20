function msg=validateInputs(prop,value,UnitDefault)
    msg='';
    validateFunc=pmsl_private('pmsl_validateunit');
    [isValid,errorString]=validateFunc(UnitDefault,value);
    if~isValid
        msg=errorString;
    end
end
