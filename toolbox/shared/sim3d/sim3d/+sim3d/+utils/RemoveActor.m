classdef RemoveActor<handle


    properties
        Writer=[];
        RemoveActorStruct=[];
    end
    properties(Constant=true)
        MaxStrLengthName=128;
        QueueDepth=sim3d.World.MaxActorLimit;
    end
    methods
        function self=RemoveActor()
            self.Writer=sim3d.io.Publisher('RemoveActorTopic','QueueDepth',sim3d.utils.CreateActor.QueueDepth);

            actorTypeBuffer=char(zeros(1,sim3d.utils.RemoveActor.MaxStrLengthName));
            actorType='Sim3dPassVeh';
            actorTypeLength=length(actorType);
            actorTypeBuffer(1:actorTypeLength)=actorType(1:actorTypeLength);

            actorNameBuffer=char(zeros(1,sim3d.utils.RemoveActor.MaxStrLengthName));
            actorName='ActorName';
            actorNameLength=length(actorName);
            actorNameBuffer(1:actorNameLength)=actorName(1:actorNameLength);

            self.RemoveActorStruct=struct(...
            'RemoveActorType',actorTypeBuffer,...
            'ActorName',actorNameBuffer);
        end

        function delete(self)
            if~isempty(self.Writer)
                self.Writer.delete();
                self.Writer=[];
            end
        end

        function write(self)
            sim3d.engine.EngineReturnCode.assertObject(self.Writer);
            self.Writer.send(self.RemoveActorStruct);
        end


        function setRemoveActorType(self,removeActorType)
            typeNameDimension1=size(removeActorType,1);
            if typeNameDimension1>sim3d.utils.RemoveActor.MaxStrLengthName
                typeNameSizeException1=MException('sim3d:RemoveActor:setRemoveActorType:SizeErrorActorType',...
                'Array size definition error: Size of array [%d] exceeds maximum allowed [%d]',...
                typeNameDimension1,sim3d.utils.RemoveActor.MaxStrLengthName);
                throw(typeNameSizeException1);
            end
            self.RemoveActorStruct.RemoveActorType=char(zeros(1,sim3d.utils.RemoveActor.MaxStrLengthName));
            actorTypeLength=length(removeActorType);
            self.RemoveActorStruct.RemoveActorType(1:actorTypeLength)=removeActorType(1:actorTypeLength);
        end

        function setActorName(self,actorName)
            aNameDimension1=size(actorName,1);
            if aNameDimension1>sim3d.utils.RemoveActor.MaxStrLengthName
                pNameSizeException1=MException('sim3d:RemoveActor:setSpline:SizeErrorActorName',...
                'Array size definition error: Size of array [%d] exceeds maximum allowed [%d]',...
                aNameDimension1,sim3d.utils.RemoveActor.MaxStrLengthName);
                throw(pNameSizeException1);
            end
            self.RemoveActorStruct.ActorName=char(zeros(1,sim3d.utils.RemoveActor.MaxStrLengthName));
            actorNameLength=length(actorName);
            self.RemoveActorStruct.ActorName(1:actorNameLength)=actorName(1:actorNameLength);
        end
    end
end