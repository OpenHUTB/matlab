function[position,velocity,trueAnomaly]=propagate(eccentricity,...
    meanMotion,periapsisTimeBeforeInitialTime,period,...
    semiLatusRectum,specificAngularMomentum,raan,inclination,...
    argOfPeriapsis,time)%#codegen





    coder.allowpcode('plain');

    if isempty(coder.target)&&~isscalar(time)
        time.TimeZone='';
        periapsisTimeBeforeInitialTime.TimeZone='';
        [position,velocity,trueAnomaly]=...
        matlabshared.orbit.internal.TwoBodyKeplerian.cg_propagate(eccentricity,...
        meanMotion,periapsisTimeBeforeInitialTime,period,...
        semiLatusRectum,specificAngularMomentum,raan,inclination,...
        argOfPeriapsis,time);
        return
    end


    numSamples=numel(time);


    secondsFromInitialTime=seconds(time-periapsisTimeBeforeInitialTime);
    timeFromPeriapsis=mod(secondsFromInitialTime,period);



    eccentricAnomaly=zeros(1,numSamples);
    if isempty(coder.target)
        fzeroOptions=matlabshared.orbit.internal.TwoBodyKeplerian.pFZeroOptions;
    else
        fzeroOptions=coder.const(optimset('TolX',1e-9));
    end
    for idx=1:numSamples
        eccentricAnomaly(idx)=fzero(@keplerEquationError,...
        2*pi*timeFromPeriapsis(idx)/period,...
        fzeroOptions,...
        timeFromPeriapsis(idx),meanMotion,eccentricity);
    end


    trueAnomaly=2*atan(sqrt((1+eccentricity)/(1-eccentricity))*...
    tan(eccentricAnomaly/2));


    radialDistance=semiLatusRectum./(1+(eccentricity*cos(trueAnomaly)));


    radialVelocity=(eccentricity*specificAngularMomentum/...
    semiLatusRectum)*sin(trueAnomaly);


    tangentialVelocity=specificAngularMomentum./radialDistance;




    theta=argOfPeriapsis+trueAnomaly;


    rCap=[(cos(raan)*cos(theta))-...
    (sin(raan)*cos(inclination)*sin(theta));...
    (sin(raan)*cos(theta))+(cos(raan)*cos(inclination)*sin(theta));...
    sin(inclination)*sin(theta)];



    thetaCap=[-(cos(raan)*sin(theta))-...
    (sin(raan)*cos(inclination)*cos(theta));...
    -(sin(raan)*sin(theta))+(cos(raan)*cos(inclination)*cos(theta));...
    sin(inclination)*cos(theta)];



    radialDistances=[radialDistance;radialDistance;radialDistance];
    radialVelocities=[radialVelocity;radialVelocity;radialVelocity];
    tangentialVelocities=...
    [tangentialVelocity;tangentialVelocity;tangentialVelocity];
    position=radialDistances.*rCap;
    velocity=(radialVelocities.*rCap)+(tangentialVelocities.*thetaCap);
end

function err=keplerEquationError(eccentricAnomaly,...
    timeFromPeriapsis,meanMotion,eccentricity)









    meanAnomaly=meanMotion*timeFromPeriapsis;
    err=meanAnomaly-eccentricAnomaly+(eccentricity*...
    sin(eccentricAnomaly));
end