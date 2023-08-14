function[rollHistory,pitchHistory,yawHistory,ned2BodyTransformHistory,itrf2BodyTransformHistory]=...
    getAttitude(satPositionITRFHistory,satPositionGeographicHistory,...
    satInertialVelocityITRFHistory,targetPositionITRFHistory)%#codegen














    coder.allowpcode('plain');

    if isempty(coder.target)
        [rollHistory,pitchHistory,yawHistory,ned2BodyTransformHistory,itrf2BodyTransformHistory]=...
        matlabshared.satellitescenario.Satellite.cg_getAttitude(satPositionITRFHistory,satPositionGeographicHistory,...
        satInertialVelocityITRFHistory,targetPositionITRFHistory);
        return
    end

    n=size(satPositionITRFHistory,2);
    yawHistory=zeros(1,n);
    pitchHistory=zeros(1,n);
    rollHistory=zeros(1,n);
    ned2BodyTransformHistory=zeros(3,3,n);
    itrf2BodyTransformHistory=zeros(3,3,n);
    for idx=1:n
        satPositionITRF=satPositionITRFHistory(:,idx);
        satPositionGeographic=satPositionGeographicHistory(:,idx);
        satInertialVelocityITRF=satInertialVelocityITRFHistory(:,idx);
        targetPositionITRF=targetPositionITRFHistory(:,idx);


        primaryAlignmentVector=[0;0;1];
        secondaryAlignmentVector=[1;0;0];



        itrf2nedTransform=matlabshared.orbit.internal.Transforms.itrf2nedTransform(...
        satPositionGeographic);


        relativePositionITRF=targetPositionITRF-satPositionITRF;


        relativePositionNED=itrf2nedTransform*relativePositionITRF;

        if norm(relativePositionNED)<1e-6


            primaryConstraintVector=[0;0;1];
        else


            primaryConstraintVector=...
            relativePositionNED/norm(relativePositionNED);
        end


        velocityNED=itrf2nedTransform*satInertialVelocityITRF;


        secondaryConstraintVector=velocityNED/norm(velocityNED);


        [roll,pitch,yaw,ned2BodyTransform]=orientation(...
        primaryAlignmentVector,primaryConstraintVector,...
        secondaryAlignmentVector,secondaryConstraintVector);


        roll=mod(roll,360);
        if roll>180
            roll=roll-360;
        end


        yaw=mod(yaw,360);


        itrf2BodyTransform=ned2BodyTransform*itrf2nedTransform;

        rollHistory(idx)=roll;
        pitchHistory(idx)=pitch;
        yawHistory(idx)=yaw;
        ned2BodyTransformHistory(:,:,idx)=ned2BodyTransform;
        itrf2BodyTransformHistory(:,:,idx)=itrf2BodyTransform;
    end
end

function[roll,pitch,yaw,ned2bodyTransform]=orientation(primaryAlignmentVector,...
    primaryConstraintVector,secondaryAlignmentVector,...
    secondaryConstraintVector)











    coder.allowpcode('plain');


    primaryAlignmentVector=...
    primaryAlignmentVector/norm(primaryAlignmentVector);
    primaryConstraintVector=...
    primaryConstraintVector/norm(primaryConstraintVector);
    secondaryAlignmentVector=...
    secondaryAlignmentVector/norm(secondaryAlignmentVector);
    secondaryConstraintVector=...
    secondaryConstraintVector/norm(secondaryConstraintVector);





    if dot(primaryAlignmentVector,primaryConstraintVector)==1



        firstRotationAxis=primaryConstraintVector;
        firstRotationAngle=0;
    elseif dot(primaryAlignmentVector,primaryConstraintVector)==-1







        a1=primaryAlignmentVector(1);
        a2=primaryAlignmentVector(2);
        a3=primaryAlignmentVector(3);


        if a1~=0


            if a2~=a3
                b2=1;
                b3=1;
            else
                b2=1;
                b3=-1;
            end


            b1=(-(a2*b2)-(a3*b3))/a1;
        elseif a2~=0



            b1=0;
            b3=1;
            b2=-(a3*b3/a2);
        else




            b1=1;
            b2=0;
            b3=0;
        end

        firstRotationAxis=[b1;b2;b3]/norm([b1;b2;b3]);


        firstRotationAngle=pi;
    else






        firstRotationAxis=...
        cross(primaryAlignmentVector,primaryConstraintVector);
        firstRotationAxis=firstRotationAxis/norm(firstRotationAxis);
        firstRotationAngle=...
        acos(max(min(dot(primaryAlignmentVector,primaryConstraintVector),1),-1));
    end







    secondRotationAxis=primaryConstraintVector;


    if(dot(primaryConstraintVector,secondaryConstraintVector)==1)||...
        (dot(primaryConstraintVector,secondaryConstraintVector)==-1)





        secondRotationAngle=0;
    else


        secondaryAlignmentVectorAfterFirstRotation=rotate(...
        secondaryAlignmentVector,firstRotationAxis,...
        firstRotationAngle);
        secondRotationAngle=rotationForAlignment(...
        secondaryAlignmentVectorAfterFirstRotation,...
        secondaryConstraintVector,secondRotationAxis);
    end


    xBody=[1;0;0];
    xBody=rotate(xBody,firstRotationAxis,firstRotationAngle);
    xBody=rotate(xBody,secondRotationAxis,secondRotationAngle);

    yBody=[0;1;0];
    yBody=rotate(yBody,firstRotationAxis,firstRotationAngle);
    yBody=rotate(yBody,secondRotationAxis,secondRotationAngle);

    zBody=[0;0;1];
    zBody=rotate(zBody,firstRotationAxis,firstRotationAngle);
    zBody=rotate(zBody,secondRotationAxis,secondRotationAngle);


    ned2bodyTransform=[xBody';yBody';zBody'];


    pitch=-asind(max(min(xBody(3),1),-1));
    tol=1e-6;
    if abs(pitch)>(90-tol)
        roll=0;
        yaw=atan2d(-yBody(1),yBody(2));
    else
        roll=atan2d(yBody(3),zBody(3));
        yaw=atan2d(xBody(2),xBody(1));
    end
end

function rotatedVector=rotate(vector,rotationAxis,rotationAngle)

    rotatedVector=vector*cos(rotationAngle)-...
    cross(vector,rotationAxis*sin(rotationAngle))+...
    dot(vector,rotationAxis)*rotationAxis*(1-cos(rotationAngle));
end

function theta=rotationForAlignment(vector1,vector2,rotationAxis)



    lambda1=rotationAxis(1);
    lambda2=rotationAxis(2);
    lambda3=rotationAxis(3);


    a1=vector1(1);
    a2=vector1(2);
    a3=vector1(3);


    c1=vector2(1);
    c2=vector2(2);
    c3=vector2(3);

























    theta=real(-log(-abs(a1*c1*lambda1^2-a2*c2-a3*c3+...
    a1*c2*lambda3*1i-a1*c3*lambda2*1i-a2*c1*lambda3*1i+...
    a2*c3*lambda1*1i+a3*c1*lambda2*1i-a3*c2*lambda1*1i-a1*c1+...
    a2*c2*lambda2^2+a3*c3*lambda3^2+a1*c2*lambda1*lambda2+...
    a2*c1*lambda1*lambda2+a1*c3*lambda1*lambda3+...
    a3*c1*lambda1*lambda3+a2*c3*lambda2*lambda3+...
    a3*c2*lambda2*lambda3)/(a1*c1*lambda1^2-a2*c2-a3*c3+...
    a1*c2*lambda3*1i-a1*c3*lambda2*1i-a2*c1*lambda3*1i+...
    a2*c3*lambda1*1i+a3*c1*lambda2*1i-a3*c2*lambda1*1i-a1*c1+...
    a2*c2*lambda2^2+a3*c3*lambda3^2+a1*c2*lambda1*lambda2+...
    a2*c1*lambda1*lambda2+a1*c3*lambda1*lambda3+...
    a3*c1*lambda1*lambda3+a2*c3*lambda2*lambda3+...
    a3*c2*lambda2*lambda3))*1i);


    proj=c1*(a1*cos(theta)-a2*lambda3*sin(theta)+...
    a3*lambda2*sin(theta)-lambda1*(cos(theta)-1)*(a1*lambda1+...
    a2*lambda2+a3*lambda3))+c2*(a2*cos(theta)+...
    a1*lambda3*sin(theta)-a3*lambda1*sin(theta)-lambda2*(cos(theta)...
    -1)*(a1*lambda1+a2*lambda2+a3*lambda3))+c3*(a3*cos(theta)-...
    a1*lambda2*sin(theta)+a2*lambda1*sin(theta)-lambda3*(cos(theta)...
    -1)*(a1*lambda1+a2*lambda2+a3*lambda3));





    if proj<0
        theta=real(-log(abs(a1*c1*lambda1^2-a2*c2-a3*c3+...
        a1*c2*lambda3*1i-a1*c3*lambda2*1i-a2*c1*lambda3*1i+...
        a2*c3*lambda1*1i+a3*c1*lambda2*1i-a3*c2*lambda1*1i-...
        a1*c1+a2*c2*lambda2^2+a3*c3*lambda3^2+...
        a1*c2*lambda1*lambda2+a2*c1*lambda1*lambda2+...
        a1*c3*lambda1*lambda3+a3*c1*lambda1*lambda3+...
        a2*c3*lambda2*lambda3+...
        a3*c2*lambda2*lambda3)/(a1*c1*lambda1^2-a2*c2-a3*c3+...
        a1*c2*lambda3*1i-a1*c3*lambda2*1i-a2*c1*lambda3*1i+...
        a2*c3*lambda1*1i+a3*c1*lambda2*1i-a3*c2*lambda1*1i-...
        a1*c1+a2*c2*lambda2^2+a3*c3*lambda3^2+...
        a1*c2*lambda1*lambda2+a2*c1*lambda1*lambda2+...
        a1*c3*lambda1*lambda3+a3*c1*lambda1*lambda3+...
        a2*c3*lambda2*lambda3+a3*c2*lambda2*lambda3))*1i);
    end
end




