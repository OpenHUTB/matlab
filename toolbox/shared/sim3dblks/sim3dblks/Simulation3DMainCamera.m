classdef Simulation3DMainCamera<Simulation3DVisionSensor&...
Simulation3DHandleMap

    properties(Access=private)
        ModelName=[];
    end

    
    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DVisionSensor(self);
            if coder.target('MATLAB')
                cameraProperties=sim3d.sensors.MainCamera.getMainCameraProperties();
                cameraProperties.ImageSize=[self.VerticalResolution,self.HorizontalResolution];
                cameraProperties.HorizontalFieldOfView=self.HorizontalFOV;
                cameraTransform=sim3d.utils.Transform(self.Translation,self.Rotation);
                self.Sensor=sim3d.sensors.MainCamera(self.SensorIdentifier,self.VehicleIdentifier,cameraProperties,cameraTransform);
                self.Sensor.setup();
                self.Sensor.IsEnabled=self.IsEnabled;
                self.Sensor.reset();
                self.ModelName=['Simulation3DMainCamera/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end


        function[Image]=stepImpl(self)
            Image=zeros(self.VerticalResolution,self.HorizontalResolution,3,'uint8');
        end


        function icon=getIconImpl(~)
            icon={'Main','Camera'};
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

    end
end