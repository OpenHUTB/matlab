function[position,velocity]=orbitalElementsToInertialVector(...
    semiMajorAxis,eccentricity,inclination,...
    rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly)%#codegen





    coder.allowpcode('plain');


    standardGravitationalParameter=matlabshared.orbit.internal.TwoBodyKeplerian.StandardGravitationalParameter;
    specificEnergy=-(standardGravitationalParameter/(2*semiMajorAxis));
    specificAngularMomentum=standardGravitationalParameter*...
    sqrt(((eccentricity^2)-1)/(2*specificEnergy));
    semiLatusRectum=...
    (specificAngularMomentum^2)/standardGravitationalParameter;


    radialDistance=semiLatusRectum/(1+(eccentricity*cos(trueAnomaly)));


    radialVelocity=(eccentricity*specificAngularMomentum/...
    semiLatusRectum)*sin(trueAnomaly);


    tangentialVelocity=specificAngularMomentum/radialDistance;




    theta=argumentOfPeriapsis+trueAnomaly;


    rCap=[(cos(rightAscensionOfAscendingNode)*cos(theta))-...
    (sin(rightAscensionOfAscendingNode)*cos(inclination)*sin(theta)),...
    (sin(rightAscensionOfAscendingNode)*cos(theta))+...
    (cos(rightAscensionOfAscendingNode)*cos(inclination)*sin(theta)),...
    sin(inclination)*sin(theta)];



    thetaCap=[-(cos(rightAscensionOfAscendingNode)*sin(theta))-...
    (sin(rightAscensionOfAscendingNode)*cos(inclination)*cos(theta)),...
    -(sin(rightAscensionOfAscendingNode)*sin(theta))+...
    (cos(rightAscensionOfAscendingNode)*cos(inclination)*cos(theta)),...
    sin(inclination)*cos(theta)];



    position=(radialDistance*rCap)';
    velocity=((radialVelocity*rCap)+...
    (tangentialVelocity*thetaCap))';
end

