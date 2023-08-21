classdef Pedestrian<sim3d.AbstractActor
    properties(SetAccess='private',GetAccess='public')

        PedestrianType;

        ActorTag;
    end

   
 properties(SetAccess='public',GetAccess='public')
        Animation;
ActorID

    end


    properties(Access=private)
        PedestrianConfigPublisher=[];
        PedestrianConfig;
        TerrainSensorPublisher=[];
        TerrainSensorSubscriber=[];
        TerrainSensorConfig;
        TraceStart_cache;
        TraceEnd_cache;
    end

    properties(Access=private,Constant=true)
        SuffixOut='/PedestrianConfiguration_OUT';
        TerrainSensorSuffixOut='/TerrainSensorConfiguration_OUT';
        TerrainSensorSuffixIn='/TerrainSensorDetection_IN';
    end


    methods

        function self=Pedestrian(actorName,pedestrianType,varargin)
            narginchk(2,inf);
            numberOfParts=uint32(1);
            r=sim3d.pedestrians.Pedestrian.parseInputs(varargin{:});
            switch pedestrianType
            case 'Custom'
                Mesh=r.Mesh;
                Animation=r.Animation;
            otherwise
                Mesh=sim3d.pedestrians.Pedestrian.getMeshPath(pedestrianType);
                Animation=sim3d.pedestrians.Pedestrian.getAnimationPath(pedestrianType);
            end
            self@sim3d.AbstractActor(actorName,'Scene Origin',r.Translation,r.Rotation,r.Scale,'ActorClassId',r.ActorID,'NumberOfParts',numberOfParts);
            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorTag=actorName;
            self.PedestrianConfig.PedestrianMesh=Mesh;
            self.PedestrianConfig.PedestrianAnimation=Animation;
            self.TerrainSensorConfig.RayStart=[0,0,0];
            self.TerrainSensorConfig.RayEnd=[1,0,3];
        end


        function reset(self)
            self.PedestrianConfigPublisher=sim3d.io.Publisher([self.ActorTag,self.SuffixOut]);
            self.TerrainSensorPublisher=sim3d.io.Publisher([self.ActorTag,self.TerrainSensorSuffixOut]);
            self.TerrainSensorSubscriber=sim3d.io.Subscriber([self.ActorTag,self.TerrainSensorSuffixIn]);
            sim3d.engine.EngineReturnCode.assertObject(self.TransformWriter);
            if~isempty(self.Translation)&&~isempty(self.Rotation)&&~isempty(self.Scale)
                translation=self.Translation;
                rotation=self.Rotation;
                rotation(3)=rotation(3)-pi/2;
                scale=self.Scale;
                self.TransformWriter.write(translation,rotation,scale);
            end
            self.PedestrianConfigPublisher.publish(self.PedestrianConfig);
            self.TerrainSensorPublisher.publish(self.TerrainSensorConfig);
        end


        function step(self,X,Y,Yaw)
            rotation=[0,0,Yaw];
            [~,traceEnd]=self.readTerrainSensorDetections();
            HitZ=mean(traceEnd(:,3));
            translation=[X,Y,HitZ];
            self.writeTransform(translation,rotation,self.Scale);
        end

        function[traceStart,traceEnd]=readTerrainSensorDetections(self)
            if self.TerrainSensorSubscriber.has_message()
                terrainSensorDetections=self.TerrainSensorSubscriber.take();
                traceStart=terrainSensorDetections.TraceStart;
                traceEnd=terrainSensorDetections.TraceEnd;
                self.TraceStart_cache=traceStart;
                self.TraceEnd_cache=traceEnd;
            else
                traceStart=self.TraceStart_cache;
                traceEnd=self.TraceEnd_cache;
            end
        end


        function write(self,translation,rotation,scale)
            self.writeTransform(translation,rotation,scale);
        end

        function[translation,rotation,scale]=read(self)
            [translation,rotation,scale]=self.readTransform();
        end


        function writeTransform(self,translation,rotation,scale)
            if~isempty(self.TransformWriter)
                rotation(3)=rotation(3)-pi/2;
                self.TransformWriter.write(single(translation),single(rotation),single(scale));
                self.TransformReader.read();
            end
        end

        function[translation,rotation,scale]=readTransform(self)
            sim3d.engine.EngineReturnCode.assertObject(self.TransformReader);
            [translation,rotation,scale]=self.TransformReader.read;
            rotation(3)=rotation(3)+pi/2;
            if(rotation(3)<0)
                rotation(3)=rotation(3)+2*pi;
            end
        end


        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.Pedestrian;
        end


        function delete(self)
            if~isempty(self.TerrainSensorPublisher)
                self.TerrainSensorPublisher=[];
            end
            if~isempty(self.TerrainSensorSubscriber)
                self.TerrainSensorSubscriber=[];
            end
            if~isempty(self.PedestrianConfigPublisher)
                self.PedestrianConfigPublisher=[];
            end
        end

    end


    methods(Access=private,Static)

        function r=parseInputs(varargin)

            defaultParams=struct(...
            'Mesh','MeshText',...
            'Animation','AnimationText',...
            'Translation',single(zeros(1,3)),...
            'Rotation',single(zeros(1,3)),...
            'Scale',single(ones(1,3)),...
            'ActorID',4);

            parser=inputParser;
            parser.addParameter('Mesh',defaultParams.Mesh);
            parser.addParameter('Animation',defaultParams.Animation);
            parser.addParameter('Translation',defaultParams.Translation);
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ActorID',defaultParams.ActorID);

            parser.parse(varargin{:});
            r=parser.Results;
        end


        function newType=legacyPedestrianTypeMapper(PedestrianType)
            switch PedestrianType
            case{'human_01','male_01'}
                newType='Male1';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "male_01" instead');
            case{'human_02','male_02'}
                newType='Male2';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "male_02" instead');
            case{'human_03','male_03'}
                newType='Male3';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "male_03" instead');
            case{'human_04','female_01'}
                newType='Female1';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "female_01" instead');
            case{'human_05','female_02'}
                newType='Female2';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "female_02" instead');
            case{'human_06','female_03'}
                newType='Female3';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "female_03" instead');
            case 'child'
                newType='Child';
                warning('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType','This pedestrian type will be deprecated in R2020b please use "child" instead');
            otherwise
                newType=PedestrianType;
            end
        end


        function ret=getMeshPath(PedestrianType)
            PedestrianType=sim3d.pedestrians.Pedestrian.legacyPedestrianTypeMapper(PedestrianType);
            switch PedestrianType
            case 'Male1'
                ret="/MathWorksSimulation/Characters/human_01/Mesh/Male001.Male001";
            case 'Male2'
                ret="/MathWorksSimulation/Characters/human_02/Mesh/Male002.Male002";
            case 'Male3'
                ret="/MathWorksSimulation/Characters/human_03/Mesh/Male003.Male003";
            case 'Female1'
                ret="/MathWorksSimulation/Characters/human_04/Mesh/Female001.Female001";
            case 'Female2'
                ret="/MathWorksSimulation/Characters/human_05/Mesh/Female002.Female002";
            case 'Female3'
                ret="/MathWorksSimulation/Characters/human_06/Mesh/Female003.Female003";
            case 'Child'
                ret="/MathWorksSimulation/Characters/Child/Mesh/Child.Child";
            otherwise
                error('sim3dblks:invalidPedestrianType','Invalid Pedestrian Type. Please check help and select a valid Pedestrian Type.');
            end
        end


        function ret=getAnimationPath(PedestrianType)
            PedestrianType=sim3d.pedestrians.Pedestrian.legacyPedestrianTypeMapper(PedestrianType);
            switch PedestrianType
            case 'Male1'
                ret="/MathWorksSimulation/Characters/human_01/Animation/SK_Mannequin_Mobile_Skeleton_AnimBlueprint1.SK_Mannequin_Mobile_Skeleton_AnimBlueprint1_C";
            case 'Male2'
                ret="/MathWorksSimulation/Characters/human_02/Animation/SK_Mannequin_Mobile_Skeleton_AnimBlueprint1.SK_Mannequin_Mobile_Skeleton_AnimBlueprint1_C";
            case 'Male3'
                ret="/MathWorksSimulation/Characters/human_03/Animation/SK_Mannequin_Mobile_Skeleton_AnimBlueprint1.SK_Mannequin_Mobile_Skeleton_AnimBlueprint1_C";
            case 'Female1'
                ret="/MathWorksSimulation/Characters/human_04/Animation/SK_Mannequin_Mobile_Skeleton_AnimBlueprint1.SK_Mannequin_Mobile_Skeleton_AnimBlueprint1_C";
            case 'Female2'
                ret="/MathWorksSimulation/Characters/human_05/Animation/SK_Mannequin_Mobile_Skeleton_AnimBlueprint1.SK_Mannequin_Mobile_Skeleton_AnimBlueprint1_C";
            case 'Female3'
                ret="/MathWorksSimulation/Characters/human_06/Animation/SK_Mannequin_Mobile_Skeleton_AnimBlueprint1.SK_Mannequin_Mobile_Skeleton_AnimBlueprint1_C";
            case 'Child'
                ret="/MathWorksSimulation/Characters/Child/Animation/ChildAnimBP.ChildAnimBP_C";
            otherwise
                ret='';
            end
        end
    end
end