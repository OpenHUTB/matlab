classdef CameraVisionSensor<sim3d.sensors.VisionSensor

    methods
        function self=CameraVisionSensor(sensorID,vehicleID,sensorProperties,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('Camera',sensorID);
            self@sim3d.sensors.VisionSensor(sensorName,vehicleID,sensorProperties,transform);
        end
        function image=read(self)


            image=read@sim3d.sensors.AbstractCameraSensor(self);
            if(self.Reader.StepCounter==1)&&(sim3d.engine.Engine.getWarmUpSteps()==0)

                image(:)=cast(0,class(image));
            end
        end
    end


    methods(Static)
        function tagName=getTagName()
            tagName='Camera';
        end
    end

    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.Camera;
        end
    end
end
