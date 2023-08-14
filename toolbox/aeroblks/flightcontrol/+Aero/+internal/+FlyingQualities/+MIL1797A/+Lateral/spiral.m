function fqStructOut=spiral(fqStruct)




    fqStructOut=Aero.internal.FlyingQualities.MIL8785C.Lateral.spiral(fqStruct);
    [fqStructOut.RequirementSource]=deal("MIL-STD-1797A");
    [fqStructOut.RequirementName]=deal("Spiral Stability");
    [fqStructOut.ID]=deal("4.5.1.2");
end
