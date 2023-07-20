function updateStateHistory(simObj,donotAddNewSample)





%#codegen
    coder.allowpcode('plain');



    if nargin==1
        donotAddNewSample=false;
    end


    if~donotAddNewSample

        simObj.TimeHistory=[simObj.TimeHistory,simObj.Time];


        for idx=1:simObj.NumSatellites
            simObj.Satellites(idx).PositionHistory=[simObj.Satellites(idx).PositionHistory,simObj.Satellites(idx).Position];
            simObj.Satellites(idx).PositionITRFHistory=[simObj.Satellites(idx).PositionITRFHistory,simObj.Satellites(idx).PositionITRF];
            simObj.Satellites(idx).VelocityHistory=[simObj.Satellites(idx).VelocityHistory,simObj.Satellites(idx).Velocity];
            simObj.Satellites(idx).VelocityITRFHistory=[simObj.Satellites(idx).VelocityITRFHistory,simObj.Satellites(idx).VelocityITRF];
            simObj.Satellites(idx).LatitudeHistory=[simObj.Satellites(idx).LatitudeHistory,simObj.Satellites(idx).Latitude];
            simObj.Satellites(idx).LongitudeHistory=[simObj.Satellites(idx).LongitudeHistory,simObj.Satellites(idx).Longitude];
            simObj.Satellites(idx).AltitudeHistory=[simObj.Satellites(idx).AltitudeHistory,simObj.Satellites(idx).Altitude];
            simObj.Satellites(idx).AttitudeHistory=[simObj.Satellites(idx).AttitudeHistory,simObj.Satellites(idx).Attitude];
            simObj.Satellites(idx).Itrf2BodyTransformHistory=cat(3,simObj.Satellites(idx).Itrf2BodyTransformHistory,simObj.Satellites(idx).Itrf2BodyTransform);
            simObj.Satellites(idx).Ned2BodyTransformHistory=cat(3,simObj.Satellites(idx).Ned2BodyTransformHistory,simObj.Satellites(idx).Ned2BodyTransform);
        end


        for idx=1:simObj.NumGroundStations
            simObj.GroundStations(idx).PositionHistory=[simObj.GroundStations(idx).PositionHistory,simObj.GroundStations(idx).Position];
            simObj.GroundStations(idx).PositionITRFHistory=[simObj.GroundStations(idx).PositionITRFHistory,simObj.GroundStations(idx).PositionITRF];
            simObj.GroundStations(idx).VelocityHistory=[simObj.GroundStations(idx).VelocityHistory,simObj.GroundStations(idx).Velocity];
            simObj.GroundStations(idx).VelocityITRFHistory=[simObj.GroundStations(idx).VelocityITRFHistory,simObj.GroundStations(idx).VelocityITRF];
            simObj.GroundStations(idx).LatitudeHistory=[simObj.GroundStations(idx).LatitudeHistory,simObj.GroundStations(idx).Latitude];
            simObj.GroundStations(idx).LongitudeHistory=[simObj.GroundStations(idx).LongitudeHistory,simObj.GroundStations(idx).Longitude];
            simObj.GroundStations(idx).AltitudeHistory=[simObj.GroundStations(idx).AltitudeHistory,simObj.GroundStations(idx).Altitude];
            simObj.GroundStations(idx).AttitudeHistory=[simObj.GroundStations(idx).AttitudeHistory,simObj.GroundStations(idx).Attitude];
            simObj.GroundStations(idx).Itrf2BodyTransformHistory=cat(3,simObj.GroundStations(idx).Itrf2BodyTransformHistory,simObj.GroundStations(idx).Itrf2BodyTransform);
            simObj.GroundStations(idx).Ned2BodyTransformHistory=cat(3,simObj.GroundStations(idx).Ned2BodyTransformHistory,simObj.GroundStations(idx).Ned2BodyTransform);
        end


        for idx=1:simObj.NumGimbals
            simObj.Gimbals(idx).PositionHistory=[simObj.Gimbals(idx).PositionHistory,simObj.Gimbals(idx).Position];
            simObj.Gimbals(idx).PositionITRFHistory=[simObj.Gimbals(idx).PositionITRFHistory,simObj.Gimbals(idx).PositionITRF];
            simObj.Gimbals(idx).VelocityHistory=[simObj.Gimbals(idx).VelocityHistory,simObj.Gimbals(idx).Velocity];
            simObj.Gimbals(idx).VelocityITRFHistory=[simObj.Gimbals(idx).VelocityITRFHistory,simObj.Gimbals(idx).VelocityITRF];
            simObj.Gimbals(idx).LatitudeHistory=[simObj.Gimbals(idx).LatitudeHistory,simObj.Gimbals(idx).Latitude];
            simObj.Gimbals(idx).LongitudeHistory=[simObj.Gimbals(idx).LongitudeHistory,simObj.Gimbals(idx).Longitude];
            simObj.Gimbals(idx).AltitudeHistory=[simObj.Gimbals(idx).AltitudeHistory,simObj.Gimbals(idx).Altitude];
            simObj.Gimbals(idx).AttitudeHistory=[simObj.Gimbals(idx).AttitudeHistory,simObj.Gimbals(idx).Attitude];
            simObj.Gimbals(idx).Itrf2BodyTransformHistory=cat(3,simObj.Gimbals(idx).Itrf2BodyTransformHistory,simObj.Gimbals(idx).Itrf2BodyTransform);
            simObj.Gimbals(idx).Ned2BodyTransformHistory=cat(3,simObj.Gimbals(idx).Ned2BodyTransformHistory,simObj.Gimbals(idx).Ned2BodyTransform);
            simObj.Gimbals(idx).GimbalAzimuthHistory=[simObj.Gimbals(idx).GimbalAzimuthHistory,simObj.Gimbals(idx).GimbalAzimuth];
            simObj.Gimbals(idx).GimbalElevationHistory=[simObj.Gimbals(idx).GimbalElevationHistory,simObj.Gimbals(idx).GimbalElevation];
        end


        for idx=1:simObj.NumConicalSensors
            simObj.ConicalSensors(idx).PositionHistory=[simObj.ConicalSensors(idx).PositionHistory,simObj.ConicalSensors(idx).Position];
            simObj.ConicalSensors(idx).PositionITRFHistory=[simObj.ConicalSensors(idx).PositionITRFHistory,simObj.ConicalSensors(idx).PositionITRF];
            simObj.ConicalSensors(idx).VelocityHistory=[simObj.ConicalSensors(idx).VelocityHistory,simObj.ConicalSensors(idx).Velocity];
            simObj.ConicalSensors(idx).VelocityITRFHistory=[simObj.ConicalSensors(idx).VelocityITRFHistory,simObj.ConicalSensors(idx).VelocityITRF];
            simObj.ConicalSensors(idx).LatitudeHistory=[simObj.ConicalSensors(idx).LatitudeHistory,simObj.ConicalSensors(idx).Latitude];
            simObj.ConicalSensors(idx).LongitudeHistory=[simObj.ConicalSensors(idx).LongitudeHistory,simObj.ConicalSensors(idx).Longitude];
            simObj.ConicalSensors(idx).AltitudeHistory=[simObj.ConicalSensors(idx).AltitudeHistory,simObj.ConicalSensors(idx).Altitude];
            simObj.ConicalSensors(idx).AttitudeHistory=[simObj.ConicalSensors(idx).AttitudeHistory,simObj.ConicalSensors(idx).Attitude];
            simObj.ConicalSensors(idx).Itrf2BodyTransformHistory=cat(3,simObj.ConicalSensors(idx).Itrf2BodyTransformHistory,simObj.ConicalSensors(idx).Itrf2BodyTransform);
        end


        for idx=1:simObj.NumTransmitters
            simObj.Transmitters(idx).PositionHistory=[simObj.Transmitters(idx).PositionHistory,simObj.Transmitters(idx).Position];
            simObj.Transmitters(idx).PositionITRFHistory=[simObj.Transmitters(idx).PositionITRFHistory,simObj.Transmitters(idx).PositionITRF];
            simObj.Transmitters(idx).VelocityHistory=[simObj.Transmitters(idx).VelocityHistory,simObj.Transmitters(idx).Velocity];
            simObj.Transmitters(idx).VelocityITRFHistory=[simObj.Transmitters(idx).VelocityITRFHistory,simObj.Transmitters(idx).VelocityITRF];
            simObj.Transmitters(idx).LatitudeHistory=[simObj.Transmitters(idx).LatitudeHistory,simObj.Transmitters(idx).Latitude];
            simObj.Transmitters(idx).LongitudeHistory=[simObj.Transmitters(idx).LongitudeHistory,simObj.Transmitters(idx).Longitude];
            simObj.Transmitters(idx).AltitudeHistory=[simObj.Transmitters(idx).AltitudeHistory,simObj.Transmitters(idx).Altitude];
            simObj.Transmitters(idx).AttitudeHistory=[simObj.Transmitters(idx).AttitudeHistory,simObj.Transmitters(idx).Attitude];
            simObj.Transmitters(idx).Itrf2BodyTransformHistory=cat(3,simObj.Transmitters(idx).Itrf2BodyTransformHistory,simObj.Transmitters(idx).Itrf2BodyTransform);
        end


        for idx=1:simObj.NumReceivers
            simObj.Receivers(idx).PositionHistory=[simObj.Receivers(idx).PositionHistory,simObj.Receivers(idx).Position];
            simObj.Receivers(idx).PositionITRFHistory=[simObj.Receivers(idx).PositionITRFHistory,simObj.Receivers(idx).PositionITRF];
            simObj.Receivers(idx).VelocityHistory=[simObj.Receivers(idx).VelocityHistory,simObj.Receivers(idx).Velocity];
            simObj.Receivers(idx).VelocityITRFHistory=[simObj.Receivers(idx).VelocityITRFHistory,simObj.Receivers(idx).VelocityITRF];
            simObj.Receivers(idx).LatitudeHistory=[simObj.Receivers(idx).LatitudeHistory,simObj.Receivers(idx).Latitude];
            simObj.Receivers(idx).LongitudeHistory=[simObj.Receivers(idx).LongitudeHistory,simObj.Receivers(idx).Longitude];
            simObj.Receivers(idx).AltitudeHistory=[simObj.Receivers(idx).AltitudeHistory,simObj.Receivers(idx).Altitude];
            simObj.Receivers(idx).AttitudeHistory=[simObj.Receivers(idx).AttitudeHistory,simObj.Receivers(idx).Attitude];
            simObj.Receivers(idx).Itrf2BodyTransformHistory=cat(3,simObj.Receivers(idx).Itrf2BodyTransformHistory,simObj.Receivers(idx).Itrf2BodyTransform);
        end


        for idx=1:simObj.NumAccesses
            simObj.Accesses(idx).StatusHistory=[simObj.Accesses(idx).StatusHistory,simObj.Accesses(idx).Status];
        end


        for idx=1:simObj.NumLinks
            simObj.Links(idx).StatusHistory=[simObj.Links(idx).StatusHistory,simObj.Links(idx).Status];
            simObj.Links(idx).EbNoHistory=[simObj.Links(idx).EbNoHistory,simObj.Links(idx).EbNo];
            simObj.Links(idx).ReceivedIsotropicPowerHistory=[simObj.Links(idx).ReceivedIsotropicPowerHistory,simObj.Links(idx).ReceivedIsotropicPower];
            simObj.Links(idx).PowerAtReceiverInputHistory=[simObj.Links(idx).PowerAtReceiverInputHistory,simObj.Links(idx).PowerAtReceiverInput];
        end

        if coder.target('MATLAB')

            for idx=1:simObj.NumFieldsOfView
                simObj.FieldsOfView(idx).ContourHistory=cat(3,simObj.FieldsOfView(idx).ContourHistory,simObj.FieldsOfView(idx).Contour);
                simObj.FieldsOfView(idx).StatusHistory=[simObj.FieldsOfView(idx).StatusHistory,simObj.FieldsOfView(idx).Status];
            end
        end
    elseif numel(simObj.TimeHistory)~=0


        if isempty(simObj.TimeHistory)
            return
        end


        simObj.TimeHistory(end)=simObj.Time;


        for idx=1:simObj.NumSatellites
            if~isempty(simObj.Satellites(idx).LatitudeHistory)
                simObj.Satellites(idx).PositionHistory(:,end)=simObj.Satellites(idx).Position;
                simObj.Satellites(idx).PositionITRFHistory(:,end)=simObj.Satellites(idx).PositionITRF;
                simObj.Satellites(idx).VelocityHistory(:,end)=simObj.Satellites(idx).Velocity;
                simObj.Satellites(idx).VelocityITRFHistory(:,end)=simObj.Satellites(idx).VelocityITRF;
                simObj.Satellites(idx).LatitudeHistory(end)=simObj.Satellites(idx).Latitude;
                simObj.Satellites(idx).LongitudeHistory(end)=simObj.Satellites(idx).Longitude;
                simObj.Satellites(idx).AltitudeHistory(end)=simObj.Satellites(idx).Altitude;
                simObj.Satellites(idx).AttitudeHistory(:,end)=simObj.Satellites(idx).Attitude;
                simObj.Satellites(idx).Itrf2BodyTransformHistory(:,:,end)=simObj.Satellites(idx).Itrf2BodyTransform;
                simObj.Satellites(idx).Ned2BodyTransformHistory(:,:,end)=simObj.Satellites(idx).Ned2BodyTransform;
            end
        end


        for idx=1:simObj.NumGroundStations
            if~isempty(simObj.GroundStations(idx).LatitudeHistory)
                simObj.GroundStations(idx).PositionHistory(:,end)=simObj.GroundStations(idx).Position;
                simObj.GroundStations(idx).PositionITRFHistory(:,end)=simObj.GroundStations(idx).PositionITRF;
                simObj.GroundStations(idx).VelocityHistory(:,end)=simObj.GroundStations(idx).Velocity;
                simObj.GroundStations(idx).VelocityITRFHistory(:,end)=simObj.GroundStations(idx).VelocityITRF;
                simObj.GroundStations(idx).LatitudeHistory(end)=simObj.GroundStations(idx).Latitude;
                simObj.GroundStations(idx).LongitudeHistory(end)=simObj.GroundStations(idx).Longitude;
                simObj.GroundStations(idx).AltitudeHistory(end)=simObj.GroundStations(idx).Altitude;
                simObj.GroundStations(idx).AttitudeHistory(:,end)=simObj.GroundStations(idx).Attitude;
                simObj.GroundStations(idx).Itrf2BodyTransformHistory(:,:,end)=simObj.GroundStations(idx).Itrf2BodyTransform;
                simObj.GroundStations(idx).Ned2BodyTransformHistory(:,:,end)=simObj.GroundStations(idx).Ned2BodyTransform;
            end
        end


        for idx=1:simObj.NumGimbals
            if~isempty(simObj.Gimbals(idx).LatitudeHistory)
                simObj.Gimbals(idx).PositionHistory(:,end)=simObj.Gimbals(idx).Position;
                simObj.Gimbals(idx).PositionITRFHistory(:,end)=simObj.Gimbals(idx).PositionITRF;
                simObj.Gimbals(idx).VelocityHistory(:,end)=simObj.Gimbals(idx).Velocity;
                simObj.Gimbals(idx).VelocityITRFHistory(:,end)=simObj.Gimbals(idx).VelocityITRF;
                simObj.Gimbals(idx).LatitudeHistory(end)=simObj.Gimbals(idx).Latitude;
                simObj.Gimbals(idx).LongitudeHistory(end)=simObj.Gimbals(idx).Longitude;
                simObj.Gimbals(idx).AltitudeHistory(end)=simObj.Gimbals(idx).Altitude;
                simObj.Gimbals(idx).AttitudeHistory(:,end)=simObj.Gimbals(idx).Attitude;
                simObj.Gimbals(idx).Itrf2BodyTransformHistory(:,:,end)=simObj.Gimbals(idx).Itrf2BodyTransform;
                simObj.Gimbals(idx).Ned2BodyTransformHistory(:,:,end)=simObj.Gimbals(idx).Ned2BodyTransform;
                simObj.Gimbals(idx).GimbalAzimuthHistory(end)=simObj.Gimbals(idx).GimbalAzimuth;
                simObj.Gimbals(idx).GimbalElevationHistory(end)=simObj.Gimbals(idx).GimbalElevation;
            end
        end


        for idx=1:simObj.NumConicalSensors
            if~isempty(simObj.ConicalSensors(idx).LatitudeHistory)
                simObj.ConicalSensors(idx).PositionHistory(:,end)=simObj.ConicalSensors(idx).Position;
                simObj.ConicalSensors(idx).PositionITRFHistory(:,end)=simObj.ConicalSensors(idx).PositionITRF;
                simObj.ConicalSensors(idx).VelocityHistory(:,end)=simObj.ConicalSensors(idx).Velocity;
                simObj.ConicalSensors(idx).VelocityITRFHistory(:,end)=simObj.ConicalSensors(idx).VelocityITRF;
                simObj.ConicalSensors(idx).LatitudeHistory(end)=simObj.ConicalSensors(idx).Latitude;
                simObj.ConicalSensors(idx).LongitudeHistory(end)=simObj.ConicalSensors(idx).Longitude;
                simObj.ConicalSensors(idx).AltitudeHistory(end)=simObj.ConicalSensors(idx).Altitude;
                simObj.ConicalSensors(idx).AttitudeHistory(:,end)=simObj.ConicalSensors(idx).Attitude;
                simObj.ConicalSensors(idx).Itrf2BodyTransformHistory(:,:,end)=simObj.ConicalSensors(idx).Itrf2BodyTransform;
            end
        end


        for idx=1:simObj.NumTransmitters
            if~isempty(simObj.Transmitters(idx).LatitudeHistory)
                simObj.Transmitters(idx).PositionHistory(:,end)=simObj.Transmitters(idx).Position;
                simObj.Transmitters(idx).PositionITRFHistory(:,end)=simObj.Transmitters(idx).PositionITRF;
                simObj.Transmitters(idx).VelocityHistory(:,end)=simObj.Transmitters(idx).Velocity;
                simObj.Transmitters(idx).VelocityITRFHistory(:,end)=simObj.Transmitters(idx).VelocityITRF;
                simObj.Transmitters(idx).LatitudeHistory(end)=simObj.Transmitters(idx).Latitude;
                simObj.Transmitters(idx).LongitudeHistory(end)=simObj.Transmitters(idx).Longitude;
                simObj.Transmitters(idx).AltitudeHistory(end)=simObj.Transmitters(idx).Altitude;
                simObj.Transmitters(idx).AttitudeHistory(:,end)=simObj.Transmitters(idx).Attitude;
                simObj.Transmitters(idx).Itrf2BodyTransformHistory(:,:,end)=simObj.Transmitters(idx).Itrf2BodyTransform;
            end
        end


        for idx=1:simObj.NumReceivers
            if~isempty(simObj.Receivers(idx).LatitudeHistory)
                simObj.Receivers(idx).PositionHistory(:,end)=simObj.Receivers(idx).Position;
                simObj.Receivers(idx).PositionITRFHistory(:,end)=simObj.Receivers(idx).PositionITRF;
                simObj.Receivers(idx).VelocityHistory(:,end)=simObj.Receivers(idx).Velocity;
                simObj.Receivers(idx).VelocityITRFHistory(:,end)=simObj.Receivers(idx).VelocityITRF;
                simObj.Receivers(idx).LatitudeHistory(end)=simObj.Receivers(idx).Latitude;
                simObj.Receivers(idx).LongitudeHistory(end)=simObj.Receivers(idx).Longitude;
                simObj.Receivers(idx).AltitudeHistory(end)=simObj.Receivers(idx).Altitude;
                simObj.Receivers(idx).AttitudeHistory(:,end)=simObj.Receivers(idx).Attitude;
                simObj.Receivers(idx).Itrf2BodyTransformHistory(:,:,end)=simObj.Receivers(idx).Itrf2BodyTransform;
            end
        end


        for idx=1:simObj.NumAccesses
            if~isempty(simObj.Accesses(idx).StatusHistory)
                simObj.Accesses(idx).StatusHistory(end)=simObj.Accesses(idx).Status;
            end
        end


        for idx=1:simObj.NumLinks
            if~isempty(simObj.Links(idx).StatusHistory)
                simObj.Links(idx).StatusHistory(end)=simObj.Links(idx).Status;
                simObj.Links(idx).EbNoHistory(end)=simObj.Links(idx).EbNo;
                simObj.Links(idx).ReceivedIsotropicPowerHistory(end)=simObj.Links(idx).ReceivedIsotropicPower;
                simObj.Links(idx).PowerAtReceiverInputHistory(end)=simObj.Links(idx).PowerAtReceiverInput;
            end
        end


        if coder.target('MATLAB')
            for idx=1:simObj.NumFieldsOfView
                if~isempty(simObj.FieldsOfView(idx).ContourHistory)
                    simObj.FieldsOfView(idx).ContourHistory(:,:,end)=simObj.FieldsOfView(idx).Contour;
                    simObj.FieldsOfView(idx).StatusHistory(end)=simObj.FieldsOfView(idx).Status;
                end
            end
        end
    end

end

