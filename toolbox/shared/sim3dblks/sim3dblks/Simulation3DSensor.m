classdef Simulation3DSensor<Simulation3DActor

    properties(Constant,Hidden)
        MaxSensorIdentifier=65535;
    end

    properties(Nontunable)
        SensorIdentifier(1,1)uint32{mustBeLessThanOrEqual(SensorIdentifier,65535)}=uint32(1);

        VehicleIdentifier(1,:)char='SimulinkVehicle1';


        Translation(1,3)single=[0,0,0];


        Rotation(1,3)single=[0,0,0];


        IsEnabled(1,1)logical=true;
    end

    properties(Access=protected)
        Sensor=[];

        Translation0=[];

        Rotation0=[];

        MountTransform=[];
    end

    methods(Access=protected)
        function loadObjectImpl(self,s,wasInUse)

            self.Sensor=s.Sensor;

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)

            s=saveObjectImpl@Simulation3DActor(self);

            s.Sensor=self.Sensor;
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    self.Sensor.reset();
                end
            end
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'terminating')
                if coder.target('MATLAB')
                    if~isempty(self.Sensor)
                        self.Sensor.delete();
                        self.Sensor=[];
                    end
                end
            end
        end
    end
end
