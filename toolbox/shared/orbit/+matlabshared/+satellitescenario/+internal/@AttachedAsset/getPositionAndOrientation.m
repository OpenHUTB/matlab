function[positionITRFHistory,positionGeographicHistory,...
    attitudeHistory,itrf2BodyTransformHistory]=getPositionAndOrientation(...
    mountingLocation,mountingAngles,parentItrf2BodyTransformHistory,...
    parentPositionITRFHistory,parentNed2BodyTransformHistory)%#codegen




    coder.allowpcode('plain');

    if isempty(coder.target)
        [positionITRFHistory,positionGeographicHistory,attitudeHistory,...
        itrf2BodyTransformHistory]=matlabshared.satellitescenario.internal.AttachedAsset.cg_getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransformHistory,...
        parentPositionITRFHistory,parentNed2BodyTransformHistory);
        return
    end

    numSamples=size(parentPositionITRFHistory,2);
    positionITRFHistory=coder.nullcopy(parentPositionITRFHistory);
    positionGeographicHistory=coder.nullcopy(parentPositionITRFHistory);
    attitudeHistory=coder.nullcopy(parentPositionITRFHistory);
    itrf2BodyTransformHistory=coder.nullcopy(parentItrf2BodyTransformHistory);

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

        mountingYaw=mountingAngles(1)*pi/180;
        mountingPitch=mountingAngles(2)*pi/180;
        mountingRoll=mountingAngles(3)*pi/180;

        dcmParent2Body=matlabshared.orbit.internal.Transforms.ned2bodyTransform(...
        [mountingRoll;mountingPitch;mountingYaw]);

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
        positionITRFHistory(:,idx)=positionITRF;
    end
end

