classdef ActorTransformWriter<handle

    properties
        Writer=[]
        NumberOfParts=1
    end


    properties(Constant=true)
        Suffix='/Transform_OUT'
        TranslationIndex=1
        RotationIndex=2
        ScaleIndex=3
    end


    methods

        function self=ActorTransformWriter(actorTag,NumberOfParts)
            self.Writer=sim3d.io.Publisher([actorTag,sim3d.io.ActorTransformWriter.Suffix],'Packet',zeros(NumberOfParts,3,3,'single'));
            self.NumberOfParts=NumberOfParts;
            if isempty(self.Writer)||self.Writer==uint64(0)
                timeoutException=MException('sim3d:ActorTransformWriter:ActorTransformWriter:SetupError',...
                '3D Simulation engine interface writer setup error. Is the 3D Simulation engine running?');
                throw(timeoutException);
            end
        end


        function delete(self)
            if~isempty(self.Writer)
                self.Writer.delete()
            end
        end


        function write(self,translation,rotation,scale)
            transform(:,:,sim3d.io.ActorTransformWriter.TranslationIndex)=translation;
            transform(:,:,sim3d.io.ActorTransformWriter.RotationIndex)=rotation;
            transform(:,:,sim3d.io.ActorTransformWriter.ScaleIndex)=scale;
            self.Writer.publish(transform);
        end
    end
end
