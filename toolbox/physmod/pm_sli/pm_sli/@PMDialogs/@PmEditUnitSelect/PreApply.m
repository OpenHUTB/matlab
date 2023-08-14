function[status,messageString]=PreApply(hThis)





    defaultUnit=hThis.UnitDefault;
    inputUnit=hThis.Value;

    validateFunc=pmsl_private('pmsl_validateunit');
    [status,messageString]=validateFunc(defaultUnit,inputUnit);

end
