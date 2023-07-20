function fqStructOut=spiral(fqStruct)


























    fqStruct=repmat(fqStruct,1,3);

    [fqStruct.RequirementSource]=deal("MIL-F-8785C");
    [fqStruct.RequirementName]=deal("Spiral Stability");
    [fqStruct.ID]=deal("3.3.1.3");
    [fqStruct.AircraftClass]=deal(["I","II","III","IV"]);
    fqStruct(1).FlightPhase="A";
    fqStruct(2).FlightPhase="B";
    fqStruct(3).FlightPhase="C";

    fqStructOut(1,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.Spiral.verifyLevelOne(fqStruct);
    fqStructOut(2,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.Spiral.verifyLevelTwo(fqStruct);
    fqStructOut(3,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.Spiral.verifyLevelThree(fqStruct);
end
