classdef(Abstract,Hidden)GeneralPerturbations<...
    matlabshared.orbit.internal.OrbitPropagationModel %#codegen





    properties(Access=protected)
pEpoch
pBStar
pRightAscensionOfAscendingNode
pEccentricity
pInclination
pArgumentOfPeriapsis
pMeanAnomaly
pMeanMotion
pPeriod
    end

    properties(Hidden,Constant)
        MinSDP4Period=225*60
    end

    properties(Constant,Hidden)
        pDensityFunctionParameter1=1.01222928
        pDensityFunctionParameter2=1.88027916e-9;
        pNormalizedStandardGravitationalParameter=0.743669161e-1
        pEarthRadiusGP=6378135
        pJ2=0.001082616
        pJ3=-0.253881e-5
        pJ4=-0.165597e-05
    end

    properties(Access=protected)







pInitialPositionGP
pInitialVelocityGP


pTLEStruct
    end

    methods
        function propagator=GeneralPerturbations(varargin)


            coder.allowpcode('plain');

            if nargin~=0
                tleData=varargin{1};
                initialTime=varargin{2};


                validateattributes(tleData,{'struct'},...
                {'nonempty','scalar'},...
                'orbitPropagator','tleData',1);



                propagator.pEpoch=tleData(1).Epoch;
                propagator.pBStar=tleData(1).BStar;
                propagator.pRightAscensionOfAscendingNode=...
                tleData(1).RightAscensionOfAscendingNode;
                propagator.pEccentricity=tleData(1).Eccentricity;
                propagator.pInclination=tleData(1).Inclination;
                propagator.pArgumentOfPeriapsis=...
                tleData(1).ArgumentOfPeriapsis;
                propagator.pMeanAnomaly=tleData(1).MeanAnomaly;
                propagator.pMeanMotion=tleData(1).MeanMotion;



                if isempty(coder.target)&&~isequal(initialTime.TimeZone,'UTC')
                    initialTime.TimeZone='UTC';
                end


                propagator.InitialTime=initialTime;


                initialize(propagator);
            end
        end

        function infoStruct=info(propagator)















            coder.allowpcode('plain');

            infoStruct.MeanMotion=propagator.pMeanMotion;
            infoStruct.Eccentricity=propagator.pEccentricity;
            infoStruct.Inclination=propagator.pInclination;
            infoStruct.RightAscensionOfAscendingNode=...
            propagator.pRightAscensionOfAscendingNode;
            infoStruct.ArgumentOfPeriapsis=...
            propagator.pArgumentOfPeriapsis;
            infoStruct.MeanAnomaly=propagator.pMeanAnomaly;
            infoStruct.Period=propagator.pPeriod;
            infoStruct.Epoch=propagator.pEpoch;
            infoStruct.BStar=propagator.pBStar;
        end
    end

    methods(Access=protected)
        function initialize(propagator)


            coder.allowpcode('plain');


            epoch=propagator.pEpoch;
            bStar=propagator.pBStar;
            rightAscensionOfAscendingNode=...
            propagator.pRightAscensionOfAscendingNode;
            eccentricity=propagator.pEccentricity;
            inclination=propagator.pInclination;
            argumentOfPeriapsis=propagator.pArgumentOfPeriapsis;
            meanAnomaly=propagator.pMeanAnomaly;
            meanMotion=propagator.pMeanMotion;
            initialTime=propagator.InitialTime;


            period=2*pi/meanMotion;


            standardGravitationalParameter=propagator.StandardGravitationalParameter;
            semiMajorAxis=...
            (standardGravitationalParameter/(meanMotion^2))^(1/3);
            periapsis=semiMajorAxis*(1-eccentricity);


            if periapsis<propagator.EarthRadius
                msgID='shared_orbit:orbitPropagator:SGP4SDP4EarthCollisionTrajectory';
                if isempty(coder.target)
                    msg=message(msgID);
                    error(msg);
                else
                    coder.internal.error(msgID);
                end
            end



            if inclination>pi

                r3=sin(inclination)*sin(argumentOfPeriapsis);



                theta3=sin(inclination)*cos(argumentOfPeriapsis);

                argumentOfPeriapsis=atan2(r3,theta3);


                h1=sin(rightAscensionOfAscendingNode)*...
                sin(inclination);


                h2=-cos(rightAscensionOfAscendingNode)*...
                sin(inclination);

                rightAscensionOfAscendingNode=atan2(h1,-h2);


                h3=cos(inclination);

                inclination=acos(h3);
            end


            propagator.pRightAscensionOfAscendingNode=...
            rightAscensionOfAscendingNode;
            propagator.pInclination=inclination;
            propagator.pArgumentOfPeriapsis=argumentOfPeriapsis;
            propagator.pPeriod=period;


            tleStruct.Epoch=epoch;
            tleStruct.BStar=bStar;
            tleStruct.RightAscensionOfAscendingNode=...
            rightAscensionOfAscendingNode;
            tleStruct.Eccentricity=eccentricity;
            tleStruct.Inclination=inclination;
            tleStruct.ArgumentOfPeriapsis=argumentOfPeriapsis;
            tleStruct.MeanAnomaly=meanAnomaly;
            tleStruct.MeanMotion=meanMotion;
            propagator.pTLEStruct=tleStruct;


            if isa(propagator,'matlabshared.orbit.internal.SGP4')
                [initialPosition,initialVelocity]=...
                matlabshared.orbit.internal.SGP4.propagate(tleStruct,initialTime);
            else
                [initialPosition,initialVelocity]=...
                matlabshared.orbit.internal.SDP4.propagate(tleStruct,initialTime);
            end


            propagator.pInitialPositionGP=initialPosition;
            propagator.pInitialVelocityGP=initialVelocity;


            propagator.InitialPosition=initialPosition;
            propagator.InitialVelocity=initialVelocity;
            propagator.Position=initialPosition;
            propagator.Velocity=initialVelocity;
            propagator.Time=initialTime;
        end

        function[position,velocity]=stepImpl(propagator,time)


            coder.allowpcode('plain');


            tleStruct=propagator.pTLEStruct;


            [position,velocity]=propagator.propagate(tleStruct,time);
        end
    end

    methods(Static,Hidden)
        function theta=arctan(sinTheta,cosTheta)







            coder.allowpcode('plain');

            theta=zeros(1,numel(sinTheta));

            for idx=1:numel(theta)
                theta(idx)=0;
                if cosTheta(idx)==0
                    if sinTheta(idx)>0
                        theta(idx)=pi/2;
                    elseif sinTheta(idx)<0
                        theta(idx)=3*pi/2;
                    end
                elseif cosTheta(idx)>0
                    if sinTheta(idx)>0
                        theta(idx)=atan(sinTheta(idx)/cosTheta(idx));
                    elseif sinTheta(idx)<0
                        theta(idx)=(2*pi)+atan(sinTheta(idx)/cosTheta(idx));
                    end
                else
                    theta(idx)=pi+atan(sinTheta(idx)/cosTheta(idx));
                end
            end
        end
    end
end


