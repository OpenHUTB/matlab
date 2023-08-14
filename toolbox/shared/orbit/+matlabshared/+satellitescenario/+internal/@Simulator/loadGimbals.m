function loadGimbals(simObj,s)




    coder.allowpcode('plain');


    gimStruct=matlabshared.satellitescenario.internal.Simulator.gimbalStruct;


    gimbals=s.Gimbals;



    simObj.Gimbals=repmat(gimStruct,1,numel(gimbals));


    for idx=1:simObj.NumGimbals
        simObj.Gimbals(idx).ID=gimbals(idx).ID;
        simObj.Gimbals(idx).Position=gimbals(idx).Position;
        simObj.Gimbals(idx).PositionHistory=gimbals(idx).PositionHistory;
        simObj.Gimbals(idx).PositionITRF=gimbals(idx).PositionITRF;
        simObj.Gimbals(idx).PositionITRFHistory=gimbals(idx).PositionITRFHistory;
        if isfield(gimbals,'Velocity')

            simObj.Gimbals(idx).Velocity=gimbals(idx).Velocity;
        end
        if isfield(gimbals,'VelocityHistory')

            simObj.Gimbals(idx).VelocityHistory=gimbals(idx).VelocityHistory;
        end
        if isfield(gimbals,'VelocityITRF')

            simObj.Gimbals(idx).VelocityITRF=gimbals(idx).VelocityITRF;
        end
        if isfield(gimbals,'VelocityITRFHistory')

            simObj.Gimbals(idx).VelocityITRFHistory=gimbals(idx).VelocityITRFHistory;
        end
        simObj.Gimbals(idx).Latitude=gimbals(idx).Latitude;
        simObj.Gimbals(idx).Longitude=gimbals(idx).Longitude;
        simObj.Gimbals(idx).Altitude=gimbals(idx).Altitude;
        simObj.Gimbals(idx).Attitude=gimbals(idx).Attitude;
        if isfield(gimbals,'LatitudeHistory')

            simObj.Gimbals(idx).LatitudeHistory=gimbals(idx).LatitudeHistory;
        end
        if isfield(gimbals,'LongitudeHistory')

            simObj.Gimbals(idx).LongitudeHistory=gimbals(idx).LongitudeHistory;
        end
        if isfield(gimbals,'AltitudeHistory')

            simObj.Gimbals(idx).AltitudeHistory=gimbals(idx).AltitudeHistory;
        end
        simObj.Gimbals(idx).AttitudeHistory=gimbals(idx).AttitudeHistory;
        simObj.Gimbals(idx).Itrf2BodyTransform=gimbals(idx).Itrf2BodyTransform;
        simObj.Gimbals(idx).Itrf2BodyTransformHistory=gimbals(idx).Itrf2BodyTransformHistory;
        simObj.Gimbals(idx).Ned2BodyTransform=gimbals(idx).Ned2BodyTransform;
        if isfield(gimbals,'Ned2BodyTransformHistory')

            simObj.Gimbals(idx).Ned2BodyTransformHistory=gimbals(idx).Ned2BodyTransformHistory;
        end
        simObj.Gimbals(idx).PointingMode=gimbals(idx).PointingMode;
        simObj.Gimbals(idx).PointingTargetID=gimbals(idx).PointingTargetID;
        simObj.Gimbals(idx).PointingCoordinates=gimbals(idx).PointingCoordinates;
        simObj.Gimbals(idx).GimbalAzimuth=gimbals(idx).GimbalAzimuth;
        simObj.Gimbals(idx).GimbalAzimuthHistory=gimbals(idx).GimbalAzimuthHistory;
        simObj.Gimbals(idx).GimbalElevation=gimbals(idx).GimbalElevation;
        simObj.Gimbals(idx).GimbalElevationHistory=gimbals(idx).GimbalElevationHistory;
        simObj.Gimbals(idx).MountingLocation=gimbals(idx).MountingLocation;
        simObj.Gimbals(idx).MountingAngles=gimbals(idx).MountingAngles;
        simObj.Gimbals(idx).ParentSimulatorID=gimbals(idx).ParentSimulatorID;
        simObj.Gimbals(idx).Type=gimbals(idx).Type;
        simObj.Gimbals(idx).ParentType=gimbals(idx).ParentType;
        simObj.Gimbals(idx).GrandParentSimulatorID=gimbals(idx).GrandParentSimulatorID;
        simObj.Gimbals(idx).GrandParentType=gimbals(idx).GrandParentType;
        if isfield(gimbals,'CustomAngles')

            simObj.Gimbals(idx).CustomAngles=gimbals(idx).CustomAngles;
        end
    end
end

