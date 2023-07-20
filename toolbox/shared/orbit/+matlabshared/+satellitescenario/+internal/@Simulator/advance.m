function advance(simObj,time)%#codegen




    coder.allowpcode('plain');


    if simObj.NeedToMemoizeSimID
        memoizeSimID(simObj);
    end

    if coder.target('MATLAB')&&(simObj.SimulationMode==2||...
        (simObj.SimulationMode==1&&simObj.SimulationStatus==0))

        updateAntennaPatterns(simObj);
    end


    simObj.Time=time;


    itrf2gcrfTransform=matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time);


    omega=[0;0;matlabshared.orbit.internal.OrbitPropagationModel.EarthAngularVelocity];


    for idx=1:simObj.NumSatellites

        propagatorType=simObj.Satellites(idx).PropagatorType;



        switch propagatorType
        case 1



            [positionPropagator,velocityPropagator]=step(simObj.Satellites(idx).PropagatorTBK,time);



            position=positionPropagator;
            velocity=velocityPropagator;


            itrfPosition=itrf2gcrfTransform'*position;
            itrfVelocity=(itrf2gcrfTransform'*velocity)-cross(omega,itrfPosition);
        case 2






            [positionPropagator,velocityPropagator]=step(simObj.Satellites(idx).PropagatorSGP4,time);


            itrfPosition=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positionPropagator,time);
            itrfInertialVelocity=matlabshared.orbit.internal.Transforms.teme2itrf(...
            velocityPropagator,time);
            itrfVelocity=itrfInertialVelocity-cross(omega,itrfPosition);


            position=itrf2gcrfTransform*itrfPosition;
            velocity=itrf2gcrfTransform*itrfInertialVelocity;
        case 3






            [positionPropagator,velocityPropagator]=step(simObj.Satellites(idx).PropagatorSDP4,time);


            itrfPosition=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positionPropagator,time);
            itrfInertialVelocity=matlabshared.orbit.internal.Transforms.teme2itrf(...
            velocityPropagator,time);
            itrfVelocity=itrfInertialVelocity-cross(omega,itrfPosition);


            position=itrf2gcrfTransform*itrfPosition;
            velocity=itrf2gcrfTransform*itrfInertialVelocity;
        case 4



            [positionPropagator,velocityPropagator]=step(simObj.Satellites(idx).PropagatorEphemeris,time);



            position=positionPropagator;
            velocity=velocityPropagator;


            itrfPosition=itrf2gcrfTransform'*position;
            itrfVelocity=(itrf2gcrfTransform'*velocity)-cross(omega,itrfPosition);
        otherwise



            [itrfPosition,itrfVelocity]=step(simObj.Satellites(idx).PropagatorGPS,time);


            itrfInertialVelocity=itrfVelocity+cross(omega,itrfPosition);



            position=itrf2gcrfTransform*itrfPosition;
            velocity=itrf2gcrfTransform*itrfInertialVelocity;
        end


        simObj.Satellites(idx).Position=position;
        simObj.Satellites(idx).Velocity=velocity;
        simObj.Satellites(idx).PositionITRF=itrfPosition;
        simObj.Satellites(idx).VelocityITRF=itrfVelocity;


        geographicPosition=...
        matlabshared.orbit.internal.Transforms.itrf2geographic(itrfPosition);
        simObj.Satellites(idx).Latitude=geographicPosition(1)*180/pi;
        simObj.Satellites(idx).Longitude=geographicPosition(2)*180/pi;


        if geographicPosition(3)<0
            if propagatorType==4

                msg='shared_orbit:orbitPropagator:EphemerisSimulationEarthCollisionTrajectory';
                if coder.target('MATLAB')
                    error(message(msg,"satellite with ID "+simObj.Satellites(idx).ID));
                else
                    coder.internal.error(msg,"satellite with ID "+simObj.Satellites(idx).ID);
                end
            else
                msg='shared_orbit:orbitPropagator:SatelliteScenarioSimulationEarthCollisionTrajectory';
                if coder.target('MATLAB')
                    error(message(msg,"satellite with ID "+simObj.Satellites(idx).ID));
                else
                    coder.internal.error(msg,"satellite with ID "+simObj.Satellites(idx).ID);
                end
            end
        end


        simObj.Satellites(idx).Altitude=geographicPosition(3);
    end


    for idx=1:simObj.NumSatellites

        satPositionITRF=simObj.Satellites(idx).PositionITRF;
        satPositionGeographic=[simObj.Satellites(idx).Latitude*pi/180;...
        simObj.Satellites(idx).Longitude*pi/180;...
        simObj.Satellites(idx).Altitude];
        satInertialVelocityITRF=...
        itrf2gcrfTransform'*simObj.Satellites(idx).Velocity;
        roll=0;pitch=0;yaw=0;
        itrf2BodyTransform=eye(3);
        ned2BodyTransform=eye(3);


        switch simObj.Satellites(idx).PointingMode
        case 1



            targetSimID=simObj.Satellites(idx).PointingTargetID;


            targetIndex=find([simObj.Satellites.ID]==targetSimID,1);


            targetPositionITRF=...
            simObj.Satellites(targetIndex).PositionITRF;
        case 2



            targetSimID=simObj.Satellites(idx).PointingTargetID;


            targetIndex=...
            find([simObj.GroundStations.ID]==targetSimID,1);


            targetPositionITRF=...
            simObj.GroundStations(targetIndex).PositionITRF;
        case 3

            targetPositionITRF=...
            simObj.Satellites(idx).PointingCoordinates;
        case 5

            customAttitude=simObj.Satellites(idx).CustomAttitude;
            useNadir=false;
            dcmCoordFrame2body=eye(3);
            coordFrame2body=[1,0,0,0];
            if~isempty(customAttitude)
                if any(customAttitude.Properties.RowTimes==time)

                    matchedTime=customAttitude.Properties.RowTimes(customAttitude.Properties.RowTimes==time);
                    coordFrame2body=customAttitude(matchedTime,:).Variables;
                    if simObj.Satellites(idx).CustomAttitudeFormat=="euler"
                        coordFrame2body=...
                        matlabshared.satellitescenario.internal.Simulator.zyx2quat(deg2rad(coordFrame2body));
                    end
                    dcmCoordFrame2body=Aero.internal.shared.quaternion.toDCM(coordFrame2body);
                else



                    idxBeforeTime=customAttitude.Properties.RowTimes<=time;
                    idxAfterTime=customAttitude.Properties.RowTimes>=time;

                    if(~any(idxBeforeTime)||~any(idxAfterTime))&&...
                        (simObj.Satellites(idx).CustomAttitudeDefault~="fixed")


                        useNadir=true;
                    else
                        if~any(idxBeforeTime)
                            lowerBound=customAttitude.Properties.RowTimes(1);
                        else
                            lowerBound=max(customAttitude.Properties.RowTimes(idxBeforeTime));
                        end

                        if~any(idxAfterTime)
                            upperBound=customAttitude.Properties.RowTimes(end);
                        else
                            upperBound=min(customAttitude.Properties.RowTimes(idxAfterTime));
                        end

                        if lowerBound==upperBound
                            if~isempty(lowerBound)
                                coordFrame2body=customAttitude(lowerBound,:).Variables;
                                if simObj.Satellites(idx).CustomAttitudeFormat=="euler"
                                    coordFrame2body=...
                                    matlabshared.satellitescenario.internal.Simulator.zyx2quat(deg2rad(coordFrame2body));
                                end
                            end
                        else


                            interpFrac=(time-lowerBound)./(upperBound-lowerBound);

                            quatBounds=zeros(2,4);
                            if simObj.Satellites(idx).CustomAttitudeFormat=="euler"
                                quatBounds=...
                                matlabshared.satellitescenario.internal.Simulator.zyx2quat(...
                                deg2rad(customAttitude([lowerBound,upperBound],:).Variables));
                            else
                                quatBounds(1,:)=customAttitude(lowerBound,:).Variables;
                                quatBounds(2,:)=customAttitude(upperBound,:).Variables;
                            end
                            coordFrame2body=Aero.internal.shared.quaternion.interp(...
                            quatBounds(1,:),quatBounds(2,:),interpFrac);
                        end

                        dcmCoordFrame2body=Aero.internal.shared.quaternion.toDCM(coordFrame2body);
                    end
                end
            end

            if useNadir
                targetPositionGeographic=...
                [simObj.Satellites(idx).Latitude;...
                simObj.Satellites(idx).Longitude;...
                0];
                targetPositionITRF=...
                matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [targetPositionGeographic(1)*pi/180;...
                targetPositionGeographic(2)*pi/180;...
                targetPositionGeographic(3)]);
                [roll,pitch,yaw,ned2BodyTransform,itrf2BodyTransform]=...
                matlabshared.satellitescenario.Satellite.getAttitude(satPositionITRF,...
                satPositionGeographic,satInertialVelocityITRF,...
                targetPositionITRF);
            else
                targetPositionITRF=zeros(3,1);
                switch simObj.Satellites(idx).CustomAttitudeCoordFrame
                case "inertial"
                    gcrf2body=dcmCoordFrame2body;
                    itrf2gcrf=matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time);
                    ned2itrf=matlabshared.orbit.internal.Transforms.itrf2nedTransform(satPositionGeographic)';
                    itrf2BodyTransform=gcrf2body*itrf2gcrf;
                    ned2BodyTransform=itrf2BodyTransform*ned2itrf;
                case "ecef"
                    itrf2BodyTransform=dcmCoordFrame2body;
                    ned2itrf=matlabshared.orbit.internal.Transforms.itrf2nedTransform(satPositionGeographic)';
                    ned2BodyTransform=itrf2BodyTransform*ned2itrf;
                otherwise

                    ned2BodyTransform=dcmCoordFrame2body;
                    itrf2ned=matlabshared.orbit.internal.Transforms.itrf2nedTransform(satPositionGeographic);
                    itrf2BodyTransform=ned2BodyTransform*itrf2ned;

                end


                pitch=-asind(max(min(ned2BodyTransform(1,3),1),-1));
                tol=1e-6;
                if abs(pitch)>(90-tol)
                    roll=0;
                    yaw=atan2d(-ned2BodyTransform(2,1),ned2BodyTransform(2,2));
                else
                    roll=atan2d(ned2BodyTransform(2,3),ned2BodyTransform(3,3));
                    yaw=atan2d(ned2BodyTransform(1,2),ned2BodyTransform(1,1));
                end
            end
        otherwise


            targetPositionGeographic=...
            [simObj.Satellites(idx).Latitude;...
            simObj.Satellites(idx).Longitude;...
            0];
            targetPositionITRF=...
            matlabshared.orbit.internal.Transforms.geographic2itrf(...
            [targetPositionGeographic(1)*pi/180;...
            targetPositionGeographic(2)*pi/180;...
            targetPositionGeographic(3)]);
        end


        if simObj.Satellites(idx).PointingMode~=5

            [roll,pitch,yaw,ned2BodyTransform,itrf2BodyTransform]=...
            matlabshared.satellitescenario.Satellite.getAttitude(satPositionITRF,...
            satPositionGeographic,satInertialVelocityITRF,...
            targetPositionITRF);
        end


        simObj.Satellites(idx).Attitude=[roll;pitch;yaw];
        simObj.Satellites(idx).Itrf2BodyTransform=itrf2BodyTransform;
        simObj.Satellites(idx).Ned2BodyTransform=ned2BodyTransform;
    end


    for idx=1:simObj.NumGroundStations
        positionITRF=simObj.GroundStations(idx).PositionITRF;
        position=itrf2gcrfTransform*positionITRF;
        inertialVelocityITRF=cross(omega,positionITRF);
        velocity=itrf2gcrfTransform*inertialVelocityITRF;
        simObj.GroundStations(idx).Position=position;
        simObj.GroundStations(idx).Velocity=velocity;
    end


    for idx=1:simObj.NumGimbals

        parentID=simObj.Gimbals(idx).ParentSimulatorID;
        parentType=simObj.Gimbals(idx).ParentType;


        switch parentType
        case 1
            parentIndex=find([simObj.Satellites.ID]==parentID,1);
            satParent=simObj.Satellites(parentIndex);
            parentItrf2BodyTransform=satParent.Itrf2BodyTransform;
            parentPositionITRF=satParent.PositionITRF;
            parentNed2BodyTransform=satParent.Ned2BodyTransform;
            parentLatitude=satParent.Latitude;
            parentLongitude=satParent.Longitude;
            parentVelocity=satParent.Velocity;
        otherwise
            parentIndex=find([simObj.GroundStations.ID]==parentID,1);
            gsParent=simObj.GroundStations(parentIndex);
            parentItrf2BodyTransform=gsParent.Itrf2BodyTransform;
            parentPositionITRF=gsParent.PositionITRF;
            parentNed2BodyTransform=gsParent.Ned2BodyTransform;
            parentLatitude=gsParent.Latitude;
            parentLongitude=gsParent.Longitude;
            parentVelocity=gsParent.Velocity;
        end


        needToSteer=1;
        switch simObj.Gimbals(idx).PointingMode
        case 1



            targetSimID=simObj.Gimbals(idx).PointingTargetID;


            targetIndex=find([simObj.Satellites.ID]==targetSimID,1);


            targetPositionITRF=...
            simObj.Satellites(targetIndex).PositionITRF;
        case 2



            targetSimID=simObj.Gimbals(idx).PointingTargetID;


            targetIndex=...
            find([simObj.GroundStations.ID]==targetSimID,1);


            targetPositionITRF=...
            simObj.GroundStations(targetIndex).PositionITRF;
        case 3

            targetPositionITRF=...
            simObj.Gimbals(idx).PointingCoordinates;
        case 4


            targetPositionGeographic=...
            [parentLatitude;...
            parentLongitude;...
            0];
            targetPositionITRF=...
            matlabshared.orbit.internal.Transforms.geographic2itrf(...
            [targetPositionGeographic(1)*pi/180;...
            targetPositionGeographic(2)*pi/180;...
            targetPositionGeographic(3)]);
        case 6
            customAngles=simObj.Gimbals(idx).CustomAngles;
            needToSteer=0;
            targetPositionITRF=[0;0;0];

            if~isempty(customAngles)
                if any(customAngles.Properties.RowTimes==time)

                    matchedTime=customAngles.Properties.RowTimes(customAngles.Properties.RowTimes==time);
                    targetPositionITRF=deg2rad([customAngles(matchedTime,:).Variables,0]');
                    needToSteer=-1;
                else
                    lowerBound=max(customAngles.Properties.RowTimes(customAngles.Properties.RowTimes<=time));
                    upperBound=min(customAngles.Properties.RowTimes(customAngles.Properties.RowTimes>=time));
                    if(isempty(lowerBound)||isempty(upperBound))


                    else
                        needToSteer=-1;

                        azEl=deg2rad([customAngles.Variables,zeros(height(customAngles),1)]);
                        azEl(azEl(:,2)==0,2)=eps;
                        z=cos(azEl(:,2));
                        azEl(azEl(:,2)<0,1)=azEl(azEl(:,2)<0,1)+pi;
                        x=cos(azEl(:,1));
                        y=sin(azEl(:,1));

                        [~,locCartTT]=...
                        matlabshared.orbit.internal.Ephemeris.extract(...
                        timetable(customAngles.Properties.RowTimes,[x,y,z]),time,"makima",nan);

                        xyz=locCartTT.Variables;
                        azEl(:,2)=acos(max(min(xyz(:,3),1),-1));
                        azEl(:,1)=atan2(xyz(:,2),xyz(:,1));
                        targetPositionITRF=azEl';
                    end
                end
            end
        otherwise

            needToSteer=0;
            targetPositionITRF=[0;0;0];
        end


        mountingLocation=simObj.Gimbals(idx).MountingLocation;
        mountingAngles=simObj.Gimbals(idx).MountingAngles;
        [positionITRF,positionGeographic,attitude,itrf2BodyTransform,ned2BodyTransform,steeringAngles]=...
        matlabshared.satellitescenario.Gimbal.getPositionOrientationAndSteeringAngles(...
        mountingLocation,mountingAngles,parentItrf2BodyTransform,parentPositionITRF,...
        parentNed2BodyTransform,targetPositionITRF,needToSteer);


        inertialVelocityITRF=itrf2gcrfTransform'*parentVelocity;
        velocityITRF=inertialVelocityITRF-cross(omega,positionITRF);


        simObj.Gimbals(idx).Position=itrf2gcrfTransform*positionITRF;
        simObj.Gimbals(idx).PositionITRF=positionITRF;
        simObj.Gimbals(idx).Velocity=parentVelocity;
        simObj.Gimbals(idx).VelocityITRF=velocityITRF;
        simObj.Gimbals(idx).Latitude=positionGeographic(1);
        simObj.Gimbals(idx).Longitude=positionGeographic(2);
        simObj.Gimbals(idx).Altitude=positionGeographic(3);
        simObj.Gimbals(idx).Attitude=attitude;
        simObj.Gimbals(idx).GimbalAzimuth=steeringAngles(1);
        simObj.Gimbals(idx).GimbalElevation=steeringAngles(2);
        simObj.Gimbals(idx).Itrf2BodyTransform=itrf2BodyTransform;
        simObj.Gimbals(idx).Ned2BodyTransform=ned2BodyTransform;
    end


    for idx=1:simObj.NumConicalSensors

        parentID=simObj.ConicalSensors(idx).ParentSimulatorID;
        parentType=simObj.ConicalSensors(idx).ParentType;


        switch parentType
        case 1
            parentIndex=find([simObj.Satellites.ID]==parentID,1);
            satParent=simObj.Satellites(parentIndex);
            parentItrf2BodyTransform=satParent.Itrf2BodyTransform;
            parentPositionITRF=satParent.PositionITRF;
            parentNed2BodyTransform=satParent.Ned2BodyTransform;
            parentVelocity=satParent.Velocity;
        case 2
            parentIndex=find([simObj.GroundStations.ID]==parentID,1);
            gsParent=simObj.GroundStations(parentIndex);
            parentItrf2BodyTransform=gsParent.Itrf2BodyTransform;
            parentPositionITRF=gsParent.PositionITRF;
            parentNed2BodyTransform=gsParent.Ned2BodyTransform;
            parentVelocity=gsParent.Velocity;
        otherwise
            parentIndex=find([simObj.Gimbals.ID]==parentID,1);
            gimParent=simObj.Gimbals(parentIndex);
            parentItrf2BodyTransform=gimParent.Itrf2BodyTransform;
            parentPositionITRF=gimParent.PositionITRF;
            parentNed2BodyTransform=gimParent.Ned2BodyTransform;
            parentVelocity=gimParent.Velocity;
        end


        mountingLocation=simObj.ConicalSensors(idx).MountingLocation;
        mountingAngles=simObj.ConicalSensors(idx).MountingAngles;
        [positionITRF,positionGeographic,attitude,itrf2BodyTransform]=...
        matlabshared.satellitescenario.internal.AttachedAsset.getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransform,...
        parentPositionITRF,parentNed2BodyTransform);


        inertialVelocityITRF=itrf2gcrfTransform'*parentVelocity;
        velocityITRF=inertialVelocityITRF-cross(omega,positionITRF);


        simObj.ConicalSensors(idx).Position=itrf2gcrfTransform*positionITRF;
        simObj.ConicalSensors(idx).PositionITRF=positionITRF;
        simObj.ConicalSensors(idx).Velocity=parentVelocity;
        simObj.ConicalSensors(idx).VelocityITRF=velocityITRF;
        simObj.ConicalSensors(idx).Latitude=positionGeographic(1);
        simObj.ConicalSensors(idx).Longitude=positionGeographic(2);
        simObj.ConicalSensors(idx).Altitude=positionGeographic(3);
        simObj.ConicalSensors(idx).Attitude=attitude;
        simObj.ConicalSensors(idx).Itrf2BodyTransform=itrf2BodyTransform;
    end


    for idx=1:simObj.NumTransmitters

        parentID=simObj.Transmitters(idx).ParentSimulatorID;
        parentType=simObj.Transmitters(idx).ParentType;


        switch parentType
        case 1
            parentIndex=find([simObj.Satellites.ID]==parentID,1);
            satParent=simObj.Satellites(parentIndex);
            parentItrf2BodyTransform=satParent.Itrf2BodyTransform;
            parentPositionITRF=satParent.PositionITRF;
            parentNed2BodyTransform=satParent.Ned2BodyTransform;
            parentVelocity=satParent.Velocity;
            parentLatitude=satParent.Latitude;
            parentLongitude=satParent.Longitude;
        case 2
            parentIndex=find([simObj.GroundStations.ID]==parentID,1);
            gsParent=simObj.GroundStations(parentIndex);
            parentItrf2BodyTransform=gsParent.Itrf2BodyTransform;
            parentPositionITRF=gsParent.PositionITRF;
            parentNed2BodyTransform=gsParent.Ned2BodyTransform;
            parentVelocity=gsParent.Velocity;
            parentLatitude=gsParent.Latitude;
            parentLongitude=gsParent.Longitude;
        otherwise
            parentIndex=find([simObj.Gimbals.ID]==parentID,1);
            gimParent=simObj.Gimbals(parentIndex);
            parentItrf2BodyTransform=gimParent.Itrf2BodyTransform;
            parentPositionITRF=gimParent.PositionITRF;
            parentNed2BodyTransform=gimParent.Ned2BodyTransform;
            parentVelocity=gimParent.Velocity;
            parentLatitude=gimParent.Latitude;
            parentLongitude=gimParent.Longitude;
        end


        mountingLocation=simObj.Transmitters(idx).MountingLocation;
        mountingAngles=simObj.Transmitters(idx).MountingAngles;
        [positionITRF,positionGeographic,attitude,itrf2BodyTransform]=...
        matlabshared.satellitescenario.internal.AttachedAsset.getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransform,...
        parentPositionITRF,parentNed2BodyTransform);


        inertialVelocityITRF=itrf2gcrfTransform'*parentVelocity;
        velocityITRF=inertialVelocityITRF-cross(omega,positionITRF);


        simObj.Transmitters(idx).Position=itrf2gcrfTransform*positionITRF;
        simObj.Transmitters(idx).PositionITRF=positionITRF;
        simObj.Transmitters(idx).Velocity=parentVelocity;
        simObj.Transmitters(idx).VelocityITRF=velocityITRF;
        simObj.Transmitters(idx).Latitude=positionGeographic(1);
        simObj.Transmitters(idx).Longitude=positionGeographic(2);
        simObj.Transmitters(idx).Altitude=positionGeographic(3);
        simObj.Transmitters(idx).Attitude=attitude;
        simObj.Transmitters(idx).Itrf2BodyTransform=itrf2BodyTransform;



        if coder.target('MATLAB')&&simObj.Transmitters(idx).AntennaType==2&&...
            simObj.Transmitters(idx).PointingMode~=5&&simObj.Transmitters(idx).PointingMode~=6
            switch simObj.Transmitters(idx).PointingMode
            case 1

                targetSimID=simObj.Transmitters(idx).PointingTargetID;
                txPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRF=...
                simObj.Satellites(txPointingTargetIndex).PositionITRF;
            case 2

                targetSimID=simObj.Transmitters(idx).PointingTargetID;
                txPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRF=...
                simObj.GroundStations(txPointingTargetIndex).PositionITRF;
            case 3


                targetPositionITRF=...
                simObj.Transmitters(idx).PointingCoordinates;
            otherwise

                targetPositionITRF=...
                matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [parentLatitude*pi/180;...
                parentLongitude*pi/180;...
                0]);
            end


            relativePositionITRF=targetPositionITRF-positionITRF;
            relativePositionBody=itrf2BodyTransform*relativePositionITRF;


            x=relativePositionBody(1);
            y=relativePositionBody(2);
            z=relativePositionBody(3);
            r=norm(relativePositionBody);
            el=-asin(max(min(-(z/r),1),-1))*180/pi;
            az=mod(atan2(y,x),2*pi)*180/pi;
            if isnan(el)
                el=0;
            end
            if isnan(az)
                az=0;
            end
            if az>180||az<=-180
                az=mod(az,360);
                if az>180
                    az=az-360;
                end
            end

            simObj.Transmitters(idx).PointingDirection=[az;el];
        else



            simObj.Transmitters(idx).PointingDirection=zeros(2,1);
        end
    end


    for idx=1:simObj.NumReceivers

        parentID=simObj.Receivers(idx).ParentSimulatorID;
        parentType=simObj.Receivers(idx).ParentType;


        switch parentType
        case 1
            parentIndex=find([simObj.Satellites.ID]==parentID,1);
            satParent=simObj.Satellites(parentIndex);
            parentItrf2BodyTransform=satParent.Itrf2BodyTransform;
            parentPositionITRF=satParent.PositionITRF;
            parentNed2BodyTransform=satParent.Ned2BodyTransform;
            parentVelocity=satParent.Velocity;
            parentLatitude=satParent.Latitude;
            parentLongitude=satParent.Longitude;
        case 2
            parentIndex=find([simObj.GroundStations.ID]==parentID,1);
            gsParent=simObj.GroundStations(parentIndex);
            parentItrf2BodyTransform=gsParent.Itrf2BodyTransform;
            parentPositionITRF=gsParent.PositionITRF;
            parentNed2BodyTransform=gsParent.Ned2BodyTransform;
            parentVelocity=gsParent.Velocity;
            parentLatitude=gsParent.Latitude;
            parentLongitude=gsParent.Longitude;
        otherwise
            parentIndex=find([simObj.Gimbals.ID]==parentID,1);
            gimParent=simObj.Gimbals(parentIndex);
            parentItrf2BodyTransform=gimParent.Itrf2BodyTransform;
            parentPositionITRF=gimParent.PositionITRF;
            parentNed2BodyTransform=gimParent.Ned2BodyTransform;
            parentVelocity=gimParent.Velocity;
            parentLatitude=gimParent.Latitude;
            parentLongitude=gimParent.Longitude;
        end


        mountingLocation=simObj.Receivers(idx).MountingLocation;
        mountingAngles=simObj.Receivers(idx).MountingAngles;
        [positionITRF,positionGeographic,attitude,itrf2BodyTransform]=...
        matlabshared.satellitescenario.internal.AttachedAsset.getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransform,...
        parentPositionITRF,parentNed2BodyTransform);


        inertialVelocityITRF=itrf2gcrfTransform'*parentVelocity;
        velocityITRF=inertialVelocityITRF-cross(omega,positionITRF);


        simObj.Receivers(idx).Position=itrf2gcrfTransform*positionITRF;
        simObj.Receivers(idx).PositionITRF=positionITRF;
        simObj.Receivers(idx).Velocity=parentVelocity;
        simObj.Receivers(idx).VelocityITRF=velocityITRF;
        simObj.Receivers(idx).Latitude=positionGeographic(1);
        simObj.Receivers(idx).Longitude=positionGeographic(2);
        simObj.Receivers(idx).Altitude=positionGeographic(3);
        simObj.Receivers(idx).Attitude=attitude;
        simObj.Receivers(idx).Itrf2BodyTransform=itrf2BodyTransform;



        if coder.target('MATLAB')&&simObj.Receivers(idx).AntennaType==2&&...
            simObj.Receivers(idx).PointingMode~=5&&simObj.Receivers(idx).PointingMode~=6
            switch simObj.Receivers(idx).PointingMode
            case 1

                targetSimID=simObj.Receivers(idx).PointingTargetID;
                rxPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRF=...
                simObj.Satellites(rxPointingTargetIndex).PositionITRF;
            case 2

                targetSimID=simObj.Receivers(idx).PointingTargetID;
                rxPointingTargetIndex=simObj.SimIDMemo(targetSimID);


                targetPositionITRF=...
                simObj.GroundStations(rxPointingTargetIndex).PositionITRF;
            case 3


                targetPositionITRF=...
                simObj.Receivers(idx).PointingCoordinates;
            otherwise

                targetPositionITRF=...
                matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [parentLatitude*pi/180;...
                parentLongitude*pi/180;...
                0]);
            end


            relativePositionITRF=targetPositionITRF-positionITRF;
            relativePositionBody=itrf2BodyTransform*relativePositionITRF;


            x=relativePositionBody(1);
            y=relativePositionBody(2);
            z=relativePositionBody(3);
            r=norm(relativePositionBody);
            el=-asin(max(min(-(z/r),1),-1))*180/pi;
            az=mod(atan2(y,x),2*pi)*180/pi;
            if isnan(el)
                el=0;
            end
            if isnan(az)
                az=0;
            end
            if az>180||az<=-180
                az=mod(az,360);
                if az>180
                    az=az-360;
                end
            end
            simObj.Receivers(idx).PointingDirection=[az;el];
        else



            simObj.Receivers(idx).PointingDirection=zeros(2,1);
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
        positionITRF{idx}=simObj.Satellites(idx).PositionITRF;
        altitude{idx}=simObj.Satellites(idx).Altitude;
        itrf2bodyTransform{idx}=simObj.Satellites(idx).Itrf2BodyTransform;
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
        positionITRF{idx}=simObj.GroundStations(idx).PositionITRF;
        altitude{idx}=simObj.GroundStations(idx).Altitude;
        itrf2bodyTransform{idx}=simObj.GroundStations(idx).Itrf2BodyTransform;
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
        positionITRF{idx}=simObj.ConicalSensors(idx).PositionITRF;
        altitude{idx}=simObj.ConicalSensors(idx).Altitude;
        itrf2bodyTransform{idx}=simObj.ConicalSensors(idx).Itrf2BodyTransform;
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
    timeYear=time.Year;
    timeMonth=time.Month;
    timeDay=time.Day;
    timeHour=time.Hour;
    timeMinute=time.Minute;
    timeSecond=time.Second;
    timeArray=[timeYear,timeMonth,timeDay,timeHour,timeMinute,timeSecond];
    for idx=1:simObj.NumAccesses






        satF=dummySatStruct;
        gsF=dummyGsStruct;
        sensorF=dummySensorStruct;


        simIDMemoF=zeros(1,numel(simIDMemo));


        sequence=simObj.Accesses(idx).Sequence;
        nodeType=simObj.Accesses(idx).NodeType;



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



        simObj.Accesses(idx).Status=matlabshared.satellitescenario.Access.getStatus(...
        sequence,nodeType,nodeIndexF,satF,gsF,sensorF,simIDMemoF,timeArray,1);
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
        positionITRF{idx}=simObj.Transmitters(idx).PositionITRF;
        altitude{idx}=simObj.Transmitters(idx).Altitude;
        itrf2bodyTransform{idx}=simObj.Transmitters(idx).Itrf2BodyTransform;
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
        pointingDirection{idx}=simObj.Transmitters(idx).PointingDirection;

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
        positionITRF{idx}=simObj.Receivers(idx).PositionITRF;
        altitude{idx}=simObj.Receivers(idx).Altitude;
        itrf2bodyTransform{idx}=simObj.Receivers(idx).Itrf2BodyTransform;
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
        pointingDirection{idx}=simObj.Receivers(idx).PointingDirection;

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
    for idx=1:simObj.NumLinks






        satF=dummySatStruct;
        gsF=dummyGsStruct;
        txF=dummyTxStruct;
        rxF=dummyRxStruct;


        simIDMemoF=zeros(1,numel(simIDMemo));


        sequence=simObj.Links(idx).Sequence;
        nodeType=simObj.Links(idx).NodeType;




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



        [stat,receivedEbNo,rip,rxInputPower]=satcom.satellitescenario.Link.getStatus(...
        sequence,nodeType,nodeIndexF,satF,gsF,txF,...
        rxF,simIDMemoF,timeArray,antennaType,1,simObj.UpdateTaper);



        simObj.Links(idx).Status=stat;
        simObj.Links(idx).EbNo=receivedEbNo;
        simObj.Links(idx).ReceivedIsotropicPower=rip;
        simObj.Links(idx).PowerAtReceiverInput=rxInputPower;
    end

    if coder.target('MATLAB')

        for idx=1:simObj.NumFieldsOfView

            sourceID=simObj.FieldsOfView(idx).SourceID;


            sourceIndex=simObj.SimIDMemo(sourceID);
            source=simObj.ConicalSensors(sourceIndex);
            position=source.Position;
            latitude=source.Latitude;
            longitude=source.Longitude;
            altitude=source.Altitude;
            attitude=source.Attitude;
            maxViewAngle=source.MaxViewAngle;



            numContourPoints=simObj.FieldsOfView(idx).NumContourPoints;


            [contour,status]=matlabshared.satellitescenario.FieldOfView.getContour(...
            position,latitude,longitude,altitude,attitude,maxViewAngle,...
            itrf2gcrfTransform,numContourPoints,timeArray,1);



            simObj.FieldsOfView(idx).Contour=contour;
            simObj.FieldsOfView(idx).Status=status;
        end
    end
end

