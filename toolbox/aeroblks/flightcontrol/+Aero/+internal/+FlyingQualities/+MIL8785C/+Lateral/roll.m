function fqStructOut=roll(fqStruct)





















    fqStruct=repmat(fqStruct,1,5);

    [fqStruct.RequirementSource]=deal("MIL-F-8785C");
    [fqStruct.RequirementName]=deal("Roll Mode");
    [fqStruct.ID]=deal("3.3.1.2");

    fqStruct(1).FlightPhase="A";
    fqStruct(1).AircraftClass=["I","IV"];

    fqStruct(2).FlightPhase="A";
    fqStruct(2).AircraftClass=["II","III"];

    fqStruct(3).FlightPhase="B";
    fqStruct(3).AircraftClass=["I","II","III","IV"];

    fqStruct(4).FlightPhase="C";
    fqStruct(4).AircraftClass=["I","II-C","IV"];

    fqStruct(5).FlightPhase="C";
    fqStruct(5).AircraftClass=["II-L","III"];

    fqStructOut(1,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.Roll.verifyLevelOne(fqStruct);
    fqStructOut(2,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.Roll.verifyLevelTwo(fqStruct);
    fqStructOut(3,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.Roll.verifyLevelThree(fqStruct);
end
