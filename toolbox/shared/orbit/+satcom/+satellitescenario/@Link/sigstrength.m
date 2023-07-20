function[rip,rxInputPower,time]=sigstrength(lnk,varargin)%#codegen

























































































































    coder.allowpcode('plain');


    narginchk(1,2);


    validateattributes(lnk,{'satcom.satellitescenario.Link'},{'nonempty','vector'},...
    'sigstrength','LINK',1);


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





        coder.internal.errorIf(numel(lnk(1).pReceivedIsotropicPowerHistory)~=numTimeSamples,...
        'shared_orbit:orbitPropagator:SigStrengthHistoryLengthMismatch');


        rip=zeros(numLinks,numTimeSamples);
        rxInputPower=zeros(numLinks,numTimeSamples);



        if isempty(time)
            return
        end



        for idx=1:numLinks


            rip(idx,:)=lnk(idx).pReceivedIsotropicPowerHistory;
            rxInputPower(idx,:)=lnk(idx).pPowerAtReceiverInputHistory;

            if coder.target('MATLAB')


                lastTwoNodesSameParent=isLastTwoNodesSameParent(lnk(idx));
                if lastTwoNodesSameParent
                    throwWarning(idx)
                end
            end
        end
    else


        time=varargin{1};


        validateattributes(time,{'datetime'},...
        {'nonempty','finite','scalar'},'sigstrength','TIME',2);

        if coder.target('MATLAB')

            time.TimeZone="UTC";
        end



        if time<simulator.StartTime||time>simulator.StopTime
            msg='shared_orbit:orbitPropagator:TimeOutsideBounds';
            erroringFunction='sigstrength';
            if coder.target('MATLAB')
                error(message(msg,erroringFunction));
            else
                coder.internal.error(msg,erroringFunction);
            end
        end




        originalTime=simulator.Time;


        advance(simulator,time);


        rip=zeros(numLinks,1);
        rxInputPower=zeros(numLinks,1);



        for idx=1:numLinks
            rip(idx)=lnk(idx).pReceivedIsotropicPower;
            rxInputPower(idx)=lnk(idx).pPowerAtReceiverInput;

            if coder.target('MATLAB')


                lastTwoNodesSameParent=isLastTwoNodesSameParent(lnk(idx));
                if lastTwoNodesSameParent
                    throwWarning(idx)
                end
            end
        end



        if simulator.SimulationMode==1
            advance(simulator,originalTime);
        end
    end
end

function throwWarning(idx)



    msg=message(...
    'shared_orbit:orbitPropagator:CommonPenultimateAndFinalNodeGrandParent',...
    num2str(idx),'received isotropic power and power at receiver input');
    warning(msg);
end

