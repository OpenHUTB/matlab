classdef(ConstructOnLoad)UltrasonicSensorSpecification<driving.internal.scenarioApp.SensorSpecification






    properties(Dependent,Hidden,Transient)
UpdateRate
MountingLocation
    end

    properties
MinRange
MinDetectionOnlyRange
    end

    methods
        function this=UltrasonicSensorSpecification(varargin)


            this@driving.internal.scenarioApp.SensorSpecification(varargin{:});
            this.Type='ultrasonic';
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

        function set.MinRange(this,minRange)
            s=getSensor(this);
            s.DetectionRange(2)=minRange;
            this.MinRange=minRange;
        end

        function minRange=get.MinRange(this)
            s=getSensor(this);
            minRange=s.DetectionRange(2);
        end

        function set.MinDetectionOnlyRange(this,minDetOnlyRange)
            s=getSensor(this);
            s.DetectionRange(1)=minDetOnlyRange;
            this.MinDetectionOnlyRange=minDetOnlyRange;
        end

        function minDetOnlyRange=get.MinDetectionOnlyRange(this)
            s=getSensor(this);
            minDetOnlyRange=s.DetectionRange(1);
        end

    end

    methods(Hidden)


        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.UltrasonicPropertySheet';
        end

        function block=getDefaultSimulinkBlockName(~)
            block='drivingscenarioandsensors/Ultrasonic Detection Generator';
        end

        function block=getSimulation3DBlockName(~)
            block='';
        end
    end

    methods(Access=protected)

        function setDefaultValues(this)
            this.Sensor.UpdateRate=10;
        end

        function name=getProfilesPropertyName(~)
            name='Profiles';
        end

        function coords=setSensorDetectionCoordinates(~,coords)

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
            s.DetectionRange(3)=maxRange;
        end

        function maxRange=getSensorMaxRange(this)
            s=getSensor(this);
            maxRange=s.DetectionRange(3);
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
            color=[39,99,25]/255;
        end

        function sensor=getDefaultSensor(~,varargin)
            sensor=ultrasonicDetectionGenerator(varargin{:});
        end

        function value=getSpecificSimulinkBlockPV(~,~)
            value=[];
        end

        function props=getExposedProperties(~)
            props={'UpdateRate',...
            'MountingLocation',...
            'MountingAngles',...
            'FieldOfView',...
            'DetectionRange'};
        end
    end
end


