% 可以设置查看器窗口视角
classdef MainCamera<sim3d.sensors.AbstractCameraSensor

    methods
        function self=MainCamera(sensorID, vehicleID, cameraProperties, transform)
            sensorName='MainCamera1';
            self@sim3d.sensors.AbstractCameraSensor(sensorName,vehicleID,...
            cameraProperties.ImageSize(2),cameraProperties.ImageSize(1),...
            cameraProperties.HorizontalFieldOfView,transform);
        end
    end


    methods(Static)
        function tagName=getTagName()
            tagName='MainCamera';
        end
    end


    methods(Access=public,Hidden=true)
        function tag=getTag(~)
            tag=sprintf('MainCamera1');
        end
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.MainCamera;
        end
    end


    % 获取主相机的属性
    methods(Static)
        function cameraProperties=getMainCameraProperties()
            cameraProperties=struct('ImageSize',[1080,1920], ...
                'HorizontalFieldOfView',90);
        end
    end
end