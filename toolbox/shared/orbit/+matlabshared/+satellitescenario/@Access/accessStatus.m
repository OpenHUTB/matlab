function[stat,time]=accessStatus(ac,varargin)%#codegen






































































































































    coder.allowpcode('plain');


    narginchk(1,2);


    validateattributes(ac,{'matlabshared.satellitescenario.Access'},{'nonempty','vector'},...
    'accessStatus','AC',1);


    numAc=numel(ac);

    if coder.target('MATLAB')
        for idx=1:numAc

            if~isvalid(ac(idx))
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'AC');
                error(msg);
            end
        end
    end


    simulator=ac(1).Simulator;

    if coder.target('MATLAB')
        for idx=1:numAc

            if~isequal(ac(idx).Simulator,simulator)
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
        numTimeSamples=numel(time);


        stat=false(numAc,numel(time));



        if isempty(time)
            return
        end

        for idx=1:numAc

            statHistory=ac(idx).pStatusHistory;



            coder.internal.errorIf(numel(statHistory)~=numTimeSamples,...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'access status history','access analyses');


            stat(idx,:)=statHistory;
        end
    else


        time=varargin{1};

        validateattributes(time,{'datetime'},...
        {'nonempty','finite','scalar'},'accessStatus','TIME',2);

        if coder.target('MATLAB')

            time.TimeZone="UTC";
        end




        originalTime=simulator.Time;



        if time<simulator.StartTime||time>simulator.StopTime
            msg='shared_orbit:orbitPropagator:TimeOutsideBounds';
            erroringFunction='accessStatus';

            if coder.target('MATLAB')
                error(message(msg,erroringFunction));
            else
                coder.internal.error(...
                'shared_orbit:orbitPropagator:TimeOutsideBounds',...
                'accessStatus');
            end
        end


        advance(simulator,time);


        stat=false(numAc,1);

        for idx=1:numAc

            stat(idx)=ac(idx).pStatus;
        end



        if simulator.SimulationMode==1
            advance(simulator,originalTime);
        end
    end
end


