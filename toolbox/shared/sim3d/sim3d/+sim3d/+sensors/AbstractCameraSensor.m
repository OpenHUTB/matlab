classdef(Hidden)AbstractCameraSensor<sim3d.sensors.Sensor
































    properties(Access=protected)

        HorizontalResolution(1,1)uint32=1920;


        VerticalResolution(1,1)uint32=1080;


        HorizohorizontalFieldOfView(1,1)single=90;
    end

    properties(Access=public,Hidden=true)

        IsEnabled(1,1)logical=true;
    end

    properties(Access=protected)
        Reader=[];
        ConfigurationWriter=[];
        CameraConfigurationParameters=[];
    end

    methods
        function self=AbstractCameraSensor(sensorID,vehicleID,...
            horizontalResolution,verticalResolution,horizontalFieldOfView,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('Camera',sensorID);
            self@sim3d.sensors.Sensor(sensorName,vehicleID,transform);
            self.HorizontalResolution=uint32(horizontalResolution);
            self.VerticalResolution=uint32(verticalResolution);
            self.HorizohorizontalFieldOfView=single(horizontalFieldOfView);

        end

        function setup(self)
            setup@sim3d.sensors.Sensor(self);

            self.Reader=sim3d.sensors.CameraReader(self.getTag(),...
            self.getHorizontalResolution(),...
            self.getVerticalResolution());
            self.ConfigurationWriter=sim3d.sensors.CameraConfigurationWriter(self.getTag(),...
            self.getHorizontalResolution(),...
            self.getVerticalResolution(),...
            self.getHorizontalFieldOfView());
        end

        function reset(self)


            reset@sim3d.sensors.Sensor(self);
            self.CameraConfigurationParameters=self.createCameraConfigurationParameters();
            if~isempty(self.ConfigurationWriter)
                self.ConfigurationWriter.write(self.CameraConfigurationParameters);
            end
        end

        function image=read(self)


            if~isempty(self.Reader)
                image=self.Reader.read();
            else
                image=[];
            end
        end

        function delete(self)
            if~isempty(self.Reader)
                self.Reader.delete();
                self.Reader=[];
            end

            if~isempty(self.ConfigurationWriter)
                self.ConfigurationWriter.delete();
                self.ConfigurationWriter=[];
            end

            delete@sim3d.sensors.Sensor(self);
        end

    end

    methods(Static)
        function tagName=getTagName()
            tagName='Camera';
        end
    end

    methods(Access=public,Hidden=true)

        function actorType=getActorType(~)
            actorType=int32(sim3d.utils.ActorTypes.IdealCamera);
        end
    end
    methods(Access=protected,Hidden=true)
        function horizontalFieldOfView=getHorizontalFieldOfView(self)
            horizontalFieldOfView=self.HorizohorizontalFieldOfView;
        end

        function verticalFieldOfView=getVerticalFieldOfView(self)
            verticalFieldOfView=single(self.VerticalResolution)*self.HorizohorizontalFieldOfView/single(self.HorizontalResolution);
        end

        function horizontalResolution=getHorizontalResolution(self)
            horizontalResolution=self.HorizontalResolution;
        end

        function verticalResolution=getVerticalResolution(self)
            verticalResolution=self.VerticalResolution;
        end

        function focalLength=getFocalLength(self)
            focalLength=double(self.HorizontalResolution)/(2*tan(pi*double(self.HorizohorizontalFieldOfView/360)));
            focalLength=uint32([focalLength,focalLength]);
        end

        function opticalCenter=getOpticalCenter(self)
            opticalCenter=uint32([self.HorizontalResolution/2,self.VerticalResolution/2]);
        end

        function skew=getSkew(~)
            skew=single(0);
        end

        function[radialDistortion,radialDistortionLength]=getRadialDistortion(~)
            radialDistortion=single(zeros(1,9));
            radialDistortionLength=0;
        end

        function[tangentialDistortion,tangentialDistortionLength]=getTangentialDistortion(~)
            tangentialDistortion=single(zeros(1,2));
            tangentialDistortionLength=0;
        end
        function parameters=createCameraConfigurationParameters(self)
            [radialDistortion,radialDistortionLength]=self.getRadialDistortion();
            [tangentialDistortion,tangentialDistortionLength]=self.getTangentialDistortion();
            parameters=struct(...
            'horizontalResolution',self.getHorizontalResolution(),...
            'verticalResolution',self.getVerticalResolution(),...
            'horizontalFieldOfView',self.getHorizontalFieldOfView(),...
            'verticalFieldOfView',self.getVerticalFieldOfView(),...
            'isEnabled',self.IsEnabled,...
            'focalLength',self.getFocalLength(),...
            'opticalCenter',self.getOpticalCenter(),...
            'radialDistortionLength',uint32(radialDistortionLength),...
            'radialDistortion',radialDistortion,...
            'tangentialDistortionLength',uint32(tangentialDistortionLength),...
            'tangentialDistortion',tangentialDistortion,...
            'skew',self.getSkew()...
            );
        end
    end

end

