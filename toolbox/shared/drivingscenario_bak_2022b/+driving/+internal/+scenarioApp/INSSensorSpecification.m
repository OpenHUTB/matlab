classdef(ConstructOnLoad)INSSensorSpecification<driving.internal.scenarioApp.SensorSpecification




    properties
RollAccuracy
PitchAccuracy
YawAccuracy
PositionAccuracy
VelocityAccuracy
AccelerationAccuracy
AngularVelocityAccuracy
HasGNSSFix
PositionErrorFactor
RandomStream
Seed
        TimeInput=true
    end

    methods
        function this=INSSensorSpecification(varargin)
            this@driving.internal.scenarioApp.SensorSpecification(varargin{:});
            this.Type='ins';
        end

        function configureForFirstStep(this,~,~,~)
            sensor=getSensor(this);
            release(sensor);
        end

        function set.RollAccuracy(this,res)
            s=getSensor(this);
            s.RollAccuracy=res;
            this.RollAccuracy=res;
        end
        function res=get.RollAccuracy(this)
            s=getSensor(this);
            res=s.RollAccuracy;
        end

        function set.PitchAccuracy(this,res)
            s=getSensor(this);
            s.PitchAccuracy=res;
            this.PitchAccuracy=res;
        end
        function res=get.PitchAccuracy(this)
            s=getSensor(this);
            res=s.PitchAccuracy;
        end

        function set.YawAccuracy(this,res)
            s=getSensor(this);
            s.YawAccuracy=res;
            this.YawAccuracy=res;
        end
        function res=get.YawAccuracy(this)
            s=getSensor(this);
            res=s.YawAccuracy;
        end

        function set.PositionAccuracy(this,res)
            s=getSensor(this);
            s.PositionAccuracy=res;
            this.PositionAccuracy=res;
        end
        function res=get.PositionAccuracy(this)
            s=getSensor(this);
            res=s.PositionAccuracy;
        end

        function set.VelocityAccuracy(this,res)
            s=getSensor(this);
            s.VelocityAccuracy=res;
            this.VelocityAccuracy=res;
        end
        function res=get.VelocityAccuracy(this)
            s=getSensor(this);
            res=s.VelocityAccuracy;
        end

        function set.AccelerationAccuracy(this,res)
            s=getSensor(this);
            s.AccelerationAccuracy=res;
            this.AccelerationAccuracy=res;
        end
        function res=get.AccelerationAccuracy(this)
            s=getSensor(this);
            res=s.AccelerationAccuracy;
        end

        function set.AngularVelocityAccuracy(this,res)
            s=getSensor(this);
            s.AngularVelocityAccuracy=res;
            this.AngularVelocityAccuracy=res;
        end
        function res=get.AngularVelocityAccuracy(this)
            s=getSensor(this);
            res=s.AngularVelocityAccuracy;
        end

        function set.HasGNSSFix(this,res)
            s=getSensor(this);
            s.HasGNSSFix=res;
            this.HasGNSSFix=res;
        end
        function res=get.HasGNSSFix(this)
            s=getSensor(this);
            res=s.HasGNSSFix;
        end

        function set.PositionErrorFactor(this,res)
            s=getSensor(this);
            s.PositionErrorFactor=res;
            this.PositionErrorFactor=res;
        end
        function res=get.PositionErrorFactor(this)
            s=getSensor(this);
            res=s.PositionErrorFactor;
        end

        function set.RandomStream(this,res)
            s=getSensor(this);
            s.RandomStream=res;
            this.RandomStream=res;
        end
        function res=get.RandomStream(this)
            s=getSensor(this);
            res=s.RandomStream;
        end

        function set.Seed(this,res)
            s=getSensor(this);
            if strcmp(this.RandomStream,'mt19937ar with seed')%#ok<MCSUP>
                s.Seed=res;
                this.Seed=res;
            end
        end
        function res=get.Seed(this)
            s=getSensor(this);
            res=s.Seed;
        end

        function[pvPairs,warnings]=getPVPairsForSimulation3DBlock(this,params)
            [pvPairs,warnings]=getPVPairsForSimulation3DBlock@driving.internal.scenarioApp.SensorSpecification(this,params);
        end

        function b=hasUpdateInterval(~)
            b=false;
        end

        function b=hasOrientation(~)
            b=false;
        end

    end

    methods(Hidden)
        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.INSPropertySheet';
        end

        function block=getDefaultSimulinkBlockName(~)
            block='drivingscenarioandsensors/INS';
        end

        function block=getSimulation3DBlockName(~)
            block='';
        end
    end

    methods(Access=protected)

        function setFieldOfView(~,~)

        end

        function setDefaultValues(~)

        end

        function setSensorDetectionCoordinates(~,~)

        end

        function setSensorSensorLocation(this,location)
            s=getSensor(this);
            s.MountingLocation(1:2)=location;
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

        function setSensorYaw(~,~)

        end

        function yaw=getSensorYaw(~)
            yaw=0;
        end

        function setSensorPitch(~,~)

        end

        function pitch=getSensorPitch(~)
            pitch=0;
        end

        function setSensorRoll(~,~)

        end

        function roll=getSensorRoll(~)
            roll=0;
        end

        function setSensorMaxRange(~,~)

        end

        function maxRange=getSensorMaxRange(~)
            maxRange=0;
        end

        function setSensorMaxNumDetectionsSource(~,~)

        end

        function source=getSensorMaxNumDetectionsSource(this)
            s=getSensor(this);
            source=s.MaxNumDetectionsSource;
        end

        function setSensorMaxNumDetections(~,~)

        end

        function num=getSensorMaxNumDetections(this)
            s=getSensor(this);
            num=s.MaxNumDetections;
        end

        function setSensorUpdateInterval(~,~)

        end

        function interval=getSensorUpdateInterval(~)
            interval=0.1;
        end

        function color=getDefaultColor(~)
            color=[80,158,100]/255;
        end

        function sensor=getDefaultSensor(~)
            sensor=insSensor('TimeInput',true);
        end

        function value=getSpecificSimulinkBlockPV(~,~)
            value=[];
        end

        function b=hasMaxNumDetections(~)
            b=false;
        end

        function b=hasDetectionProbability(~)
            b=false;
        end

        function b=hasSensorIndex(~)
            b=false;
        end

        function b=hasActorProfiles(~)
            b=false;
        end

        function pvPairs=getPVPairsForMatlabCode(this,varargin)
            pvPairs=getPVPairsForMatlabCode@driving.internal.scenarioApp.SensorSpecification(this,varargin{:});

            pvPairs=[{'TimeInput',true},pvPairs];
        end

        function props=getExposedProperties(~)
            props={'MountingLocation',...
            'RollAccuracy',...
            'PitchAccuracy',...
            'YawAccuracy',...
            'PositionAccuracy',...
            'VelocityAccuracy',...
            'AccelerationAccuracy',...
            'AngularVelocityAccuracy',...
            'TimeInput',...
            'HasGNSSFix',...
            'PositionErrorFactor',...
            'RandomStream',...
            'Seed'};
        end

        function names=getSensorBlockParameterNames(this)
            names=fieldnames(get_param(getDefaultSimulinkBlockName(this),'DialogParameters'));
            names(strcmp(names,'ActorProfilesSource'))=[];
            names(strcmp(names,'ActorProfilesVariableName'))=[];
        end
    end
end


