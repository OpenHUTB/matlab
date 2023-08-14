classdef Gimbal<matlabshared.satellitescenario.internal.AttachedAsset %#codegen





    properties(Dependent,SetAccess={?matlabshared.satellitescenario.internal.Gimbal,...
        ?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.coder.Gimbal})



Name
    end

    properties(SetAccess={?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.coder.internal.Access})


ConicalSensors


Transmitters


Receivers
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.internal.Gimbal,...
        ?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.coder.Gimbal})
GimbalAzimuth
GimbalElevation
GimbalAzimuthHistory
GimbalElevationHistory
    end

    properties(Access={?matlabshared.satellitescenario.internal.Gimbal,...
        ?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.coder.Gimbal})
PointingTarget



    end

    properties(Access={?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.coder.Gimbal,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
        pConicalSensorsAddedBefore=false
        pTransmittersAddedBefore=false
        pReceiversAddedBefore=false
    end

    methods
        function delete(gim)


            coder.allowpcode('plain');

            if coder.target('MATLAB')




                parent=gim.Parent;



                simulator=gim.Simulator;
                if isa(simulator,'matlabshared.satellitescenario.internal.Simulator')&&isvalid(simulator)
                    simIndex=getIdxInSimulatorStruct(gim);
                    simulator.Gimbals(simIndex)=[];
                    simulator.NumGimbals=simulator.NumGimbals-1;
                    simulator.NeedToMemoizeSimID=true;
                end


                sensors=gim.ConicalSensors;
                for idx=1:numel(sensors)
                    delete(sensors(idx));
                end


                tx=gim.Transmitters;
                for idx=1:numel(tx)
                    delete(tx(idx));
                end


                rx=gim.Receivers;
                for idx=1:numel(rx)
                    delete(rx(idx));
                end


                if(isa(parent,'matlabshared.satellitescenario.internal.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.internal.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.GroundStation'))&&...
                    ~isempty(parent)
                    gimbalIdx=...
                    find([parent.Gimbals.ID]==gim.ID,1);
                    if~isempty(gimbalIdx)
                        parent.Gimbals(gimbalIdx)=[];
                    end
                    scenario=parent.Scenario;
                    if isa(scenario,'satelliteScenario')
                        removeFromScenarioGraphics(scenario,gim);
                    end
                end
                removeGraphic(gim);
            end
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function gim=Gimbal(varargin)


            coder.allowpcode('plain');






            if nargin~=0

                name=varargin{1};
                mountingLocation=varargin{2};
                mountingAngles=varargin{3};
                parent=varargin{4};


                simulator=parent.Simulator;
                parentSimID=parent.ID;
                parentType=parent.Type;

                simID=addGimbal(simulator,mountingLocation,...
                mountingAngles,parentSimID,parentType);

                if isempty(name)||name==""
                    gim.pName="Gimbal "+simID;
                else
                    if coder.target('MATLAB')
                        gim.pName=name;
                    else
                        gim.pName=string(name);
                    end
                end
                gim.ParentSimulatorID=parentSimID;
                gim.ParentType=parentType;
                gim.SimulatorID=simID;
                gim.Simulator=simulator;
                gim.Type=4;


                ptTarget=-2;
                coder.varsize('ptTarget',[3,3],[1,1]);
                gim.PointingTarget=ptTarget;


                gim.ConicalSensors=matlabshared.satellitescenario.ConicalSensor;


                gim.Transmitters=satcom.satellitescenario.Transmitter;


                gim.Receivers=satcom.satellitescenario.Receiver;

                if coder.target('MATLAB')

                    gim.pMarkerColor=[0,1,1];


                    scenario=parent.Scenario;
                    gim.Scenario=scenario;


                    gim.Graphic="Gimbal"+simID;



                    gim.Parent=parent;
                end
            else
                if~coder.target('MATLAB')
                    gim.pName="";
                    gim.SimulatorID=0;
                    gim.Type=4;
                end
            end
        end
    end

    methods
        function name=get.Name(gim)


            coder.allowpcode('plain');

            name=gim.pName;
        end

        function gimbalAzimuth=get.GimbalAzimuth(gim)


            coder.allowpcode('plain');

            simulator=gim.Simulator;
            gimIdx=getIdxInSimulatorStruct(gim);
            gimbalAzimuth=simulator.Gimbals(gimIdx).GimbalAzimuth;
        end

        function gimbalElevation=get.GimbalElevation(gim)


            coder.allowpcode('plain');

            simulator=gim.Simulator;
            gimIdx=getIdxInSimulatorStruct(gim);
            gimbalElevation=simulator.Gimbals(gimIdx).GimbalElevation;
        end

        function gimbalAzimuthHistory=get.GimbalAzimuthHistory(gim)


            coder.allowpcode('plain');

            simulator=gim.Simulator;
            gimIdx=getIdxInSimulatorStruct(gim);
            gimbalAzimuthHistory=...
            simulator.Gimbals(gimIdx).GimbalAzimuthHistory;
        end

        function gimbalElevationHistory=get.GimbalElevationHistory(gim)


            coder.allowpcode('plain');

            simulator=gim.Simulator;
            gimIdx=getIdxInSimulatorStruct(gim);
            gimbalElevationHistory=...
            simulator.Gimbals(gimIdx).GimbalElevationHistory;
        end
    end

    methods(Static,Access={?matlabshared.satellitescenario.internal.Simulator})
        [positionITRF,positionGeographic,attitude,itrf2BodyTransform,ned2bodyTransform,steeringAngles]=...
        getPositionOrientationAndSteeringAngles(asset,parent,targetPositionITRF,needToSteer)
    end

    methods(Hidden)
        updateVisualizations(gimbals,viewer)
    end

    methods(Hidden)
        function ID=getGraphicID(gim)
            ID=gim.Graphic;
        end

        function IDs=getChildGraphicsIDs(gim)
            IDs=[];



            for idx=1:numel(gim.ConicalSensors)
                sensor=gim.ConicalSensors(idx);
                if strcmp(sensor.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(sensor)];
                end
                IDs=[IDs,getChildGraphicsIDs(sensor)];
            end

            for idx=1:numel(gim.Transmitters)
                tx=gim.Transmitters(idx);
                if strcmp(tx.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(tx)];
                end
            end

            for idx=1:numel(gim.Receivers)
                rx=gim.Receivers(idx);
                if strcmp(rx.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(rx)];
                end
            end
        end

        function addCZMLGraphic(gim,writer,times,initiallyVisible)
            id=gim.getGraphicID;
            positions=gim.pPositionHistory';
            markerSize=gim.pMarkerSize;
            markerColor=[gim.pMarkerColor,1];

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
    end
end

