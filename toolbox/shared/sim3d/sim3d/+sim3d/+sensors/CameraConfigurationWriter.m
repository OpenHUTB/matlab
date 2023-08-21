classdef CameraConfigurationWriter<handle

    properties
        Writer=[];
        HorizontalResolution=uint32(1920);

        VerticalResolution=uint32(1080);

        HorizontalFOV=single(90);

        VerticalFOV=single(67.5);
    end


    properties(Constant=true)
        Suffix='/CameraConfiguration_OUT';
    end


    methods

        function self=CameraConfigurationWriter(actorTag,hResolution,vResolution,hFOV)
            self.HorizontalResolution=hResolution;
            self.VerticalResolution=vResolution;
            self.HorizontalFOV=hFOV;
            self.VerticalFOV=single(self.VerticalResolution)*...
            self.HorizontalFOV/single(self.HorizontalResolution);
            self.Writer=sim3d.io.Publisher([actorTag,sim3d.sensors.CameraConfigurationWriter.Suffix]);
        end


        function delete(self)
            if~isempty(self.Writer)
                self.Writer.delete();
                self.Writer=[];
            end
        end


        function write(self,cameraConfigurationParameters)
            sim3d.engine.EngineReturnCode.assertObject(self.Writer);
            self.Writer.send(cameraConfigurationParameters);
        end
    end
end

