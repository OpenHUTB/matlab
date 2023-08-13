classdef SemanticSegmentationVisionSensor<sim3d.sensors.VisionSensor


    methods
        function self=SemanticSegmentationVisionSensor(sensorID,vehicleID,sensorProperties,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('SemanticSegmentationSensor',sensorID);
            self@sim3d.sensors.VisionSensor(sensorName,vehicleID,sensorProperties,transform);
        end
        function[ClassIDs]=read(self)
            if~isempty(self.Reader)
                image=self.Reader.read();
                ClassIDs=image(:,:,1);
            else
                ClassIDs=[];
            end
        end
    end


    methods(Static)
        function tagName=getTagName()
            tagName='SemanticSegmentationSensor';
        end
    end

    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.SemanticSegmentation;
        end
    end
end
