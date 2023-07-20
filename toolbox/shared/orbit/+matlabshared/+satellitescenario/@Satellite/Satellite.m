classdef Satellite<matlabshared.satellitescenario.internal.PrimaryAssetWrapper %#codegen




    properties(Dependent,SetAccess=private)

































Name












































OrbitPropagator
    end

    properties(Dependent,SetAccess=?matlabshared.satellitescenario.GroundTrack)



GroundTrack
    end

    properties(Dependent,SetAccess=?matlabshared.satellitescenario.Orbit)











Orbit
    end

    properties(Dependent)




MarkerColor



MarkerSize



ShowLabel



LabelFontSize




LabelFontColor
    end

    properties(Dependent,Access=private)
PointingTarget
    end

    properties(Dependent,Hidden,SetAccess=private)
Attitude
AttitudeHistory
    end

    properties(Dependent,Access={?satelliteScenario,?matlabshared.satellitescenario.ScenarioGraphic,?matlabshared.satellitescenario.Viewer})
SatelliteGraphic
LabelGraphic
PropagatorTBK
PropagatorSGP4
PropagatorSDP4
PropagatorEphemeris
PropagatorGPS
PropagatorType
    end

    methods
        function name=get.Name(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.Name','sat');
                name=sat.Handles{1}.Name;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                name=strings(0,0);
            else
                name=[handles.Name];
            end
        end

        function p=get.OrbitPropagator(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.OrbitPropagator','sat');
                p=sat.Handles{1}.OrbitPropagator;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                p=strings(0,0);
            else
                p=[handles.OrbitPropagator];
            end
        end

        function o=get.Orbit(sat)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetCodegen';
                coder.internal.error(msg,'Orbit','matlabshared.satellitescenario.Satellite');
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                o=matlabshared.satellitescenario.Orbit.empty;
            else
                o=[handles.Orbit];
            end
        end

        function sat=set.Orbit(sat,orb)

            if~isempty(sat)
                handles=[sat.Handles{:}];
                handles.Orbit=orb;
            end
        end

        function g=get.GroundTrack(sat)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetCodegen';
                coder.internal.error(msg,'GroundTrack','matlabshared.satellitescenario.Satellite');
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                g=matlabshared.satellitescenario.GroundTrack.empty;
            else
                g=[handles.GroundTrack];
            end
        end

        function sat=set.GroundTrack(sat,gt)

            if~isempty(sat)
                handles=[sat.Handles{:}];
                handles.GroundTrack=gt;
            end
        end

        function c=get.MarkerColor(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerColor','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                c=[];
            else
                c=[handles.MarkerColor];
            end
        end

        function asset=set.MarkerColor(asset,c)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerColor','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).MarkerColor=c;
            end
        end

        function s=get.MarkerSize(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerSize','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.MarkerSize];
            end
        end

        function asset=set.MarkerSize(asset,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerSize','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];
            matlabshared.satellitescenario.ScenarioGraphic.setGraphicalField(handles,"MarkerSize",s);
        end

        function s=get.ShowLabel(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'ShowLabel','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=false(0,0);
            else
                s=[handles.ShowLabel];
            end
        end

        function asset=set.ShowLabel(asset,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'ShowLabel','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];
            matlabshared.satellitescenario.ScenarioGraphic.setGraphicalField(handles,"ShowLabel",s);
        end

        function c=get.LabelFontColor(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontColor','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                c=[];
            else
                c=[handles.LabelFontColor];
            end
        end

        function asset=set.LabelFontColor(asset,c)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontColor','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).LabelFontColor=c;
            end
        end

        function s=get.LabelFontSize(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontSize','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.LabelFontSize];
            end
        end

        function asset=set.LabelFontSize(asset,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontSize','matlabshared.satellitescenario.Satellite');
            end

            handles=[asset.Handles{:}];
            matlabshared.satellitescenario.ScenarioGraphic.setGraphicalField(handles,"LabelFontSize",s);
        end

        function attitude=get.Attitude(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.Attitude','sat');
                attitude=sat.Handles{1}.Attitude;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                attitude=zeros(3,0);
            else
                attitude=[handles.Attitude];
            end
        end

        function attitudeHistory=get.AttitudeHistory(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.AttitudeHistory','sat');
                attitudeHistory=sat.Handles{1}.AttitudeHistory;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                attitudeHistory=zeros(3,0);
            else
                attitudeHistory=[handles.AttitudeHistory];
            end
        end

        function t=get.PointingTarget(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PointingTarget','sat');
                t=sat.Handles{1}.PointingTarget;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                t=[];
            else
                t=[handles.PointingTarget];
            end
        end

        function sat=set.PointingTarget(sat,t)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PointingTarget','sat');
                sat.Handles{1}.PointingTarget=t;
                return
            end

            handles=[sat.Handles{:}];
            handles.PointingTarget=t;
        end

        function t=get.PropagatorTBK(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PropagatorTBK','sat');
                t=sat.Handles{1}.PropagatorTBK;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                t=matlabshared.orbit.internal.TwoBodyKeplerian.empty;
            else
                t=[handles.PropagatorTBK];
            end
        end

        function sat=set.PropagatorTBK(sat,t)


            handles=[sat.Handles{:}];
            handles.PropagatorTBK=t;
        end

        function t=get.PropagatorSGP4(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PropagatorSGP4','sat');
                t=sat.Handles{1}.PropagatorSGP4;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                t=matlabshared.orbit.internal.SGP4.empty;
            else
                t=[handles.PropagatorSGP4];
            end
        end

        function sat=set.PropagatorSGP4(sat,t)


            handles=[sat.Handles{:}];
            handles.PropagatorSGP4=t;
        end

        function t=get.PropagatorSDP4(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PropagatorSDP4','sat');
                t=sat.Handles{1}.PropagatorSDP4;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                t=matlabshared.orbit.internal.SDP4.empty;
            else
                t=[handles.PropagatorSDP4];
            end
        end

        function sat=set.PropagatorSDP4(sat,t)


            handles=[sat.Handles{:}];
            handles.PropagatorSDP4=t;
        end

        function t=get.PropagatorEphemeris(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PropagatorEphemeris','sat');
                t=sat.Handles{1}.PropagatorEphemeris;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                t=matlabshared.orbit.internal.Ephemeris.empty;
            else
                t=[handles.PropagatorEphemeris];
            end
        end

        function sat=set.PropagatorEphemeris(sat,t)


            handles=[sat.Handles{:}];
            handles.PropagatorEphemeris=t;
        end

        function p=get.PropagatorGPS(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PropagatorGPS','sat');
                p=sat.Handles{1}.PropagatorGPS;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                p=matlabshared.orbit.internal.GPS.empty;
            else
                p=[handles.PropagatorGPS];
            end
        end

        function sat=set.PropagatorGPS(sat,p)


            handles=[sat.Handles{:}];
            handles.PropagatorGPS=p;
        end

        function t=get.PropagatorType(sat)


            if~coder.target('MATLAB')
                validateattributes(sat,...
                {'matlabshared.satellitescenario.Satellite'},...
                {'scalar'},'get.PropagatorType','sat');
                t=sat.Handles{1}.PropagatorType;
                return
            end

            handles=[sat.Handles{:}];

            if isempty(handles)
                t=[];
            else
                t=[handles.PropagatorType];
            end
        end

        function sat=set.PropagatorType(sat,t)


            handles=[sat.Handles{:}];
            handles.PropagatorType=t;
        end

        function t=get.SatelliteGraphic(sat)


            handles=[sat.Handles{:}];

            if isempty(handles)
                t=strings(0,0);
            else
                t=[handles.SatelliteGraphic];
            end
        end

        function sat=set.SatelliteGraphic(sat,t)


            handles=[sat.Handles{:}];
            handles.SatelliteGraphic=t;
        end

        function t=get.LabelGraphic(sat)


            handles=[sat.Handles{:}];

            if isempty(handles)
                t=strings(0,0);
            else
                t=[handles.LabelGraphic];
            end
        end

        function sat=set.LabelGraphic(sat,t)


            handles=[sat.Handles{:}];
            handles.LabelGraphic=t;
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?satelliteScenario})
        function sat=Satellite(varargin)



            coder.allowpcode('plain');


            if~coder.target('MATLAB')
                sat.Handles={matlabshared.satellitescenario.internal.Satellite};
                sat.Handles=cell(1,0);
            else
                sat.Handles=cell(1,0);
            end






            if nargin~=0


                names=varargin{1};
                orbitPropagator=varargin{2};
                simulator=varargin{3};
                if nargin==10




                    semiMajorAxes=varargin{4};
                    eccentricities=varargin{5};
                    inclinations=varargin{6};
                    rightAscensionOfAscendingNodes=varargin{7};
                    argumentsOfPeriapsis=varargin{8};
                    trueAnomalies=varargin{9};
                    scenario=varargin{10};


                    numSats=numel(semiMajorAxes);

                    initMode="keplerian";
                elseif nargin==7




                    isInputTimeseries=true;
                    x=varargin{4};
                    if~iscell(x)
                        isInputTimeseries=false;
                    else
                        for idx=1:numel(x)
                            if~isa(x{idx},'timeseries')
                                isInputTimeseries=false;
                                break
                            end
                        end
                    end


                    if istimetable(varargin{4})

                        posTable=varargin{4};
                        velTable=varargin{5};
                        coordFrame=varargin{6};
                        numSats=numel(posTable.Properties.VariableNames);
                        initMode="timetable";
                        scenario=varargin{7};
                    elseif isInputTimeseries

                        posSeries=varargin{4};
                        velSeries=varargin{5};
                        coordFrame=varargin{6};
                        numSats=numel(posSeries);
                        initMode="timeseries";
                        scenario=varargin{7};
                    end
                elseif nargin==5

                    tleData=varargin{4};
                    numSats=numel(tleData);
                    initMode="tle";
                    scenario=varargin{5};
                else

                    initMode="gnss";
                    gnssParameters=varargin{4};
                    gnssRecords=varargin{5};
                    numSats=numel(gnssRecords);
                    scenario=varargin{6};
                end


                totalSats=max(1,numSats);
                handles=cell(1,totalSats);

                if simulator.NumSatellites==0
                    simulator.Satellites=repmat(simulator.SatelliteStruct,1,numSats);
                else
                    newSatelliteStruct=repmat(simulator.SatelliteStruct,1,numSats);
                    simulator.Satellites=[simulator.Satellites,newSatelliteStruct];
                end
                for idx=1:totalSats


                    switch initMode
                    case "keplerian"
                        semiMajorAxis=semiMajorAxes(idx);
                        eccentricity=eccentricities(idx);
                        inclination=inclinations(idx);
                        rightAscensionOfAscendingNode=...
                        rightAscensionOfAscendingNodes(idx);
                        argumentOfPeriapsis=...
                        argumentsOfPeriapsis(idx);
                        trueAnomaly=trueAnomalies(idx);

                        handles{idx}=matlabshared.satellitescenario.internal.Satellite(...
                        names{idx},orbitPropagator,simulator,...
                        scenario,semiMajorAxis,eccentricity,inclination,...
                        rightAscensionOfAscendingNode,argumentOfPeriapsis,...
                        trueAnomaly);

                    case "timetable"
                        if~isdatetime(posTable.Properties.StartTime)



                            posTable.Properties.StartTime=posTable.Properties.StartTime...
                            +scenario.StartTime;
                        end

                        ephemerisSourcePosTable=timetable(...
                        posTable.Properties.RowTimes,...
                        posTable.(posTable.Properties.VariableNames{idx}),...
                        'VariableNames',names{idx});
                        if~isempty(velTable)
                            if~isdatetime(velTable.Properties.StartTime)
                                velTable.Properties.StartTime=velTable.Properties.StartTime...
                                +scenario.StartTime;
                            end
                            ephemerisSourceVelTable=timetable(...
                            velTable.Properties.RowTimes,...
                            velTable.(velTable.Properties.VariableNames{idx}),...
                            'VariableNames',names{idx});
                        else
                            ephemerisSourceVelTable=timetable.empty;
                        end

                        if isempty(ephemerisSourcePosTable.Time.TimeZone)&&isempty(coder.target)
                            ephemerisSourcePosTable.Time.TimeZone='UTC';
                            if~isempty(velTable)
                                ephemerisSourceVelTable.Time.TimeZone='UTC';
                            end
                        end

                        handles{idx}=matlabshared.satellitescenario.internal.Satellite(...
                        names{idx},orbitPropagator,simulator,...
                        scenario,ephemerisSourcePosTable,...
                        ephemerisSourceVelTable,...
                        coordFrame);

                    case "timeseries"


                        if isempty(posSeries{idx}.TimeInfo.StartDate)
                            posSeries{idx}.TimeInfo.StartDate=scenario.StartTime;
                        end


                        ephemerisSourcePosTable=timetable(...
                        datetime(posSeries{idx}.getabstime,'Locale','en'),...
                        posSeries{idx}.Data,...
                        'VariableNames',names{idx});
                        if~isempty(velSeries)
                            if isempty(velSeries{idx}.TimeInfo.StartDate)
                                velSeries{idx}.TimeInfo.StartDate=scenario.StartTime;
                            end
                            ephemerisSourceVelTable=timetable(...
                            datetime(velSeries{idx}.getabstime,'Locale','en'),...
                            velSeries{idx}.Data,...
                            'VariableNames',names{idx});
                        else
                            ephemerisSourceVelTable=timetable.empty;
                        end
                        if isempty(ephemerisSourcePosTable.Time.TimeZone)
                            ephemerisSourcePosTable.Time.TimeZone='UTC';
                            if~isempty(velSeries)
                                ephemerisSourceVelTable.Time.TimeZone='UTC';
                            end
                        end

                        handles{idx}=matlabshared.satellitescenario.internal.Satellite(...
                        names{idx},orbitPropagator,simulator,...
                        scenario,ephemerisSourcePosTable,...
                        ephemerisSourceVelTable,...
                        coordFrame);

                    case "tle"
                        currentTLEData=tleData(idx);

                        handles{idx}=matlabshared.satellitescenario.internal.Satellite(...
                        names{idx},orbitPropagator,simulator,...
                        scenario,currentTLEData);

                    case "gnss"
                        currentGNSSData=gnssRecords(idx);
                        if isscalar(gnssParameters)
                            currentGNSSParameters=gnssParameters;
                        else
                            currentGNSSParameters=gnssParameters(idx);
                        end
                        handles{idx}=matlabshared.satellitescenario.internal.Satellite(...
                        names{idx},orbitPropagator,simulator,...
                        scenario,currentGNSSData,currentGNSSParameters);
                    end
                end


                sat.Handles=handles;
            end
        end
    end

    methods(Static,Access={?matlabshared.satellitescenario.internal.Simulator})
        [roll,pitch,yaw,ned2BodyTransform,itrf2BodyTransform]=...
        getAttitude(satPositionITRF,satPositionGeographic,...
        satInertialVelocityITRF,targetPositionITRF)

        [roll,pitch,yaw,ned2BodyTransform,itrf2BodyTransform]=...
        cg_getAttitude(satPositionITRF,satPositionGeographic,...
        satInertialVelocityITRF,targetPositionITRF)
    end

    methods(Hidden)
        disp(sat)
    end

    methods
        elements=orbitalElements(sat)
        gt=groundTrack(sat,varargin)
        pointAt(sat,target,varargin)
        [position,velocity,time]=states(sat,varargin)
    end

    methods(Hidden,Static)
        function sat=loadobj(s)


            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                sat=s;
            else





                sat=matlabshared.satellitescenario.Satellite;

                if isfield(s,'Handles')


                    sat.Handles=s.Handles;
                else


                    satHandle=matlabshared.satellitescenario.internal.Satellite;



                    sat.Handles={satHandle};


                    satHandle.OrbitPropagator=s.OrbitPropagator;
                    satHandle.Orbit=s.Orbit;
                    satHandle.GroundTrack=s.GroundTrack;
                    satHandle.SatelliteGraphic=s.SatelliteGraphic;
                    satHandle.LabelGraphic=s.LabelGraphic;







                    propagator=s.Propagator;
                    switch class(propagator)
                    case 'matlabshared.orbit.internal.TwoBodyKeplerian'
                        satHandle.PropagatorTBK=propagator;
                        satHandle.PropagatorType=1;
                    case 'matlabshared.orbit.internal.SGP4'
                        satHandle.PropagatorSGP4=propagator;
                        satHandle.PropagatorType=2;
                    case 'matlabshared.orbit.internal.SDP4'
                        satHandle.PropagatorSDP4=propagator;
                        satHandle.PropagatorType=3;
                    otherwise
                        satHandle.PropagatorEphemeris=propagator;
                        satHandle.PropagatorType=4;
                    end

                    if isa(s.Gimbals,'double')




                        satHandle.Gimbals=matlabshared.satellitescenario.Gimbal;
                    else







                        handles=[s.Gimbals.Handles];
                        if~isempty(handles)
                            satHandle.pGimbalsAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end


                        for idx=1:numel(handles)
                            handles{idx}.Parent=sat;
                        end



                        gim=matlabshared.satellitescenario.Gimbal;
                        gim.Handles=handles;



                        satHandle.Gimbals=gim;
                    end

                    if isa(s.ConicalSensors,'double')




                        satHandle.ConicalSensors=matlabshared.satellitescenario.ConicalSensor;
                    else







                        handles=[s.ConicalSensors.Handles];
                        if~isempty(handles)
                            satHandle.pConicalSensorsAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=sat;
                        end



                        cs=matlabshared.satellitescenario.ConicalSensor;
                        cs.Handles=handles;



                        satHandle.ConicalSensors=cs;
                    end

                    if isa(s.Accesses,'double')




                        satHandle.Accesses=matlabshared.satellitescenario.Access;
                    else







                        handles=[s.Accesses.Handles];
                        if~isempty(handles)
                            satHandle.pAccessesAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end


                        for idx=1:numel(handles)
                            handles{idx}.Parent=sat;
                        end



                        ac=matlabshared.satellitescenario.Access;
                        ac.Handles=handles;



                        satHandle.Accesses=ac;
                    end

                    if isa(s.Transmitters,'double')




                        satHandle.Transmitters=satcom.satellitescenario.Transmitter;
                    else







                        handles=[s.Transmitters.Handles];
                        if~isempty(handles)
                            satHandle.pTransmittersAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=sat;
                        end



                        tx=satcom.satellitescenario.Transmitter;
                        tx.Handles=handles;



                        satHandle.Transmitters=tx;
                    end

                    if isa(s.Receivers,'double')




                        satHandle.Receivers=satcom.satellitescenario.Receiver;
                    else







                        handles=[s.Receivers.Handles];
                        if~isempty(handles)
                            satHandle.pReceiversAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=sat;
                        end



                        rx=satcom.satellitescenario.Receiver;
                        rx.Handles=handles;



                        satHandle.Receivers=rx;
                    end


                    satHandle.pName=s.pName;
                    satHandle.Simulator=s.Simulator;
                    satHandle.SimulatorID=s.SimulatorID;
                    satHandle.Type=s.Type;
                    satHandle.ZoomHeight=s.ZoomHeight;
                    satHandle.PointingTarget=s.PointingTarget;
                    satHandle.pShowLabel=s.pShowLabel;
                    satHandle.pLabelFontSize=s.pLabelFontSize;
                    satHandle.pLabelFontColor=s.pLabelFontColor;
                    satHandle.pMarkerSize=s.pMarkerSize;
                    satHandle.pMarkerColor=s.pMarkerColor;
                    satHandle.ColorConverter=s.ColorConverter;
                end



                for idx=1:numel(sat.Handles)
                    sat.Handles{idx}.Orbit.Parent=sat.Handles{idx};
                    sat.Handles{idx}.GroundTrack.Parent=sat.Handles{idx};
                end
            end
        end
    end
end


