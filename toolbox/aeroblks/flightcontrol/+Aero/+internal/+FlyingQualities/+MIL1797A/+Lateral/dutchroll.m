function fqStructOut=dutchroll(fqStruct)




    fqStructOut=Aero.internal.FlyingQualities.MIL8785C.Lateral.dutchroll(fqStruct);
    [fqStructOut.RequirementSource]=deal("MIL-STD-1797A");
    [fqStructOut.RequirementName]=deal("Dynamic Lateral-Directional Response");
    [fqStructOut.ID]=deal("4.6.1.1");
end
