classdef Transmitter<satcom.satellitescenario.internal.CommDevice %#codegen




    properties(Dependent,SetAccess={?matlabshared.satellitescenario.Transmitter,...
        ?matlabshared.satellitescenario.coder.Transmitter})




Name
    end

    properties(Dependent)



Frequency



BitRate



Power
    end

    properties(SetAccess={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.ScenarioGraphicBase,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})


Links
    end

    properties(Access={?satcom.satellitescenario.Transmitter,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
        pLinksAddedBefore=false
    end

    methods
        function delete(tx)


            coder.allowpcode('plain');

            if coder.target('MATLAB')




                parent=tx.Parent;



                simulator=tx.Simulator;
                if isa(simulator,'matlabshared.satellitescenario.internal.Simulator')&&isvalid(simulator)
                    simIndex=getIdxInSimulatorStruct(tx);
                    simulator.Transmitters(simIndex)=[];
                    simulator.NumTransmitters=simulator.NumTransmitters-1;
                    simulator.NeedToMemoizeSimID=true;
                end


                if isa(tx.Antenna,'satcom.satellitescenario.GaussianAntenna')
                    delete(tx.Antenna);
                end


                links=tx.Links;
                for idx=1:numel(links)
                    delete(links(idx));
                end


                scenario=tx.Scenario;
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
                        txIndexInSequence=find(links(idx).Sequence==tx.ID,1);
                        if~isempty(txIndexInSequence)
                            delete(links(idx));
                        end
                    end

                    removeFromScenarioGraphics(scenario,tx);
                end


                if(isa(parent,'matlabshared.satellitescenario.internal.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.internal.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.internal.Gimbal')||...
                    isa(parent,'matlabshared.satellitescenario.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.Gimbal'))&&...
                    ~isempty(parent)
                    txIdx=...
                    find([parent.Transmitters.ID]==tx.ID,1);
                    if~isempty(txIdx)
                        parent.Transmitters(txIdx)=[];
                    end
                end
                removeGraphic(tx);
            end
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.Transmitter,?satcom.satellitescenario.coder.Transmitter})
        function tx=Transmitter(varargin)

            coder.allowpcode('plain');






            if nargin~=0

                name=varargin{1};
                mountingLocation=varargin{2};
                mountingAngles=varargin{3};
                frequency=varargin{4};
                bitRate=varargin{5};
                power=varargin{6};
                systemLoss=varargin{7};
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

                tx.ParentSimulatorID=parent.SimulatorID;
                tx.ParentType=parent.Type;
                tx.Simulator=parent.Simulator;
                tx.Antenna=antennaConditioned;

                simulator=parent.Simulator;
                parentSimID=parent.SimulatorID;
                parentType=parent.Type;

                simID=addTransmitter(simulator,mountingLocation,...
                mountingAngles,parentSimID,parentType,frequency,...
                bitRate,power,systemLoss,antennaConditioned);

                if isempty(name)||name==""
                    tx.pName="Transmitter "+simID;
                else
                    if coder.target('MATLAB')
                        tx.pName=name;
                    else
                        tx.pName=string(name);
                    end
                end

                tx.SimulatorID=simID;
                tx.Type=5;


                tx.Links=satcom.satellitescenario.Link;

                if coder.target('MATLAB')

                    tx.pMarkerColor=[0,1,0];


                    tx.Scenario=parent.Scenario;


                    tx.Graphic="Transmitter"+tx.SimulatorID;



                    tx.Parent=parent;
                end
            else
                tx.pName="";
                tx.SimulatorID=0;
                tx.Type=0;
            end
        end
    end

    methods
        function name=get.Name(tx)


            coder.allowpcode('plain');

            name=tx.pName;
        end

        function f=get.Frequency(tx)


            coder.allowpcode('plain');

            simulator=tx.Simulator;
            assetIdx=getIdxInSimulatorStruct(tx);
            f=simulator.Transmitters(assetIdx).Frequency;
        end

        function set.Frequency(tx,f)


            coder.allowpcode('plain');

            validateattributes(f,...
            {'numeric'},...
            {'nonempty','finite','real','scalar','nonnegative'},...
            'set.Frequency','frequency');


            simulator=tx.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'Frequency');


            assetIdx=getIdxInSimulatorStruct(tx);
            originalF=simulator.Transmitters(assetIdx).Frequency;


            if f~=originalF
                simulator.Transmitters(assetIdx).Frequency=f;

                if isempty(coder.target)&&simulator.SimulationMode==1

                    updateAntennaPattern(tx);
                end


                advance(simulator,simulator.Time);

                if simulator.SimulationMode==1



                    updateStateHistory(simulator,true);
                end


                simulator.NeedToSimulate=true;


                if coder.target('MATLAB')&&isa(tx.Scenario,'satelliteScenario')
                    tx.Scenario.NeedToSimulate=true;
                    updateViewers(tx,tx.Scenario.Viewers,false,true);
                    if~isempty(tx.Pattern)&&isvalid(tx.Pattern)
                        tx.Pattern.Frequency=f;
                        updateViewers(tx.Pattern,tx.Scenario.Viewers,false,true);
                    end
                end
            end
        end

        function br=get.BitRate(tx)


            coder.allowpcode('plain');

            simulator=tx.Simulator;
            assetIdx=getIdxInSimulatorStruct(tx);
            br=simulator.Transmitters(assetIdx).BitRate;
        end

        function set.BitRate(tx,br)


            coder.allowpcode('plain');

            validateattributes(br,...
            {'numeric'},...
            {'nonempty','finite','real','scalar','positive'},...
            'set.BitRate','bit rate');


            simulator=tx.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'BitRate');


            assetIdx=getIdxInSimulatorStruct(tx);
            originalBr=simulator.Transmitters(assetIdx).BitRate;


            if originalBr~=br
                simulator.Transmitters(assetIdx).BitRate=br;


                advance(simulator,simulator.Time);

                if simulator.SimulationMode==1



                    updateStateHistory(simulator,true);
                end


                simulator.NeedToSimulate=true;

                if coder.target('MATLAB')&&isa(tx.Scenario,'satelliteScenario')

                    tx.Scenario.NeedToSimulate=true;
                    updateViewers(tx,tx.Scenario.Viewers,false,true);
                end
            end
        end

        function p=get.Power(tx)


            coder.allowpcode('plain');

            simulator=tx.Simulator;
            assetIdx=getIdxInSimulatorStruct(tx);
            p=simulator.Transmitters(assetIdx).Power;
        end

        function set.Power(tx,p)


            coder.allowpcode('plain');

            validateattributes(p,...
            {'numeric'},...
            {'nonempty','finite','real','scalar'},...
            'set.Power','power');


            simulator=tx.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'Power');


            assetIdx=getIdxInSimulatorStruct(tx);
            originalP=simulator.Transmitters(assetIdx).Power;


            if originalP~=p
                simulator.Transmitters(assetIdx).Power=p;


                advance(simulator,simulator.Time);

                if simulator.SimulationMode==1



                    updateStateHistory(simulator,true);
                end


                simulator.NeedToSimulate=true;

                if coder.target('MATLAB')&&isa(tx.Scenario,'satelliteScenario')

                    tx.Scenario.NeedToSimulate=true;
                    updateViewers(tx,tx.Scenario.Viewers,false,true);
                end
            end
        end
    end

    methods(Access=private)
        updateAntennaPattern(tx)
    end
end

