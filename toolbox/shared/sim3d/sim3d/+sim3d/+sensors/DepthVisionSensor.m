classdef DepthVisionSensor<sim3d.sensors.VisionSensor

    properties(Constant=true)
        DetectionRange=1000;
    end

    methods
        function self=DepthVisionSensor(sensorID,vehicleID,sensorProperties,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('Depth',sensorID);
            self@sim3d.sensors.VisionSensor(sensorName,vehicleID,sensorProperties,transform);
        end
        function[depth]=read(self)


            if~isempty(self.Reader)
                image=self.Reader.read();
                depth=bitshift(uint32(image(:,:,3)),16)+bitshift(uint32(image(:,:,2)),8)+uint32(image(:,:,1));
                depth=sim3d.sensors.DepthVisionSensor.DetectionRange*double(depth)/(pow2(24)-1);
            else
                depth=[];
            end
        end
    end

    methods(Static)
        function tagName=getTagName()
            tagName='Depth';
        end
    end

    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.DepthSensor;
        end
    end
end
