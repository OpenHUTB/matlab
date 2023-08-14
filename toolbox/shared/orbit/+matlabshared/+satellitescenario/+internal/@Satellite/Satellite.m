classdef Satellite<matlabshared.satellitescenario.internal.PrimaryAsset %#codegen




    properties(Dependent,SetAccess=protected)

Name
    end

    properties(SetAccess={?satelliteScenario,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.Satellite})

OrbitPropagator

Orbit

GroundTrack
    end

    properties(Dependent)




        MarkerColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor



        MarkerSize(1,1)double{mustBePositive(MarkerSize),mustBeLessThanOrEqual(MarkerSize,30)}



        ShowLabel(1,1)logical



        LabelFontSize(1,1)double{mustBeGreaterThanOrEqual(LabelFontSize,6),mustBeLessThanOrEqual(LabelFontSize,30)}




        LabelFontColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor
    end

    properties(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.Satellite})
SatelliteGraphic
LabelGraphic
PropagatorTBK
PropagatorSGP4
PropagatorSDP4
PropagatorEphemeris
PropagatorGPS
        PropagatorType=0
    end

    properties(Access={?matlabshared.satellitescenario.Satellite,...
        ?matlabshared.satellitescenario.coder.Satellite})
PointingTarget



    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic,?matlabshared.satellitescenario.Satellite,?satelliteScenario,?matlabshared.satellitescenario.Viewer})
        pShowLabel(1,1)logical=true
    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic,?matlabshared.satellitescenario.Satellite})
        pLabelFontSize(1,1)double{mustBeGreaterThanOrEqual(pLabelFontSize,6),mustBeLessThanOrEqual(pLabelFontSize,30)}=15
        pLabelFontColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.SatelliteLabelFontColor
        pMarkerSize(1,1)double{mustBePositive(pMarkerSize),mustBeLessThanOrEqual(pMarkerSize,30)}=6
        pMarkerColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.SatelliteMarkerColor
    end

    properties(Dependent,Hidden,SetAccess=private)
Attitude
AttitudeHistory
    end


    methods
        function markerSize=get.MarkerSize(sat)
            markerSize=sat.pMarkerSize;
        end

        function markerColor=get.MarkerColor(sat)
            markerColor=sat.pMarkerColor;
        end

        function showLabel=get.ShowLabel(sat)
            showLabel=sat.pShowLabel;
        end

        function labelFontSize=get.LabelFontSize(sat)
            labelFontSize=sat.pLabelFontSize;
        end

        function labelFontColor=get.LabelFontColor(sat)
            labelFontColor=sat.pLabelFontColor;
        end

        function set.MarkerSize(sat,markerSize)
            sat.pMarkerSize=markerSize;
            if isa(sat.Scenario,'satelliteScenario')
                updateViewers(sat,sat.Scenario.Viewers,false,true);
            end
        end

        function set.MarkerColor(sat,markerColor)
            sat.pMarkerColor=markerColor;
            if isa(sat.Scenario,'satelliteScenario')
                updateViewers(sat,sat.Scenario.Viewers,false,true);
            end
        end

        function set.ShowLabel(sat,showLabel)
            sat.pShowLabel=showLabel;
            if isa(sat.Scenario,'satelliteScenario')
                updateViewers(sat,sat.Scenario.Viewers,false,true);
            end
        end

        function set.LabelFontSize(sat,labelFontSize)
            sat.pLabelFontSize=labelFontSize;
            if isa(sat.Scenario,'satelliteScenario')
                updateViewers(sat,sat.Scenario.Viewers,false,true);
            end
        end

        function set.LabelFontColor(sat,labelFontColor)
            sat.pLabelFontColor=labelFontColor;
            if isa(sat.Scenario,'satelliteScenario')
                updateViewers(sat,sat.Scenario.Viewers,false,true);
            end
        end
    end

    methods
        function delete(sat)


            coder.allowpcode('plain');

            if isempty(coder.target)




                scenario=sat.Scenario;



                if isa(scenario,'satelliteScenario')&&isvalid(scenario)
                    simulator=sat.Simulator;
                    simIndex=getIdxInSimulatorStruct(sat);
                    simulator.Satellites(simIndex)=[];
                    simulator.NumSatellites=simulator.NumSatellites-1;
                    simulator.NeedToMemoizeSimID=true;
                end


                sensors=sat.ConicalSensors;
                for idx=1:numel(sensors)
                    delete(sensors(idx));
                end


                gimbals=sat.Gimbals;
                for idx=1:numel(gimbals)
                    delete(gimbals(idx));
                end


                tx=sat.Transmitters;
                for idx=1:numel(tx)
                    delete(tx(idx));
                end


                rx=sat.Receivers;
                for idx=1:numel(rx)
                    delete(rx(idx));
                end


                accesses=sat.Accesses;
                for idx=1:numel(accesses)
                    delete(accesses(idx));
                end


                delete(sat.Orbit);


                delete(sat.GroundTrack);




                scenario=sat.Scenario;
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
                        satIndexInSequence=find(accesses(idx).Sequence==sat.ID,1);
                        if~isempty(satIndexInSequence)
                            delete(accesses(idx));
                        end
                    end
                end


                if isa(scenario,'satelliteScenario')&&~isempty(scenario)&&isvalid(scenario)
                    satIdx=[];
                    satHandles=scenario.Satellites.Handles;
                    numHandles=numel(satHandles);
                    for k=1:numHandles
                        if satHandles{k}.ID==sat.ID
                            satIdx=k;
                            break;
                        end
                    end
                    if~isempty(satIdx)
                        scenario.Satellites(satIdx)=[];
                    end

                    removeFromScenarioGraphics(scenario,sat);
                end
                removeGraphic(sat);
            end
        end

        function name=get.Name(sat)


            coder.allowpcode('plain');

            name=string(sat.pName);
        end

        function attitude=get.Attitude(sat)


            coder.allowpcode('plain');

            attitude=sat.pAttitude;
        end

        function attitudeHistory=get.AttitudeHistory(sat)


            coder.allowpcode('plain');

            attitudeHistory=sat.pAttitudeHistory;
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function sat=Satellite(varargin)



            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                sat.PropagatorTBK=defaultTwoBodyKeplerian;
                sat.PropagatorSGP4=defaultSGP4;
                sat.PropagatorSDP4=defaultSDP4;
                sat.PropagatorEphemeris=defaultEphemeris;
                sat.PropagatorGPS=defaultGPS;


                placeHolderNameChar='ab';
                coder.varsize('placeHolderNameChar')
                sat.pName=placeHolderNameChar;




                sat.OrbitPropagator="ab";
                sat.OrbitPropagator="a";
            end






            if nargin~=0



                names=varargin{1};
                orbitPropagator=varargin{2};
                simulator=varargin{3};
                scenario=varargin{4};
                if nargin==10




                    semiMajorAxis=varargin{5};
                    eccentricity=varargin{6};
                    inclination=varargin{7};
                    rightAscensionOfAscendingNode=varargin{8};
                    argumentOfPeriapsis=varargin{9};
                    trueAnomaly=varargin{10};

                    initMode="keplerian";
                elseif nargin==7



                    ephemerisSourcePosTable=varargin{5};
                    ephemerisSourceVelTable=varargin{6};
                    coordFrame=varargin{7};

                    initMode="timetable";
                elseif nargin==5



                    currentTLEData=varargin{5};
                    initMode="tle";
                else


                    currentSEMData=varargin{5};
                    gpsTimeData=varargin{6};
                    initMode="gnss";
                end


                initialTime=simulator.StartTime;



                minSDP4Period=...
                matlabshared.orbit.internal.GeneralPerturbations.MinSDP4Period;


                itrf2gcrfTransform=matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(initialTime);


                omega=[0;0;matlabshared.orbit.internal.OrbitPropagationModel.EarthAngularVelocity];


                switch orbitPropagator
                case 'two-body-keplerian'
                    if initMode=="tle"||initMode=="gnss"




                        if initMode=="tle"


                            meanMotionTLE=currentTLEData.MeanMotion;
                            periodTLE=2*pi/meanMotionTLE;
                            if periodTLE<minSDP4Period
                                [position,velocity]=...
                                matlabshared.orbit.internal.SGP4.propagate(...
                                currentTLEData,initialTime);
                            else
                                [position,velocity]=...
                                matlabshared.orbit.internal.SDP4.propagate(...
                                currentTLEData,initialTime);
                            end




                            position=...
                            matlabshared.orbit.internal.Transforms.teme2itrf(...
                            position,initialTime);
                            velocity=...
                            matlabshared.orbit.internal.Transforms.teme2itrf(...
                            velocity,initialTime);



                            itrf2gcrfTransform=matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(initialTime);
                            position=itrf2gcrfTransform*position;
                            velocity=itrf2gcrfTransform*velocity;
                        else


                            [positionITRF,velocityITRF]=matlabshared.orbit.internal.GPS.propagate(gpsTimeData.GPSWeekNumber,...
                            gpsTimeData.GPSTimeOfApplicability,currentSEMData,initialTime);



                            position=itrf2gcrfTransform*positionITRF;
                            velocity=itrf2gcrfTransform*(velocityITRF+cross(omega,positionITRF));
                        end


                        [semiMajorAxis,eccentricity,...
                        rightAscensionOfAscendingNode,...
                        inclination,argumentOfPeriapsis,...
                        trueAnomaly]=matlabshared.orbit.internal.TwoBodyKeplerian.inertialVectorToOrbitalElements(...
                        position,velocity);
                    end



                    propagator=...
                    matlabshared.orbit.internal.TwoBodyKeplerian(...
                    semiMajorAxis,eccentricity,...
                    inclination,...
                    rightAscensionOfAscendingNode,...
                    argumentOfPeriapsis,...
                    trueAnomaly,initialTime);


                    propagatorName="two-body-keplerian";
                case 'sgp4'
                    if initMode=="keplerian"


                        currentTLEData=...
                        orbitalElementsToTLEData(...
                        names,semiMajorAxis,...
                        eccentricity,...
                        inclination,...
                        rightAscensionOfAscendingNode,...
                        argumentOfPeriapsis,...
                        trueAnomaly,initialTime);
                    elseif initMode=="gnss"


                        [positionITRF,velocityITRF]=matlabshared.orbit.internal.GPS.propagate(gpsTimeData.GPSWeekNumber,...
                        gpsTimeData.GPSTimeOfApplicability,currentSEMData,initialTime);
                        position=itrf2gcrfTransform*positionITRF;
                        velocity=itrf2gcrfTransform*(velocityITRF+cross(omega,positionITRF));

                        [semiMajorAxis,eccentricity,...
                        rightAscensionOfAscendingNode,...
                        inclination,argumentOfPeriapsis,...
                        trueAnomaly]=matlabshared.orbit.internal.TwoBodyKeplerian.inertialVectorToOrbitalElements(...
                        position,velocity);

                        currentTLEData=...
                        orbitalElementsToTLEData(...
                        names,semiMajorAxis,...
                        eccentricity,...
                        inclination,...
                        rightAscensionOfAscendingNode,...
                        argumentOfPeriapsis,...
                        trueAnomaly,initialTime);
                    end


                    propagator=matlabshared.orbit.internal.SGP4(...
                    currentTLEData,initialTime);


                    propagatorName="sgp4";
                case 'sdp4'
                    if initMode=="keplerian"


                        currentTLEData=...
                        orbitalElementsToTLEData(...
                        names,semiMajorAxis,...
                        eccentricity,...
                        inclination,...
                        rightAscensionOfAscendingNode,...
                        argumentOfPeriapsis,...
                        trueAnomaly,initialTime);
                    elseif initMode=="gnss"


                        [positionITRF,velocityITRF]=matlabshared.orbit.internal.GPS.propagate(gpsTimeData.GPSWeekNumber,...
                        gpsTimeData.GPSTimeOfApplicability,currentSEMData,initialTime);
                        position=itrf2gcrfTransform*positionITRF;
                        velocity=itrf2gcrfTransform*(velocityITRF+cross(omega,positionITRF));

                        [semiMajorAxis,eccentricity,...
                        rightAscensionOfAscendingNode,...
                        inclination,argumentOfPeriapsis,...
                        trueAnomaly]=matlabshared.orbit.internal.TwoBodyKeplerian.inertialVectorToOrbitalElements(...
                        position,velocity);

                        currentTLEData=...
                        orbitalElementsToTLEData(...
                        names,semiMajorAxis,...
                        eccentricity,...
                        inclination,...
                        rightAscensionOfAscendingNode,...
                        argumentOfPeriapsis,...
                        trueAnomaly,initialTime);
                    end


                    propagator=matlabshared.orbit.internal.SDP4(...
                    currentTLEData,initialTime);


                    propagatorName="sdp4";
                case 'ephemeris'
                    if isempty(ephemerisSourceVelTable)
                        propagator=matlabshared.orbit.internal.Ephemeris(...
                        coordFrame,...
                        initialTime,...
                        ephemerisSourcePosTable);
                    else
                        propagator=matlabshared.orbit.internal.Ephemeris(...
                        coordFrame,...
                        initialTime,...
                        ephemerisSourcePosTable,...
                        ephemerisSourceVelTable);
                    end

                    propagatorName="ephemeris";
                case "gps"
                    propagator=matlabshared.orbit.internal.GPS(...
                    gpsTimeData.GPSWeekNumber,...
                    gpsTimeData.GPSTimeOfApplicability,...
                    gpsTimeData.GNSSSystem,...
                    currentSEMData,...
                    initialTime);

                    propagatorName="gps";
                case "galileo"
                    propagator=matlabshared.orbit.internal.GPS(...
                    gpsTimeData.GPSWeekNumber,...
                    gpsTimeData.GPSTimeOfApplicability,...
                    gpsTimeData.GNSSSystem,...
                    currentSEMData,...
                    initialTime);

                    propagatorName="galileo";
                otherwise
                    if initMode=="keplerian"||initMode=="tle"




                        if initMode=="keplerian"


                            currentTLEData=...
                            orbitalElementsToTLEData(...
                            names,semiMajorAxis,...
                            eccentricity,...
                            inclination,...
                            rightAscensionOfAscendingNode,...
                            argumentOfPeriapsis,...
                            trueAnomaly,initialTime);
                        end


                        meanMotion=currentTLEData.MeanMotion;
                        period=2*pi/meanMotion;




                        if period<minSDP4Period
                            propagator=matlabshared.orbit.internal.SGP4(...
                            currentTLEData,initialTime);
                            propagatorName="sgp4";
                        else
                            propagator=matlabshared.orbit.internal.SDP4(...
                            currentTLEData,initialTime);
                            propagatorName="sdp4";
                        end
                    else


                        propagator=matlabshared.orbit.internal.GPS(...
                        gpsTimeData.GPSWeekNumber,...
                        gpsTimeData.GPSTimeOfApplicability,...
                        gpsTimeData.GNSSSystem,...
                        currentSEMData,...
                        initialTime);
                        if gpsTimeData.GNSSSystem==uint8(0)
                            propagatorName="gps";
                        else
                            propagatorName="galileo";
                        end
                    end
                end

                switch propagatorName
                case "two-body-keplerian"
                    sat.PropagatorTBK=propagator;
                    sat.PropagatorType=1;
                case "sgp4"
                    sat.PropagatorSGP4=propagator;
                    sat.PropagatorType=2;
                case "sdp4"
                    sat.PropagatorSDP4=propagator;
                    sat.PropagatorType=3;
                case "ephemeris"
                    sat.PropagatorEphemeris=propagator;
                    sat.PropagatorType=4;
                otherwise
                    sat.PropagatorGPS=propagator;
                    sat.PropagatorType=5;
                end


                simID=addSatellite(simulator,propagator);


                if isempty(names)||names==""||names=="unnamed"
                    sat.pName=['Satellite ',sprintf('%.0f',simID)];
                else
                    if isempty(coder.target)
                        sat.pName=names;
                    else
                        sat.pName=char(names);
                    end
                end
                sat.OrbitPropagator=propagatorName;

                sat.Simulator=simulator;
                sat.SimulatorID=simID;
                sat.Type=1;


                ptTarget=-1;
                coder.varsize('ptTarget',[3,3],[1,1]);
                sat.PointingTarget=ptTarget;


                sat.Gimbals=matlabshared.satellitescenario.Gimbal;


                sat.ConicalSensors=matlabshared.satellitescenario.ConicalSensor;


                sat.Accesses=matlabshared.satellitescenario.Access;


                sat.Transmitters=satcom.satellitescenario.Transmitter;


                sat.Receivers=satcom.satellitescenario.Receiver;

                if isempty(coder.target)

                    sat.Scenario=scenario;

                    sat.Orbit=matlabshared.satellitescenario.Orbit(sat);
                    sat.GroundTrack=matlabshared.satellitescenario.GroundTrack(sat,scenario);


                    scenario.addToScenarioGraphics(sat.Orbit);
                    scenario.addToScenarioGraphics(sat.GroundTrack);


                    sat.SatelliteGraphic="satellite"+simID;
                    sat.LabelGraphic=sat.SatelliteGraphic+" label ID";








                    satelliteHeight=matlabshared.orbit.internal.TwoBodyKeplerian.inertialVectorToOrbitalElements(...
                    propagator.InitialPosition,propagator.InitialVelocity);
                    zoomHeightOffset=satelliteHeight*0.5;
                    if zoomHeightOffset<7000000
                        zoomHeightOffset=7000000;
                    end
                    sat.ZoomHeight=satelliteHeight+zoomHeightOffset;
                end
            end
        end
    end

    methods(Hidden)
        updateVisualizations(sat,viewer)
        function ID=getGraphicID(sat)
            ID=sat.SatelliteGraphic;
        end

        function IDs=getChildGraphicsIDs(sat)
            IDs=[];



            if(sat.ShowLabel)
                IDs=[IDs,sat.LabelGraphic];
            end



            if(~isempty(sat.Orbit)&&strcmp(sat.Orbit.VisibilityMode,'inherit'))
                IDs=[IDs,sat.Orbit.getGraphicID];
            end

            if(~isempty(sat.GroundTrack)&&~strcmp(sat.GroundTrack.VisibilityMode,'manual'))
                IDs=[IDs,sat.GroundTrack.getGraphicID,sat.GroundTrack.getChildGraphicsIDs];
            end

            for idx=1:numel(sat.Gimbals)
                gim=sat.Gimbals(idx);
                if strcmp(gim.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(gim)];
                end
                IDs=[IDs,getChildGraphicsIDs(gim)];
            end

            for idx=1:numel(sat.ConicalSensors)
                sensor=sat.ConicalSensors(idx);
                if strcmp(sensor.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(sensor)];
                end
                IDs=[IDs,getChildGraphicsIDs(sensor)];
            end

            for idx=1:numel(sat.Transmitters)
                tx=sat.Transmitters(idx);
                if strcmp(tx.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(tx),getChildGraphicsIDs(tx)];
                end
            end

            for idx=1:numel(sat.Receivers)
                rx=sat.Receivers(idx);
                if strcmp(rx.VisibilityMode,'inherit')
                    IDs=[IDs,getGraphicID(rx),getChildGraphicsIDs(rx)];
                end
            end
        end


        function ids=hideInViewerState(sat,viewer)
            ids=hideInViewerState@matlabshared.satellitescenario.ScenarioGraphic(sat,viewer);


            viewer.DeclutterMap.(sat.getGraphicID).childVisibility=false;
        end

        function addCZMLGraphic(sat,writer,times,initiallyVisible)
            positions=sat.pPositionHistory';
            addPoint(writer,sat.getGraphicID,positions,times,...
            'Interpolation','lagrange',...
            'InterpolationDegree',5,...
            'CoordinateDefinition','cartesian',...
            'ReferenceFrame','inertial',...
            'PixelSize',sat.MarkerSize,...
            'OutlineWidth',1,...
            'Color',[sat.MarkerColor,1],...
            'ID',sat.getGraphicID,...
            'InitiallyVisible',initiallyVisible,...
            'ShowTooltip',true,...
            'LinkedGraphic',sat.LabelGraphic);


            addLabel(writer,sat.LabelGraphic+" label",positions,times,sat.Name,...
            'Interpolation','lagrange',...
            'InterpolationDegree',5,...
            'CoordinateDefinition','cartesian',...
            'ReferenceFrame','inertial',...
            'PixelOffset',[15,0],...
            'FontSize',sat.LabelFontSize*2,...
            'Scale',0.5,...
            'Color',[sat.LabelFontColor,1],...
            'ID',sat.LabelGraphic,...
            'InitiallyVisible',sat.ShowLabel);
        end


        function objs=getChildObjects(sat)
            objs={};
            objs{1}=sat.Orbit;
            if(~isempty(sat.GroundTrack))
                objs{end+1}=sat.GroundTrack;
            end
        end

    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(~)
            proplist={'Name','ID','ConicalSensors','Gimbals',...
            'Transmitters','Receivers','Accesses','GroundTrack','Orbit',...
            'OrbitPropagator','MarkerColor','MarkerSize','ShowLabel','LabelFontColor',...
            'LabelFontSize'};
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods
        elements=orbitalElements(sat)
    end
end

function tleData=orbitalElementsToTLEData(name,semiMajorAxis,...
    eccentricity,inclination,rightAscensionOfAscendingNode,...
    argumentOfPeriapsis,trueAnomaly,epoch)



    coder.allowpcode('plain');

    eccentricAnomaly=2*atan(sqrt((1-eccentricity)/...
    (1+eccentricity))*tan(trueAnomaly/2));
    meanAnomaly=eccentricAnomaly-(eccentricity*...
    sin(eccentricAnomaly));
    standardGravitationalParameter=...
    matlabshared.orbit.internal.OrbitPropagationModel.StandardGravitationalParameter;
    meanMotion=...
    sqrt(standardGravitationalParameter/(semiMajorAxis^3));
    bStar=0;
    tleData=...
    matlabshared.orbit.internal.tledata(name,epoch,bStar,...
    rightAscensionOfAscendingNode,eccentricity,inclination,...
    argumentOfPeriapsis,meanAnomaly,meanMotion);
end

function propagator=defaultTwoBodyKeplerian



    coder.allowpcode('plain');

    defaultTime=datetime(2021,3,8);
    if isempty(coder.target)
        defaultTime.TimeZone='UTC';
    end
    propagator=matlabshared.orbit.internal.TwoBodyKeplerian(...
    10000000,0,0,0,0,0,defaultTime);
end

function propagator=defaultSGP4


    coder.allowpcode('plain');

    defaultTime=datetime(2021,3,8);
    if isempty(coder.target)
        defaultTime.TimeZone='UTC';
    end
    defaultTLEData=matlabshared.orbit.internal.tledata('Default Satellite',...
    defaultTime,0,0,0,0,0,0,0.0001);
    propagator=matlabshared.orbit.internal.SGP4(defaultTLEData,defaultTime);
end

function propagator=defaultSDP4


    coder.allowpcode('plain');

    defaultTime=datetime(2021,3,8);
    if isempty(coder.target)
        defaultTime.TimeZone='UTC';
    end
    defaultTLEData=matlabshared.orbit.internal.tledata('Default Satellite',...
    defaultTime,0,0,0,0,0,0,0.0001);
    propagator=matlabshared.orbit.internal.SDP4(defaultTLEData,defaultTime);
end

function propagator=defaultEphemeris


    coder.allowpcode('plain');

    defaultTime=datetime(2021,3,8);
    if isempty(coder.target)
        defaultTime.TimeZone='UTC';
    end
    if isempty(coder.target)
        propagator=matlabshared.orbit.internal.Ephemeris;
    else
        defaultTLEData=matlabshared.orbit.internal.tledata('Default Satellite',...
        defaultTime,0,0,0,0,0,0,0.0001);
        propagator=matlabshared.orbit.internal.SDP4(defaultTLEData,defaultTime);
    end
end

function propagator=defaultGPS


    coder.allowpcode('plain');

    defaultTime=datetime(2021,3,8);
    if isempty(coder.target)
        defaultTime.TimeZone='UTC';
    end

    weekNum=45;
    toa=503808;
    gnssSystem=uint8(0);
    records=struct(...
    'PRNNumber',1,...
    'SVN',63,...
    'AverageURANumber',0,...
    'Eccentricity',0.0094,...
    'InclinationOffset',0.0362,...
    'RateOfInclination',0,...
    'InclinationSineHarmonicCorrectionAmplitude',0,...
    'InclinationCosineHarmonicCorrectionAmplitude',0,...
    'OrbitRadiusSineHarmonicCorrectionAmplitude',0,...
    'OrbitRadiusCosineHarmonicCorrectionAmplitude',0,...
    'ArgumentOfLatitudeSineHarmonicCorrectionAmplitude',0,...
    'ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude',0,...
    'RateOfRightAscension',-8.1261e-09,...
    'RateOfRightAscensionDifference',0,...
    'SqrtOfSemiMajorAxis',5.1536e+03,...
    'SemiMajorAxisDifference',0,...
    'RateOfSemiMajorAxis',0,...
    'MeanMotionDifference',0,...
    'RateOfMeanMotionDifference',0,...
    'GeographicLongitudeOfOrbitalPlane',-1.4576,...
    'ArgumentOfPerigee',0.7555,...
    'MeanAnomaly',-1.7346,...
    'ZerothOrderClockCorrection',-3.0231e-04,...
    'FirstOrderClockCorrection',-1.0914e-11,...
    'SatelliteHealth',0,...
    'SatelliteConfiguration',11);

    propagator=matlabshared.orbit.internal.GPS(...
    weekNum,...
    toa,...
    gnssSystem,...
    records,...
    defaultTime);
end


