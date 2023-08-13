classdef TruthSensor<handle


    methods(Static)
        function tag=GetActorTag(id)
            tokens=strsplit(mfilename('class'),'.');
            tag=sprintf(strcat(tokens{end},'%d'),id);
        end
    end

    properties
        ActorTag;
        VehicleTag;

        Reader=[];
        Writer=[];
        NumberOfRays=1;
        StepCounter=0;
        TruthTopic=[];
    end

    properties(Constant=true)
        SuffixIn='/TruthSensorSignal_IN';
        SuffixOut='/TruthSensor_OUT';
    end

    properties(Access=private)
        CreateActor=[]
    end

    methods
        function self=TruthSensor(actorID,vehicleID,NumberOfRays,translation,rotation)
            ActorTag=self.GetActorTag(actorID);
            self.CreateActor=sim3d.utils.CreateActor;
            self.CreateActor.setActorName(ActorTag);
            self.CreateActor.setParentName(vehicleID);
            self.CreateActor.setCreateActorType(self.getActorType());

            transform=struct('translation',translation,'rotation',deg2rad(rotation),'scale',[1,1,1]);
            self.CreateActor.setActorLocation(transform);
            self.CreateActor.write;

            self.NumberOfRays=NumberOfRays;
            self.TruthTopic=struct('NumberOfRays',uint32(self.NumberOfRays),...
            'RayStartingPoints',single(zeros(uint32(self.NumberOfRays),3)),...
            'RayEndingPoints',single(zeros(uint32(self.NumberOfRays),3)),...
            'Translation',single(zeros(1,3)),...
            'Rotation',single(zeros(1,3)));

            self.Reader=sim3d.io.Subscriber([ActorTag,sim3d.sensors.TruthSensor.SuffixIn]);
            self.Writer=sim3d.io.Publisher([ActorTag,sim3d.sensors.TruthSensor.SuffixOut],'Packet',self.TruthTopic);
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.RadarGroundTruth;
        end

        function delete(self)
            if~isempty(self.Reader)
                self.Reader.delete();
                self.Reader=[];
            end
            if~isempty(self.Writer)
                self.Writer.delete();
                self.Writer=[];
            end

            if~isempty(self.CreateActor)
                self.CreateActor.delete();
                self.CreateActor=[];
            end
        end

        function[ClassIDs,MaterialIDs,ImpactPoints,ObjLocations,ObjRotations,Velocities]=read(self)
            self.StepCounter=self.StepCounter+1;
            if(self.Reader.hasMessage())
                TruthSignal=self.Reader.receive();
                ClassIDs=TruthSignal.HitObjectClassIDs;
                MaterialIDs=TruthSignal.HitObjectMaterialIDs;
                ImpactPoints=TruthSignal.HitObjectImpactPoints';
                ObjLocations=TruthSignal.HitObjectLocations';
                ObjRotations=TruthSignal.HitObjectRotations';
                Velocities=TruthSignal.HitObjectVelocities';
                result=sim3d.engine.EngineReturnCode.OK;
            else
                ClassIDs=uint32(zeros(1,uint32(self.NumberOfRays)));
                MaterialIDs=single(zeros(1,uint32(self.NumberOfRays)));
                ImpactPoints=single(zeros(3,uint32(self.NumberOfRays)));
                ObjLocations=single(zeros(3,uint32(self.NumberOfRays)));
                ObjRotations=single(zeros(3,uint32(self.NumberOfRays)));
                Velocities=single(zeros(3,uint32(self.NumberOfRays)));
                result=sim3d.engine.EngineReturnCode.No_Data;
            end
            sim3d.engine.EngineReturnCode.assertReturnCodeAndWarnNoData(result,gcb,self.StepCounter);


            ImpactPoints(2,:)=-1*ImpactPoints(2,:);
            ObjLocations(2,:)=-1*ObjLocations(2,:);
            Velocities(2,:)=-1*Velocities(2,:);
        end

        function write(self,rayStartingPoints,rayEndingPoints,translation,rotation)
            if size(rayStartingPoints,1)~=uint32(self.NumberOfRays)||size(rayStartingPoints,2)~=3
                timeoutException=MException('sim3d:ActorTruthWriter:InvalidSize',...
                'Truth Sensor input data size mismatch');
                throw(timeoutException);
            end
            if size(rayEndingPoints,1)~=uint32(self.NumberOfRays)||size(rayEndingPoints,2)~=3
                timeoutException=MException('sim3d:ActorTruthWriter:InvalidSize',...
                'Truth Sensor input data size mismatch');
                throw(timeoutException);
            end
            if size(translation,1)~=1||size(translation,2)~=3
                timeoutException=MException('sim3d:ActorTruthWriter:InvalidSize',...
                'Truth Sensor input data size mismatch');
                throw(timeoutException);
            end
            if size(rotation,1)~=1||size(rotation,2)~=3
                timeoutException=MException('sim3d:ActorTruthWriter:InvalidSize',...
                'Truth Sensor input data size mismatch');
                throw(timeoutException);
            end
            self.TruthTopic.RayStartingPoints=rayStartingPoints;
            self.TruthTopic.RayEndingPoints=rayEndingPoints;
            self.TruthTopic.Translation=translation;
            self.TruthTopic.Rotation=rotation;
            self.Writer.send(self.TruthTopic);
        end
    end


    methods(Static)
        function tagName=getTagName()
            tagName='TruthSensor';
        end
    end
end
