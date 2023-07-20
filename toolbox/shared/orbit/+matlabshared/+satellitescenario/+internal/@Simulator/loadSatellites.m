function loadSatellites(simObj,s)




    coder.allowpcode('plain');


    satStruct=matlabshared.satellitescenario.internal.Simulator.satelliteStruct;


    satellites=s.Satellites;



    simObj.Satellites=repmat(satStruct,1,numel(satellites));


    for idx=1:simObj.NumSatellites
        simObj.Satellites(idx).ID=satellites(idx).ID;
        if isfield(satellites(idx),'PropagatorType')

            simObj.Satellites(idx).PropagatorTBK=satellites(idx).PropagatorTBK;
            simObj.Satellites(idx).PropagatorSGP4=satellites(idx).PropagatorSGP4;
            simObj.Satellites(idx).PropagatorSDP4=satellites(idx).PropagatorSDP4;
            simObj.Satellites(idx).PropagatorEphemeris=satellites(idx).PropagatorEphemeris;
            if isfield(satellites(idx),'PropagatorGPS')

                simObj.Satellites(idx).PropagatorGPS=satellites(idx).PropagatorGPS;
            end
            simObj.Satellites(idx).PropagatorType=satellites(idx).PropagatorType;
        else

            switch class(satellites(idx).Propagator)
            case 'matlabshared.orbit.internal.TwoBodyKeplerian'
                simObj.Satellites(idx).PropagatorTBK=satellites(idx).Propagator;
                simObj.Satellites(idx).PropagatorType=1;
            case 'matlabshared.orbit.internal.SGP4'
                simObj.Satellites(idx).PropagatorSGP4=satellites(idx).Propagator;
                simObj.Satellites(idx).PropagatorType=2;
            case 'matlabshared.orbit.internal.SDP4'
                simObj.Satellites(idx).PropagatorSDP4=satellites(idx).Propagator;
                simObj.Satellites(idx).PropagatorType=3;
            case 'matlabshared.orbit.internal.Ephemeris'
                simObj.Satellites(idx).PropagatorEphemeris=satellites(idx).Propagator;
                simObj.Satellites(idx).PropagatorType=4;
            otherwise
                simObj.Satellites(idx).PropagatorGPS=satellites(idx).Propagator;
                simObj.Satellites(idx).PropagatorType=5;
            end
        end

        simObj.Satellites(idx).Position=satellites(idx).Position;
        simObj.Satellites(idx).PositionHistory=satellites(idx).PositionHistory;
        simObj.Satellites(idx).PositionITRF=satellites(idx).PositionITRF;
        simObj.Satellites(idx).PositionITRFHistory=satellites(idx).PositionITRFHistory;
        simObj.Satellites(idx).Velocity=satellites(idx).Velocity;
        simObj.Satellites(idx).VelocityHistory=satellites(idx).VelocityHistory;
        simObj.Satellites(idx).Latitude=satellites(idx).Latitude;
        simObj.Satellites(idx).Longitude=satellites(idx).Longitude;
        simObj.Satellites(idx).Altitude=satellites(idx).Altitude;
        simObj.Satellites(idx).LatitudeHistory=satellites(idx).LatitudeHistory;
        simObj.Satellites(idx).LongitudeHistory=satellites(idx).LongitudeHistory;
        simObj.Satellites(idx).AltitudeHistory=satellites(idx).AltitudeHistory;
        simObj.Satellites(idx).Attitude=satellites(idx).Attitude;
        simObj.Satellites(idx).AttitudeHistory=satellites(idx).AttitudeHistory;
        simObj.Satellites(idx).Itrf2BodyTransform=satellites(idx).Itrf2BodyTransform;
        simObj.Satellites(idx).Itrf2BodyTransformHistory=satellites(idx).Itrf2BodyTransformHistory;
        simObj.Satellites(idx).Ned2BodyTransform=satellites(idx).Ned2BodyTransform;
        simObj.Satellites(idx).Ned2BodyTransformHistory=satellites(idx).Ned2BodyTransformHistory;
        simObj.Satellites(idx).PointingMode=satellites(idx).PointingMode;
        simObj.Satellites(idx).PointingTargetID=satellites(idx).PointingTargetID;
        simObj.Satellites(idx).PointingCoordinates=satellites(idx).PointingCoordinates;
        simObj.Satellites(idx).Type=satellites(idx).Type;
        simObj.Satellites(idx).GrandParentSimulatorID=satellites(idx).GrandParentSimulatorID;
        simObj.Satellites(idx).GrandParentType=satellites(idx).GrandParentType;
        if isfield(satellites,'CustomAttitude')

            simObj.Satellites(idx).CustomAttitude=satellites(idx).CustomAttitude;
        end
        if isfield(satellites,'CustomAttitudeDefault')

            simObj.Satellites(idx).CustomAttitudeDefault=satellites(idx).CustomAttitudeDefault;
        end
        if isfield(satellites,'CustomAttitudeCoordFrame')

            simObj.Satellites(idx).CustomAttitudeCoordFrame=satellites(idx).CustomAttitudeCoordFrame;
        end
        if isfield(satellites,'CustomAttitudeFormat')

            simObj.Satellites(idx).CustomAttitudeFormat=satellites(idx).CustomAttitudeFormat;
        end
    end
end

