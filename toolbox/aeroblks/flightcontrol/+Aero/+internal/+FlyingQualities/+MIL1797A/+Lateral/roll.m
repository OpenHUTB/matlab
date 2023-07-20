function fqStructOut=roll(fqStruct)




    fqStructOut=Aero.internal.FlyingQualities.MIL8785C.Lateral.roll(fqStruct);
    [fqStructOut.RequirementSource]=deal("MIL-STD-1797A");
    [fqStructOut.RequirementName]=deal("Roll Mode");
    [fqStructOut.ID]=deal("4.5.1.1");
end
