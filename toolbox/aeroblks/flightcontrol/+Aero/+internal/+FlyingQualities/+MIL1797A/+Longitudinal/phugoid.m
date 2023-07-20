function fqStructOut=phugoid(fqStruct)




    fqStructOut=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.phugoid(fqStruct);
    [fqStructOut.RequirementSource]=deal("MIL-STD-1797A");
    [fqStructOut.RequirementName]=deal("Long-Term Pitch Response");
    [fqStructOut.ID]=deal("4.2.1.1");
end
