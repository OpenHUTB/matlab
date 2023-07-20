function[semiMajorAxis,eccentricity,rightAscensionOfAscendingNode,...
    inclination,argumentOfPeriapsis,trueAnomaly,semiLatusRectum,...
    specificAngularMomentum]=inertialVectorToOrbitalElements(...
    inertialPositionVector,inertialVelocityVector)%#codegen





    coder.allowpcode('plain');


    standardGravitationalParameter=...
    matlabshared.orbit.internal.TwoBodyKeplerian.StandardGravitationalParameter;


    inertialPosition=norm(inertialPositionVector);
    inertialVelocity=norm(inertialVelocityVector);


    specificAngularMomentumVector=...
    cross(inertialPositionVector,inertialVelocityVector);
    specificAngularMomentum=norm(specificAngularMomentumVector);



    hCap=specificAngularMomentumVector/specificAngularMomentum;

    rCap=inertialPositionVector/inertialPosition;


    thetaCap=cross(hCap,rCap);


    inclination=acos(max(min(hCap(3),1),-1));

    if inclination~=0

        rightAscensionOfAscendingNode=mod(atan2(hCap(1),-hCap(2)),2*pi);



        angleFromAscendingNode=mod(atan2(rCap(3),thetaCap(3)),2*pi);

    else
        rightAscensionOfAscendingNodePlusangleFromAscendingNode=...
        atan2(rCap(2),rCap(1));
        angleFromAscendingNode=0;
        rightAscensionOfAscendingNode=...
        rightAscensionOfAscendingNodePlusangleFromAscendingNode-...
        angleFromAscendingNode;
    end

    semiLatusRectum=...
    (specificAngularMomentum^2)/standardGravitationalParameter;

    specificEnergy=((inertialVelocity^2)/2)-...
    (standardGravitationalParameter/inertialPosition);

    eccentricity=real(sqrt(1+(2*specificEnergy*(...
    specificAngularMomentum^2)/(standardGravitationalParameter^2))));



    inertialToOrbit=zeros(3);
    inertialToOrbit(1,1)=...
    (cos(rightAscensionOfAscendingNode)*cos(angleFromAscendingNode))-...
    (sin(rightAscensionOfAscendingNode)*...
    cos(inclination)*sin(angleFromAscendingNode));
    inertialToOrbit(1,2)=...
    -(cos(rightAscensionOfAscendingNode)*sin(angleFromAscendingNode))-...
    (sin(rightAscensionOfAscendingNode)*cos(inclination)*...
    cos(angleFromAscendingNode));
    inertialToOrbit(1,3)=sin(rightAscensionOfAscendingNode)*sin(inclination);
    inertialToOrbit(2,1)=...
    (sin(rightAscensionOfAscendingNode)*cos(angleFromAscendingNode))+...
    (cos(rightAscensionOfAscendingNode)*cos(inclination)*...
    sin(angleFromAscendingNode));
    inertialToOrbit(2,2)=...
    -(sin(rightAscensionOfAscendingNode)*sin(angleFromAscendingNode))+...
    (cos(rightAscensionOfAscendingNode)*cos(inclination)*...
    cos(angleFromAscendingNode));
    inertialToOrbit(2,3)=-(cos(rightAscensionOfAscendingNode)*...
    sin(inclination));
    inertialToOrbit(3,1)=sin(inclination)*sin(angleFromAscendingNode);
    inertialToOrbit(3,2)=sin(inclination)*cos(angleFromAscendingNode);
    inertialToOrbit(3,3)=cos(inclination);

    inertialVelocityVectorOrbitFrame=inertialVelocityVector'*inertialToOrbit;
    radialVelocity=inertialVelocityVectorOrbitFrame(1);





    if radialVelocity>=0
        trueAnomaly=real(acos((1/eccentricity)*...
        ((semiLatusRectum/inertialPosition)-1)));
    else
        trueAnomaly=(2*pi)-real(acos((1/eccentricity)*...
        ((semiLatusRectum/inertialPosition)-1)));
    end



    if isnan(trueAnomaly)
        trueAnomaly=0;
    end


    argumentOfPeriapsis=mod(angleFromAscendingNode-trueAnomaly,2*pi);


    semiMajorAxis=semiLatusRectum/(1-(eccentricity^2));
end


