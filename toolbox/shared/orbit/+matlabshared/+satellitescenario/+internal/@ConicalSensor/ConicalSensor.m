classdef ConicalSensor<matlabshared.satellitescenario.internal.AttachedAsset %#codegen




    properties(Dependent,SetAccess={?matlabshared.satellitescenario.internal.ConicalSensor,...
        ?matlabshared.satellitescenario.ConicalSensor,...
        ?matlabshared.satellitescenario.coder.ConicalSensor})




Name
    end

    properties(SetAccess={?satelliteScenario,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Access})


Accesses
    end

    properties(Dependent)




        MaxViewAngle(1,1)double{mustBeNonnegative,mustBeLessThanOrEqual(MaxViewAngle,180)}
    end

    properties(SetAccess={?matlabshared.satellitescenario.Satellite,...
        ?matlabshared.satellitescenario.GroundStation,...
        ?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.ConicalSensor,...
        ?matlabshared.satellitescenario.Viewer})


FieldOfView
    end

    properties(Access={?matlabshared.satellitescenario.ConicalSensor,...
        ?matlabshared.satellitescenario.coder.ConicalSensor,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
        pAccessesAddedBefore=false
    end

    methods
        function delete(sensor)


            coder.allowpcode('plain');

            if coder.target('MATLAB')




                parent=sensor.Parent;



                simulator=sensor.Simulator;
                if isa(simulator,'matlabshared.satellitescenario.internal.Simulator')&&isvalid(simulator)
                    simIndex=getIdxInSimulatorStruct(sensor);
                    simulator.ConicalSensors(simIndex)=[];
                    simulator.NumConicalSensors=simulator.NumConicalSensors-1;
                    simulator.NeedToMemoizeSimID=true;
                end


                accesses=sensor.Accesses;
                for idx=1:numel(accesses)
                    delete(accesses(idx));
                end

                delete(sensor.FieldOfView);




                scenario=sensor.Scenario;
                if isa(scenario,'satelliteScenario')&&isvalid(scenario)
                    sats=scenario.Satellites;
                    if~isempty(sats)
                        satAccesses=[sats.Accesses];
                        satGimbals=[sats.Gimbals];
                        satSensors=[sats.ConicalSensors];
                    else
                        satAccesses=[];
                        satGimbals=[];
                        satSensors=[];
                    end

                    gs=scenario.GroundStations;
                    if~isempty(gs)
                        gsAccesses=[gs.Accesses];
                        gsGimbals=[gs.Gimbals];
                        gsSensors=[gs.ConicalSensors];
                    else
                        gsAccesses=[];
                        gsGimbals=[];
                        gsSensors=[];
                    end

                    gimbals=[satGimbals,gsGimbals];
                    if~isempty(gimbals)
                        gimbalSensors=[gimbals.ConicalSensors];
                    else
                        gimbalSensors=[];
                    end

                    sensors=[satSensors,gsSensors,gimbalSensors];
                    if~isempty(sensors)
                        sensorAccesses=[sensors.Accesses];
                    else
                        sensorAccesses=[];
                    end

                    accesses=[satAccesses,gsAccesses,sensorAccesses];

                    for idx=1:numel(accesses)
                        sensorIndexInSequence=find(accesses(idx).Sequence==sensor.ID,1);
                        if~isempty(sensorIndexInSequence)
                            delete(accesses(idx));
                        end
                    end
                    removeFromScenarioGraphics(scenario,sensor);
                end


                if(isa(parent,'matlabshared.satellitescenario.internal.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.internal.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.internal.Gimbal')||...
                    isa(parent,'matlabshared.satellitescenario.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.Gimbal'))&&...
                    ~isempty(parent)
                    sensorIdx=...
                    find([parent.ConicalSensors.ID]==sensor.ID,1);
                    if~isempty(sensorIdx)
                        parent.ConicalSensors(sensorIdx)=[];
                    end
                end
                removeGraphic(sensor);
            end
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function sensor=ConicalSensor(varargin)


            coder.allowpcode('plain');






            if nargin~=0

                name=varargin{1};
                mountingLocation=varargin{2};
                mountingAngles=varargin{3};
                maxViewAngle=varargin{4};
                parent=varargin{5};


                simulator=parent.Simulator;
                parentSimID=parent.ID;
                parentType=parent.Type;


                simID=addConicalSensor(simulator,mountingLocation,...
                mountingAngles,maxViewAngle,parentSimID,parentType);


                if isempty(name)||name==""
                    sensor.pName="Conical sensor "+simID;
                else
                    if coder.target('MATLAB')
                        sensor.pName=name;
                    else
                        sensor.pName=string(name);
                    end
                end


                sensor.ParentSimulatorID=parentSimID;
                sensor.ParentType=parentType;
                sensor.SimulatorID=simID;
                sensor.Simulator=simulator;
                sensor.Type=3;


                sensor.Accesses=matlabshared.satellitescenario.Access;

                if isempty(coder.target)

                    sensor.pMarkerColor=[1,0,1];


                    sensor.Scenario=parent.Scenario;


                    sensor.Graphic="ConicalSensor"+simID;



                    sensor.Parent=parent;
                end
            else
                if~coder.target('MATLAB')
                    sensor.pName="";
                    sensor.SimulatorID=0;
                    sensor.Type=0;
                end
            end
        end
    end

    methods
        function name=get.Name(sensor)


            coder.allowpcode('plain');

            name=string(sensor.pName);
        end

        function maxViewAngle=get.MaxViewAngle(sensor)


            coder.allowpcode('plain');

            simulator=sensor.Simulator;
            sensorIdx=getIdxInSimulatorStruct(sensor);
            maxViewAngle=...
            simulator.ConicalSensors(sensorIdx).MaxViewAngle;
        end

        function set.MaxViewAngle(sensor,maxViewAngle)


            coder.allowpcode('plain');


            simulator=sensor.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
            'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
            'MaxViewAngle');


            sensorIdx=getIdxInSimulatorStruct(sensor);
            originalMaxViewAngle=...
            simulator.ConicalSensors(sensorIdx).MaxViewAngle;



            if~isequal(originalMaxViewAngle,maxViewAngle)
                simulator.ConicalSensors(sensorIdx).MaxViewAngle=...
                maxViewAngle;



                advance(simulator,simulator.Time);



                if simulator.SimulationMode==1
                    donotAddNewSample=true;
                    updateStateHistory(simulator,donotAddNewSample);
                end



                simulator.NeedToSimulate=true;

                if coder.target('MATLAB')&&isa(sensor.Scenario,'satelliteScenario')

                    sensor.Scenario.NeedToSimulate=true;
                    updateViewers(sensor,sensor.Scenario.Viewers,false,true);
                end
            end
        end
    end

    methods(Hidden)
        updateVisualizations(sensors,viewer)
    end

    methods(Hidden)
        function ID=getGraphicID(sensor)
            ID=sensor.Graphic;
        end

        function IDs=getChildGraphicsIDs(sensor)
            IDs=[];



            if(~isempty(sensor.FieldOfView)&&isvalid(sensor.FieldOfView)&&...
                strcmp(sensor.FieldOfView.VisibilityMode,'inherit'))
                IDs=[IDs,sensor.FieldOfView.getGraphicID,sensor.FieldOfView.getChildGraphicsIDs];
            end
        end

        function addCZMLGraphic(sensor,writer,times,initiallyVisible)
            id=sensor.getGraphicID;
            positions=sensor.pPositionHistory';
            markerSize=sensor.pMarkerSize;
            markerColor=[sensor.pMarkerColor,1];

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

