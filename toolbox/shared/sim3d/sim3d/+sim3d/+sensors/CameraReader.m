classdef CameraReader<handle



    properties
        Reader=[];



        HorizontalResolution=uint32(1920);




        VerticalResolution=uint32(1080);
    end
    properties(Hidden)
        StepCounter=0;
    end
    properties(Constant=true)
        Suffix='/Camera_IN';
    end
    methods
        function self=CameraReader(actorTag,HorizontalResolution,VerticalResolution)
            self.Reader=sim3d.io.Subscriber([actorTag,sim3d.sensors.CameraReader.Suffix]);
            self.HorizontalResolution=HorizontalResolution;
            self.VerticalResolution=VerticalResolution;
        end

        function delete(self)
            if~isempty(self.Reader)
                self.Reader.delete();
                self.Reader=[];
            end
        end

        function[image]=read(self)
            self.StepCounter=self.StepCounter+1;
            if(self.Reader.hasMessage())
                image=self.Reader.receive();
                result=sim3d.engine.EngineReturnCode.OK;
            else
                image=zeros(self.VerticalResolution,self.HorizontalResolution,3,'uint8');
                result=sim3d.engine.EngineReturnCode.No_Data;
            end
            sim3d.engine.EngineReturnCode.assertReturnCodeAndWarnNoData(result,gcb,self.StepCounter);
        end
    end
end

