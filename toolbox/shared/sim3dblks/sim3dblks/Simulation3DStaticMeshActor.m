classdef Simulation3DStaticMeshActor<Simulation3DActor&...
Simulation3DHandleMap


    properties(Nontunable)

        StaticMeshActorType='Cone';

        ActorTag='StaticMeshActor1';

        MeshPath='';

        InitialPos(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[0,0,0];

        InitialRot(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[0,0,0];

        InitialScale(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[1,1,1];

        ParentActor='Scene Origin';

        ActorID=uint16(sim3d.utils.SemanticType.None);

        Mobility='Moveable';

        Visibility(1,1)logical=true;

        HiddenInGame(1,1)logical=false;

        SimulatePhysics(1,1)logical=false;

        EnableGravity(1,1)logical=false;

        CastShadows(1,1)logical=true;

        ActorControl(1,1)logical=true;

        ControlledActor='StaticMeshActor1';
    end

    properties(Hidden,Constant)
        StaticMeshActorTypeSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkStaticMeshActor:cone'});

        MobilitySet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkStaticMeshActor:moveable',...
        'shared_sim3dblks:sim3dblkStaticMeshActor:static'});
    end


    properties(Access=private)
        ActorObj=[];
NumOfActors
NumOfControlledActors
Writer
Writer2
Reader2
ActorType
Translation
Rotation
Scale
MobilityType
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            self.Translation=single(self.InitialPos);
            self.Rotation=single(self.InitialRot);
            self.Scale=single(self.InitialScale);

            setupImpl@Simulation3DActor(self);

            switch self.Mobility
            case 'Moveable'
                self.MobilityType=int32(sim3d.utils.MobilityTypes.Movable);
            case 'Static'
                self.MobilityType=int32(sim3d.utils.MobilityTypes.Static);
            end

            self.ActorType='/Game/Environment/Industrial/Props/Cone/Mesh/SM_Cone.SM_Cone';

            self.NumOfActors=size(self.Translation,1);

            self.ActorTag=split(self.ActorTag,',');
            self.ControlledActor=split(self.ControlledActor,',');
            ActorOriginalList=self.ActorTag;

            for k=1:length(self.ActorTag)
                self.ActorTag{k}=['StaticMeshActor',self.ActorTag{k}];
            end
            for k=1:length(self.ControlledActor)
                self.ControlledActor{k}=['StaticMeshActor',self.ControlledActor{k}];
            end

            self.NumOfControlledActors=length(self.ControlledActor);

            for i=1:self.NumOfActors
                self.ActorObj=[self.ActorObj,sim3d.StaticActor(self.ActorTag{i},self.ActorType,self.Translation(i,:),...
                'Rotation',self.Rotation(i,:),...
                'Scale',self.Scale(i,:),...
                'ParentActor',self.ParentActor,...
                'CustomDepthStencilValue',self.ActorID,...
                'Mobility',self.MobilityType,...
                'Visibility',self.Visibility,...
                'HiddenInGame',self.HiddenInGame,...
                'SimulatePhysics',self.SimulatePhysics,...
                'EnableGravity',self.EnableGravity,...
                'CastShadow',self.CastShadows)];
                self.ModelName=['Simulation3DStaticMeshActor/',self.ActorTag(i)];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/ActorObj'],self.ActorObj(i));
                end


                self.ActorObj(i).setup();
                self.ActorObj(i).reset();
            end


            coneNameL=['ConeA,','ConeB,','ConeC,','ConeD,','ConeE,','ConeF,','ConeG,','ConeH,','ConeI,','ConeJ,','ConeK,','ConeL,','ConeM,','ConeN,','ConeO'];
            coneNameR=['ConeA'',','ConeB'',','ConeC'',','ConeD'',','ConeE'',','ConeF'',','ConeG'',','ConeH'',','ConeI'',','ConeJ'',','ConeK'',','ConeL'',','ConeM'',','ConeN'',','ConeO'''];
            coneNameL=split(coneNameL,',');
            coneNameR=split(coneNameR,',');
            coneNameUE=[coneNameL;coneNameR];

            LNames=['a,','b,','c,','d,','e,','f,','g,','h,','i,','j,','k,','l,','m,','n,','o'];
            RNames=['a'',','b'',','c'',','d'',','e'',','f'',','g'',','h'',','i'',','j'',','k'',','l'',','m'',','n'',','o'''];
            LNames=split(LNames,',');
            RNames=split(RNames,',');
            coneNameSL=[LNames;RNames];

            removeActor=sim3d.utils.RemoveActor;
            for c=1:length(coneNameSL)
                if(ismember(coneNameSL{c},ActorOriginalList))
                    removeActor.setActorName(coneNameUE{c});
                    removeActor.write;
                end
            end



        end

        function[translation,rotation,collision]=stepImpl(self,location,orientation,scale)
            if coder.target('MATLAB')
                for i=1:self.NumOfActors
                    if~isempty(self.ActorObj(i))

                        [translation1,rotation1,~]=self.ActorObj(i).readTransform();


                        collision(i,1)=self.ActorObj(i).readMessage();


                        translation(i,:)=double(translation1);
                        rotation(i,:)=double(rotation1);


                        if(self.ActorControl)
                            self.Translation=single(reshape(location,[self.NumOfControlledActors,3]));
                            self.Rotation=single(reshape(orientation,[self.NumOfControlledActors,3]));
                            self.Scale=single(reshape(scale,[self.NumOfControlledActors,3]));
                            index=find(strcmp(self.ControlledActor,self.ActorObj(i).getTag()),1);
                            if~(isempty(index))

                                self.ActorObj(i).writeTransform(single(self.Translation(index,:)),...
                                single(self.Rotation(index,:)),single(self.Scale(index,:)));
                            end
                        end
                    end
                end
            end
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if~strcmp(simulationStatus,'terminating')
                return;
            end

            if~coder.target('MATLAB')
                return;
            end

            if isempty(self.ActorObj)
                return;
            end

            self.ActorObj.delete();
            self.ActorObj=[];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/ActorObj'],[]);
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.ActorObj=s.ActorObj;
            self.NumOfActors=s.NumOfActors;
            self.NumOfControlledActors=s.NumOfControlledActors;
            self.Writer=s.Writer;
            self.Writer2=s.Writer2;
            self.Reader2=s.Reader2;
            self.ActorType=s.ActorType;
            self.ActorTag=s.ActorTag;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Scale=s.Scale;
            self.MobilityType=s.MobilityType;

            self.ModelName=s.ModelName;

            if self.loadflag
                self.ActorObj=self.Sim3dSetGetHandle([self.ModelName,'/ActorObj']);
            else
                self.ActorObj=s.ActorObj;
            end

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DActor(self);
            s.ActorObj=self.ActorObj;
            s.NumOfActors=self.NumOfActors;
            s.NumOfControlledActors=self.NumOfControlledActors;
            s.Writer=self.Writer;
            s.Writer2=self.Writer2;
            s.Reader2=self.Reader2;
            s.ActorType=self.ActorType;
            s.ActorTag=self.ActorTag;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Scale=self.Scale;
            s.MobilityType=self.MobilityType;

            s.ModelName=self.ModelName;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function[sz1,sz2,sz3]=getOutputSizeImpl(self)
            Size=size(self.InitialPos,1);
            sz1=[Size,3];
            sz2=[Size,3];
            sz3=[Size,1];
        end
        function[fz1,fz2,fz3]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
            fz3=true;
        end
        function[dt1,dt2,dt3]=getOutputDataTypeImpl(~)
            dt1='double';
            dt2='double';
            dt3='double';
        end
        function[cp1,cp2,cp3]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
            cp3=false;
        end
        function[pn1,pn2,pn3]=getOutputNamesImpl(~)

            pn1='Translation';
            pn2='Rotation';
            pn3='Collision Flag';
        end

        function validateInputsImpl(self,location,orientation,scale)
            if(self.ActorControl)
                if(isvector(location))
                    location=location';
                end
                if(isvector(orientation))
                    orientation=orientation';
                end
                if(isvector(scale))
                    scale=scale';
                end
                translationSize=size(location);
                orientationSize=size(orientation);
                scaleSize=size(scale);
                numOfActors=length(split(self.ControlledActor,','));

                validTranslation=(translationSize(1)==numOfActors)&(translationSize(2)==3);
                validOrientation=(orientationSize(1)==numOfActors)&(orientationSize(2)==3);
                validScale=(scaleSize(1)==numOfActors)&(scaleSize(2)==3);

                if~validTranslation
                    error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidTranslationSize',numOfActors,3))
                end
                if~validOrientation
                    error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidRotationSize',numOfActors,3))
                end
                if~validScale
                    error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidScaleSize',numOfActors,3))
                end
            end
        end

        function validatePropertiesImpl(self)
            translationSize=size(self.InitialPos,1);
            orientationSize=size(self.InitialRot,1);
            scaleSize=size(self.InitialScale,1);
            numOfActors=length(split(self.ActorTag,','));

            validTransform=(translationSize==numOfActors)&(orientationSize==numOfActors)&(scaleSize==numOfActors);

            if~validTransform
                error(message('shared_sim3dblks:sim3dblkStaticMeshActor:invalidInitialTransform',numOfActors,3))
            end
        end
    end
end
