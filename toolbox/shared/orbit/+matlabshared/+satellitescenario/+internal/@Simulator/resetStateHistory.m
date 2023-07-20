function resetStateHistory(simObj)





%#codegen

    coder.allowpcode('plain');


    simObj.TimeHistory=NaT(1,0);
    if coder.target('MATLAB')
        simObj.TimeHistory.TimeZone='UTC';
    end


    for idx=1:simObj.NumSatellites
        simObj.Satellites(idx).PositionHistory=zeros(3,0);
        simObj.Satellites(idx).PositionITRFHistory=zeros(3,0);
        simObj.Satellites(idx).VelocityHistory=zeros(3,0);
        simObj.Satellites(idx).VelocityITRFHistory=zeros(3,0);
        simObj.Satellites(idx).LatitudeHistory=zeros(1,0);
        simObj.Satellites(idx).LongitudeHistory=zeros(1,0);
        simObj.Satellites(idx).AltitudeHistory=zeros(1,0);
        simObj.Satellites(idx).AttitudeHistory=zeros(3,0);
        simObj.Satellites(idx).Itrf2BodyTransformHistory=zeros(3,3,0);
        simObj.Satellites(idx).Ned2BodyTransformHistory=zeros(3,3,0);
    end


    for idx=1:simObj.NumGroundStations
        simObj.GroundStations(idx).PositionHistory=zeros(3,0);
        simObj.GroundStations(idx).PositionITRFHistory=zeros(3,0);
        simObj.GroundStations(idx).VelocityHistory=zeros(3,0);
        simObj.GroundStations(idx).VelocityITRFHistory=zeros(3,0);
        simObj.GroundStations(idx).LatitudeHistory=zeros(1,0);
        simObj.GroundStations(idx).LongitudeHistory=zeros(1,0);
        simObj.GroundStations(idx).AltitudeHistory=zeros(1,0);
        simObj.GroundStations(idx).AttitudeHistory=zeros(3,0);
        simObj.GroundStations(idx).Itrf2BodyTransformHistory=zeros(3,3,0);
        simObj.GroundStations(idx).Ned2BodyTransformHistory=zeros(3,3,0);
    end


    for idx=1:simObj.NumGimbals
        simObj.Gimbals(idx).PositionHistory=zeros(3,0);
        simObj.Gimbals(idx).PositionITRFHistory=zeros(3,0);
        simObj.Gimbals(idx).VelocityHistory=zeros(3,0);
        simObj.Gimbals(idx).VelocityITRFHistory=zeros(3,0);
        simObj.Gimbals(idx).LatitudeHistory=zeros(1,0);
        simObj.Gimbals(idx).LongitudeHistory=zeros(1,0);
        simObj.Gimbals(idx).AltitudeHistory=zeros(1,0);
        simObj.Gimbals(idx).AttitudeHistory=zeros(3,0);
        simObj.Gimbals(idx).Itrf2BodyTransformHistory=zeros(3,3,0);
        simObj.Gimbals(idx).Ned2BodyTransformHistory=zeros(3,3,0);
        simObj.Gimbals(idx).GimbalAzimuthHistory=zeros(1,0);
        simObj.Gimbals(idx).GimbalElevationHistory=zeros(1,0);
    end


    for idx=1:simObj.NumConicalSensors
        simObj.ConicalSensors(idx).PositionHistory=zeros(3,0);
        simObj.ConicalSensors(idx).PositionITRFHistory=zeros(3,0);
        simObj.ConicalSensors(idx).VelocityHistory=zeros(3,0);
        simObj.ConicalSensors(idx).VelocityITRFHistory=zeros(3,0);
        simObj.ConicalSensors(idx).LatitudeHistory=zeros(1,0);
        simObj.ConicalSensors(idx).LongitudeHistory=zeros(1,0);
        simObj.ConicalSensors(idx).AltitudeHistory=zeros(1,0);
        simObj.ConicalSensors(idx).AttitudeHistory=zeros(3,0);
        simObj.ConicalSensors(idx).Itrf2BodyTransformHistory=zeros(3,3,0);
    end


    for idx=1:simObj.NumTransmitters
        simObj.Transmitters(idx).PositionHistory=zeros(3,0);
        simObj.Transmitters(idx).PositionITRFHistory=zeros(3,0);
        simObj.Transmitters(idx).VelocityHistory=zeros(3,0);
        simObj.Transmitters(idx).VelocityITRFHistory=zeros(3,0);
        simObj.Transmitters(idx).LatitudeHistory=zeros(1,0);
        simObj.Transmitters(idx).LongitudeHistory=zeros(1,0);
        simObj.Transmitters(idx).AltitudeHistory=zeros(1,0);
        simObj.Transmitters(idx).AttitudeHistory=zeros(3,0);
        simObj.Transmitters(idx).Itrf2BodyTransformHistory=zeros(3,3,0);
        simObj.Transmitters(idx).PointingDirection=zeros(2,0);
    end


    for idx=1:simObj.NumReceivers
        simObj.Receivers(idx).PositionHistory=zeros(3,0);
        simObj.Receivers(idx).PositionITRFHistory=zeros(3,0);
        simObj.Receivers(idx).VelocityHistory=zeros(3,0);
        simObj.Receivers(idx).VelocityITRFHistory=zeros(3,0);
        simObj.Receivers(idx).LatitudeHistory=zeros(1,0);
        simObj.Receivers(idx).LongitudeHistory=zeros(1,0);
        simObj.Receivers(idx).AltitudeHistory=zeros(1,0);
        simObj.Receivers(idx).AttitudeHistory=zeros(3,0);
        simObj.Receivers(idx).Itrf2BodyTransformHistory=zeros(3,3,0);
        simObj.Receivers(idx).PointingDirection=zeros(2,0);
    end


    for idx=1:simObj.NumAccesses
        simObj.Accesses(idx).StatusHistory=false(1,0);
    end


    for idx=1:simObj.NumLinks
        simObj.Links(idx).StatusHistory=false(1,0);
        simObj.Links(idx).EbNoHistory=zeros(1,0);
        simObj.Links(idx).ReceivedIsotropicPowerHistory=zeros(1,0);
        simObj.Links(idx).PowerAtReceiverInputHistory=zeros(1,0);
    end


    for idx=1:simObj.NumFieldsOfView
        simObj.FieldsOfView(idx).ContourHistory=zeros(simObj.FieldsOfView(idx).NumContourPoints,3,0);
        simObj.FieldsOfView(idx).StatusHistory=false(1,0);
    end

end

