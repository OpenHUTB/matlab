function[stat,time]=linkStatus(lnk,varargin)%#codegen































































































































































    coder.allowpcode('plain');


    narginchk(1,2);


    validateattributes(lnk,{'satcom.satellitescenario.Link'},{'nonempty','vector'},...
    'linkStatus','LINK',1);


    numLinks=numel(lnk);

    if coder.target('MATLAB')

        for idx=1:numLinks
            if~isvalid(lnk(idx))
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'LINK');
                error(msg);
            end
        end
    end


    simulator=lnk(1).Simulator;

    if coder.target('MATLAB')

        for idx=1:numLinks
            if~isequal(lnk(idx).Simulator,simulator)
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


        stat=false(numLinks,numel(time));



        if isempty(time)
            return
        end


        for idx=1:numLinks

            statHistory=lnk(idx).pStatusHistory;



            coder.internal.errorIf(numel(statHistory)~=numTimeSamples,...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'link status history','link analyses');


            stat(idx,:)=lnk(idx).pStatusHistory;
        end
    else


        time=varargin{1};


        validateattributes(time,{'datetime'},...
        {'nonempty','finite','scalar'},'linkStatus','TIME',2);

        if coder.target('MATLAB')

            time.TimeZone="UTC";
        end



        if time<simulator.StartTime||time>simulator.StopTime
            msg='shared_orbit:orbitPropagator:TimeOutsideBounds';
            erroringFunction='linkStatus';

            if coder.target('MATLAB')
                error(message(msg,erroringFunction));
            else
                coder.internal.error(msg,erroringFunction);
            end
        end




        originalTime=simulator.Time;


        advance(simulator,time);


        stat=false(numLinks,1);


        for idx=1:numLinks
            stat(idx)=lnk(idx).pStatus;
        end



        if simulator.SimulationMode==1
            advance(simulator,originalTime);
        end
    end
end


