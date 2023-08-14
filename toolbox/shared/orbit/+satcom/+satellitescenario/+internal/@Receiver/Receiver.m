classdef Receiver<satcom.satellitescenario.internal.CommDevice %#codegen




    properties(Dependent,SetAccess={?matlabshared.satellitescenario.Satellite,...
        ?matlabshared.satellitescenario.coder.Receiver})




Name
    end

    properties(Dependent)




RequiredEbNo



GainToNoiseTemperatureRatio

















PreReceiverLoss
    end

    methods
        function delete(rx)


            coder.allowpcode('plain');

            if isempty(coder.target)




                parent=rx.Parent;



                simulator=rx.Simulator;
                if isa(simulator,'matlabshared.satellitescenario.internal.Simulator')&&isvalid(simulator)
                    simIndex=getIdxInSimulatorStruct(rx);
                    simulator.Receivers(simIndex)=[];
                    simulator.NumReceivers=simulator.NumReceivers-1;
                    simulator.NeedToMemoizeSimID=true;
                end


                if isa(rx.Antenna,'satcom.satellitescenario.GaussianAntenna')
                    delete(rx.Antenna);
                end


                scenario=rx.Scenario;
                if isa(scenario,'satelliteScenario')&&isvalid(scenario)
                    sats=scenario.Satellites;
                    if~isempty(sats)
                        satTx=[sats.Transmitters];
                        satGimbals=[sats.Gimbals];
                    else
                        satTx=[];
                        satGimbals=[];
                    end

                    gs=scenario.GroundStations;
                    if~isempty(gs)
                        gsTx=[gs.Transmitters];
                        gsGimbals=[gs.Gimbals];
                    else
                        gsTx=[];
                        gsGimbals=[];
                    end

                    gimbals=[satGimbals,gsGimbals];
                    if~isempty(gimbals)
                        gimbalTx=[gimbals.Transmitters];
                    else
                        gimbalTx=[];
                    end

                    txs=[satTx,gsTx,gimbalTx];
                    if~isempty(txs)
                        links=[txs.Links];
                    else
                        links=[];
                    end

                    for idx=1:numel(links)
                        rxIndexInSequence=find(links(idx).Sequence==rx.ID,1);
                        if~isempty(rxIndexInSequence)
                            delete(links(idx));
                        end
                    end

                    removeFromScenarioGraphics(scenario,rx);
                end


                if(isa(parent,'matlabshared.satellitescenario.internal.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.internal.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.internal.Gimbal')||...
                    isa(parent,'matlabshared.satellitescenario.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.Gimbal'))&&...
                    ~isempty(parent)
                    rxIdx=...
                    find([parent.Receivers.ID]==rx.ID,1);
                    if~isempty(rxIdx)
                        parent.Receivers(rxIdx)=[];
                    end
                end
                removeGraphic(rx);
            end
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.Receiver,?satcom.satellitescenario.coder.Receiver})
        function rx=Receiver(varargin)

            coder.allowpcode('plain');






            if nargin~=0

                name=varargin{1};
                mountingLocation=varargin{2};
                mountingAngles=varargin{3};
                requiredEbNo=varargin{4};
                gainToNoiseTemperatureRatio=varargin{5};
                systemLoss=varargin{6};
                preReceiverLoss=varargin{7};
                antenna=varargin{8};
                parent=varargin{9};

                if isempty(antenna)
                    dishDiameter=1;
                    apertureEfficiency=0.65;
                    antennaConditioned=satcom.satellitescenario.GaussianAntenna(dishDiameter,...
                    apertureEfficiency);
                else
                    antennaConditioned=antenna;
                end

                rx.ParentSimulatorID=parent.SimulatorID;
                rx.ParentType=parent.Type;
                rx.Simulator=parent.Simulator;
                rx.Antenna=antennaConditioned;

                simulator=parent.Simulator;
                parentSimID=parent.SimulatorID;
                parentType=parent.Type;

                simID=addReceiver(simulator,mountingLocation,...
                mountingAngles,parentSimID,parentType,requiredEbNo,...
                gainToNoiseTemperatureRatio,systemLoss,preReceiverLoss,...
                antennaConditioned);

                if isempty(name)||name==""
                    rx.pName="Receiver "+simID;
                else
                    if coder.target('MATLAB')
                        rx.pName=name;
                    else
                        rx.pName=string(name);
                    end
                end

                rx.SimulatorID=simID;
                rx.Type=6;

                if coder.target('MATLAB')

                    rx.pMarkerColor=[1,1,0];


                    rx.Scenario=parent.Scenario;


                    rx.Graphic=genvarname("Receiver"+rx.SimulatorID);



                    rx.Parent=parent;
                end
            end
        end
    end

    methods
        function name=get.Name(rx)


            coder.allowpcode('plain');

            name=rx.pName;
        end

        function reqEbNo=get.RequiredEbNo(rx)


            coder.allowpcode('plain');

            simulator=rx.Simulator;
            assetIdx=getIdxInSimulatorStruct(rx);
            reqEbNo=simulator.Receivers(assetIdx).RequiredEbNo;
        end

        function set.RequiredEbNo(rx,reqEbNo)


            coder.allowpcode('plain');

            validateattributes(reqEbNo,...
            {'numeric'},...
            {'nonempty','finite','real','scalar'},...
            'set.RequiredEbNo','required Eb/No');


            simulator=rx.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'RequiredEbNo');


            assetIdx=getIdxInSimulatorStruct(rx);
            originalReqEbNo=simulator.Receivers(assetIdx).RequiredEbNo;



            if originalReqEbNo~=reqEbNo
                simulator.Receivers(assetIdx).RequiredEbNo=reqEbNo;


                advance(simulator,simulator.Time);

                if simulator.SimulationMode==1



                    updateStateHistory(simulator,true);
                end


                simulator.NeedToSimulate=true;

                if coder.target('MATLAB')&&isa(rx.Scenario,'satelliteScenario')

                    rx.Scenario.NeedToSimulate=true;
                    updateViewers(rx,rx.Scenario.Viewers,false,true);
                end
            end
        end

        function gbyt=get.GainToNoiseTemperatureRatio(rx)


            coder.allowpcode('plain');

            simulator=rx.Simulator;
            assetIdx=getIdxInSimulatorStruct(rx);
            gbyt=simulator.Receivers(assetIdx).GainToNoiseTemperatureRatio;
        end

        function set.GainToNoiseTemperatureRatio(rx,gbyt)


            coder.allowpcode('plain');

            validateattributes(gbyt,...
            {'numeric'},...
            {'nonempty','finite','real','scalar'},...
            'set.GainToNoiseTemperatureRatio','gain to noise temperature ratio');


            simulator=rx.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'GainToNoiseTemperatureRatio');


            assetIdx=getIdxInSimulatorStruct(rx);
            originalGbyt=simulator.Receivers(assetIdx).GainToNoiseTemperatureRatio;



            if originalGbyt~=gbyt
                simulator.Receivers(assetIdx).GainToNoiseTemperatureRatio=gbyt;


                advance(simulator,simulator.Time);

                if simulator.SimulationMode==1



                    updateStateHistory(simulator,true);
                end


                simulator.NeedToSimulate=true;

                if coder.target('MATLAB')&&isa(rx.Scenario,'satelliteScenario')

                    rx.Scenario.NeedToSimulate=true;
                    updateViewers(rx,rx.Scenario.Viewers,false,true);
                end
            end
        end

        function l=get.PreReceiverLoss(rx)


            coder.allowpcode('plain');

            simulator=rx.Simulator;
            assetIdx=getIdxInSimulatorStruct(rx);
            l=simulator.Receivers(assetIdx).PreReceiverLoss;
        end

        function set.PreReceiverLoss(rx,l)


            coder.allowpcode('plain');

            validateattributes(l,...
            {'numeric'},...
            {'nonempty','finite','real','scalar','<=',rx.SystemLoss},...
            'set.PreReceiverLoss','pre-receiver loss');


            simulator=rx.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'PreReceiverLoss');


            assetIdx=getIdxInSimulatorStruct(rx);
            originalLoss=simulator.Receivers(assetIdx).PreReceiverLoss;



            if originalLoss~=l
                simulator.Receivers(assetIdx).PreReceiverLoss=l;


                advance(simulator,simulator.Time);

                if simulator.SimulationMode==1



                    updateStateHistory(simulator,true);
                end


                simulator.NeedToSimulate=true;

                if coder.target('MATLAB')&&isa(rx.Scenario,'satelliteScenario')

                    rx.Scenario.NeedToSimulate=true;
                    updateViewers(rx,rx.Scenario.Viewers,false,true);
                end
            end
        end
    end
end

