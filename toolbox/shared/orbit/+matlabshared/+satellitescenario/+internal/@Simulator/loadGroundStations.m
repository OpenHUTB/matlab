function loadGroundStations(simObj,s)




    coder.allowpcode('plain');


    gsStruct=matlabshared.satellitescenario.internal.Simulator.groundStationStruct;


    gs=s.GroundStations;



    simObj.GroundStations=repmat(gsStruct,1,numel(gs));


    for idx=1:simObj.NumGroundStations
        simObj.GroundStations(idx).ID=gs(idx).ID;
        simObj.GroundStations(idx).Position=gs(idx).Position;
        simObj.GroundStations(idx).PositionHistory=gs(idx).PositionHistory;
        simObj.GroundStations(idx).PositionITRF=gs(idx).PositionITRF;
        simObj.GroundStations(idx).PositionITRFHistory=gs(idx).PositionITRFHistory;
        simObj.GroundStations(idx).Velocity=gs(idx).Velocity;
        simObj.GroundStations(idx).VelocityHistory=gs(idx).VelocityHistory;
        if isfield(gs,'VelocityITRF')

            simObj.GroundStations(idx).VelocityITRF=gs(idx).VelocityITRF;
        end
        if isfield(gs,'VelocityITRFHistory')

            simObj.GroundStations(idx).VelocityITRFHistory=gs(idx).VelocityITRFHistory;
        end
        simObj.GroundStations(idx).Latitude=gs(idx).Latitude;
        simObj.GroundStations(idx).Longitude=gs(idx).Longitude;
        simObj.GroundStations(idx).Altitude=gs(idx).Altitude;
        simObj.GroundStations(idx).LatitudeHistory=gs(idx).LatitudeHistory;
        simObj.GroundStations(idx).LongitudeHistory=gs(idx).LongitudeHistory;
        simObj.GroundStations(idx).AltitudeHistory=gs(idx).AltitudeHistory;
        simObj.GroundStations(idx).Attitude=gs(idx).Attitude;
        simObj.GroundStations(idx).AttitudeHistory=gs(idx).AttitudeHistory;
        simObj.GroundStations(idx).MinElevationAngle=gs(idx).MinElevationAngle;
        simObj.GroundStations(idx).Itrf2BodyTransform=gs(idx).Itrf2BodyTransform;
        simObj.GroundStations(idx).Itrf2BodyTransformHistory=gs(idx).Itrf2BodyTransformHistory;
        simObj.GroundStations(idx).Ned2BodyTransform=gs(idx).Ned2BodyTransform;
        simObj.GroundStations(idx).Ned2BodyTransformHistory=gs(idx).Ned2BodyTransformHistory;
        simObj.GroundStations(idx).Type=gs(idx).Type;
        simObj.GroundStations(idx).GrandParentSimulatorID=gs(idx).GrandParentSimulatorID;
        simObj.GroundStations(idx).GrandParentType=gs(idx).GrandParentType;
    end
end

