classdef(ConstructOnLoad)RadarSensorSpecification<driving.internal.scenarioApp.SensorSpecification

    properties
        FalseAlarmRate;
        AzimuthBiasFraction;
        AzimuthResolution;

        HasElevation;
        ElevationBiasFraction;
        ElevationResolution;

        HasOcclusion;
        HasFalseAlarms;

        HasRangeRate;
        RangeRateBiasFraction;
        RangeRateResolution;
        RangeRateLimits;

        RangeBiasFraction;
        RangeResolution;
        ReferenceRCS;
        ReferenceRange;
    end



    properties(Dependent,Hidden,Transient)
UpdateRate
TargetReportFormat
MountingLocation
    end

    methods
        function this=RadarSensorSpecification(varargin)


            this@driving.internal.scenarioApp.SensorSpecification(varargin{:});
            this.Type='radar';
            fixBackwardsCompatibility(this);
            sensor=getSensor(this);
            sensor.TargetReportFormat='Detections';
        end

        function configureForFirstStep(this,sensorIndex,actorProfs,~)
            sensor=getSensor(this);
            release(sensor);
            sensor.SensorIndex=sensorIndex;
            sensor.Profiles=actorProfs;
        end

        function set.UpdateRate(this,rate)


            this.UpdateInterval=1000/rate;
        end

        function rate=get.UpdateRate(this)


            rate=1000/this.UpdateInterval;
        end

        function set.MountingLocation(this,location)
            this.SensorLocation=location(1:2);
            this.Height=location(3);
        end

        function location=get.MountingLocation(this)
            s=getSensor(this);
            location=s.MountingLocation;
        end

        function set.TargetReportFormat(this,format)
            s=getSensor(this);
            s.TargetReportFormat=format;
        end

        function format=get.TargetReportFormat(this)
            s=getSensor(this);
            format=s.TargetReportFormat;
        end

        function set.RangeRateLimits(this,limits)
            s=getSensor(this);
            s.RangeRateLimits=limits;
            this.RangeRateLimits=limits;
        end
        function limits=get.RangeRateLimits(this)
            s=getSensor(this);
            limits=s.RangeRateLimits;
        end

        function set.FalseAlarmRate(this,rate)
            s=getSensor(this);
            s.FalseAlarmRate=rate;
            this.FalseAlarmRate=rate;
        end
        function rate=get.FalseAlarmRate(this)
            s=getSensor(this);
            rate=s.FalseAlarmRate;
        end

        function set.AzimuthBiasFraction(this,frac)
            s=getSensor(this);
            s.AzimuthBiasFraction=frac;
            this.AzimuthBiasFraction=frac;
        end
        function frac=get.AzimuthBiasFraction(this)
            s=getSensor(this);
            frac=s.AzimuthBiasFraction;
        end

        function set.AzimuthResolution(this,res)
            s=getSensor(this);
            s.AzimuthResolution=res;
            this.AzimuthResolution=res;
        end
        function res=get.AzimuthResolution(this)
            s=getSensor(this);
            res=s.AzimuthResolution;
        end

        function set.ElevationBiasFraction(this,frac)
            oldElev=this.HasElevation;
            this.HasElevation=true;
            s=getSensor(this);
            s.ElevationBiasFraction=frac;
            this.ElevationBiasFraction=frac;
            this.HasElevation=oldElev;
        end
        function frac=get.ElevationBiasFraction(this)
            s=getSensor(this);
            frac=s.ElevationBiasFraction;
        end

        function set.ElevationResolution(this,res)
            oldElev=this.HasElevation;
            this.HasElevation=true;
            s=getSensor(this);
            s.ElevationResolution=res;
            this.ElevationResolution=res;
            this.HasElevation=oldElev;
        end
        function res=get.ElevationResolution(this)
            s=getSensor(this);
            res=s.ElevationResolution;
        end

        function set.HasElevation(this,has)
            s=getSensor(this);
            s.HasElevation=has;
            this.HasElevation=has;
        end
        function has=get.HasElevation(this)
            s=getSensor(this);
            has=s.HasElevation;
        end

        function set.HasOcclusion(this,has)
            s=getSensor(this);
            s.HasOcclusion=has;
            this.HasOcclusion=has;
        end
        function has=get.HasOcclusion(this)
            s=getSensor(this);
            has=s.HasOcclusion;
        end

        function set.HasFalseAlarms(this,has)
            s=getSensor(this);
            s.HasFalseAlarms=has;
            this.HasFalseAlarms=has;
        end
        function has=get.HasFalseAlarms(this)
            s=getSensor(this);
            has=s.HasFalseAlarms;
        end

        function set.HasRangeRate(this,has)
            s=getSensor(this);
            s.HasRangeRate=has;
            this.HasRangeRate=has;
        end
        function has=get.HasRangeRate(this)
            s=getSensor(this);
            has=s.HasRangeRate;
        end

        function set.RangeBiasFraction(this,frac)
            s=getSensor(this);
            s.RangeBiasFraction=frac;
            this.RangeBiasFraction=frac;
        end
        function frac=get.RangeBiasFraction(this)
            s=getSensor(this);
            frac=s.RangeBiasFraction;
        end

        function set.RangeRateBiasFraction(this,frac)
            oldRR=this.HasRangeRate;
            this.HasRangeRate=true;
            s=getSensor(this);
            s.RangeRateBiasFraction=frac;
            this.RangeRateBiasFraction=frac;
            this.HasRangeRate=oldRR;
        end
        function frac=get.RangeRateBiasFraction(this)
            s=getSensor(this);
            frac=s.RangeRateBiasFraction;
        end

        function set.RangeRateResolution(this,res)
            oldRR=this.HasRangeRate;%#ok<*MCSUP>
            this.HasRangeRate=true;
            s=getSensor(this);
            s.RangeRateResolution=res;
            this.RangeRateResolution=res;
            this.HasRangeRate=oldRR;
        end
        function res=get.RangeRateResolution(this)
            s=getSensor(this);
            res=s.RangeRateResolution;
        end

        function set.RangeResolution(this,res)
            s=getSensor(this);
            s.RangeResolution=res;
            this.RangeResolution=res;
        end
        function res=get.RangeResolution(this)
            s=getSensor(this);
            res=s.RangeResolution;
        end

        function set.ReferenceRCS(this,rcs)
            s=getSensor(this);
            s.ReferenceRCS=rcs;
            this.ReferenceRCS=rcs;
        end
        function rcs=get.ReferenceRCS(this)
            s=getSensor(this);
            rcs=s.ReferenceRCS;
        end

        function set.ReferenceRange(this,range)
            s=getSensor(this);
            s.ReferenceRange=range;
            this.ReferenceRange=range;
        end
        function range=get.ReferenceRange(this)
            s=getSensor(this);
            range=s.ReferenceRange;
        end
    end

    methods(Hidden)

        function fixBackwardsCompatibility(this)
            oldSensor=this.Sensor;
            if isa(oldSensor,'radarDetectionGenerator')

                iw=matlabshared.application.IgnoreWarnings('MATLAB:system:nonRelevantProperty');
                iw.RethrowWarning=false;


                this.Sensor=getDefaultSensor(this,...
                'SensorIndex',oldSensor.SensorIndex,...
                'UpdateRate',1/oldSensor.UpdateInterval,...
                'MountingLocation',[oldSensor.SensorLocation,oldSensor.Height],...
                'MountingAngles',[oldSensor.Yaw,oldSensor.Pitch,oldSensor.Roll],...
                'DetectionProbability',oldSensor.DetectionProbability,...
                'ReferenceRange',oldSensor.ReferenceRange,...
                'ReferenceRCS',oldSensor.ReferenceRCS,...
                'FalseAlarmRate',oldSensor.FalseAlarmRate,...
                'FieldOfView',oldSensor.FieldOfView,...
                'RangeLimits',[0,oldSensor.MaxRange],...
                'RangeRateLimits',oldSensor.RangeRateLimits,...
                'AzimuthResolution',oldSensor.AzimuthResolution,...
                'ElevationResolution',oldSensor.ElevationResolution,...
                'RangeResolution',oldSensor.RangeResolution,...
                'RangeRateResolution',oldSensor.RangeRateResolution,...
                'AzimuthBiasFraction',oldSensor.AzimuthBiasFraction,...
                'ElevationBiasFraction',oldSensor.ElevationBiasFraction,...
                'RangeBiasFraction',oldSensor.RangeBiasFraction,...
                'RangeRateBiasFraction',oldSensor.RangeRateBiasFraction,...
                'HasElevation',oldSensor.HasElevation,...
                'HasRangeRate',oldSensor.HasRangeRate,...
                'HasNoise',oldSensor.HasNoise,...
                'HasFalseAlarms',oldSensor.HasFalseAlarms,...
                'HasOcclusion',oldSensor.HasOcclusion,...
                'MaxNumReportsSource',oldSensor.MaxNumDetectionsSource);
            end
        end

        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.RadarPropertySheet';
        end

        function block=getDefaultSimulinkBlockName(~)
            block='drivingscenarioandsensors/Driving Radar Data Generator';
        end

        function block=getSimulation3DBlockName(~)
            block='drivingsim3d/Simulation 3D Probabilistic Radar';
        end
    end

    methods(Access=protected)

        function setDefaultValues(this)
            this.Sensor.UpdateRate=10;
        end

        function name=getProfilesPropertyName(~)
            name='Profiles';
        end

        function coords=setSensorDetectionCoordinates(this,coords)
            if strcmpi(coords,'Ego Cartesian')
                coords='Body';
            elseif strcmp(coords,'Sensor Cartesian')
                coords='Sensor rectangular';
            end
            s=getSensor(this);
            s.DetectionCoordinates=coords;
        end

        function setSensorSensorLocation(this,location)
            s=getSensor(this);
            s.MountingLocation(1:2)=location;%#ok<*MCSUP>
        end

        function location=getSensorSensorLocation(this)
            s=getSensor(this);
            location=s.MountingLocation(1:2);
        end

        function setSensorHeight(this,height)
            s=getSensor(this);
            s.MountingLocation(3)=height;
        end

        function height=getSensorHeight(this)
            s=getSensor(this);
            height=s.MountingLocation(3);
        end

        function setSensorYaw(this,yaw)
            s=getSensor(this);
            s.MountingAngles(1)=yaw;
        end

        function yaw=getSensorYaw(this)
            s=getSensor(this);
            yaw=s.MountingAngles(1);
        end

        function setSensorPitch(this,pitch)
            s=getSensor(this);
            s.MountingAngles(2)=pitch;
        end

        function pitch=getSensorPitch(this)
            s=getSensor(this);
            pitch=s.MountingAngles(2);
        end

        function setSensorRoll(this,roll)
            s=getSensor(this);
            s.MountingAngles(3)=roll;
        end

        function roll=getSensorRoll(this)
            s=getSensor(this);
            roll=s.MountingAngles(3);
        end

        function setSensorMaxRange(this,maxRange)
            s=getSensor(this);
            s.RangeLimits(2)=maxRange;
        end

        function maxRange=getSensorMaxRange(this)
            s=getSensor(this);
            maxRange=s.RangeLimits(2);
        end

        function setSensorMaxNumDetectionsSource(this,source)
            s=getSensor(this);
            if isObjectDetections(this)
                s.MaxNumReportsSource=source;
                if strcmp(source,'property')
                    s.MaxNumReports=this.MaxNumDetections;
                end
            end
        end

        function source=getSensorMaxNumDetectionsSource(this)
            s=getSensor(this);
            source=s.MaxNumReportsSource;
        end

        function setSensorMaxNumDetections(this,num)
            s=getSensor(this);
            if strcmpi(this.MaxNumDetectionsSource,'property')
                s.MaxNumReports=num;
            end
        end

        function num=getSensorMaxNumDetections(this)
            s=getSensor(this);
            num=s.MaxNumReports;
        end

        function setSensorUpdateInterval(this,int)
            s=getSensor(this);
            s.UpdateRate=1/int;
        end

        function int=getSensorUpdateInterval(this)
            s=getSensor(this);
            int=1/s.UpdateRate;
        end

        function color=getDefaultColor(~)
            color=[217,83,25]/255;
        end

        function sensor=getDefaultSensor(~,varargin)
            sensor=drivingRadarDataGenerator(varargin{:});
        end

        function value=getSpecificSimulinkBlockPV(~,~)
            value=[];
        end

        function props=getExposedProperties(this)
            props={'UpdateRate',...
            'MountingLocation',...
            'MountingAngles',...
            'RangeLimits',...
            'HasNoise',...
            'DetectionProbability',...
            'TargetReportFormat',...
            'MaxNumReportsSource'};
            if strcmp(this.MaxNumDetectionsSource,'Property')
                props=[props,{'MaxNumReports'}];
            end
            props=[props,{'FalseAlarmRate',...
            'AzimuthBiasFraction',...
            'AzimuthResolution',...
            'HasElevation'}];
            if this.HasElevation
                props=[props,{'ElevationBiasFraction','ElevationResolution'}];
            end
            props=[props,{'HasOcclusion','HasFalseAlarms','HasRangeRate'}];
            if this.HasRangeRate
                props=[props,{'RangeRateBiasFraction','RangeRateResolution','RangeRateLimits'}];
            end
            props=[props,{'RangeBiasFraction',...
            'RangeResolution',...
            'ReferenceRCS',...
            'ReferenceRange',...
            'FieldOfView'}];
        end
    end
end


