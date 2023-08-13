classdef(ConstructOnLoad)LidarSensorSpecification<driving.internal.scenarioApp.SensorSpecification

    properties
HasOrganizedOutput
HasEgoVehicle
EgoVehicleActorID
HasRoadsInputPort
RangeAccuracy
AzimuthResolution
ElevationResolution
AzimuthLimits
ElevationLimits
    end

    methods
        function this=LidarSensorSpecification(varargin)
            this@driving.internal.scenarioApp.SensorSpecification(varargin{:});
            this.Type='lidar';
        end

        function configureForFirstStep(this,sensorIndex,actorProfs,egoId)
            sensor=getSensor(this);
            release(sensor);
            sensor.SensorIndex=sensorIndex;
            sensor.ActorProfiles=actorProfs;

            if sensor.HasEgoVehicle
                sensor.EgoVehicleActorID=egoId;
            end
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

        function set.ElevationResolution(this,res)
            s=getSensor(this);
            s.ElevationResolution=res;
            this.ElevationResolution=res;
        end
        function res=get.ElevationResolution(this)
            s=getSensor(this);
            res=s.ElevationResolution;
        end

        function set.HasOrganizedOutput(this,res)
            s=getSensor(this);
            s.HasOrganizedOutput=res;
            this.HasOrganizedOutput=res;
        end
        function res=get.HasOrganizedOutput(this)
            s=getSensor(this);
            res=s.HasOrganizedOutput;
        end

        function set.HasEgoVehicle(this,res)
            s=getSensor(this);
            s.HasEgoVehicle=res;
            this.HasEgoVehicle=res;
        end
        function res=get.HasEgoVehicle(this)
            s=getSensor(this);
            res=s.HasEgoVehicle;
        end

        function set.EgoVehicleActorID(this,res)
            s=getSensor(this);
            if s.HasEgoVehicle
                s.EgoVehicleActorID=res;
            end
            this.EgoVehicleActorID=res;
        end
        function res=get.EgoVehicleActorID(this)
            s=getSensor(this);
            res=s.EgoVehicleActorID;
        end

        function set.HasRoadsInputPort(this,res)
            s=getSensor(this);
            s.HasRoadsInputPort=res;
            this.HasRoadsInputPort=res;
        end
        function res=get.HasRoadsInputPort(this)
            s=getSensor(this);
            res=s.HasRoadsInputPort;
        end

        function set.RangeAccuracy(this,res)
            s=getSensor(this);
            s.RangeAccuracy=res;
            this.RangeAccuracy=res;
        end
        function res=get.RangeAccuracy(this)
            s=getSensor(this);
            res=s.RangeAccuracy;
        end

        function set.AzimuthLimits(this,res)
            s=getSensor(this);
            s.AzimuthLimits=res;
            this.AzimuthLimits=res;
        end
        function res=get.AzimuthLimits(this)
            s=getSensor(this);
            res=s.AzimuthLimits;
        end

        function set.ElevationLimits(this,res)
            s=getSensor(this);
            s.ElevationLimits=res;
            this.ElevationLimits=res;
        end
        function res=get.ElevationLimits(this)
            s=getSensor(this);
            res=s.ElevationLimits;
        end

        function[pvPairs,warnings]=getPVPairsForSimulation3DBlock(this,params)
            [pvPairs,warnings]=getPVPairsForSimulation3DBlock@driving.internal.scenarioApp.SensorSpecification(this,params);
            if~this.HasOrganizedOutput
                warnings{end+1}='driving:scenarioApp:Export3dSimLidarHasOrganizedOutputWarning';
            end
            if~this.HasNoise
                warnings{end+1}='driving:scenarioApp:Export3dSimLidarHasNoiseWarning';
            end
        end
    end

    methods(Hidden)
        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.LidarPropertySheet';
        end

        function block=getDefaultSimulinkBlockName(~)
            block='drivingscenarioandsensors/Lidar Point Cloud Generator';
        end

        function block=getSimulation3DBlockName(~)
            block='drivingsim3d/Simulation 3D Lidar';
        end
    end

    methods(Access=protected)
        function color=getDefaultColor(~)
            color=[0,0,0]/255;
        end

        function sensor=getDefaultSensor(~)
            sensor=lidarPointCloudGenerator();
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

        function props=getExposedProperties(this)
            props=getExposedProperties@driving.internal.scenarioApp.SensorSpecification(this);
            props=[props,{'HasOrganizedOutput',...
            'HasEgoVehicle',...
            'EgoVehicleActorID',...
            'HasRoadsInputPort',...
            'RangeAccuracy',...
            'AzimuthResolution',...
            'ElevationResolution',...
            'AzimuthLimits',...
            'ElevationLimits'}];
        end

        function names=getSensorBlockParameterNames(this)
            names=fieldnames(get_param(getDefaultSimulinkBlockName(this),'DialogParameters'));
            names(strcmp(names,'ActorProfilesSource'))=[];
            names(strcmp(names,'ActorProfilesVariableName'))=[];
        end
    end
end


