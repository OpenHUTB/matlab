classdef Simulator<handle %#codegen




    properties
StartTime
StopTime
SampleTime
Time
TimeHistory
SimIDMemo
        NeedToMemoizeSimID=true
Satellites
        NumSatellites=0
GroundStations
        NumGroundStations=0
ConicalSensors
        NumConicalSensors=0
Gimbals
        NumGimbals=0
Transmitters
        NumTransmitters=0
Receivers
        NumReceivers=0
Accesses
        NumAccesses=0
FieldsOfView
Links
        NumLinks=0
        NumFieldsOfView=0
SimObjectID
        NeedToSimulate=true
        SimulationStatus=0
        SimulationMode=0
        UpdateTaper=false
Version
    end

    properties(Constant)
        DatetimeComparisonTolerance=1e-9
    end

    properties
SatelliteStruct
GroundStationStruct
GimbalStruct
ConicalSensorStruct
AccessStruct
FieldOfViewStruct
TransmitterStruct
ReceiverStruct
LinkStruct
    end

    methods(Hidden,Static)
        function simObj=loadobj(s)
            if isa(s,'matlabshared.satellitescenario.internal.Simulator')&&strcmp(s.Version,['R',version('-release')])

                simObj=s;
            else




                simObj=matlabshared.satellitescenario.internal.Simulator(...
                s.StartTime,s.StopTime,s.SampleTime);

                simObj.Time=s.Time;
                simObj.TimeHistory=s.TimeHistory;
                simObj.NeedToMemoizeSimID=true;

                if isprop(s,'SimulationStatus')||isfield(s,'SimulationStatus')


                    simObj.SimulationStatus=s.SimulationStatus;
                    simObj.SimulationMode=s.SimulationMode;
                end

                simObj.NumSatellites=s.NumSatellites;
                loadSatellites(simObj,s);

                simObj.NumGroundStations=s.NumGroundStations;
                loadGroundStations(simObj,s);

                simObj.NumConicalSensors=s.NumConicalSensors;
                loadConicalSensors(simObj,s);

                simObj.NumGimbals=s.NumGimbals;
                loadGimbals(simObj,s);

                simObj.NumTransmitters=s.NumTransmitters;
                loadTransmitters(simObj,s);

                simObj.NumReceivers=s.NumReceivers;
                loadReceivers(simObj,s);

                simObj.NumAccesses=s.NumAccesses;
                loadAccesses(simObj,s);

                simObj.NumLinks=s.NumLinks;
                loadLinks(simObj,s);

                simObj.NumFieldsOfView=s.NumFieldsOfView;
                loadFieldsOfView(simObj,s);

                simObj.SimObjectID=s.SimObjectID;
                simObj.NeedToSimulate=true;

                advance(simObj,simObj.Time);

                simObj.Version=['R',version('-release')];
            end
        end

        function quat=zyx2quat(euler)


            coder.allowpcode('plain');

            cc=cos(euler/2);
            ss=sin(euler/2);
            quat=[...
            cc(:,1).*cc(:,2).*cc(:,3)+ss(:,1).*ss(:,2).*ss(:,3),...
            cc(:,1).*cc(:,2).*ss(:,3)-ss(:,1).*ss(:,2).*cc(:,3),...
            cc(:,1).*ss(:,2).*cc(:,3)+ss(:,1).*cc(:,2).*ss(:,3),...
            ss(:,1).*cc(:,2).*cc(:,3)-cc(:,1).*ss(:,2).*ss(:,3)];
        end
    end

    methods
        function simObj=Simulator(startTime,stopTime,sampleTime)


            coder.allowpcode('plain');


            simObj.SatelliteStruct=matlabshared.satellitescenario.internal.Simulator.satelliteStruct;
            simObj.GroundStationStruct=matlabshared.satellitescenario.internal.Simulator.groundStationStruct;
            simObj.GimbalStruct=matlabshared.satellitescenario.internal.Simulator.gimbalStruct;
            simObj.ConicalSensorStruct=matlabshared.satellitescenario.internal.Simulator.conicalSensorStruct;
            simObj.AccessStruct=matlabshared.satellitescenario.internal.Simulator.accessStruct;
            simObj.FieldOfViewStruct=matlabshared.satellitescenario.internal.Simulator.fieldOfViewStruct;
            simObj.TransmitterStruct=matlabshared.satellitescenario.internal.Simulator.transmitterStruct;
            simObj.ReceiverStruct=matlabshared.satellitescenario.internal.Simulator.receiverStruct;
            simObj.LinkStruct=matlabshared.satellitescenario.internal.Simulator.linkStruct;


            simObj.StartTime=startTime;
            simObj.StopTime=stopTime;
            simObj.SampleTime=sampleTime;
            simObj.Time=startTime;
            simObj.SimObjectID=0;


            sat=simObj.SatelliteStruct;
            coder.varsize('sat');
            simObj.Satellites=sat;


            simObj.TimeHistory=NaT;
            simObj.TimeHistory=NaT(1,0);
            if coder.target('MATLAB')
                simObj.TimeHistory.TimeZone='UTC';
            end


            gs=simObj.GroundStationStruct;
            coder.varsize('gs');
            simObj.GroundStations=gs;


            gim=simObj.GimbalStruct;
            coder.varsize('gim');
            simObj.Gimbals=gim;


            sensor=simObj.ConicalSensorStruct;
            coder.varsize('sensor');
            simObj.ConicalSensors=sensor;


            ac=simObj.AccessStruct;
            coder.varsize('ac');
            simObj.Accesses=ac;


            tx=simObj.TransmitterStruct;
            coder.varsize('tx');
            simObj.Transmitters=tx;


            rx=simObj.ReceiverStruct;
            coder.varsize('rx');
            simObj.Receivers=rx;


            lnk=simObj.LinkStruct;
            coder.varsize('lnk');
            simObj.Links=lnk;

            if coder.target('MATLAB')

                simObj.FieldsOfView=simObj.FieldOfViewStruct;
            end


            simIDMemo=[0,0];
            coder.varsize('simIDMemo');
            simObj.SimIDMemo=simIDMemo;


            simObj.Version='R2022b';
        end

        function id=addSatellite(simObj,propagator)


            coder.allowpcode('plain');


            id=addSimObjectID(simObj);



            simObj.Satellites(simObj.NumSatellites+1)=simObj.SatelliteStruct;


            simObj.Satellites(simObj.NumSatellites+1).ID=id;


            switch class(propagator)
            case 'matlabshared.orbit.internal.TwoBodyKeplerian'
                simObj.Satellites(simObj.NumSatellites+1).PropagatorTBK=propagator;
                simObj.Satellites(simObj.NumSatellites+1).PropagatorType=1;
            case 'matlabshared.orbit.internal.SGP4'
                simObj.Satellites(simObj.NumSatellites+1).PropagatorSGP4=propagator;
                simObj.Satellites(simObj.NumSatellites+1).PropagatorType=2;
            case 'matlabshared.orbit.internal.SDP4'
                simObj.Satellites(simObj.NumSatellites+1).PropagatorSDP4=propagator;
                simObj.Satellites(simObj.NumSatellites+1).PropagatorType=3;
            case 'matlabshared.orbit.internal.Ephemeris'
                simObj.Satellites(simObj.NumSatellites+1).PropagatorEphemeris=propagator;
                simObj.Satellites(simObj.NumSatellites+1).PropagatorType=4;
            otherwise
                simObj.Satellites(simObj.NumSatellites+1).PropagatorGPS=propagator;
                simObj.Satellites(simObj.NumSatellites+1).PropagatorType=5;
            end


            simObj.Satellites(simObj.NumSatellites+1).GrandParentSimulatorID=id;


            simObj.NeedToMemoizeSimID=true;



            simObj.NumSatellites=simObj.NumSatellites+1;
        end

        function id=addGroundStation(simObj,lat,lon,alt,minElevationAngle)


            coder.allowpcode('plain');


            id=addSimObjectID(simObj);


            positionITRF=matlabshared.orbit.internal.Transforms.geographic2itrf(...
            [lat*pi/180;lon*pi/180;alt]);


            itrf2BodyTransform=...
            matlabshared.orbit.internal.Transforms.itrf2nedTransform(...
            [lat*pi/180;lon*pi/180;alt]);



            simObj.GroundStations(simObj.NumGroundStations+1)=simObj.GroundStationStruct;


            simObj.GroundStations(simObj.NumGroundStations+1).ID=id;
            simObj.GroundStations(simObj.NumGroundStations+1).PositionITRF=positionITRF;
            simObj.GroundStations(simObj.NumGroundStations+1).VelocityITRF=[0;0;0];
            simObj.GroundStations(simObj.NumGroundStations+1).Latitude=lat;
            simObj.GroundStations(simObj.NumGroundStations+1).Longitude=lon;
            simObj.GroundStations(simObj.NumGroundStations+1).Altitude=alt;
            simObj.GroundStations(simObj.NumGroundStations+1).MinElevationAngle=minElevationAngle;
            simObj.GroundStations(simObj.NumGroundStations+1).Itrf2BodyTransform=itrf2BodyTransform;
            simObj.GroundStations(simObj.NumGroundStations+1).GrandParentSimulatorID=id;


            simObj.NeedToMemoizeSimID=true;



            simObj.NumGroundStations=simObj.NumGroundStations+1;
        end

        function id=addConicalSensor(simObj,mountingLocation,...
            mountingAngles,maxViewAngle,parentSimID,parentType)


            coder.allowpcode('plain');


            id=addSimObjectID(simObj);



            simObj.ConicalSensors(simObj.NumConicalSensors+1)=simObj.ConicalSensorStruct;


            simObj.ConicalSensors(simObj.NumConicalSensors+1).ID=id;
            simObj.ConicalSensors(simObj.NumConicalSensors+1).MountingLocation=mountingLocation;
            simObj.ConicalSensors(simObj.NumConicalSensors+1).MountingAngles=mountingAngles;
            simObj.ConicalSensors(simObj.NumConicalSensors+1).MaxViewAngle=maxViewAngle;
            simObj.ConicalSensors(simObj.NumConicalSensors+1).ParentSimulatorID=parentSimID(1);
            simObj.ConicalSensors(simObj.NumConicalSensors+1).ParentType=parentType;


            switch parentType
            case{1,2}
                simObj.ConicalSensors(simObj.NumConicalSensors+1).GrandParentType=parentType;
                simObj.ConicalSensors(simObj.NumConicalSensors+1).GrandParentSimulatorID=parentSimID(1);
            otherwise

                parentIndex=find([simObj.Gimbals.ID]==parentSimID(1),1);
                parent=simObj.Gimbals(parentIndex);
                simObj.ConicalSensors(simObj.NumConicalSensors+1).GrandParentType=parent.GrandParentType(1);
                simObj.ConicalSensors(simObj.NumConicalSensors+1).GrandParentSimulatorID=parent.GrandParentSimulatorID;
            end


            simObj.NeedToMemoizeSimID=true;



            simObj.NumConicalSensors=simObj.NumConicalSensors+1;
        end

        function id=addGimbal(simObj,mountingLocation,...
            mountingAngles,parentSimID,parentType)


            coder.allowpcode('plain');


            id=addSimObjectID(simObj);



            simObj.Gimbals(simObj.NumGimbals+1)=simObj.GimbalStruct;


            simObj.Gimbals(simObj.NumGimbals+1).ID=id;
            simObj.Gimbals(simObj.NumGimbals+1).MountingLocation=mountingLocation;
            simObj.Gimbals(simObj.NumGimbals+1).MountingAngles=mountingAngles;
            simObj.Gimbals(simObj.NumGimbals+1).ParentSimulatorID=parentSimID(1);
            simObj.Gimbals(simObj.NumGimbals+1).ParentType=parentType;


            simObj.Gimbals(simObj.NumGimbals+1).GrandParentType=parentType;
            simObj.Gimbals(simObj.NumGimbals+1).GrandParentSimulatorID=parentSimID(1);


            simObj.NeedToMemoizeSimID=true;



            simObj.NumGimbals=simObj.NumGimbals+1;
        end

        function id=addTransmitter(simObj,mountingLocation,...
            mountingAngles,parentSimID,parentType,frequency,...
            bitRate,power,systemLoss,antenna)


            coder.allowpcode('plain');


            id=addSimObjectID(simObj);



            simObj.Transmitters(simObj.NumTransmitters+1)=simObj.TransmitterStruct;


            simObj.Transmitters(simObj.NumTransmitters+1).ID=id;
            simObj.Transmitters(simObj.NumTransmitters+1).MountingLocation=mountingLocation;
            simObj.Transmitters(simObj.NumTransmitters+1).MountingAngles=mountingAngles;
            simObj.Transmitters(simObj.NumTransmitters+1).ParentSimulatorID=parentSimID(1);
            simObj.Transmitters(simObj.NumTransmitters+1).ParentType=parentType;
            simObj.Transmitters(simObj.NumTransmitters+1).Frequency=frequency;
            simObj.Transmitters(simObj.NumTransmitters+1).BitRate=bitRate;
            simObj.Transmitters(simObj.NumTransmitters+1).Power=power;
            simObj.Transmitters(simObj.NumTransmitters+1).SystemLoss=systemLoss;
            simObj.Transmitters(simObj.NumTransmitters+1).Antenna=antenna;

            if isa(antenna,'satcom.satellitescenario.GaussianAntenna')
                simObj.Transmitters(simObj.NumTransmitters+1).AntennaType=0;
            elseif satcom.satellitescenario.internal.usingElectronicallySteeredAntenna(antenna)
                simObj.Transmitters(simObj.NumTransmitters+1).AntennaType=2;
                simObj.Transmitters(simObj.NumTransmitters+1).PhasedArrayWeightsDefault=antenna.Taper;
                simObj.Transmitters(simObj.NumTransmitters+1).AntennaPatternResolution=1;
            else
                simObj.Transmitters(simObj.NumTransmitters+1).AntennaType=1;
                if isa(antenna,'phased.internal.AbstractAntennaElement')||...
                    isa(antenna,'phased.internal.AbstractSubarray')
                    simObj.Transmitters(simObj.NumTransmitters+1).AntennaPatternResolution=1;
                end
            end


            switch parentType
            case{1,2}
                simObj.Transmitters(simObj.NumTransmitters+1).GrandParentType=parentType;
                simObj.Transmitters(simObj.NumTransmitters+1).GrandParentSimulatorID=parentSimID(1);
            otherwise

                parentIndex=find([simObj.Gimbals.ID]==parentSimID(1),1);
                parent=simObj.Gimbals(parentIndex);
                simObj.Transmitters(simObj.NumTransmitters+1).GrandParentType=parent.GrandParentType;
                simObj.Transmitters(simObj.NumTransmitters+1).GrandParentSimulatorID=parent.GrandParentSimulatorID;
            end


            simObj.NeedToMemoizeSimID=true;



            simObj.NumTransmitters=simObj.NumTransmitters+1;
        end

        function id=addReceiver(simObj,mountingLocation,...
            mountingAngles,parentSimID,parentType,requiredEbNo,...
            gainToNoiseTemperatureRatio,systemLoss,preReceiverLoss,...
            antenna)


            coder.allowpcode('plain');


            id=addSimObjectID(simObj);



            simObj.Receivers(simObj.NumReceivers+1)=simObj.ReceiverStruct;
            rx=simObj.ReceiverStruct;


            simObj.Receivers(simObj.NumReceivers+1).ID=id;
            simObj.Receivers(simObj.NumReceivers+1).MountingLocation=mountingLocation;
            simObj.Receivers(simObj.NumReceivers+1).MountingAngles=mountingAngles;
            simObj.Receivers(simObj.NumReceivers+1).ParentSimulatorID=parentSimID(1);
            simObj.Receivers(simObj.NumReceivers+1).ParentType=parentType;
            simObj.Receivers(simObj.NumReceivers+1).RequiredEbNo=requiredEbNo;
            simObj.Receivers(simObj.NumReceivers+1).GainToNoiseTemperatureRatio=gainToNoiseTemperatureRatio;
            simObj.Receivers(simObj.NumReceivers+1).SystemLoss=systemLoss;
            simObj.Receivers(simObj.NumReceivers+1).PreReceiverLoss=preReceiverLoss;
            simObj.Receivers(simObj.NumReceivers+1).Antenna=antenna;

            if isa(antenna,'satcom.satellitescenario.GaussianAntenna')
                simObj.Receivers(simObj.NumReceivers+1).AntennaType=0;
            elseif satcom.satellitescenario.internal.usingElectronicallySteeredAntenna(antenna)
                simObj.Receivers(simObj.NumReceivers+1).AntennaType=2;
                simObj.Receivers(simObj.NumReceivers+1).PhasedArrayWeightsDefault=antenna.Taper;
                simObj.Receivers(simObj.NumReceivers+1).AntennaPatternResolution=1;
            else
                simObj.Receivers(simObj.NumReceivers+1).AntennaType=1;
                if isa(antenna,'phased.internal.AbstractAntennaElement')||...
                    isa(antenna,'phased.internal.AbstractSubarray')
                    simObj.Receivers(simObj.NumReceivers+1).AntennaPatternResolution=1;
                end
            end


            switch parentType
            case{1,2}
                simObj.Receivers(simObj.NumReceivers+1).GrandParentType=parentType;
                simObj.Receivers(simObj.NumReceivers+1).GrandParentSimulatorID=parentSimID(1);
            otherwise

                parentIndex=find([simObj.Gimbals.ID]==parentSimID(1),1);
                parent=simObj.Gimbals(parentIndex);
                simObj.Receivers(simObj.NumReceivers+1).GrandParentType=parent.GrandParentType;
                simObj.Receivers(simObj.NumReceivers+1).GrandParentSimulatorID=parent.GrandParentSimulatorID;
            end


            simObj.NeedToMemoizeSimID=true;



            simObj.NumReceivers=simObj.NumReceivers+1;
        end

        function id=addAccess(simObj,sequence,nodeType)


            coder.allowpcode('plain');



            id=addSimObjectID(simObj);



            simObj.Accesses(simObj.NumAccesses+1)=simObj.AccessStruct;
            simObj.Accesses(simObj.NumAccesses+1)=simObj.AccessStruct;
            if isempty(coder.target)
                simObj.Accesses(simObj.NumAccesses+1).Intervals.StartTime.TimeZone='UTC';
                simObj.Accesses(simObj.NumAccesses+1).Intervals.EndTime.TimeZone='UTC';
            end


            simObj.Accesses(simObj.NumAccesses+1).ID=id;
            simObj.Accesses(simObj.NumAccesses+1).Sequence=sequence;
            simObj.Accesses(simObj.NumAccesses+1).NodeType=nodeType;


            simObj.NeedToMemoizeSimID=true;



            simObj.NumAccesses=simObj.NumAccesses+1;
        end

        function id=addLink(simObj,sequence,nodeType)


            coder.allowpcode('plain');



            id=addSimObjectID(simObj);



            simObj.Links(simObj.NumLinks+1)=simObj.LinkStruct;
            if isempty(coder.target)
                simObj.Links(simObj.NumLinks+1).Intervals.StartTime.TimeZone='UTC';
                simObj.Links(simObj.NumLinks+1).Intervals.EndTime.TimeZone='UTC';
            end


            simObj.Links(simObj.NumLinks+1).ID=id;
            simObj.Links(simObj.NumLinks+1).Sequence=sequence;
            simObj.Links(simObj.NumLinks+1).NodeType=nodeType;


            simObj.NeedToMemoizeSimID=true;



            simObj.NumLinks=simObj.NumLinks+1;
        end

        function id=addFieldOfView(simObj,sourceID)




            id=addSimObjectID(simObj);



            simObj.FieldsOfView(simObj.NumFieldsOfView+1)=simObj.FieldOfViewStruct;

            if isempty(coder.target)
                simObj.FieldsOfView(simObj.NumFieldsOfView+1).Intervals.StartTime.TimeZone='UTC';
                simObj.FieldsOfView(simObj.NumFieldsOfView+1).Intervals.EndTime.TimeZone='UTC';
            end


            simObj.FieldsOfView(simObj.NumFieldsOfView+1).ID=id;
            simObj.FieldsOfView(simObj.NumFieldsOfView+1).SourceID=sourceID;


            simObj.FieldsOfView(simObj.NumFieldsOfView+1).ContourHistory=zeros(simObj.FieldsOfView(simObj.NumFieldsOfView+1).NumContourPoints,3,0);


            simObj.NeedToMemoizeSimID=true;



            simObj.NumFieldsOfView=simObj.NumFieldsOfView+1;
        end

        function memoizeSimID(simObj)



            coder.allowpcode('plain');


            memoSize=simObj.SimObjectID;
            memo=zeros(1,memoSize);

            for idx=1:simObj.NumSatellites
                simID=simObj.Satellites(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumGroundStations
                simID=simObj.GroundStations(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumConicalSensors
                simID=simObj.ConicalSensors(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumGimbals
                simID=simObj.Gimbals(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumTransmitters
                simID=simObj.Transmitters(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumReceivers
                simID=simObj.Receivers(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumLinks
                simID=simObj.Links(idx).ID;
                memo(simID)=idx;
            end

            for idx=1:simObj.NumAccesses
                simID=simObj.Accesses(idx).ID;
                memo(simID)=idx;
            end

            if isempty(coder.target)
                for idx=1:simObj.NumFieldsOfView
                    simID=simObj.FieldsOfView(idx).ID;
                    memo(simID)=idx;
                end
            end

            simObj.SimIDMemo=memo;
            simObj.NeedToMemoizeSimID=false;
        end
    end

    methods(Access=private)
        function id=addSimObjectID(simObj)


            coder.allowpcode('plain');

            id=simObj.SimObjectID+1;
            simObj.SimObjectID=id;
        end
    end

    methods(Static)
        function satStruct=satelliteStruct


            coder.allowpcode('plain');

            coder.varsize('name');
            startTime=datetime(2020,9,4,0,0,0);
            if isempty(coder.target)
                startTime.TimeZone="UTC";
            end


            twoBodyKeplerian=matlabshared.orbit.internal.TwoBodyKeplerian(...
            10000000,0,0,0,0,0,startTime);

            tleData=matlabshared.orbit.internal.tledata('Default Satellite',...
            startTime,0,0,0,0,0,0,0.0001);


            sgp4=matlabshared.orbit.internal.SGP4(tleData,startTime);


            sdp4=matlabshared.orbit.internal.SDP4(tleData,startTime);


            if isempty(coder.target)
                ephemerisStartTime=datetime(2021,3,8,16,24,0);
                ephemerisEndTime=ephemerisStartTime+hours(1);
                Time=[ephemerisStartTime;ephemerisEndTime];
                Time.TimeZone='UTC';
                ephemerisPosition=[10000000,0,0;20000000,0,0];
                ephemerisData=timetable(Time,ephemerisPosition,'VariableNames',{'sat1'});
                ephemeris=matlabshared.orbit.internal.Ephemeris('inertial',startTime,ephemerisData);
            else
                ephemeris=sdp4;
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

            gps=matlabshared.orbit.internal.GPS(...
            weekNum,...
            toa,...
            gnssSystem,...
            records,...
            startTime);


            if isempty(coder.target)
                Time=datetime(2021,3,8,16,24,0);
                Time.TimeZone='UTC';
                attitude=[1,0,0,0];
                customAttitude=timetable(Time,attitude,'VariableNames',{'sat1'});
            else
                customAttitude=[];
            end

            states=[0;0;0];
            stateHistory=zeros(3,0);
            coder.varsize('stateHistory',[3,Inf],[0,1]);
            geoStateHistory=zeros(1,0);
            coder.varsize('geoStateHistory',[1,Inf],[0,1]);
            transformationMatrix=eye(3);
            transformationMatrixHistory=zeros(3,3,0);
            coder.varsize('transformationMatrixHistory',[3,3,Inf],[0,0,1]);

            satStruct=struct('ID',0,...
            'PropagatorTBK',twoBodyKeplerian,...
            'PropagatorSGP4',sgp4,...
            'PropagatorSDP4',sdp4,...
            'PropagatorEphemeris',ephemeris,...
            'PropagatorGPS',gps,...
            'PropagatorType',0,...
            'Position',states,...
            'PositionHistory',stateHistory,...
            'PositionITRF',states,...
            'PositionITRFHistory',stateHistory,...
            'Velocity',states,...
            'VelocityHistory',stateHistory,...
            'VelocityITRF',states,...
            'VelocityITRFHistory',stateHistory,...
            'Latitude',0,...
            'Longitude',0,...
            'Altitude',0,...
            'LatitudeHistory',geoStateHistory,...
            'LongitudeHistory',geoStateHistory,...
            'AltitudeHistory',geoStateHistory,...
            'Attitude',states,...
            'AttitudeHistory',stateHistory,...
            'Itrf2BodyTransform',transformationMatrix,...
            'Itrf2BodyTransformHistory',transformationMatrixHistory,...
            'Ned2BodyTransform',transformationMatrix,...
            'Ned2BodyTransformHistory',transformationMatrixHistory,...
            'PointingMode',4,...
            'PointingTargetID',0,...
            'PointingCoordinates',[0;0;0],...
            'CustomAttitude',customAttitude,...
            'CustomAttitudeDefault','nadir',...
            'CustomAttitudeCoordFrame','inertial',...
            'CustomAttitudeFormat','quaternion',...
            'Type',1,...
            'GrandParentSimulatorID',0,...
            'GrandParentType',1);
        end

        function gsStruct=groundStationStruct


            coder.allowpcode('plain');

            states=[0;0;0];
            stateHistory=zeros(3,0);
            coder.varsize('stateHistory',[3,Inf],[0,1]);
            geoStateHistory=zeros(1,0);
            coder.varsize('geoStateHistory',[1,Inf],[0,1]);
            transformationMatrix=eye(3);
            transformationMatrixHistory=zeros(3,3,0);
            coder.varsize('transformationMatrixHistory',[3,3,Inf],[0,0,1]);

            gsStruct=struct('ID',0,...
            'Position',states,...
            'PositionHistory',stateHistory,...
            'PositionITRF',states,...
            'PositionITRFHistory',stateHistory,...
            'Velocity',states,...
            'VelocityHistory',stateHistory,...
            'VelocityITRF',states,...
            'VelocityITRFHistory',stateHistory,...
            'Latitude',0,...
            'Longitude',0,...
            'Altitude',0,...
            'LatitudeHistory',geoStateHistory,...
            'LongitudeHistory',geoStateHistory,...
            'AltitudeHistory',geoStateHistory,...
            'Attitude',states,...
            'Itrf2BodyTransform',transformationMatrix,...
            'Itrf2BodyTransformHistory',transformationMatrixHistory,...
            'Ned2BodyTransform',transformationMatrix,...
            'Ned2BodyTransformHistory',transformationMatrixHistory,...
            'AttitudeHistory',stateHistory,...
            'MinElevationAngle',10,...
            'Type',2,...
            'GrandParentSimulatorID',0,...
            'GrandParentType',2);
        end

        function sensorStruct=conicalSensorStruct


            coder.allowpcode('plain');

            states=[0;0;0];
            stateHistory=zeros(3,0);
            coder.varsize('stateHistory',[3,Inf],[0,1]);
            geoStateHistory=zeros(1,0);
            coder.varsize('geoStateHistory',[1,Inf],[0,1]);
            transformationMatrix=eye(3);
            transformationMatrixHistory=zeros(3,3,0);
            coder.varsize('transformationMatrixHistory',[3,3,Inf],[0,0,1]);

            sensorStruct=struct('ID',0,...
            'Position',states,...
            'PositionHistory',stateHistory,...
            'PositionITRF',states,...
            'PositionITRFHistory',stateHistory,...
            'Velocity',states,...
            'VelocityHistory',stateHistory,...
            'VelocityITRF',states,...
            'VelocityITRFHistory',stateHistory,...
            'Latitude',0,...
            'Longitude',0,...
            'Altitude',0,...
            'LatitudeHistory',geoStateHistory,...
            'LongitudeHistory',geoStateHistory,...
            'AltitudeHistory',geoStateHistory,...
            'Attitude',states,...
            'AttitudeHistory',stateHistory,...
            'Itrf2BodyTransform',transformationMatrix,...
            'Itrf2BodyTransformHistory',transformationMatrixHistory,...
            'MountingLocation',[0;0;0],...
            'MountingAngles',[0;0;0],...
            'MaxViewAngle',60,...
            'ParentSimulatorID',0,...
            'Type',3,...
            'ParentType',0,...
            'GrandParentSimulatorID',0,...
            'GrandParentType',0);
        end

        function gimStruct=gimbalStruct


            coder.allowpcode('plain');

            states=[0;0;0];
            stateHistory=zeros(3,0);
            coder.varsize('stateHistory',[3,Inf],[0,1]);
            scalarStateHistory=zeros(1,0);
            coder.varsize('scalarStateHistory',[1,Inf],[0,1]);
            transformationMatrix=eye(3);
            transformationMatrixHistory=zeros(3,3,0);
            coder.varsize('transformationMatrixHistory',[3,3,Inf],[0,0,1]);


            if isempty(coder.target)
                Time=datetime(2021,3,8,16,24,0);
                Time.TimeZone='UTC';
                angles=[45,45];
                customAngles=timetable(Time,angles,'VariableNames',{'sat1'});
            else
                customAngles=[];
            end

            gimStruct=struct('ID',0,...
            'Position',states,...
            'PositionHistory',stateHistory,...
            'PositionITRF',states,...
            'PositionITRFHistory',stateHistory,...
            'Velocity',states,...
            'VelocityHistory',stateHistory,...
            'VelocityITRF',states,...
            'VelocityITRFHistory',stateHistory,...
            'Latitude',0,...
            'Longitude',0,...
            'Altitude',0,...
            'LatitudeHistory',scalarStateHistory,...
            'LongitudeHistory',scalarStateHistory,...
            'AltitudeHistory',scalarStateHistory,...
            'Attitude',states,...
            'AttitudeHistory',stateHistory,...
            'Itrf2BodyTransform',transformationMatrix,...
            'Itrf2BodyTransformHistory',transformationMatrixHistory,...
            'Ned2BodyTransform',transformationMatrix,...
            'Ned2BodyTransformHistory',transformationMatrixHistory,...
            'PointingMode',5,...
            'PointingTargetID',0,...
            'PointingCoordinates',[0;0;0],...
            'CustomAngles',customAngles,...
            'GimbalAzimuth',0,...
            'GimbalAzimuthHistory',scalarStateHistory,...
            'GimbalElevation',0,...
            'GimbalElevationHistory',scalarStateHistory,...
            'MountingLocation',[0;0;0],...
            'MountingAngles',[0;0;0],...
            'ParentSimulatorID',0,...
            'Type',4,...
            'ParentType',0,...
            'GrandParentSimulatorID',0,...
            'GrandParentType',0);
        end

        function txStruct=transmitterStruct


            coder.allowpcode('plain');

            states=[0;0;0];
            stateHistory=zeros(3,0);
            coder.varsize('stateHistory',[3,Inf],[0,1]);
            geoStateHistory=zeros(1,0);
            coder.varsize('geoStateHistory',[1,Inf],[0,1]);
            transformationMatrix=eye(3);
            transformationMatrixHistory=zeros(3,3,0);
            coder.varsize('transformationMatrixHistory',[3,3,Inf],[0,0,1]);
            pointingDirectionHistory=zeros(2,0);
            coder.varsize('pointingDirectionHistory',[2,Inf],[0,1]);

            if coder.target('MATLAB')
                an=[];
            else
                an=satcom.satellitescenario.GaussianAntenna(1,0.65);
            end

            s=matlabshared.satellitescenario.internal.Simulator.antennaPatternStruct;

            txStruct=struct('ID',0,...
            'Position',states,...
            'PositionHistory',stateHistory,...
            'PositionITRF',states,...
            'PositionITRFHistory',stateHistory,...
            'Velocity',states,...
            'VelocityHistory',stateHistory,...
            'VelocityITRF',states,...
            'VelocityITRFHistory',stateHistory,...
            'Latitude',0,...
            'Longitude',0,...
            'Altitude',0,...
            'LatitudeHistory',geoStateHistory,...
            'LongitudeHistory',geoStateHistory,...
            'AltitudeHistory',geoStateHistory,...
            'Attitude',states,...
            'AttitudeHistory',stateHistory,...
            'Itrf2BodyTransform',transformationMatrix,...
            'Itrf2BodyTransformHistory',transformationMatrixHistory,...
            'MountingLocation',[0;0;0],...
            'MountingAngles',[0;0;0],...
            'Frequency',14e9,...
            'BitRate',10,...
            'Power',0,...
            'SystemLoss',0,...
            'Antenna',an,...
            'AntennaPattern',s,...
            'AntennaPatternResolution',5,...
            'AntennaPatternFrequency',zeros(1,0),...
            'DishDiameter',1,...
            'ApertureEfficiency',0.65,...
            'ParentSimulatorID',0,...
            'Type',5,...
            'ParentType',0,...
            'GrandParentSimulatorID',0,...
            'GrandParentType',0,...
            'AntennaType',0,...
            'PointingMode',5,...
            'PointingTargetID',0,...
            'PointingCoordinates',[0;0;0],...
            'PhasedArrayWeights',1,...
            'PhasedArrayWeightsDefault',1,...
            'PointingDirection',[0;0],...
            'PointingDirectionHistory',pointingDirectionHistory);
        end

        function rxStruct=receiverStruct


            coder.allowpcode('plain');

            states=[0;0;0];
            stateHistory=zeros(3,0);
            coder.varsize('stateHistory',[3,Inf],[0,1]);

            geoStateHistory=zeros(1,0);
            coder.varsize('geoStateHistory',[1,Inf],[0,1]);

            transformationMatrix=eye(3);

            transformationMatrixHistory=zeros(3,3,0);
            coder.varsize('transformationMatrixHistory',[3,3,Inf],[0,0,1]);

            pointingDirectionHistory=zeros(2,0);
            coder.varsize('pointingDirectionHistory',[2,Inf],[0,1]);

            if coder.target('MATLAB')
                an=[];
            else
                an=satcom.satellitescenario.GaussianAntenna(1,0.65);
            end

            s=matlabshared.satellitescenario.internal.Simulator.antennaPatternStruct;

            rxStruct=struct('ID',0,...
            'Position',states,...
            'PositionHistory',stateHistory,...
            'PositionITRF',states,...
            'PositionITRFHistory',stateHistory,...
            'Latitude',0,...
            'Longitude',0,...
            'Altitude',0,...
            'Velocity',states,...
            'VelocityHistory',stateHistory,...
            'VelocityITRF',states,...
            'VelocityITRFHistory',stateHistory,...
            'Attitude',states,...
            'LatitudeHistory',geoStateHistory,...
            'LongitudeHistory',geoStateHistory,...
            'AltitudeHistory',geoStateHistory,...
            'AttitudeHistory',stateHistory,...
            'Itrf2BodyTransform',transformationMatrix,...
            'Itrf2BodyTransformHistory',transformationMatrixHistory,...
            'MountingLocation',[0;0;0],...
            'MountingAngles',[0;0;0],...
            'GainToNoiseTemperatureRatio',1,...
            'RequiredEbNo',10,...
            'SystemLoss',0,...
            'PreReceiverLoss',3,...
            'Antenna',an,...
            'AntennaPattern',s,...
            'AntennaPatternResolution',5,...
            'AntennaPatternFrequency',zeros(1,0),...
            'DishDiameter',1,...
            'ApertureEfficiency',0.65,...
            'ParentSimulatorID',0,...
            'Type',6,...
            'ParentType',0,...
            'GrandParentSimulatorID',0,...
            'GrandParentType',0,...
            'AntennaType',0,...
            'PointingMode',5,...
            'PointingTargetID',0,...
            'PointingCoordinates',[0;0;0],...
            'PhasedArrayWeights',1,...
            'PhasedArrayWeightsDefault',1,...
            'PointingDirection',[0;0],...
            'PointingDirectionHistory',pointingDirectionHistory);
        end

        function acStruct=accessStruct


            coder.allowpcode('plain');

            statusHistory=false(1,0);
            coder.varsize('statusHistory',[1,Inf],[0,1]);

            t=NaT;
            intervalStruct=struct("StartTime",t,"EndTime",t);
            coder.varsize('intervalStruct',[1,Inf],[0,1]);

            sequence=[0,0];
            coder.varsize('sequence',[1,Inf],[0,1]);

            acStruct=struct('ID',0,...
            'Sequence',sequence,...
            'NodeType',sequence,...
            'Status',true,...
            'StatusHistory',statusHistory,...
            'NumIntervals',0,...
            'Intervals',intervalStruct);
        end

        function lnkStruct=linkStruct


            coder.allowpcode('plain');

            statusHistory=false(1,0);
            coder.varsize('statusHistory',[1,Inf],[0,1]);

            linkMetricHistory=zeros(1,0);
            coder.varsize('linkMetricHistory',[1,Inf],[0,1]);

            t=NaT;
            intervalStruct=struct("StartTime",t,"EndTime",t);
            coder.varsize('intervalStruct',[1,Inf],[0,1]);

            sequence=[0,0];
            coder.varsize('sequence',[1,Inf],[0,1]);

            lnkStruct=struct('ID',0,...
            'Sequence',sequence,...
            'NodeType',sequence,...
            'Status',true,...
            'StatusHistory',statusHistory,...
            'NumIntervals',0,...
            'Intervals',intervalStruct,...
            'EbNo',0,...
            'EbNoHistory',linkMetricHistory,...
            'ReceivedIsotropicPower',0,...
            'ReceivedIsotropicPowerHistory',linkMetricHistory,...
            'PowerAtReceiverInput',0,...
            'PowerAtReceiverInputHistory',linkMetricHistory);
        end

        function fovStruct=fieldOfViewStruct


            t=NaT;
            intervalStruct=struct("StartTime",t,"EndTime",t);

            fovStruct=struct('ID',0,...
            'SourceID',0,...
            'Status',false,...
            'StatusHistory',false(1,0),...
            'PreviousStatus',false,...
            'NumContourPoints',40,...
            'Contour',zeros(40,3),...
            'ContourHistory',zeros(40,3,0),...
            'NumIntervals',0,...
            'Intervals',intervalStruct);
        end

        function s=antennaPatternStruct



            az=-180:5:180;
            el=-90:5:90;
            g=nan(37,73);
            coder.varsize('az','el','g',[Inf,Inf],[1,1]);

            s=struct('Azimuth',az,'Elevation',el,'Gain',g);
            coder.varsize('s',[1,Inf],[0,1]);
            s(1)=[];
        end

        function s=getDummySatStructForAccessOrLink




            coder.allowpcode('plain');

            position=zeros(3,1);
            coder.varsize('position',[3,Inf],[0,1]);

            altitude=0;
            coder.varsize('altitude',[1,Inf],[0,1]);

            transformationMatrix=zeros(3);
            coder.varsize('transformationMatrix',[3,3,Inf],[0,0,1]);

            s=struct("Type",0,...
            "GrandParentType",0,...
            "GrandParentSimulatorID",0,...
            "PositionITRF",position,...
            "Altitude",altitude,...
            "Itrf2BodyTransform",transformationMatrix);
            coder.varsize('s',[1,Inf],[0,1]);
            s(1)=[];
        end

        function s=getDummyGsStructForAccessOrLink




            coder.allowpcode('plain');

            position=zeros(3,1);
            coder.varsize('position',[3,Inf],[0,1]);

            altitude=0;
            coder.varsize('altitude',[1,Inf],[0,1]);

            transformationMatrix=zeros(3);
            coder.varsize('transformationMatrix',[3,3,Inf],[0,0,1]);

            s=struct("Type",0,...
            "GrandParentType",0,...
            "GrandParentSimulatorID",0,...
            "PositionITRF",position,...
            "Altitude",altitude,...
            "Itrf2BodyTransform",transformationMatrix,...
            "MinElevationAngle",0);
            coder.varsize('s',[1,Inf],[0,1]);
            s(1)=[];
        end

        function s=getDummySensorStructForAccess




            coder.allowpcode('plain');

            position=zeros(3,1);
            coder.varsize('position',[3,Inf],[0,1]);

            altitude=0;
            coder.varsize('altitude',[1,Inf],[0,1]);

            transformationMatrix=zeros(3);
            coder.varsize('transformationMatrix',[3,3,Inf],[0,0,1]);

            s=struct("Type",0,...
            "GrandParentType",0,...
            "GrandParentSimulatorID",0,...
            "PositionITRF",position,...
            "Altitude",altitude,...
            "Itrf2BodyTransform",transformationMatrix,...
            "MaxViewAngle",0);
            coder.varsize('s',[1,Inf],[0,1]);
            s(1)=[];
        end

        function s=getDummyTxStructForLink




            coder.allowpcode('plain');

            position=zeros(3,1);
            coder.varsize('position',[3,Inf],[0,1]);

            altitude=0;
            coder.varsize('altitude',[1,Inf],[0,1]);

            transformationMatrix=zeros(3);
            coder.varsize('transformationMatrix',[3,3,Inf],[0,0,1]);

            pointingDirection=[0;0];
            coder.varsize('pointingDirection',[2,Inf],[0,1]);

            antennaFrequency=0;
            coder.varsize('antennaFrequency',[1,Inf],[0,1]);
            s=struct("Type",0,...
            "GrandParentType",0,...
            "GrandParentSimulatorID",0,...
            "PositionITRF",position,...
            "Altitude",altitude,...
            "Itrf2BodyTransform",transformationMatrix,...
            "Frequency",0,...
            "DishDiameter",0,...
            "ApertureEfficiency",0,...
            "Antenna",0,...
            "AntennaPattern",matlabshared.satellitescenario.internal.Simulator.antennaPatternStruct,...
            "AntennaType",0,...
            "AntennaPatternFrequency",antennaFrequency,...
            "Power",0,...
            "BitRate",0,...
            "SystemLoss",0,...
            "PointingMode",0,...
            "PhasedArrayWeights",0,...
            "PhasedArrayWeightsDefault",0,...
            "PointingDirection",pointingDirection);
            coder.varsize('s',[1,Inf],[0,1]);
            s(1)=[];
        end

        function s=getDummyRxStructForLink




            coder.allowpcode('plain');

            position=zeros(3,1);
            coder.varsize('position',[3,Inf],[0,1]);

            altitude=0;
            coder.varsize('altitude',[1,Inf],[0,1]);

            transformationMatrix=zeros(3);
            coder.varsize('transformationMatrix',[3,3,Inf],[0,0,1]);

            pointingDirection=[0;0];
            coder.varsize('pointingDirection',[2,Inf],[0,1]);

            antennaFrequency=0;
            coder.varsize('antennaFrequency',[1,Inf],[0,1]);
            s=struct("Type",0,...
            "GrandParentType",0,...
            "GrandParentSimulatorID",0,...
            "PositionITRF",position,...
            "Altitude",altitude,...
            "Itrf2BodyTransform",transformationMatrix,...
            "DishDiameter",0,...
            "ApertureEfficiency",0,...
            "Antenna",0,...
            "AntennaPattern",matlabshared.satellitescenario.internal.Simulator.antennaPatternStruct,...
            "AntennaType",0,...
            "AntennaPatternFrequency",antennaFrequency,...
            "SystemLoss",0,...
            "PreReceiverLoss",0,...
            "GainToNoiseTemperatureRatio",0,...
            "RequiredEbNo",0,...
            "PointingMode",0,...
            "PhasedArrayWeights",0,...
            "PhasedArrayWeightsDefault",0,...
            "PointingDirection",pointingDirection);
            coder.varsize('s',[1,Inf],[0,1]);
            s(1)=[];
        end
    end

    methods
        simulate(simObj)
        advance(simObj,time)

        loadSatellites(simObj,s)
        loadGroundStations(simObj,s)
        loadGimbals(simObj,s)
        loadConicalSensors(simObj,s)
        loadFieldsOfView(simObj,s)
        loadAccesses(simObj,s)

        loadTransmitters(simObj,s)
        loadReceivers(simObj,s)
        loadLinks(simObj,s)

        updateAntennaPatterns(simObj)
        resetStateHistory(simObj)
    end
end

