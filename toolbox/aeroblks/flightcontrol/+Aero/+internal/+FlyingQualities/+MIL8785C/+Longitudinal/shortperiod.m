function fqStructOut=shortperiod(fqStruct)





















    fqStruct=repmat(fqStruct,1,3);

    [fqStruct.RequirementSource]=deal("MIL-F-8785C");
    [fqStruct.RequirementName]=deal("Short-Period Damping");
    [fqStruct.ID]=deal("3.2.2.1.2");
    fqStruct(1).FlightPhase="A";
    fqStruct(2).FlightPhase="B";
    fqStruct(3).FlightPhase="C";
    [fqStruct.AircraftClass]=deal(["I","II","III","IV"]);

    fqStructOut(1,:)=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.verifyLevelOne(fqStruct);
    fqStructOut(2,:)=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.verifyLevelTwo(fqStruct);
    fqStructOut(3,:)=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.verifyLevelThree(fqStruct);
end
