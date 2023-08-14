function[positionITRFHistory,positionGeographicHistory,attitudeHistory,...
    itrf2BodyTransformHistory,ned2bodyTransformHistory,steeringAnglesHistory]=...
    getPositionOrientationAndSteeringAngles(mountingLocation,mountingAngles,...
    parentItrf2BodyTransformHistory,parentPositionITRFHistory,...
    parentNed2BodyTransformHistory,targetPositionITRFHistory,needToSteer)%#codegen




    coder.allowpcode("plain");

    if isempty(coder.target)
        [positionITRFHistory,positionGeographicHistory,attitudeHistory,...
        itrf2BodyTransformHistory,ned2bodyTransformHistory,steeringAnglesHistory]=...
        matlabshared.satellitescenario.Gimbal.cg_getPositionOrientationAndSteeringAngles(...
        mountingLocation,mountingAngles,...
        parentItrf2BodyTransformHistory,parentPositionITRFHistory,...
        parentNed2BodyTransformHistory,targetPositionITRFHistory,needToSteer);
        return
    end


    numSamples=size(parentPositionITRFHistory,2);
    positionITRFHistory=coder.nullcopy(parentPositionITRFHistory);
    positionGeographicHistory=coder.nullcopy(parentPositionITRFHistory);
    attitudeHistory=coder.nullcopy(parentPositionITRFHistory);
    itrf2BodyTransformHistory=coder.nullcopy(parentNed2BodyTransformHistory);
    ned2bodyTransformHistory=coder.nullcopy(parentNed2BodyTransformHistory);
    steeringAnglesHistory=coder.nullcopy(zeros(2,numSamples));

    for idx=1:numSamples
        parentItrf2BodyTransform=parentItrf2BodyTransformHistory(:,:,idx);
        parentPositionITRF=parentPositionITRFHistory(:,idx);
        parentNed2BodyTransform=parentNed2BodyTransformHistory(:,:,idx);

        mountingLocationITRF=parentItrf2BodyTransform'*mountingLocation;
        positionITRF=parentPositionITRF+mountingLocationITRF;

        positionGeographic=...
        matlabshared.orbit.internal.Transforms.itrf2geographic(positionITRF);

        itrf2nedTransform=...
        matlabshared.orbit.internal.Transforms.itrf2nedTransform(positionGeographic);

        mountingYaw=deg2rad(mountingAngles(1));
        mountingPitch=deg2rad(mountingAngles(2));
        mountingRoll=deg2rad(mountingAngles(3));

        dcmParent2Mounting=matlabshared.orbit.internal.Transforms.ned2bodyTransform(...
        [mountingRoll;mountingPitch;mountingYaw]);

        if needToSteer==0
            el=0;
            az=0;
        elseif needToSteer==-1

            azEl=targetPositionITRFHistory(:,idx);
            az=azEl(1);
            el=azEl(2);
        else
            targetPositionITRF=targetPositionITRFHistory(:,idx);
            relativeTargetPositionITRF=targetPositionITRF-positionITRF;
            relativeTargetPositionParentBody=parentItrf2BodyTransform*relativeTargetPositionITRF;
            relativeTargetPositionMounting=dcmParent2Mounting*relativeTargetPositionParentBody;
            relativeTargetPositionMountingMagnitude=norm(relativeTargetPositionMounting);
            if relativeTargetPositionMountingMagnitude==0
                el=0;
            else
                el=acos(max(min(relativeTargetPositionMounting(3)/relativeTargetPositionMountingMagnitude,1),-1));
            end
            az=atan2(relativeTargetPositionMounting(2),relativeTargetPositionMounting(1));
        end

        dcmMounting2Body=[cos(az)*cos(el),sin(az)*cos(el),-sin(el);...
        -sin(az),cos(az),0;...
        cos(az)*sin(el),sin(az)*sin(el),cos(el)];
        dcmParent2Body=dcmMounting2Body*dcmParent2Mounting;

        elSteering=el*180/pi;
        azSteering=az*180/pi;

        ned2ParentNedTransform=parentNed2BodyTransform'*parentItrf2BodyTransform*itrf2nedTransform';

        ned2bodyTransform=dcmParent2Body*parentNed2BodyTransform*ned2ParentNedTransform;

        xBody=ned2bodyTransform(1,:);
        yBody=ned2bodyTransform(2,:);
        zBody=ned2bodyTransform(3,:);

        pitch=-asind(max(min(xBody(3),1),-1));
        tol=1e-6;
        if abs(pitch)>(90-tol)
            roll=0;
            yaw=atan2d(-yBody(1),yBody(2));
        else
            roll=atan2d(yBody(3),zBody(3));
            yaw=atan2d(xBody(2),xBody(1));
        end

        attitudeHistory(:,idx)=[roll;pitch;yaw];
        itrf2BodyTransformHistory(:,:,idx)=ned2bodyTransform*itrf2nedTransform;
        positionGeographicHistory(:,idx)=[positionGeographic(1)*180/pi;...
        positionGeographic(2)*180/pi;positionGeographic(3)];
        steeringAnglesHistory(:,idx)=[azSteering;elSteering];
        ned2bodyTransformHistory(:,:,idx)=ned2bodyTransform;
        positionITRFHistory(:,idx)=positionITRF;
    end
end

