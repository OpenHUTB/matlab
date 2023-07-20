classdef Simulation3DCameraRead<Simulation3DVisionSensor&...
Simulation3DHandleMap







    properties(Access=private)
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DVisionSensor(self);
            if coder.target('MATLAB')
                cameraProperties=sim3d.sensors.IdealCamera.getIdealCameraProperties();
                cameraProperties.ImageSize=[self.VerticalResolution,self.HorizontalResolution];
                cameraProperties.HorizontalFieldOfView=self.HorizontalFOV;
                cameraTransform=sim3d.utils.Transform(self.Translation,self.Rotation);
                self.Sensor=sim3d.sensors.IdealCamera(self.SensorIdentifier,self.VehicleIdentifier,...
                cameraProperties,cameraTransform);
                self.Sensor.setup();
                self.Sensor.reset();
                self.Sensor.IsEnabled=self.IsEnabled;
                self.Sensor.reset();
                self.ModelName=['Simulation3DCameraRead/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            if self.loadflag
                self.ModelName=s.ModelName;
                self.Sensor=self.Sim3dSetGetHandle([self.ModelName,'/Sensor']);
                loadObjectImpl@matlab.System(self,s,wasInUse);
            else
                loadObjectImpl@Simulation3DSensor(self,s,wasInUse);
            end
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DSensor(self);
            s.ModelName=self.ModelName;
        end


        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end
        end

        function icon=getIconImpl(~)

            icon=matlab.system.display.Icon('sim3dcamera.png');
        end
    end
end
