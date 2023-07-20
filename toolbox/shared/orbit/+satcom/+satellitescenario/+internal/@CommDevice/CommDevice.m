classdef CommDevice<matlabshared.satellitescenario.internal.AttachedAsset %#codegen




    properties(Dependent)



SystemLoss
    end

    properties(SetAccess={?satcom.satellitescenario.internal.CommDeviceWrapper,...
        ?satcom.satellitescenario.coder.internal.CommDeviceWrapper,...
        ?satcom.satellitescenario.internal.CommDevice})




Antenna
    end

    properties(SetAccess={?satcom.satellitescenario.Pattern,...
        ?satcom.satellitescenario.internal.CommDeviceWrapper,...
        ?satcom.satellitescenario.coder.internal.CommDeviceWrapper})



Pattern
    end

    properties(Dependent,Hidden)
AntennaPatternResolution
    end

    properties(Access={?satcom.satellitescenario.internal.CommDevice,...
        ?satcom.satellitescenario.internal.CommDeviceWrapper})
PointingTarget




    end

    methods
        function loss=get.SystemLoss(asset)


            coder.allowpcode('plain');

            simulator=asset.Simulator;
            assetIdx=getIdxInSimulatorStruct(asset);
            switch asset.Type
            case 5
                loss=...
                simulator.Transmitters(assetIdx).SystemLoss;
            otherwise
                loss=...
                simulator.Receivers(assetIdx).SystemLoss;
            end
        end

        function set.SystemLoss(asset,loss)


            coder.allowpcode('plain');

            if asset.Type==5
                validateattributes(loss,...
                {'numeric'},...
                {'nonempty','finite','real','scalar','nonnegative'},...
                'set.SystemLoss','system loss');
            else
                validateattributes(loss,...
                {'numeric'},...
                {'nonempty','finite','real','scalar','nonnegative','>=',asset.PreReceiverLoss},...
                'set.SystemLoss','system loss');
            end


            simulator=asset.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'SystemLoss');


            assetIdx=getIdxInSimulatorStruct(asset);
            switch asset.Type
            case 5
                originalLoss=simulator.Transmitters(assetIdx).SystemLoss;
                simulator.Transmitters(assetIdx).SystemLoss=loss;
            otherwise
                originalLoss=simulator.Receivers(assetIdx).SystemLoss;
                simulator.Receivers(assetIdx).SystemLoss=loss;
            end

            if originalLoss~=loss


                simulator.NeedToSimulate=true;


                advance(simulator,simulator.Time);



                if simulator.SimulationMode==1
                    updateStateHistory(simulator,true);
                end


                if coder.target('MATLAB')&&isa(asset.Scenario,'satelliteScenario')
                    asset.Scenario.NeedToSimulate=true;
                    updateViewers(asset,asset.Scenario.Viewers,false,true);
                end
            end
        end

        function r=get.AntennaPatternResolution(asset)


            coder.allowpcode('plain');

            simulator=asset.Simulator;
            assetIdx=getIdxInSimulatorStruct(asset);

            switch asset.Type
            case 5
                r=simulator.Transmitters(assetIdx).AntennaPatternResolution;
            otherwise
                r=simulator.Receivers(assetIdx).AntennaPatternResolution;
            end
        end

        function set.AntennaPatternResolution(asset,r)


            coder.allowpcode('plain');

            validateattributes(r,...
            {'numeric'},...
            {'nonempty','finite','real','scalar'},...
            'set.AntennaPatternResolution','pattern resolution');


            simulator=asset.Simulator;
            assetIdx=getIdxInSimulatorStruct(asset);
            switch asset.Type
            case 5
                originalRes=simulator.Transmitters(assetIdx).AntennaPatternResolution;
                simulator.Transmitters(assetIdx).AntennaPatternResolution=r;
            otherwise
                originalRes=simulator.Transmitters(assetIdx).AntennaPatternResolution;
                simulator.Receivers(assetIdx).AntennaPatternResolution=r;
            end

            if originalRes~=r


                simulator.NeedToSimulate=true;


                advance(simulator,simulator.Time);



                if simulator.SimulationMode==1
                    updateStateHistory(simulator,true);
                end


                if coder.target('MATLAB')
                    if isa(asset.Scenario,'satelliteScenario')
                        asset.Scenario.NeedToSimulate=true;
                        updateViewers(asset,asset.Scenario.Viewers,false,true);
                    end
                end
            end
        end
    end

    methods(Hidden)
        updateVisualizations(trx,viewer)
        pat=createPattern(trx,fq,varargin)
    end

    methods
        an=gaussianAntenna(trx,varargin)
    end

    methods(Hidden)
        function ID=getGraphicID(trx)
            ID=trx.Graphic;
        end

        function IDs=getChildGraphicsIDs(trx)
            IDs=[];



            if(~isempty(trx.Pattern)&&isvalid(trx.Pattern)&&...
                strcmp(trx.Pattern.VisibilityMode,'inherit'))
                IDs=[IDs,trx.Pattern.getGraphicID];
            end
        end

        function addCZMLGraphic(trx,writer,times,initiallyVisible)
            id=getGraphicID(trx);
            positions=trx.pPositionHistory';
            markerSize=trx.pMarkerSize;
            markerColor=[trx.pMarkerColor,1];

            addPoint(writer,id,positions,times,...
            'Interpolation','lagrange',...
            'InterpolationDegree',5,...
            'CoordinateDefinition','cartesian',...
            'ReferenceFrame','inertial',...
            'PixelSize',markerSize,...
            'OutlineWidth',1,...
            'Color',markerColor,...
            'DisplayDistance',1000,...
            'ID',id,...
            'InitiallyVisible',initiallyVisible);
        end

        function lnks=getAllRelatedLinks(trx)
            scenario=trx.Scenario;
            allLinks=scenario.Links;
            numGraphics=numel(allLinks);
            lnks=satcom.satellitescenario.Link;


            for k=1:numGraphics
                lnk=allLinks{k};



                for k2=2:numel(lnk.Sequence)
                    if lnk.Sequence(k2)==trx.ID
                        lnks(end+1)=lnk;%#ok<EMGRO> 
                    end
                end
            end
        end
    end
end

