function setVariableUnit_implementation(KS,id,unit)




    p=inputParser;
    p.addRequired('id',@validateScalarText)
    p.addRequired('unit',@validateScalarText)
    p.parse(id,unit);

    [id,unit]=convertCharsToStrings(id,unit);
    KS.mSystem.setVariableUnit(id,unit);