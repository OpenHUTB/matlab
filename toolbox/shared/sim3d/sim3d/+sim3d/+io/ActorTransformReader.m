classdef ActorTransformReader<handle

    properties
        Reader=[];
        NumberOfParts=1;
        translation=[];
        rotation=[];
        scale=[];
    end
    properties(Constant=true)
        Suffix='/Transform_IN';
        TranslationIndex=1
        RotationIndex=2
        ScaleIndex=3
    end
    methods
        function self=ActorTransformReader(actorTag,NumberOfParts)
            self.Reader=sim3d.io.Subscriber([actorTag,sim3d.io.ActorTransformReader.Suffix]);
            self.NumberOfParts=NumberOfParts;
            if isempty(self.Reader)||self.Reader==uint64(0)
                timeoutException=MException('sim3d:ActorTransformReader:ActorTransformReader:SetupError',...
                '3D Simulation engine interface reader setup error. Is the 3D Simulation engine running?');
                throw(timeoutException);
            end
        end

        function delete(self)
            if~isempty(self.Reader)
                self.Reader.delete();
            end
        end

        function[translation,rotation,scale]=read(self)
            if self.Reader.has_message()
                transform=self.Reader.receive();
                translation=transform(1:self.NumberOfParts,:,sim3d.io.ActorTransformReader.TranslationIndex);
                rotation=transform(1:self.NumberOfParts,:,sim3d.io.ActorTransformReader.RotationIndex);
                scale=transform(1:self.NumberOfParts,:,sim3d.io.ActorTransformReader.ScaleIndex);
                self.translation=translation;
                self.rotation=rotation;
                self.scale=scale;
            else
                translation=self.translation;
                rotation=self.rotation;
                scale=self.scale;
            end
            translation=single(translation);
            rotation=single(rotation);
            scale=single(scale);
        end
    end
end