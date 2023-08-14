classdef GroundStation<matlabshared.satellitescenario.internal.PrimaryAsset %#codegen




    properties(Dependent,SetAccess=?matlabshared.satellitescenario.GroundStation)













Name














Latitude















Longitude











Altitude
    end

    properties(Dependent)















        MinElevationAngle(1,1)double{mustBeGreaterThanOrEqual(MinElevationAngle,-90),mustBeLessThanOrEqual(MinElevationAngle,90)}




        MarkerColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor



        MarkerSize(1,1)double{mustBePositive(MarkerSize),mustBeLessThanOrEqual(MarkerSize,30)}



        ShowLabel(1,1)logical



        LabelFontSize(1,1)double{mustBeGreaterThanOrEqual(LabelFontSize,6),mustBeLessThanOrEqual(LabelFontSize,30)}




        LabelFontColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor
    end

    properties(Access={?matlabshared.satellitescenario.Viewer,?matlabshared.satellitescenario.GroundStation})
GroundStationGraphic
LabelGraphic
    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.GroundStation,?matlabshared.satellitescenario.Viewer,?satelliteScenario})
        pMarkerSize(1,1)double{mustBePositive(pMarkerSize),mustBeLessThanOrEqual(pMarkerSize,30)}=6
        pMarkerColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.GroundStationMarkerColor
        pShowLabel(1,1)logical=true
        pLabelFontSize(1,1)double{mustBeGreaterThanOrEqual(pLabelFontSize,6),mustBeLessThanOrEqual(pLabelFontSize,30)}=15
        pLabelFontColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.GroundStationLabelFontColor
    end

    properties(Access=?matlabshared.satellitescenario.GroundStation)
        pMinElevationAngle=0
    end

    methods
        function delete(gs)

            coder.allowpcode('plain');

            if isempty(coder.target)




                scenario=gs.Scenario;



                if isa(scenario,'satelliteScenario')&&isvalid(scenario)
                    simulator=gs.Simulator;
                    simIndex=getIdxInSimulatorStruct(gs);
                    simulator.GroundStations(simIndex)=[];
                    simulator.NumGroundStations=simulator.NumGroundStations-1;
                    simulator.NeedToMemoizeSimID=true;
                end



                sensors=gs.ConicalSensors;
                for idx=1:numel(sensors)
                    delete(sensors(idx));
                end


                gimbals=gs.Gimbals;
                for idx=1:numel(gimbals)
                    delete(gimbals(idx));
                end


                tx=gs.Transmitters;
                for idx=1:numel(tx)
                    delete(tx(idx));
                end


                rx=gs.Receivers;
                for idx=1:numel(rx)
                    delete(rx(idx));
                end


                accesses=gs.Accesses;
                for idx=1:numel(accesses)
                    delete(accesses(idx));
                end




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

                    gss=scenario.GroundStations;
                    if~isempty(gss)
                        gsAccesses=[gss.Accesses];
                        gsGimbals=[gss.Gimbals];
                        gsSensors=[gss.ConicalSensors];
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
                        gsIndexInSequence=find(accesses(idx).Sequence==gs.ID,1);
                        if~isempty(gsIndexInSequence)
                            delete(accesses(idx));
                        end
                    end
                end



                if isa(scenario,'satelliteScenario')&&~isempty(scenario)&&isvalid(scenario)
                    gsIdx=find(scenario.GroundStations==gs,1);
                    if~isempty(gsIdx)
                        scenario.GroundStations(gsIdx)=[];
                    end
                    removeFromScenarioGraphics(scenario,gs);
                end
                removeGraphic(gs);
            end
        end

        function name=get.Name(sat)


            coder.allowpcode('plain');

            name=string(sat.pName);
        end

        function set.Name(gs,name)


            coder.allowpcode('plain');

            gs.pName=name;
        end

        function latitude=get.Latitude(gs)


            coder.allowpcode('plain');

            latitude=gs.pLatitude;
        end

        function set.Latitude(gs,lat)


            coder.allowpcode('plain');

            gs.pLatitude=lat;
        end

        function longitude=get.Longitude(sat)


            coder.allowpcode('plain');

            longitude=sat.pLongitude;
        end

        function set.Longitude(gs,lon)


            coder.allowpcode('plain');

            gs.pLongitude=lon;
        end

        function altitude=get.Altitude(sat)


            coder.allowpcode('plain');

            altitude=sat.pAltitude;
        end

        function set.Altitude(gs,alt)


            coder.allowpcode('plain');

            gs.pAltitude=alt;
        end

        function minElevationAngle=get.MinElevationAngle(sat)


            coder.allowpcode('plain');

            minElevationAngle=sat.pMinElevationAngle;
        end

        function set.MinElevationAngle(gs,minElevationAngle)


            coder.allowpcode('plain');


            validateattributes(minElevationAngle,{'double'},...
            {'nonempty','scalar','real','finite','>=',-90,...
            '<=',90});



            if~isequal(gs.pMinElevationAngle,minElevationAngle)
                gs.pMinElevationAngle=minElevationAngle;


                simulator=gs.Simulator;


                coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
                'shared_orbit:orbitPropagator:UnableTunablePropertySetIncorrectSimStatus',...
                'MinElevationAngle');

                gsIdx=find(...
                [simulator.GroundStations.ID]==gs.SimulatorID,1);
                simulator.GroundStations(gsIdx).MinElevationAngle=...
                minElevationAngle;



                advance(simulator,simulator.Time);



                if simulator.SimulationMode==1
                    updateStateHistory(simulator,true);
                end



                simulator.NeedToSimulate=true;
                if coder.target('MATLAB')&&isa(gs.Scenario,'satelliteScenario')
                    gs.Scenario.NeedToSimulate=true;
                    updateViewers(gs,gs.Scenario.Viewers,false,true);
                end
            end
        end

        function markerSize=get.MarkerSize(gs)
            markerSize=gs.pMarkerSize;
        end

        function markerColor=get.MarkerColor(gs)
            markerColor=gs.pMarkerColor;
        end

        function showLabel=get.ShowLabel(gs)
            showLabel=gs.pShowLabel;
        end

        function labelFontSize=get.LabelFontSize(gs)
            labelFontSize=gs.pLabelFontSize;
        end

        function labelFontColor=get.LabelFontColor(gs)
            labelFontColor=gs.pLabelFontColor;
        end

        function set.MarkerSize(gs,markerSize)
            gs.pMarkerSize=markerSize;
            if isa(gs.Scenario,'satelliteScenario')
                updateViewers(gs,gs.Scenario.Viewers,false,true);
            end
        end

        function set.MarkerColor(gs,markerColor)
            gs.pMarkerColor=markerColor;
            if isa(gs.Scenario,'satelliteScenario')
                updateViewers(gs,gs.Scenario.Viewers,false,true);
            end
        end

        function set.ShowLabel(gs,showLabel)
            gs.pShowLabel=showLabel;
            if isa(gs.Scenario,'satelliteScenario')
                updateViewers(gs,gs.Scenario.Viewers,false,true);
            end
        end

        function set.LabelFontSize(gs,labelFontSize)
            gs.pLabelFontSize=labelFontSize;
            if isa(gs.Scenario,'satelliteScenario')
                updateViewers(gs,gs.Scenario.Viewers,false,true);
            end
        end

        function set.LabelFontColor(gs,labelFontColor)
            gs.pLabelFontColor=labelFontColor;
            if isa(gs.Scenario,'satelliteScenario')
                updateViewers(gs,gs.Scenario.Viewers,false,true);
            end
        end
    end

    methods(Hidden)
        updateVisualizations(gs,viewer)
        function ID=getGraphicID(gs)
            ID=gs.GroundStationGraphic;
        end

        function IDs=getChildGraphicsIDs(gs)
            IDs=[];



            if(gs.ShowLabel)
                IDs=[IDs,gs.LabelGraphic];
            end



            for idx=1:numel(gs.Gimbals)
                gim=gs.Gimbals(idx);
                if strcmp(gim.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(gim)];
                end
                IDs=[IDs,getChildGraphicsIDs(gim)];
            end

            for idx=1:numel(gs.ConicalSensors)
                sensor=gs.ConicalSensors(idx);
                if strcmp(sensor.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(sensor)];
                end
                IDs=[IDs,getChildGraphicsIDs(sensor)];
            end

            for idx=1:numel(gs.Transmitters)
                tx=gs.Transmitters(idx);
                if strcmp(tx.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(tx)];
                end
            end

            for idx=1:numel(gs.Receivers)
                rx=gs.Receivers(idx);
                if strcmp(rx.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(rx)];
                end
            end
        end


        function ids=hideInViewerState(gs,viewer)
            ids=hideInViewerState@matlabshared.satellitescenario.ScenarioGraphic(gs,viewer);


            viewer.DeclutterMap.(gs.getGraphicID).childVisibility=false;
        end

        function addCZMLGraphic(gs,writer,~,initiallyVisible)

            position=gs.pPositionHistory;


            time=gs.Simulator.TimeHistory;


            addPoint(writer,gs.GroundStationGraphic,position',time,...
            'PixelSize',gs.MarkerSize,...
            'OutlineWidth',1,...
            'Color',[gs.MarkerColor,1],...
            'Interpolation','lagrange',...
            'InterpolationDegree',5,...
            'CoordinateDefinition','cartesian',...
            'ReferenceFrame','inertial',...
            'ID',gs.GroundStationGraphic,...
            'InitiallyVisible',initiallyVisible,...
            'ShowTooltip',true,...
            'LinkedGraphic',gs.LabelGraphic);



            addLabel(writer,gs.LabelGraphic,position',time,gs.Name,...
            'PixelOffset',[15,0],...
            'FontSize',gs.LabelFontSize*2,...
            'Scale',0.5,...
            'Color',[gs.LabelFontColor,1],...
            'Interpolation','lagrange',...
            'InterpolationDegree',5,...
            'CoordinateDefinition','cartesian',...
            'ReferenceFrame','inertial',...
            'ID',gs.LabelGraphic,...
            'InitiallyVisible',gs.ShowLabel);
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function gs=GroundStation(varargin)



            coder.allowpcode('plain');






            if nargin~=0

                name=varargin{1};
                lat=varargin{2};
                lon=varargin{3};
                alt=varargin{4};
                minElevationAngle=varargin{5};
                simulator=varargin{6};
                scenario=varargin{7};



                simID=addGroundStation(simulator,lat,...
                lon,alt,minElevationAngle);


                if isempty(name)||name==""
                    gs.pName=['Ground station ',sprintf('%.0f',simID)];
                else
                    if coder.target('MATLAB')
                        gs.pName=name;
                    else
                        gs.pName=char(name);
                    end
                end
                gs.pMinElevationAngle=minElevationAngle;
                gs.Simulator=simulator;
                gs.SimulatorID=simID;
                gs.Type=2;


                gs.Gimbals=matlabshared.satellitescenario.Gimbal;


                gs.ConicalSensors=matlabshared.satellitescenario.ConicalSensor;


                gs.Accesses=matlabshared.satellitescenario.Access;


                gs.Transmitters=satcom.satellitescenario.Transmitter;


                gs.Receivers=satcom.satellitescenario.Receiver;

                if isempty(coder.target)

                    gs.Scenario=scenario;


                    gs.GroundStationGraphic="GroundStation"+gs.ID;
                    gs.LabelGraphic=gs.GroundStationGraphic+" label ID";
                end
            else
                if~coder.target('MATLAB')
                    gs.pName='';
                    gs.SimulatorID=0;
                    gs.Type=0;
                end
            end
        end
    end
end


