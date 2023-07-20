function fqStructOut=dutchroll(fqStruct)



























    fqStruct=repmat(fqStruct,1,7);

    [fqStruct.RequirementSource]=deal("MIL-F-8785C");
    [fqStruct.RequirementName]=deal("Lateral-Directional Oscillations (Dutch Roll)");
    [fqStruct.ID]=deal("3.3.1.1");

    fqStruct(1).FlightPhase="CO";
    fqStruct(1).AircraftClass="IV";

    fqStruct(2).FlightPhase="GA";
    fqStruct(2).AircraftClass="IV";

    fqStruct(3).FlightPhase="A";
    fqStruct(3).AircraftClass=["I","II"];

    fqStruct(4).FlightPhase="A";
    fqStruct(4).AircraftClass=["III","IV"];

    fqStruct(5).FlightPhase="B";
    fqStruct(5).AircraftClass=["I","II","III","IV"];

    fqStruct(6).FlightPhase="C";
    fqStruct(6).AircraftClass=["I","II-C"];

    fqStruct(7).FlightPhase="C";
    fqStruct(7).AircraftClass=["II-L","III"];

    fqStructOut(1,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.DutchRoll.verifyLevelOne(fqStruct);
    fqStructOut(2,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.DutchRoll.verifyLevelTwo(fqStruct);
    fqStructOut(3,:)=Aero.internal.FlyingQualities.MIL8785C.Lateral.DutchRoll.verifyLevelThree(fqStruct);
end
