function fqStructOut=shortperiod(fqStruct)













    fqStructOut=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.shortperiod(fqStruct);
    [fqStructOut.RequirementSource]=deal("MIL-STD-1797A");
    [fqStructOut.RequirementName]=deal("Short-Term Pitch Response");
    [fqStructOut.ID]=deal("4.2.1.2");
end
