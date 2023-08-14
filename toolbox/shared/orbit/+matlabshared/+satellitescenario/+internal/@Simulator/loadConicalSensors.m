function loadConicalSensors(simObj,s)




    coder.allowpcode('plain');


    sensorStruct=matlabshared.satellitescenario.internal.Simulator.conicalSensorStruct;


    sensors=s.ConicalSensors;



    simObj.ConicalSensors=repmat(sensorStruct,1,numel(sensors));


    for idx=1:simObj.NumConicalSensors
        simObj.ConicalSensors(idx).ID=sensors(idx).ID;
        simObj.ConicalSensors(idx).Position=sensors(idx).Position;
        simObj.ConicalSensors(idx).PositionHistory=sensors(idx).PositionHistory;
        simObj.ConicalSensors(idx).PositionITRF=sensors(idx).PositionITRF;
        simObj.ConicalSensors(idx).PositionITRFHistory=sensors(idx).PositionITRFHistory;
        if isfield(sensors,'Velocity')

            simObj.ConicalSensors(idx).Velocity=sensors(idx).Velocity;
        end
        if isfield(sensors,'VelocityHistory')

            simObj.ConicalSensors(idx).VelocityHistory=sensors(idx).VelocityHistory;
        end
        if isfield(sensors,'VelocityITRF')

            simObj.ConicalSensors(idx).VelocityITRF=sensors(idx).VelocityITRF;
        end
        if isfield(sensors,'VelocityITRFHistory')

            simObj.ConicalSensors(idx).VelocityITRFHistory=sensors(idx).VelocityITRFHistory;
        end
        simObj.ConicalSensors(idx).Latitude=sensors(idx).Latitude;
        simObj.ConicalSensors(idx).Longitude=sensors(idx).Longitude;
        simObj.ConicalSensors(idx).Altitude=sensors(idx).Altitude;
        simObj.ConicalSensors(idx).Attitude=sensors(idx).Attitude;
        if isfield(sensors,'LatitudeHistory')

            simObj.ConicalSensors(idx).LatitudeHistory=sensors(idx).LatitudeHistory;
        end
        if isfield(sensors,'LongitudeHistory')

            simObj.ConicalSensors(idx).LongitudeHistory=sensors(idx).LongitudeHistory;
        end
        if isfield(sensors,'AltitudeHistory')

            simObj.ConicalSensors(idx).AltitudeHistory=sensors(idx).AltitudeHistory;
        end
        simObj.ConicalSensors(idx).AttitudeHistory=sensors(idx).AttitudeHistory;
        simObj.ConicalSensors(idx).Itrf2BodyTransform=sensors(idx).Itrf2BodyTransform;
        simObj.ConicalSensors(idx).Itrf2BodyTransformHistory=sensors(idx).Itrf2BodyTransformHistory;
        simObj.ConicalSensors(idx).MountingLocation=sensors(idx).MountingLocation;
        simObj.ConicalSensors(idx).MountingAngles=sensors(idx).MountingAngles;
        simObj.ConicalSensors(idx).MaxViewAngle=sensors(idx).MaxViewAngle;
        simObj.ConicalSensors(idx).ParentSimulatorID=sensors(idx).ParentSimulatorID;
        simObj.ConicalSensors(idx).Type=sensors(idx).Type;
        simObj.ConicalSensors(idx).ParentType=sensors(idx).ParentType;
        simObj.ConicalSensors(idx).GrandParentSimulatorID=sensors(idx).GrandParentSimulatorID;
        simObj.ConicalSensors(idx).GrandParentType=sensors(idx).GrandParentType;
    end
end

