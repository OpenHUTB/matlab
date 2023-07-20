function simulate(simObj)%#codegen




    coder.allowpcode('plain');


    if simObj.NeedToMemoizeSimID
        memoizeSimID(simObj);
    end



    if~simObj.NeedToSimulate||simObj.SimulationMode==1
        return
    end

    if coder.target('MATLAB')

        updateAntennaPatterns(simObj);
    end


    startTime=simObj.StartTime;
    stopTime=simObj.StopTime;
    sampleTime=simObj.SampleTime;


    if stopTime<startTime
        msg='shared_orbit:orbitPropagator:SatelliteScenarioInvalidStopTime';
        if coder.target('MATLAB')
            errMsg=message(msg);
            error(errMsg);
        else
            coder.internal.error(msg);
        end
    end



    timeHistory=startTime:seconds(sampleTime):stopTime;
    if~isequal(stopTime,timeHistory(end))
        timeHistory=[timeHistory,stopTime];
    end
    simObj.TimeHistory=timeHistory;


    numTimeSamples=numel(timeHistory);



    itrf2gcrfTransforms=...
    matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(timeHistory);


    omega=repmat([0;0;matlabshared.orbit.internal.OrbitPropagationModel.EarthAngularVelocity],1,numTimeSamples);


    for satIdx=1:simObj.NumSatellites


        propagatorType=simObj.Satellites(satIdx).PropagatorType;


        switch propagatorType
        case 1
            [positionHistory,velocityHistory]=...
            step(simObj.Satellites(satIdx).PropagatorTBK,timeHistory);
            positionITRFHistoryCalc=pagemtimes(itrf2gcrfTransforms,'transpose',reshape(positionHistory,3,1,[]),'none');
            positionITRFHistory=reshape(positionITRFHistoryCalc,3,[]);
        case 2
            [positionPropagator,velocityPropagator]=...
            step(simObj.Satellites(satIdx).PropagatorSGP4,timeHistory);
            positionITRFHistory=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positionPropagator(1:3,:),...
            timeHistory);
            itrfInertialVelocityHistory=...
            matlabshared.orbit.internal.Transforms.teme2itrf(...
            velocityPropagator(1:3,:),...
            timeHistory);
            positionHistoryCalc=pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[]));
            positionHistory=reshape(positionHistoryCalc,3,[]);
            velocityHistoryCalc=pagemtimes(itrf2gcrfTransforms,reshape(itrfInertialVelocityHistory,3,1,[]));
            velocityHistory=reshape(velocityHistoryCalc,3,[]);
        case 3
            [positionPropagator,velocityPropagator]=...
            step(simObj.Satellites(satIdx).PropagatorSDP4,timeHistory);
            positionITRFHistory=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positionPropagator(1:3,:),...
            timeHistory);
            itrfInertialVelocityHistory=...
            matlabshared.orbit.internal.Transforms.teme2itrf(...
            velocityPropagator(1:3,:),...
            timeHistory);
            positionHistoryCalc=pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[]));
            positionHistory=reshape(positionHistoryCalc,3,[]);
            velocityHistoryCalc=pagemtimes(itrf2gcrfTransforms,reshape(itrfInertialVelocityHistory,3,1,[]));
            velocityHistory=reshape(velocityHistoryCalc,3,[]);
        case 4
            [positionHistory,velocityHistory]=...
            step(simObj.Satellites(satIdx).PropagatorEphemeris,timeHistory);
            positionITRFHistoryCalc=pagemtimes(itrf2gcrfTransforms,'transpose',reshape(positionHistory,3,1,[]),'none');
            positionITRFHistory=reshape(positionITRFHistoryCalc,3,[]);
        otherwise
            [positionITRFHistory,velocityITRFHistory]=...
            step(simObj.Satellites(satIdx).PropagatorGPS,timeHistory);
            positionHistory=reshape(pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[])),3,[]);
            inertialVelocityITRFHistory=velocityITRFHistory+cross(omega,positionITRFHistory(1:3,:,1));
            velocityHistory=reshape(pagemtimes(itrf2gcrfTransforms,reshape(inertialVelocityITRFHistory,3,1,[])),3,[]);
        end

        geographicPositionHistory=matlabshared.orbit.internal.Transforms.itrf2geographic(positionITRFHistory);
        altitude=geographicPositionHistory(3,:);

        if any(altitude<0)
            arg="satellite with ID "+simObj.Satellites(satIdx).ID;
            if simObj.Satellites(satIdx).PropagatorType==4

                msg='shared_orbit:orbitPropagator:EphemerisSimulationEarthCollisionTrajectory';
                if coder.target('MATLAB')
                    error(message(msg,arg));
                else
                    coder.internal.error(msg,arg);
                end
            else
                msg='shared_orbit:orbitPropagator:SatelliteScenarioSimulationEarthCollisionTrajectory';
                if coder.target('MATLAB')
                    error(message(msg,arg));
                else
                    coder.internal.error(msg,arg);
                end
            end
        end

        simObj.Satellites(satIdx).PositionHistory=positionHistory(1:3,:,1);
        simObj.Satellites(satIdx).VelocityHistory=velocityHistory(1:3,:,1);
        simObj.Satellites(satIdx).PositionITRFHistory=positionITRFHistory(1:3,:,1);

        simObj.Satellites(satIdx).LatitudeHistory=geographicPositionHistory(1,:)*180/pi;
        simObj.Satellites(satIdx).LongitudeHistory=geographicPositionHistory(2,:)*180/pi;
        simObj.Satellites(satIdx).AltitudeHistory=geographicPositionHistory(3,:);
    end


    for gsIdx=1:simObj.NumGroundStations




        latitude=simObj.GroundStations(gsIdx).Latitude;
        longitude=simObj.GroundStations(gsIdx).Longitude;
        altitude=simObj.GroundStations(gsIdx).Altitude;
        positionITRF=simObj.GroundStations(gsIdx).PositionITRF;

        latitudeHistory=latitude*ones(1,numTimeSamples);
        longitudeHistory=longitude*ones(1,numTimeSamples);
        altitudeHistory=altitude*ones(1,numTimeSamples);
        positionITRFHistory=repmat(positionITRF,1,numTimeSamples);
        attitudeHistory=zeros(3,numTimeSamples);

        positionHistoryCalc=pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[]));
        positionHistory=reshape(positionHistoryCalc,3,[]);

        simObj.GroundStations(gsIdx).PositionHistory=positionHistory;
        simObj.GroundStations(gsIdx).PositionITRFHistory=positionITRFHistory;
        simObj.GroundStations(gsIdx).VelocityITRFHistory=zeros(3,numTimeSamples);
        simObj.GroundStations(gsIdx).LatitudeHistory=latitudeHistory;
        simObj.GroundStations(gsIdx).LongitudeHistory=longitudeHistory;
        simObj.GroundStations(gsIdx).AltitudeHistory=altitudeHistory;
        simObj.GroundStations(gsIdx).AttitudeHistory=attitudeHistory;
        simObj.GroundStations(gsIdx).Ned2BodyTransformHistory=repmat(simObj.GroundStations(gsIdx).Ned2BodyTransform,1,1,numTimeSamples);
        simObj.GroundStations(gsIdx).Itrf2BodyTransformHistory=repmat(simObj.GroundStations(gsIdx).Itrf2BodyTransform,1,1,numTimeSamples);
    end

    itrf2BodyTransformHistory=zeros(3,3,numTimeSamples);
    ned2BodyTransformHistory=zeros(3,3,numTimeSamples);
    roll=zeros(1,numTimeSamples);
    pitch=zeros(1,numTimeSamples);
    yaw=zeros(1,numTimeSamples);


    for satIdx=1:simObj.NumSatellites

        satPositionITRFHistory=simObj.Satellites(satIdx).PositionITRFHistory;
        satPositionGeographicHistory=...
        [simObj.Satellites(satIdx).LatitudeHistory*pi/180;...
        simObj.Satellites(satIdx).LongitudeHistory*pi/180;...
        simObj.Satellites(satIdx).AltitudeHistory];
        satInertialVelocityITRFHistory=reshape(pagemtimes(itrf2gcrfTransforms,'transpose',reshape(simObj.Satellites(satIdx).VelocityHistory,3,1,[]),'none'),3,[]);


        switch simObj.Satellites(satIdx).PointingMode
        case 1



            targetSimID=simObj.Satellites(satIdx).PointingTargetID;
            pointingTargetIndex=simObj.SimIDMemo(targetSimID);


            targetPositionITRFHistory=...
            simObj.Satellites(pointingTargetIndex).PositionITRFHistory;
        case 2



            targetSimID=simObj.Satellites(satIdx).PointingTargetID;
            pointingTargetIndex=simObj.SimIDMemo(targetSimID);


            targetPositionITRFHistory=...
            simObj.GroundStations(pointingTargetIndex).PositionITRFHistory;
        case 3

            targetPositionITRFHistory=...
            repmat(simObj.Satellites(satIdx).PointingCoordinates,1,numTimeSamples);
        case 5

            customAttitude=simObj.Satellites(satIdx).CustomAttitude;
            useNadir=false;
            targetPositionITRFHistory=zeros(3,numTimeSamples);
            if~isempty(customAttitude)


                lowerBound=interp1(customAttitude.Properties.RowTimes,...
                customAttitude.Properties.RowTimes,timeHistory,"previous","NaT");
                upperBound=interp1(customAttitude.Properties.RowTimes,...
                customAttitude.Properties.RowTimes,timeHistory,"next","NaT");

                if(any(isnat(lowerBound))||any(isnat(upperBound)))
                    indexOutsideCustomData=isnat(lowerBound)|isnat(upperBound);
                    switch simObj.Satellites(satIdx).CustomAttitudeDefault
                    case "nadir"
                        useNadir=true;
                    case "fixed"
                        useNadir=false;
                    otherwise
                        useNadir=true;
                        msg='shared_orbit:orbitPropagator:SatelliteScenarioAttitudeOutOfRange';
                        if coder.target('MATLAB')
                            warning(message(msg));
                        else
                            coder.internal.compileWarning(msg);
                        end
                    end
                end


                lowerBound=fillmissing(lowerBound,"nearest");
                upperBound=fillmissing(upperBound,"nearest");



                interpFrac=min(max((timeHistory-lowerBound)./(upperBound-lowerBound),0),1);
                interpFrac(isinf(interpFrac)|isnan(interpFrac))=0;


                lowerQuat=customAttitude(lowerBound,:).Variables;
                upperQuat=customAttitude(upperBound,:).Variables;
                if simObj.Satellites(satIdx).CustomAttitudeFormat=="euler"
                    lowerQuat=...
                    matlabshared.satellitescenario.internal.Simulator.zyx2quat(deg2rad(lowerQuat));
                    upperQuat=...
                    matlabshared.satellitescenario.internal.Simulator.zyx2quat(deg2rad(upperQuat));
                end
                coordFrame2body=Aero.internal.shared.quaternion.toDCM(...
                Aero.internal.shared.quaternion.interp(lowerQuat,upperQuat,interpFrac,"slerp"));
            else
                coordFrame2body=repmat(eye(3),1,1,numTimeSamples);
            end

            switch simObj.Satellites(satIdx).CustomAttitudeCoordFrame
            case "inertial"
                gcrf2body=coordFrame2body;
                itrf2gcrf=matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(timeHistory);
                ned2itrf=permute(...
                matlabshared.orbit.internal.Transforms.itrf2nedTransform(satPositionGeographicHistory),[2,1,3]);
                itrf2BodyTransformHistory(:,:,:)=pagemtimes(gcrf2body,itrf2gcrf);
                ned2BodyTransformHistory(:,:,:)=pagemtimes(itrf2BodyTransformHistory,ned2itrf);
            case "ecef"
                itrf2BodyTransformHistory(:,:,:)=coordFrame2body;
                ned2itrf=permute(...
                matlabshared.orbit.internal.Transforms.itrf2nedTransform(satPositionGeographicHistory),[2,1,3]);
                ned2BodyTransformHistory(:,:,:)=pagemtimes(itrf2BodyTransformHistory,ned2itrf);
            otherwise

                ned2BodyTransformHistory(:,:,:)=coordFrame2body;
                itrf2ned=matlabshared.orbit.internal.Transforms.itrf2nedTransform(satPositionGeographicHistory);
                itrf2BodyTransformHistory(:,:,:)=pagemtimes(ned2BodyTransformHistory,itrf2ned);
            end


            pitch(1,:)=-asind(max(min(ned2BodyTransformHistory(1,3,:),1),-1));
            pitchGr90=abs(pitch)>(90-1e-6);
            roll(1,~pitchGr90)=atan2d(ned2BodyTransformHistory(2,3,~pitchGr90),ned2BodyTransformHistory(3,3,~pitchGr90));
            yaw(1,pitchGr90)=atan2d(-ned2BodyTransformHistory(2,1,pitchGr90),ned2BodyTransformHistory(2,2,pitchGr90));
            yaw(1,~pitchGr90)=atan2d(ned2BodyTransformHistory(1,2,~pitchGr90),ned2BodyTransformHistory(1,1,~pitchGr90));



            if useNadir
                targetPositionGeographicHistory=...
                [simObj.Satellites(satIdx).LatitudeHistory(indexOutsideCustomData);...
                simObj.Satellites(satIdx).LongitudeHistory(indexOutsideCustomData);...
                zeros(1,sum(indexOutsideCustomData))];
                targetPositionITRFHistory=...
                matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [targetPositionGeographicHistory(1,:)*pi/180;...
                targetPositionGeographicHistory(2,:)*pi/180;...
                targetPositionGeographicHistory(3,:)]);
                [roll(indexOutsideCustomData),...
                pitch(indexOutsideCustomData),...
                yaw(indexOutsideCustomData),...
                ned2BodyTransformHistory(:,:,indexOutsideCustomData),...
                itrf2BodyTransformHistory(:,:,indexOutsideCustomData)]=...
                matlabshared.satellitescenario.Satellite.getAttitude(...
                satPositionITRFHistory(:,indexOutsideCustomData),...
                satPositionGeographicHistory(:,indexOutsideCustomData),...
                satInertialVelocityITRFHistory(:,indexOutsideCustomData),...
                targetPositionITRFHistory);
            end
        otherwise


            targetPositionGeographicHistory=...
            [simObj.Satellites(satIdx).LatitudeHistory;...
            simObj.Satellites(satIdx).LongitudeHistory;...
            zeros(1,numTimeSamples)];
            targetPositionITRFHistory=...
            matlabshared.orbit.internal.Transforms.geographic2itrf(...
            [targetPositionGeographicHistory(1,:)*pi/180;...
            targetPositionGeographicHistory(2,:)*pi/180;...
            targetPositionGeographicHistory(3,:)]);
        end


        if simObj.Satellites(satIdx).PointingMode~=5
            [roll,pitch,yaw,ned2BodyTransformHistory,itrf2BodyTransformHistory]=...
            matlabshared.satellitescenario.Satellite.getAttitude(satPositionITRFHistory,...
            satPositionGeographicHistory,satInertialVelocityITRFHistory,...
            targetPositionITRFHistory);
        end


        simObj.Satellites(satIdx).AttitudeHistory=[roll;pitch;yaw];
        simObj.Satellites(satIdx).Itrf2BodyTransformHistory=...
        itrf2BodyTransformHistory;
        simObj.Satellites(satIdx).Ned2BodyTransformHistory=...
        ned2BodyTransformHistory;
    end


    for gimbalIdx=1:simObj.NumGimbals

        parentID=simObj.Gimbals(gimbalIdx).ParentSimulatorID;
        parentType=simObj.Gimbals(gimbalIdx).ParentType;


        switch parentType
        case 1
            gimbalParentIndex=simObj.SimIDMemo(parentID);
            parent=simObj.Satellites(gimbalParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        otherwise
            gimbalParentIndex=simObj.SimIDMemo(parentID);
            parent=simObj.GroundStations(gimbalParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        end


        needToSteer=1;
        switch simObj.Gimbals(gimbalIdx).PointingMode
        case 1



            targetSimID=simObj.Gimbals(gimbalIdx).PointingTargetID;
            gimbalPointingTargetIndex=simObj.SimIDMemo(targetSimID);


            targetPositionITRFHistory=...
            simObj.Satellites(gimbalPointingTargetIndex).PositionITRFHistory;
        case 2



            targetSimID=simObj.Gimbals(gimbalIdx).PointingTargetID;
            gimbalPointingTargetIndex=simObj.SimIDMemo(targetSimID);


            targetPositionITRFHistory=...
            simObj.GroundStations(gimbalPointingTargetIndex).PositionITRFHistory;
        case 3

            targetPositionITRFHistory=...
            repmat(simObj.Gimbals(gimbalIdx).PointingCoordinates,1,numTimeSamples);
        case 4


            targetPositionITRFHistory=...
            matlabshared.orbit.internal.Transforms.geographic2itrf(...
            [parentLatitudeHistory*pi/180;...
            parentLongitudeHistory*pi/180;...
            zeros(1,numTimeSamples)]);
        case 6
            customAngles=simObj.Gimbals(gimbalIdx).CustomAngles;
            needToSteer=0;
            targetPositionITRFHistory=zeros(3,numTimeSamples);
            if~isempty(customAngles)

                lowerBound=interp1(customAngles.Properties.RowTimes,...
                customAngles.Properties.RowTimes,timeHistory,"previous","NaT");
                upperBound=interp1(customAngles.Properties.RowTimes,...
                customAngles.Properties.RowTimes,timeHistory,"next","NaT");
                indexOutsideCustomData=[];
                if(any(isnat(lowerBound))||any(isnat(upperBound)))
                    indexOutsideCustomData=isnat(lowerBound)|isnat(upperBound);
                end
                needToSteer=-1;


                azEl=deg2rad([customAngles.Variables,zeros(height(customAngles),1)]);
                azEl(azEl(:,2)==0,2)=eps;
                z=cos(azEl(:,2));
                azEl(azEl(:,2)<0,1)=azEl(azEl(:,2)<0,1)+pi;
                x=cos(azEl(:,1));
                y=sin(azEl(:,1));

                [~,locCartTT]=...
                matlabshared.orbit.internal.Ephemeris.extract(...
                timetable(customAngles.Properties.RowTimes,[x,y,z]),timeHistory,"makima",nan);

                azEl=zeros(height(locCartTT),3);
                xyz=locCartTT.Variables;
                azEl(:,2)=acos(max(min(xyz(:,3),1),-1));
                azEl(:,1)=atan2(xyz(:,2),xyz(:,1));


                azEl(indexOutsideCustomData,:)=0;
                targetPositionITRFHistory=azEl';
            end
        otherwise

            needToSteer=0;
            targetPositionITRFHistory=[0;0;0];
        end

        mountingLocation=simObj.Gimbals(gimbalIdx).MountingLocation;
        mountingAngles=simObj.Gimbals(gimbalIdx).MountingAngles;

        [positionITRFHistory,positionGeographicHistory,...
        attitudeHistory,itrf2BodyTransformHistory,...
        ned2BodyTransformHistory,steeringAnglesHistory]=...
        matlabshared.satellitescenario.Gimbal.getPositionOrientationAndSteeringAngles(...
        mountingLocation,mountingAngles,parentItrf2BodyTransformHistory,parentPositionITRFHistory,...
        parentNed2BodyTransformHistory,targetPositionITRFHistory,needToSteer);

        simObj.Gimbals(gimbalIdx).PositionHistory=reshape(pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[])),3,[]);
        simObj.Gimbals(gimbalIdx).PositionITRFHistory=positionITRFHistory;
        simObj.Gimbals(gimbalIdx).LatitudeHistory=positionGeographicHistory(1,:);
        simObj.Gimbals(gimbalIdx).LongitudeHistory=positionGeographicHistory(2,:);
        simObj.Gimbals(gimbalIdx).AltitudeHistory=positionGeographicHistory(3,:);
        simObj.Gimbals(gimbalIdx).AttitudeHistory=attitudeHistory;
        simObj.Gimbals(gimbalIdx).GimbalAzimuthHistory=steeringAnglesHistory(1,:);
        simObj.Gimbals(gimbalIdx).GimbalElevationHistory=steeringAnglesHistory(2,:);
        simObj.Gimbals(gimbalIdx).Itrf2BodyTransformHistory=itrf2BodyTransformHistory;
        simObj.Gimbals(gimbalIdx).Ned2BodyTransformHistory=ned2BodyTransformHistory;
    end


    for sensorIdx=1:simObj.NumConicalSensors

        parentID=simObj.ConicalSensors(sensorIdx).ParentSimulatorID;
        parentType=simObj.ConicalSensors(sensorIdx).ParentType;


        conicalSensorParentIndex=simObj.SimIDMemo(parentID);
        switch parentType
        case 1
            parent=simObj.Satellites(conicalSensorParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
        case 2
            parent=simObj.GroundStations(conicalSensorParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
        otherwise
            parent=simObj.Gimbals(conicalSensorParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
        end

        mountingLocation=simObj.ConicalSensors(sensorIdx).MountingLocation;
        mountingAngles=simObj.ConicalSensors(sensorIdx).MountingAngles;
        [positionITRFHistory,positionGeographicHistory,attitudeHistory,itrf2BodyTransformHistory]=...
        matlabshared.satellitescenario.internal.AttachedAsset.getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransformHistory,...
        parentPositionITRFHistory,parentNed2BodyTransformHistory);

        simObj.ConicalSensors(sensorIdx).PositionHistory=reshape(pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[])),3,[]);
        simObj.ConicalSensors(sensorIdx).PositionITRFHistory=positionITRFHistory;
        simObj.ConicalSensors(sensorIdx).LatitudeHistory=positionGeographicHistory(1,:);
        simObj.ConicalSensors(sensorIdx).LongitudeHistory=positionGeographicHistory(2,:);
        simObj.ConicalSensors(sensorIdx).AltitudeHistory=positionGeographicHistory(3,:);
        simObj.ConicalSensors(sensorIdx).AttitudeHistory=attitudeHistory;
        simObj.ConicalSensors(sensorIdx).Itrf2BodyTransformHistory=itrf2BodyTransformHistory;
    end


    for txIdx=1:simObj.NumTransmitters

        parentID=simObj.Transmitters(txIdx).ParentSimulatorID;
        parentType=simObj.Transmitters(txIdx).ParentType;


        txParentIndex=simObj.SimIDMemo(parentID);
        switch parentType
        case 1
            parent=simObj.Satellites(txParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        case 2
            parent=simObj.GroundStations(txParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        otherwise
            parent=simObj.Gimbals(txParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        end

        mountingLocation=simObj.Transmitters(txIdx).MountingLocation;
        mountingAngles=simObj.Transmitters(txIdx).MountingAngles;
        [positionITRFHistory,positionGeographicHistory,...
        attitudeHistory,itrf2BodyTransformHistory]=...
        matlabshared.satellitescenario.internal.AttachedAsset.getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransformHistory,...
        parentPositionITRFHistory,parentNed2BodyTransformHistory);

        simObj.Transmitters(txIdx).PositionHistory=reshape(pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[])),3,[]);
        simObj.Transmitters(txIdx).PositionITRFHistory=positionITRFHistory;
        simObj.Transmitters(txIdx).LatitudeHistory=positionGeographicHistory(1,:);
        simObj.Transmitters(txIdx).LongitudeHistory=positionGeographicHistory(2,:);
        simObj.Transmitters(txIdx).AltitudeHistory=positionGeographicHistory(3,:);
        simObj.Transmitters(txIdx).AttitudeHistory=attitudeHistory;
        simObj.Transmitters(txIdx).Itrf2BodyTransformHistory=itrf2BodyTransformHistory;



        if coder.target('MATLAB')&&simObj.Transmitters(txIdx).AntennaType==2&&...
            simObj.Transmitters(txIdx).PointingMode~=5&&simObj.Transmitters(txIdx).PointingMode~=6
            switch simObj.Transmitters(txIdx).PointingMode
            case 1

                targetSimID=simObj.Transmitters(txIdx).PointingTargetID;
                txPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRFHistory=...
                simObj.Satellites(txPointingTargetIndex).PositionITRFHistory;
            case 2

                targetSimID=simObj.Transmitters(txIdx).PointingTargetID;
                txPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRFHistory=...
                simObj.GroundStations(txPointingTargetIndex).PositionITRFHistory;
            case 3


                targetPositionITRFHistory=...
                repmat(simObj.Transmitters(txIdx).PointingCoordinates,1,numTimeSamples);
            otherwise

                targetPositionITRFHistory=...
                matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [parentLatitudeHistory*pi/180;...
                parentLongitudeHistory*pi/180;...
                zeros(1,numTimeSamples)]);
            end


            relativePositionITRFHistory=targetPositionITRFHistory-positionITRFHistory;
            relativePositionBodyHistory=reshape(pagemtimes(itrf2BodyTransformHistory,reshape(relativePositionITRFHistory,3,1,[])),3,[]);


            x=relativePositionBodyHistory(1,:);
            y=relativePositionBodyHistory(2,:);
            z=relativePositionBodyHistory(3,:);
            r=vecnorm(relativePositionBodyHistory,2,1);
            el=asin(max(min(-(z./r),1),-1))*180/pi;
            az=wrapTo180(mod(atan2(y,x),2*pi)*180/pi);
            el(isnan(el))=0;
            az(isnan(az))=0;
            indexOutside180=(az>180)|(az<-180);
            az(indexOutside180)=mod(az(indexOutside180),360);
            indexGreaterThan180=az>180;
            az(indexGreaterThan180)=az(indexGreaterThan180)-360;

            simObj.Transmitters(txIdx).PointingDirectionHistory=[az;-el];
        else



            simObj.Transmitters(txIdx).PointingDirectionHistory=zeros(2,numTimeSamples);
        end
    end


    for rxIdx=1:simObj.NumReceivers

        parentID=simObj.Receivers(rxIdx).ParentSimulatorID;
        parentType=simObj.Receivers(rxIdx).ParentType;


        rxParentIndex=simObj.SimIDMemo(parentID);
        switch parentType
        case 1
            parent=simObj.Satellites(rxParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        case 2
            parent=simObj.GroundStations(rxParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        otherwise
            parent=simObj.Gimbals(rxParentIndex);
            parentItrf2BodyTransformHistory=parent.Itrf2BodyTransformHistory;
            parentPositionITRFHistory=parent.PositionITRFHistory;
            parentNed2BodyTransformHistory=parent.Ned2BodyTransformHistory;
            parentLatitudeHistory=parent.LatitudeHistory;
            parentLongitudeHistory=parent.LongitudeHistory;
        end


        mountingLocation=simObj.Receivers(rxIdx).MountingLocation;
        mountingAngles=simObj.Receivers(rxIdx).MountingAngles;
        [positionITRFHistory,positionGeographicHistory,...
        attitudeHistory,itrf2BodyTransformHistory]=...
        matlabshared.satellitescenario.internal.AttachedAsset.getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransformHistory,...
        parentPositionITRFHistory,parentNed2BodyTransformHistory);


        simObj.Receivers(rxIdx).PositionHistory=reshape(pagemtimes(itrf2gcrfTransforms,reshape(positionITRFHistory,3,1,[])),3,[]);
        simObj.Receivers(rxIdx).PositionITRFHistory=positionITRFHistory;
        simObj.Receivers(rxIdx).LatitudeHistory=positionGeographicHistory(1,:);
        simObj.Receivers(rxIdx).LongitudeHistory=positionGeographicHistory(2,:);
        simObj.Receivers(rxIdx).AltitudeHistory=positionGeographicHistory(3,:);
        simObj.Receivers(rxIdx).AttitudeHistory=attitudeHistory;
        simObj.Receivers(rxIdx).Itrf2BodyTransformHistory=itrf2BodyTransformHistory;



        if coder.target('MATLAB')&&simObj.Receivers(rxIdx).AntennaType==2&&...
            simObj.Receivers(rxIdx).PointingMode~=5&&simObj.Receivers(rxIdx).PointingMode~=6
            switch simObj.Receivers(rxIdx).PointingMode
            case 1

                targetSimID=simObj.Receivers(rxIdx).PointingTargetID;
                rxPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRFHistory=...
                simObj.Satellites(rxPointingTargetIndex).PositionITRFHistory;
            case 2

                targetSimID=simObj.Receivers(rxIdx).PointingTargetID;
                rxPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRFHistory=...
                simObj.GroundStations(rxPointingTargetIndex).PositionITRFHistory;
            case 3


                targetPositionITRFHistory=...
                repmat(simObj.Receivers(rxIdx).PointingCoordinates,1,numTimeSamples);
            otherwise

                targetPositionITRFHistory=...
                matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [parentLatitudeHistory*pi/180;...
                parentLongitudeHistory*pi/180;...
                zeros(1,numTimeSamples)]);
            end


            relativePositionITRFHistory=targetPositionITRFHistory-positionITRFHistory;
            relativePositionBodyHistory=reshape(pagemtimes(itrf2BodyTransformHistory,reshape(relativePositionITRFHistory,3,1,[])),3,[]);


            x=relativePositionBodyHistory(1,:);
            y=relativePositionBodyHistory(2,:);
            z=relativePositionBodyHistory(3,:);
            r=vecnorm(relativePositionBodyHistory,2,1);
            el=asin(max(min(-(z./r),1),-1))*180/pi;
            az=mod(atan2(y,x),2*pi)*180/pi;
            el(isnan(el))=0;
            az(isnan(az))=0;
            indexOutside180=(az>180)|(az<-180);
            az(indexOutside180)=mod(az(indexOutside180),360);
            indexGreaterThan180=az>180;
            az(indexGreaterThan180)=az(indexGreaterThan180)-360;

            simObj.Receivers(rxIdx).PointingDirectionHistory=[az;-el];
        else



            simObj.Receivers(rxIdx).PointingDirectionHistory=zeros(2,numTimeSamples);
        end
    end


    simIDMemo=simObj.SimIDMemo;
    numSatellites=simObj.NumSatellites;
    typ=cell(1,numSatellites);
    grandParentType=cell(1,numSatellites);
    grandParentSimulatorID=cell(1,numSatellites);
    positionITRF=cell(1,numSatellites);
    altitude=cell(1,numSatellites);
    itrf2bodyTransform=cell(1,numSatellites);
    for idx=1:numSatellites
        typ{idx}=simObj.Satellites(idx).Type;
        grandParentType{idx}=simObj.Satellites(idx).GrandParentType;
        grandParentSimulatorID{idx}=simObj.Satellites(idx).GrandParentSimulatorID;
        positionITRF{idx}=simObj.Satellites(idx).PositionITRFHistory;
        altitude{idx}=simObj.Satellites(idx).AltitudeHistory;
        itrf2bodyTransform{idx}=simObj.Satellites(idx).Itrf2BodyTransformHistory;
    end
    sats=struct("Type",typ,...
    "GrandParentType",grandParentType,...
    "GrandParentSimulatorID",grandParentSimulatorID,...
    "PositionITRF",positionITRF,...
    "Altitude",altitude,...
    "Itrf2BodyTransform",itrf2bodyTransform);

    numGroundStations=simObj.NumGroundStations;
    typ=cell(1,numGroundStations);
    grandParentType=cell(1,numGroundStations);
    grandParentSimulatorID=cell(1,numGroundStations);
    positionITRF=cell(1,numGroundStations);
    altitude=cell(1,numGroundStations);
    itrf2bodyTransform=cell(1,numGroundStations);
    minElevationAngle=cell(1,numGroundStations);
    for idx=1:numGroundStations
        typ{idx}=simObj.GroundStations(idx).Type;
        grandParentType{idx}=simObj.GroundStations(idx).GrandParentType;
        grandParentSimulatorID{idx}=simObj.GroundStations(idx).GrandParentSimulatorID;
        positionITRF{idx}=simObj.GroundStations(idx).PositionITRFHistory;
        altitude{idx}=simObj.GroundStations(idx).AltitudeHistory;
        itrf2bodyTransform{idx}=simObj.GroundStations(idx).Itrf2BodyTransformHistory;
        minElevationAngle{idx}=simObj.GroundStations(idx).MinElevationAngle;
    end
    gss=struct("Type",typ,...
    "GrandParentType",grandParentType,...
    "GrandParentSimulatorID",grandParentSimulatorID,...
    "PositionITRF",positionITRF,...
    "Altitude",altitude,...
    "Itrf2BodyTransform",itrf2bodyTransform,...
    "MinElevationAngle",minElevationAngle);

    numConicalSensors=simObj.NumConicalSensors;
    typ=cell(1,numConicalSensors);
    grandParentType=cell(1,numConicalSensors);
    grandParentSimulatorID=cell(1,numConicalSensors);
    positionITRF=cell(1,numConicalSensors);
    altitude=cell(1,numConicalSensors);
    itrf2bodyTransform=cell(1,numConicalSensors);
    maxViewAngle=cell(1,numConicalSensors);
    for idx=1:numConicalSensors
        typ{idx}=simObj.ConicalSensors(idx).Type;
        grandParentType{idx}=simObj.ConicalSensors(idx).GrandParentType;
        grandParentSimulatorID{idx}=simObj.ConicalSensors(idx).GrandParentSimulatorID;
        positionITRF{idx}=simObj.ConicalSensors(idx).PositionITRFHistory;
        altitude{idx}=simObj.ConicalSensors(idx).AltitudeHistory;
        itrf2bodyTransform{idx}=simObj.ConicalSensors(idx).Itrf2BodyTransformHistory;
        maxViewAngle{idx}=simObj.ConicalSensors(idx).MaxViewAngle;
    end
    sensors=struct("Type",typ,...
    "GrandParentType",grandParentType,...
    "GrandParentSimulatorID",grandParentSimulatorID,...
    "PositionITRF",positionITRF,...
    "Altitude",altitude,...
    "Itrf2BodyTransform",itrf2bodyTransform,...
    "MaxViewAngle",maxViewAngle);


    dummySatStruct=matlabshared.satellitescenario.internal.Simulator.getDummySatStructForAccessOrLink;
    dummyGsStruct=matlabshared.satellitescenario.internal.Simulator.getDummyGsStructForAccessOrLink;
    dummySensorStruct=matlabshared.satellitescenario.internal.Simulator.getDummySensorStructForAccess;
    timeHistoryYear=timeHistory.Year;
    timeHistoryMonth=timeHistory.Month;
    timeHistoryDay=timeHistory.Day;
    timeHistoryHour=timeHistory.Hour;
    timeHistoryMinute=timeHistory.Minute;
    timeHistorySecond=timeHistory.Second;
    timeHistoryArray=[timeHistoryYear',timeHistoryMonth',timeHistoryDay',timeHistoryHour',timeHistoryMinute',timeHistorySecond'];
    for acIdx=1:simObj.NumAccesses






        satF=dummySatStruct;
        gsF=dummyGsStruct;
        sensorF=dummySensorStruct;


        simIDMemoF=zeros(1,numel(simIDMemo));


        sequence=simObj.Accesses(acIdx).Sequence;
        nodeType=simObj.Accesses(acIdx).NodeType;



        nodeIndexF=zeros(1,numel(sequence));

        for idx2=1:numel(sequence)


            nodeIndex=simIDMemo(sequence(idx2));



            if simIDMemoF(sequence(idx2))==0
                switch nodeType(idx2)
                case 1

                    satF=[satF,sats(nodeIndex)];


                    nodeIndexF(idx2)=numel(satF);


                    simIDMemoF(sequence(idx2))=numel(satF);
                case 2

                    gsF=[gsF,gss(nodeIndex)];


                    nodeIndexF(idx2)=numel(gsF);


                    simIDMemoF(sequence(idx2))=numel(gsF);
                otherwise

                    sensorF=[sensorF,sensors(nodeIndex)];


                    nodeIndexF(idx2)=numel(sensorF);


                    simIDMemoF(sequence(idx2))=numel(sensorF);







                    grandParentType=sensors(nodeIndex).GrandParentType;
                    grandParentSimulatorID=sensors(nodeIndex).GrandParentSimulatorID;



                    grandParentIndex=simIDMemo(grandParentSimulatorID);

                    switch grandParentType
                    case 1



                        satF=[satF,sats(grandParentIndex)];
                        simIDMemoF(grandParentSimulatorID)=numel(satF);
                    otherwise



                        gsF=[gsF,gss(grandParentIndex)];
                        simIDMemoF(grandParentSimulatorID)=numel(gsF);
                    end
                end
            else


                nodeIndexF(idx2)=simIDMemoF(sequence(idx2));
            end
        end




        [statusHistory,intervals,numIntervals]=...
        matlabshared.satellitescenario.Access.getStatus(...
        sequence,nodeType,nodeIndexF,satF,gsF,sensorF,simIDMemoF,timeHistoryArray,numTimeSamples);
        simObj.Accesses(acIdx).StatusHistory=statusHistory;
        simObj.Accesses(acIdx).Intervals=intervals;
        simObj.Accesses(acIdx).NumIntervals=numIntervals;
    end


    numTransmitters=simObj.NumTransmitters;
    typ=cell(1,numTransmitters);
    grandParentType=cell(1,numTransmitters);
    grandParentSimulatorID=cell(1,numTransmitters);
    positionITRF=cell(1,numTransmitters);
    altitude=cell(1,numTransmitters);
    itrf2bodyTransform=cell(1,numTransmitters);
    frequency=cell(1,numTransmitters);
    dishDiameter=cell(1,numTransmitters);
    apertureEfficiency=cell(1,numTransmitters);
    antenna=cell(1,numTransmitters);
    antennaPattern=cell(1,numTransmitters);
    antennaType=cell(1,numTransmitters);
    antennaPatternFrequency=cell(1,numTransmitters);
    power=cell(1,numTransmitters);
    bitRate=cell(1,numTransmitters);
    systemLoss=cell(1,numTransmitters);
    pointingMode=cell(1,numTransmitters);
    phasedArrayWeights=cell(1,numTransmitters);
    phasedArrayWeightsDefault=cell(1,numTransmitters);
    pointingDirection=cell(1,numTransmitters);
    for idx=1:numTransmitters
        typ{idx}=simObj.Transmitters(idx).Type;
        grandParentType{idx}=simObj.Transmitters(idx).GrandParentType;
        grandParentSimulatorID{idx}=simObj.Transmitters(idx).GrandParentSimulatorID;
        positionITRF{idx}=simObj.Transmitters(idx).PositionITRFHistory;
        altitude{idx}=simObj.Transmitters(idx).AltitudeHistory;
        itrf2bodyTransform{idx}=simObj.Transmitters(idx).Itrf2BodyTransformHistory;
        frequency{idx}=simObj.Transmitters(idx).Frequency;
        dishDiameter{idx}=simObj.Transmitters(idx).DishDiameter;
        apertureEfficiency{idx}=simObj.Transmitters(idx).ApertureEfficiency;
        antennaPattern{idx}=simObj.Transmitters(idx).AntennaPattern;
        antennaType{idx}=simObj.Transmitters(idx).AntennaType;
        antennaPatternFrequency{idx}=simObj.Transmitters(idx).AntennaPatternFrequency;
        power{idx}=simObj.Transmitters(idx).Power;
        bitRate{idx}=simObj.Transmitters(idx).BitRate;
        systemLoss{idx}=simObj.Transmitters(idx).SystemLoss;
        pointingMode{idx}=simObj.Transmitters(idx).PointingMode;
        pointingDirection{idx}=simObj.Transmitters(idx).PointingDirectionHistory;

        if~isempty(coder.target)||simObj.Transmitters(idx).AntennaType~=2
            antenna{idx}=0;
            phasedArrayWeights{idx}=0;
            phasedArrayWeightsDefault{idx}=0;
        else
            antenna{idx}=simObj.Transmitters(idx).Antenna;
            phasedArrayWeights{idx}=simObj.Transmitters(idx).PhasedArrayWeights;
            phasedArrayWeightsDefault{idx}=simObj.Transmitters(idx).PhasedArrayWeightsDefault;
        end
    end

    txs=struct("Type",typ,...
    "GrandParentType",grandParentType,...
    "GrandParentSimulatorID",grandParentSimulatorID,...
    "PositionITRF",positionITRF,...
    "Altitude",altitude,...
    "Itrf2BodyTransform",itrf2bodyTransform,...
    "Frequency",frequency,...
    "DishDiameter",dishDiameter,...
    "ApertureEfficiency",apertureEfficiency,...
    "Antenna",antenna,...
    "AntennaPattern",antennaPattern,...
    "AntennaType",antennaType,...
    "AntennaPatternFrequency",antennaPatternFrequency,...
    "Power",power,...
    "BitRate",bitRate,...
    "SystemLoss",systemLoss,...
    "PointingMode",pointingMode,...
    "PhasedArrayWeights",phasedArrayWeights,...
    "PhasedArrayWeightsDefault",phasedArrayWeightsDefault,...
    "PointingDirection",pointingDirection);

    numReceivers=simObj.NumReceivers;
    typ=cell(1,numReceivers);
    grandParentType=cell(1,numReceivers);
    grandParentSimulatorID=cell(1,numReceivers);
    positionITRF=cell(1,numReceivers);
    altitude=cell(1,numReceivers);
    itrf2bodyTransform=cell(1,numReceivers);
    dishDiameter=cell(1,numReceivers);
    apertureEfficiency=cell(1,numReceivers);
    antenna=cell(1,numReceivers);
    antennaPattern=cell(1,numReceivers);
    antennaType=cell(1,numReceivers);
    antennaPatternFrequency=cell(1,numReceivers);
    systemLoss=cell(1,numReceivers);
    preReceiverLoss=cell(1,numReceivers);
    gainToNoiseTemperatureRatio=cell(1,numReceivers);
    requiredEbNo=cell(1,numReceivers);
    pointingMode=cell(1,numReceivers);
    phasedArrayWeights=cell(1,numReceivers);
    phasedArrayWeightsDefault=cell(1,numReceivers);
    pointingDirection=cell(1,numReceivers);
    for idx=1:numReceivers
        typ{idx}=simObj.Receivers(idx).Type;
        grandParentType{idx}=simObj.Receivers(idx).GrandParentType;
        grandParentSimulatorID{idx}=simObj.Receivers(idx).GrandParentSimulatorID;
        positionITRF{idx}=simObj.Receivers(idx).PositionITRFHistory;
        altitude{idx}=simObj.Receivers(idx).AltitudeHistory;
        itrf2bodyTransform{idx}=simObj.Receivers(idx).Itrf2BodyTransformHistory;
        dishDiameter{idx}=simObj.Receivers(idx).DishDiameter;
        apertureEfficiency{idx}=simObj.Receivers(idx).ApertureEfficiency;
        antennaPattern{idx}=simObj.Receivers(idx).AntennaPattern;
        antennaType{idx}=simObj.Receivers(idx).AntennaType;
        antennaPatternFrequency{idx}=simObj.Receivers(idx).AntennaPatternFrequency;
        systemLoss{idx}=simObj.Receivers(idx).SystemLoss;
        preReceiverLoss{idx}=simObj.Receivers(idx).PreReceiverLoss;
        gainToNoiseTemperatureRatio{idx}=simObj.Receivers(idx).GainToNoiseTemperatureRatio;
        requiredEbNo{idx}=simObj.Receivers(idx).RequiredEbNo;
        pointingMode{idx}=simObj.Receivers(idx).PointingMode;
        pointingDirection{idx}=simObj.Receivers(idx).PointingDirectionHistory;

        if~isempty(coder.target)||simObj.Receivers(idx).AntennaType~=2
            antenna{idx}=0;
            phasedArrayWeights{idx}=0;
            phasedArrayWeightsDefault{idx}=0;
        else
            antenna{idx}=simObj.Receivers(idx).Antenna;
            phasedArrayWeights{idx}=simObj.Receivers(idx).PhasedArrayWeights;
            phasedArrayWeightsDefault{idx}=simObj.Receivers(idx).PhasedArrayWeightsDefault;
        end
    end

    rxs=(struct("Type",typ,...
    "GrandParentType",grandParentType,...
    "GrandParentSimulatorID",grandParentSimulatorID,...
    "PositionITRF",positionITRF,...
    "Altitude",altitude,...
    "Itrf2BodyTransform",itrf2bodyTransform,...
    "DishDiameter",dishDiameter,...
    "ApertureEfficiency",apertureEfficiency,...
    "Antenna",antenna,...
    "AntennaPattern",antennaPattern,...
    "AntennaType",antennaType,...
    "AntennaPatternFrequency",antennaPatternFrequency,...
    "SystemLoss",systemLoss,...
    "PreReceiverLoss",preReceiverLoss,...
    "GainToNoiseTemperatureRatio",gainToNoiseTemperatureRatio,...
    "RequiredEbNo",requiredEbNo,...
    "PointingMode",pointingMode,...
    "PhasedArrayWeights",phasedArrayWeights,...
    "PhasedArrayWeightsDefault",phasedArrayWeightsDefault,...
    "PointingDirection",pointingDirection));


    dummyTxStruct=matlabshared.satellitescenario.internal.Simulator.getDummyTxStructForLink;
    dummyRxStruct=matlabshared.satellitescenario.internal.Simulator.getDummyRxStructForLink;
    for lnkIdx=1:simObj.NumLinks






        satF=dummySatStruct;
        gsF=dummyGsStruct;
        txF=dummyTxStruct;
        rxF=dummyRxStruct;


        simIDMemoF=zeros(1,numel(simIDMemo));


        sequence=simObj.Links(lnkIdx).Sequence;
        nodeType=simObj.Links(lnkIdx).NodeType;



        nodeIndexF=zeros(1,numel(sequence));
        nodeIndex=zeros(1,numel(sequence));

        for idx2=1:numel(sequence)


            nodeIndex(idx2)=simIDMemo(sequence(idx2));



            if simIDMemoF(sequence(idx2))==0
                switch nodeType(idx2)
                case 5

                    txF=[txF,txs(nodeIndex(idx2))];


                    nodeIndexF(idx2)=numel(txF);


                    grandParentType=txs(nodeIndex(idx2)).GrandParentType;
                    grandParentSimulatorID=txs(nodeIndex(idx2)).GrandParentSimulatorID;


                    simIDMemoF(sequence(idx2))=numel(txF);
                otherwise

                    rxF=[rxF,rxs(nodeIndex(idx2))];


                    nodeIndexF(idx2)=numel(rxF);


                    grandParentType=rxs(nodeIndex(idx2)).GrandParentType;
                    grandParentSimulatorID=rxs(nodeIndex(idx2)).GrandParentSimulatorID;


                    simIDMemoF(sequence(idx2))=numel(rxF);
                end




                if simIDMemoF(grandParentSimulatorID)==0


                    grandParentIndex=simObj.SimIDMemo(grandParentSimulatorID);

                    switch grandParentType
                    case 1


                        satF=[satF,sats(grandParentIndex)];
                        simIDMemoF(grandParentSimulatorID)=numel(satF);
                    otherwise



                        gsF=[gsF,gss(grandParentIndex)];
                        simIDMemoF(grandParentSimulatorID)=numel(gsF);
                    end
                end
            else


                nodeIndexF(idx2)=simIDMemoF(sequence(idx2));
            end
        end




        antennaType=0;
        if coder.target('MATLAB')
            for nodeIdx=1:numel(sequence)
                switch nodeType(nodeIdx)
                case 5
                    antennaType=max(antennaType,simObj.Transmitters(nodeIndex(nodeIdx)).AntennaType);
                otherwise
                    antennaType=max(antennaType,simObj.Receivers(nodeIndex(nodeIdx)).AntennaType);
                end

                if antennaType==2
                    break
                end
            end
        end



        [statHistory,ebnoHistory,ripHistory,rxInputPowerHistory,intervals,numIntervals]=...
        satcom.satellitescenario.Link.getStatus(sequence,...
        nodeType,nodeIndexF,satF,gsF,txF,rxF,simIDMemoF,...
        timeHistoryArray,antennaType,numTimeSamples,simObj.UpdateTaper);



        simObj.Links(lnkIdx).StatusHistory=statHistory;
        simObj.Links(lnkIdx).EbNoHistory=ebnoHistory;
        simObj.Links(lnkIdx).ReceivedIsotropicPowerHistory=ripHistory;
        simObj.Links(lnkIdx).PowerAtReceiverInputHistory=rxInputPowerHistory;
        simObj.Links(lnkIdx).Intervals=intervals;
        simObj.Links(lnkIdx).NumIntervals=numIntervals;
    end

    if coder.target('MATLAB')


        for fovIdx=1:simObj.NumFieldsOfView


            sourceID=simObj.FieldsOfView(fovIdx).SourceID;


            fovSourceIndex=simObj.SimIDMemo(sourceID);

            source=simObj.ConicalSensors(fovSourceIndex);

            positionHistory=source.PositionHistory;
            latitudeHistory=source.LatitudeHistory;
            longitudeHistory=source.LongitudeHistory;
            altitudeHistory=source.AltitudeHistory;
            attitudeHistory=source.AttitudeHistory;
            maxViewAngle=source.MaxViewAngle;



            numContourPoints=simObj.FieldsOfView(fovIdx).NumContourPoints;


            [contourHistory,statusHistory,intervals,numIntervals]=...
            matlabshared.satellitescenario.FieldOfView.getContour(...
            positionHistory,latitudeHistory,longitudeHistory,...
            altitudeHistory,attitudeHistory,maxViewAngle,...
            itrf2gcrfTransforms,numContourPoints,timeHistoryArray,...
            numTimeSamples);

            simObj.FieldsOfView(fovIdx).StatusHistory=statusHistory;
            simObj.FieldsOfView(fovIdx).ContourHistory=contourHistory;
            simObj.FieldsOfView(fovIdx).Intervals=intervals;
            simObj.FieldsOfView(fovIdx).NumIntervals=numIntervals;
        end
    end



    simObj.NeedToSimulate=false;
end

