classdef IdealCamera<sim3d.sensors.AbstractCameraSensor

    methods

        function self=IdealCamera(varargin)
            r=sim3d.sensors.IdealCamera.parseInputs(varargin{:});
            sensorID=r.SensorID;
            vehicleID=r.VehicleID;
            cameraProperties=r.CameraProperties;
            transform=r.Transform;
            actorName=r.ActorName;
            imageSize=r.ImageSize;
            horizontalFieldOfView=r.HorizontalFieldOfView;

            if(~strcmp(sensorID,""))
                sensorName=sim3d.sensors.Sensor.getSensorName('Camera',sensorID);
            else
                sensorName=actorName;
            end

            if(strcmp(transform,""))
                transform=sim3d.utils.Transform();
            end
            if(strcmp(cameraProperties,""))
                cameraProperties=sim3d.sensors.IdealCamera.getIdealCameraProperties();
                cameraProperties.ImageSize=imageSize;
                cameraProperties.HorizontalFieldOfView=horizontalFieldOfView;
            end
            self@sim3d.sensors.AbstractCameraSensor(sensorName,vehicleID,...
            cameraProperties.ImageSize(2),cameraProperties.ImageSize(1),...
            cameraProperties.HorizontalFieldOfView,transform);
        end
    end


    methods(Static)
        function tagName=getTagName()
            tagName='Camera';
        end
    end


    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.IdealCamera;
        end
    end


    methods(Static)

        function cameraProperties=getIdealCameraProperties()
            cameraProperties=struct('ImageSize',[1080,1920],'HorizontalFieldOfView',90);
        end
    end


    methods(Access=private,Static)
        function r=parseInputs(varargin)

            defaultParams=struct(...
            'ActorName','Camera1',...
            'ImageSize',single([768,1024]),...
            'HorizontalFieldOfView',single(90)...
            );

            parser=inputParser;
            parser.addOptional('SensorID',"");
            parser.addOptional('VehicleID',"",@(s)isstring(s)||ischar(s));
            parser.addOptional('CameraProperties',"",@isstruct);
            parser.addOptional('Transform',"");
            parser.addParameter('ActorName',defaultParams.ActorName);
            parser.addParameter('ImageSize',defaultParams.ImageSize);
            parser.addParameter('HorizontalFieldOfView',defaultParams.HorizontalFieldOfView);

            parser.parse(varargin{:});
            r=parser.Results;
        end
    end
end



