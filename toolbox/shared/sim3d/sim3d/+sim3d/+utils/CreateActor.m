classdef CreateActor<handle


    properties
        Writer=[];
        CreateActorStruct=[];
    end
    properties(Constant=true)
        MaxNumOfSplinePts=2048;
        SplineDimension=3;
        BankAngleDimension=1;
        PathWidthDimension=1;
        MaxStrLengthName=128;
        MaxStrLengthMesh=256;
        MaxStrLengthAnim=256;
        QueueDepth=sim3d.World.MaxActorLimit;
    end
    methods
        function self=CreateActor()

            sim3d.engine.Engine.start();

            actorTypeBuffer=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthName));
            actorType='Sim3dPassVeh';
            actorTypeLength=length(actorType);
            actorTypeBuffer(1:actorTypeLength)=actorType(1:actorTypeLength);

            parentNameBuffer=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthName));
            parentName='Scene Origin';
            parentNameLength=length(parentName);
            parentNameBuffer(1:parentNameLength)=parentName(1:parentNameLength);

            actorNameBuffer=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthName));
            actorName='ActorName';
            actorNameLength=length(actorName);
            actorNameBuffer(1:actorNameLength)=actorName(1:actorNameLength);



            meshNameBuffer=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthMesh));
            meshName='MeshPath';
            meshNameLength=length(meshName);
            meshNameBuffer(1:meshNameLength)=meshName(1:meshNameLength);

            animNameBuffer=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthAnim));
            animName='AnimPath';
            animNameLength=length(animName);
            animNameBuffer(1:animNameLength)=animName(1:animNameLength);

            actorLocationStruct=struct(...
            'translation',single(zeros(1,3)),...
            'rotation',single(zeros(1,3)),...
            'scale',single(ones(1,3)));

            self.CreateActorStruct=struct(...
            'CreateActorType',actorTypeBuffer,...
            'ActorInitialLocation',actorLocationStruct,...
            'ParentName',parentNameBuffer,...
            'ActorName',actorNameBuffer,...
            'ActorId',uint16(0),...
            'Mesh',meshNameBuffer,...
            'Animation',animNameBuffer,...
            'Mobility',int32(sim3d.utils.MobilityTypes.Static),...
            'Visible',true,...
            'Hidden',false,...
            'SimulatePhysics',false,...
            'CollisionType',int32(sim3d.utils.CollisionTypes.NoCollision),...
            'Weight',single(0),...
            'GravityEnabled',true,...
            'ShadowsEnabled',true);

            self.Writer=sim3d.io.Publisher('CreateActorTopic',...
            'Packet',self.CreateActorStruct,...
            'QueueDepth',sim3d.utils.CreateActor.QueueDepth);
        end

        function delete(self)
            if~isempty(self.Writer)
                self.Writer.delete();
                self.Writer=[];
            end
        end

        function write(self)
            sim3d.engine.EngineReturnCode.assertObject(self.Writer);
            self.Writer.send(self.CreateActorStruct);

            if self.CreateActorStruct.SimulatePhysics==true&&self.CreateActorStruct.Mobility~=int32(sim3d.utils.MobilityTypes.Movable)
                error(message('shared_sim3dblks:CreateActorMessage:SetPhysGrpError').getString);
            end
        end


        function setCreateActorType(self,createActorType)
            typeNameDimension1=size(createActorType,1);
            if typeNameDimension1>sim3d.utils.CreateActor.MaxStrLengthName
                error(message('shared_sim3dblks:CreateActorMessage:SizeErrorActorType').getString,...
                typeNameDimension1,sim3d.utils.CreateActor.MaxStrLengthName);
            end
            self.CreateActorStruct.CreateActorType=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthName));
            actorTypeLength=length(createActorType);
            self.CreateActorStruct.CreateActorType(1:actorTypeLength)=createActorType(1:actorTypeLength);
        end

        function setActorLocation(self,actorlLocation)
            initLocFieldNames=fieldnames(actorlLocation);
            if~isempty(find(strcmp(initLocFieldNames,'translation'),1))

                self.CreateActorStruct.ActorInitialLocation.translation=single(100*actorlLocation.translation(1,:));
            end
            if~isempty(find(strcmp(initLocFieldNames,'rotation'),1))

                self.CreateActorStruct.ActorInitialLocation.rotation=single(rad2deg(actorlLocation.rotation(1,:)));
            end
            if~isempty(find(strcmp(initLocFieldNames,'scale'),1))

                self.CreateActorStruct.ActorInitialLocation.scale=single(actorlLocation.scale(1,:));
            end
        end

        function setParentName(self,parentName)
            pNameDimension1=size(parentName,1);
            if pNameDimension1>sim3d.utils.CreateActor.MaxStrLengthName
                error(message('shared_sim3dblks:CreateActorMessage:SizeErrorParentName').getString,...
                pNameDimension1,sim3d.utils.CreateActor.MaxStrLengthName);
            end
            self.CreateActorStruct.ParentName=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthName));
            parentNameLength=length(parentName);
            self.CreateActorStruct.ParentName(1:parentNameLength)=parentName(1:parentNameLength);
        end

        function setActorName(self,actorName)
            aNameDimension1=size(actorName,1);
            if aNameDimension1>sim3d.utils.CreateActor.MaxStrLengthName
                error(message('shared_sim3dblks:CreateActorMessage:SizeErrorActorName').getString,...
                aNameDimension1,sim3d.utils.CreateActor.MaxStrLengthName);
            end
            self.CreateActorStruct.ActorName=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthName));
            actorNameLength=length(actorName);
            self.CreateActorStruct.ActorName(1:actorNameLength)=actorName(1:actorNameLength);
        end

        function setActorId(self,actorId)
            self.CreateActorStruct.ActorId=uint16(actorId);
        end

        function setMesh(self,meshName)
            meshDimension1=size(meshName,1);
            if meshDimension1>sim3d.utils.CreateActor.MaxStrLengthMesh
                error(message('shared_sim3dblks:CreateActorMessage:SizeErrorMeshName').getString,...
                meshDimension1,sim3d.utils.CreateActor.MaxStrLengthMesh);
            end
            self.CreateActorStruct.Mesh=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthMesh));
            meshNameLength=length(meshName);
            self.CreateActorStruct.Mesh(1:meshNameLength)=meshName(1:meshNameLength);
        end

        function setAnimation(self,animName)
            animDimension1=size(animName,1);
            if animDimension1>sim3d.utils.CreateActor.MaxStrLengthAnim
                error(message('shared_sim3dblks:CreateActorMessage:SizeErrorAnimName').getString,...
                animDimension1,sim3d.utils.CreateActor.MaxStrLengthAnim);
            end
            self.CreateActorStruct.Animation=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthAnim));
            animNameLength=length(animName);
            self.CreateActorStruct.Animation(1:animNameLength)=animName(1:animNameLength);
        end

        function setMobility(self,mobilityType)
            self.CreateActorStruct.Mobility=int32(mobilityType);
        end

        function setVisiblity(self,visibilityEn)
            self.CreateActorStruct.Visible=logical(visibilityEn);
        end

        function setHidden(self,hiddenEn)
            self.CreateActorStruct.Hidden=logical(hiddenEn);
        end

        function setPhysics(self,physicsEn)
            self.CreateActorStruct.SimulatePhysics=logical(physicsEn);
        end

        function setCollision(self,collisionType)
            collTypeDim1=size(collisionType,1);
            if collTypeDim1>sim3d.utils.CollisionTypes.Max||...
                collTypeDim1<sim3d.utils.CollisionTypes.Min
                error(message('shared_sim3dblks:CreateActorMessage:CollTypeSizeError').getString,...
                collTypeDim1,sim3d.utils.CollisionTypes.Min,sim3d.utils.CollisionTypes.Max);
            end
            collTypeDim2=size(collisionType,2);
            if collTypeDim2>1
                error(message('shared_sim3dblks:CreateActorMessage:CollTypeDimensionsError').getString,collTypeDim2);
            end
            self.CreateActorStruct.CollisionType=int32(collisionType);
        end

        function setWeight(self,weight)
            self.CreateActorStruct.Weight=single(weight);
        end

        function setGravity(self,gravityEn)
            self.CreateActorStruct.GravityEnabled=logical(gravityEn);
        end

        function setShadows(self,shadowsEn)
            self.CreateActorStruct.ShadowsEnabled=logical(shadowsEn);
        end
    end
end
