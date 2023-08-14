function[az,el,time]=gimbalAngles(gim,varargin)%#codegen



































































































    coder.allowpcode('plain');


    narginchk(1,2);


    validateattributes(gim,{'matlabshared.satellitescenario.Gimbal'},{'nonempty','vector'},...
    'gimbalAngles','GIMBAL',1);


    numGimbals=numel(gim);

    if coder.target('MATLAB')

        for idx=1:numGimbals
            if~isvalid(gim(idx))
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'GIMBAL');
                error(msg);
            end
        end
    end


    simulator=gim(1).Simulator;
    if coder.target('MATLAB')

        for idx=1:numGimbals
            if~isequal(gim(idx).Simulator,simulator)
                msg=message(...
                'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
                error(msg);
            end
        end
    end


    historyRequested=(nargin==1);

    if historyRequested

        simulate(simulator);


        time=simulator.TimeHistory;


        historyLength=numel(time);


        az=zeros(numGimbals,historyLength);
        el=az;



        if historyLength==0
            return
        end


        for idx=1:numGimbals




            azHistory=gim(idx).GimbalAzimuthHistory;
            coder.internal.errorIf(numel(azHistory)~=historyLength,...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'gimbal angles','gimbals');
            az(idx,:)=gim(idx).GimbalAzimuthHistory;
            el(idx,:)=gim(idx).GimbalElevationHistory;
        end
    else


        time=varargin{1};

        validateattributes(time,{'datetime'},...
        {'nonempty','finite','scalar'},'gimbalAngles','TIME',2);

        if coder.target('MATLAB')

            time.TimeZone="UTC";
        end



        if time<simulator.StartTime||time>simulator.StopTime
            msg='shared_orbit:orbitPropagator:TimeOutsideBounds';
            erroringFunction='gimbalAngles';
            if coder.target('MATLAB')
                error(message(msg,erroringFunction));
            else
                coder.internal.error(msg,erroringFunction);
            end
        end




        originalTime=simulator.Time;


        advance(simulator,time);


        az=zeros(numGimbals,1);
        el=az;


        for idx=1:numGimbals
            az(idx)=gim(idx).GimbalAzimuth;
            el(idx)=gim(idx).GimbalElevation;
        end



        if simulator.SimulationMode==1
            advance(simulator,originalTime);
        end
    end
end

