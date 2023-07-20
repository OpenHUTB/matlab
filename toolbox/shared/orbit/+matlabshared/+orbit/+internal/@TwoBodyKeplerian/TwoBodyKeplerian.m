classdef TwoBodyKeplerian<matlabshared.orbit.internal.OrbitPropagationModel %#codegen






    properties(Access=private)
pRightAscensionOfAscendingNode
pInclination
pArgumentOfPeriapsis
pSemiMajorAxis
pEccentricity
pTrueAnomaly
pPeriapsis
pApoapsis
pPeriod
pMeanMotion
pPeriapsisTimeBeforeInitialTime
pSemiLatusRectum
pSpecificAngularMomentum
pTrueAnomalyAtInitialTime
    end

    properties(Constant,Hidden)
        pFZeroOptions=optimset('TolX',1e-9)
    end

    methods
        function propagator=TwoBodyKeplerian(semiMajorAxis,...
            eccentricity,inclination,raan,argOfPeriapsis,...
            trueAnomalyAtInitialTime,initialTime)


            coder.allowpcode('plain');



            if isempty(coder.target)&&~isequal(initialTime.TimeZone,'UTC')
                initialTime.TimeZone='UTC';
            end


            propagator.pSemiMajorAxis=semiMajorAxis;
            propagator.pEccentricity=eccentricity;
            propagator.pInclination=inclination;
            propagator.pRightAscensionOfAscendingNode=raan;
            propagator.pArgumentOfPeriapsis=argOfPeriapsis;
            propagator.pTrueAnomalyAtInitialTime=...
            trueAnomalyAtInitialTime;
            propagator.InitialTime=initialTime;


            initialize(propagator);
        end

        function infoStruct=info(propagator)















            coder.allowpcode('plain');

            infoStruct.RightAscensionOfAscendingNode=...
            propagator.pRightAscensionOfAscendingNode;
            infoStruct.Inclination=propagator.pInclination;
            infoStruct.ArgumentOfPeriapsis=...
            propagator.pArgumentOfPeriapsis;
            infoStruct.SemiMajorAxis=propagator.pSemiMajorAxis;
            infoStruct.Eccentricity=propagator.pEccentricity;
            infoStruct.TrueAnomaly=propagator.pTrueAnomaly;
            infoStruct.Periapsis=propagator.pPeriapsis;
            infoStruct.Apoapsis=propagator.pApoapsis;
            infoStruct.Period=propagator.pPeriod;
        end
    end

    methods(Access=protected)
        function initialize(propagator)


            coder.allowpcode('plain');


            standardGravitationalParameter=...
            propagator.StandardGravitationalParameter;


            semiMajorAxis=propagator.pSemiMajorAxis;
            eccentricity=propagator.pEccentricity;
            semiLatusRectum=semiMajorAxis*(1-(eccentricity^2));


            specificAngularMomentum=...
            sqrt(standardGravitationalParameter*semiLatusRectum);


            meanMotion=...
            sqrt(standardGravitationalParameter/(semiMajorAxis^3));


            trueAnomalyAtInitialTime=...
            propagator.pTrueAnomalyAtInitialTime;
            initialTime=propagator.InitialTime;
            eccentricAnomalyAtInitialTime=...
            2*atan(sqrt((1-eccentricity)/...
            (1+eccentricity))*tan(trueAnomalyAtInitialTime/2));
            periapsisTimeToInitialTime=...
            (eccentricAnomalyAtInitialTime-...
            (eccentricity*sin(eccentricAnomalyAtInitialTime)))/...
            meanMotion;
            periapsisTimeBeforeInitialTime=initialTime-...
            seconds(periapsisTimeToInitialTime);


            periapsis=semiMajorAxis*(1-eccentricity);
            apoapsis=semiMajorAxis*(1+eccentricity);


            if periapsis<propagator.EarthRadius
                msgID='shared_orbit:orbitPropagator:TwoBodyKeplerianEarthCollisionTrajectory';
                if isempty(coder.target)
                    msg=message(msgID);
                    error(msg);
                else
                    coder.internal.error(msgID);
                end
            end


            propagator.pPeriapsis=periapsis;
            propagator.pApoapsis=apoapsis;
            propagator.pPeriod=...
            2*pi*sqrt((semiMajorAxis^3)/...
            standardGravitationalParameter);
            propagator.pMeanMotion=meanMotion;
            propagator.pPeriapsisTimeBeforeInitialTime=...
            periapsisTimeBeforeInitialTime;
            propagator.pSemiLatusRectum=semiLatusRectum;
            propagator.pSpecificAngularMomentum=specificAngularMomentum;


            step(propagator,propagator.InitialTime);
            propagator.InitialPosition=propagator.Position;
            propagator.InitialVelocity=propagator.Velocity;
        end

        function[position,velocity]=stepImpl(propagator,time)


            coder.allowpcode('plain');


            eccentricity=propagator.pEccentricity;
            meanMotion=propagator.pMeanMotion;
            periapsisTimeBeforeInitialTime=...
            propagator.pPeriapsisTimeBeforeInitialTime;
            period=propagator.pPeriod;
            semiLatusRectum=propagator.pSemiLatusRectum;
            specificAngularMomentum=propagator.pSpecificAngularMomentum;
            raan=propagator.pRightAscensionOfAscendingNode;
            inclination=propagator.pInclination;
            argOfPeriapsis=propagator.pArgumentOfPeriapsis;


            [position,velocity,trueAnomaly]=...
            matlabshared.orbit.internal.TwoBodyKeplerian.propagate(...
            eccentricity,meanMotion,...
            periapsisTimeBeforeInitialTime,period,...
            semiLatusRectum,specificAngularMomentum,raan,...
            inclination,argOfPeriapsis,time);


            propagator.pTrueAnomaly=trueAnomaly(:,end);
        end
    end

    methods(Static)
        [position,velocity,trueAnomaly]=propagate(eccentricity,...
        meanMotion,periapsisTimeBeforeInitialTime,period,...
        semiLatusRectum,specificAngularMomentum,raan,...
        inclination,argOfPeriapsis,time)

        [position,velocity,trueAnomaly]=cg_propagate(eccentricity,...
        meanMotion,periapsisTimeBeforeInitialTime,period,...
        semiLatusRectum,specificAngularMomentum,raan,inclination,...
        argOfPeriapsis,time)

        [semiMajorAxis,eccentricity,rightAscensionOfAscendingNode,...
        inclination,argumentOfPeriapsis,trueAnomaly,...
        semiLatusRectum,specificAngularMomentum]=...
        inertialVectorToOrbitalElements(inertialPositionVector,...
        inertialVelocityVector)

        [position,velocity]=orbitalElementsToInertialVector(...
        semiMajorAxis,eccentricity,rightAscensionOfAscendingNode,...
        inclination,argumentOfPeriapsis,trueAnomaly)
    end
end


