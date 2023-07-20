function[position,velocity,time]=states(sat,varargin)%#codegen



































































































    coder.allowpcode('plain');




    historyRequested=(mod(nargin,2)~=0);


    if~historyRequested
        time=varargin{1};
        paramArgs={varargin{2:end}};
    else
        paramArgs=varargin;
    end
    paramNames={'CoordinateFrame'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,paramArgs{:});
    coordinateFrame=coder.internal.getParameterValue(pstruct.CoordinateFrame,'inertial',paramArgs{:});


    validateattributes(sat,{'matlabshared.satellitescenario.Satellite'},{'nonempty','vector'},...
    'states','SAT',1);


    numSats=numel(sat);

    if isempty(coder.target)

        for idx=1:numSats
            if~isvalid(sat(idx))
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'SAT');
                error(msg);
            end
        end
    end


    simulator=sat(1).Simulator;

    if isempty(coder.target)

        for idx=1:numSats
            if~isequal(sat(idx).Simulator,simulator)
                msg=message(...
                'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
                error(msg);
            end
        end
    end


    coordinateFrame=validatestring(coordinateFrame,...
    {'inertial','geographic','ecef'},'states','CoordinateFrame');

    if historyRequested



        simulate(simulator);


        time=simulator.TimeHistory;


        numTimeSamples=numel(time);


        position=zeros(3,numTimeSamples,numSats);
        velocity=position;



        if numTimeSamples==0
            return
        end


        omega=repmat([0;0;matlabshared.orbit.internal.OrbitPropagationModel.EarthAngularVelocity],1,numel(time));



        for idx=1:numSats
            if strcmpi(coordinateFrame,'inertial')
                pos=sat(idx).pPositionHistory;
                coder.internal.errorIf(size(pos,2)~=numTimeSamples,...
                'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
                'satellite state history','satellites');
                position(:,:,idx)=sat(idx).pPositionHistory;
                velocity(:,:,idx)=sat(idx).pVelocityHistory;
            elseif strcmpi(coordinateFrame,'geographic')

                positionCurrent=[sat(idx).pLatitudeHistory;...
                sat(idx).pLongitudeHistory;...
                sat(idx).pAltitudeHistory];
                coder.internal.errorIf(size(positionCurrent,2)~=numTimeSamples,...
                'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
                'satellite state history','satellites');

                position(:,:,idx)=positionCurrent;


                gcrf2itrfTransform=...
                permute(matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time),[2,1,3]);


                inertialVelocityITRF=squeeze(pagemtimes(gcrf2itrfTransform,reshape(sat(idx).pVelocityHistory,3,1,[])));


                velocityITRF=inertialVelocityITRF-cross(omega,sat(idx).pPositionITRFHistory);


                geodeticPosition=[positionCurrent(1,:)*pi/180;...
                positionCurrent(2,:)*pi/180;...
                positionCurrent(3,:)];
                itrf2nedTransform=...
                matlabshared.orbit.internal.Transforms.itrf2nedTransform(...
                geodeticPosition);


                velocity(:,:,idx)=squeeze(pagemtimes(itrf2nedTransform,reshape(velocityITRF,3,1,[])));

            else

                positionCurrent=sat(idx).pPositionITRFHistory;
                coder.internal.errorIf(size(positionCurrent,2)~=numTimeSamples,...
                'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
                'satellite state history','satellites');

                position(:,:,idx)=positionCurrent;


                gcrf2itrfTransform=...
                permute(matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time),[2,1,3]);


                inertialVelocityITRF=squeeze(pagemtimes(gcrf2itrfTransform,reshape(sat(idx).pVelocityHistory,3,1,[])));


                velocity(:,:,idx)=inertialVelocityITRF-cross(omega,positionCurrent);
            end
        end
    else

        validateattributes(time,{'datetime'},...
        {'nonempty','finite','scalar'},'states','TIME',2);

        if isempty(coder.target)

            time.TimeZone="UTC";
        end



        if time<simulator.StartTime||time>simulator.StopTime
            msg='shared_orbit:orbitPropagator:TimeOutsideBounds';
            erroringFunction='states';
            if coder.target('MATLAB')
                error(message(msg,erroringFunction));
            else
                coder.internal.error(msg,erroringFunction);
            end
        end




        originalTime=simulator.Time;


        advance(simulator,time);


        omega=[0;0;matlabshared.orbit.internal.OrbitPropagationModel.EarthAngularVelocity];


        position=zeros(3,1,numSats);
        velocity=position;



        for idx=1:numSats

            if strcmpi(coordinateFrame,'inertial')
                position(:,:,idx)=sat(idx).pPosition;
                velocity(:,:,idx)=sat(idx).pVelocity;
            elseif strcmpi(coordinateFrame,'geographic')

                positionCurrent=[sat(idx).pLatitude;sat(idx).pLongitude;sat(idx).pAltitude];
                position(:,:,idx)=positionCurrent;


                gcrf2itrfTransform=...
                matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time)';


                positionITRF=sat(idx).pPositionITRF;


                inertialVelocityITRF=gcrf2itrfTransform*sat(idx).pVelocity;


                velocityITRF=inertialVelocityITRF-cross(omega,positionITRF);


                geodeticPosition=[positionCurrent(1)*pi/180;...
                positionCurrent(2)*pi/180;...
                positionCurrent(3)];
                itrf2nedTransform=...
                matlabshared.orbit.internal.Transforms.itrf2nedTransform(...
                geodeticPosition);


                velocity(:,:,idx)=itrf2nedTransform*velocityITRF;
            else

                positionCurrent=sat(idx).pPositionITRF;
                position(:,:,idx)=positionCurrent;


                gcrf2itrfTransform=...
                matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time)';


                inertialVelocityITRF=gcrf2itrfTransform*sat(idx).pVelocity;


                velocity(:,:,idx)=inertialVelocityITRF-cross(omega,positionCurrent);
            end
        end



        if simulator.SimulationMode==1
            advance(simulator,originalTime);
        end
    end
end


