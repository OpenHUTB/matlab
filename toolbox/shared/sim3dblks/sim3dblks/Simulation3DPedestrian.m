classdef Simulation3DPedestrian<Simulation3DActor&Simulation3DHandleMap

    properties(Nontunable)

        PedMesh='Male 1';

        Scale=[1,1,1];

        InitialPos=[0,0,0];

        InitialYaw=0;

        ActorTag='Pedestrian1';

        CoordinateScheme='ISO';

    end
    properties(Hidden,Constant)

        PedMeshSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Male1',...
        'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Male2',...
        'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Male3',...
        'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Female1',...
        'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Female2',...
        'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Female3',...
        'shared_sim3dblks:sim3dblkPedestrianWithGroundFollowing:Child'});
        CoordinateSchemeSet=matlab.system.StringSet({'ISO','SAE'});
    end
    properties(Access=private)
PedObj
PedestrianType
Translation
Rotation
        HitLocLimit=100000;
        ModelName=[];
    end
    methods(Access=protected)
        function setupImpl(self)

            self.Translation=zeros(1,3,'single');
            self.Rotation=zeros(1,3,'single');

            self.setInitialPedestrianPosition(self.InitialPos,self.InitialYaw);
            self.PedestrianType=sim3d.utils.internal.StringMap.fwd(self.PedMesh);
            setupImpl@Simulation3DActor(self);
            self.PedObj=sim3d.pedestrians.Pedestrian(self.ActorTag,self.PedestrianType,...
            'Translation',self.Translation,...
            'Rotation',self.Rotation,...
            'Scale',self.Scale);
            self.PedObj.setup();
            self.PedObj.reset();
            self.ModelName=['Simulation3DPedestrian/',self.ActorTag];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/PedObj'],self.PedObj);
            end
        end
        function[translation,rotation]=stepImpl(self,X,Y,Yaw)
            self.setPedestrianPosition(X,Y,Yaw);
            if coder.target('MATLAB')
                if~isempty(self.PedObj)
                    [translation,rotation]=getPosition(self);
                    translation=double(translation);
                    rotation=double(rotation);
                    translation(:,2)=-translation(:,2);
                    rotation=[rotation(1:2),rotation(3)-pi];
                    self.PedObj.step(single(self.Translation(1)),single(self.Translation(2)),single(self.Rotation(3)));
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

            if isempty(self.PedObj)
                return;
            end

            self.PedObj.delete();
            self.PedObj=[];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/PedObj'],[]);
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.PedestrianType=s.PedestrianType;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Scale=s.Scale;
            self.PedMesh=s.PedMesh;
            self.ActorTag=s.ActorTag;
            self.ModelName=s.ModelName;
            if self.loadflag
                self.PedObj=self.Sim3dSetGetHandle([self.ModelName,'/PedObj']);
            else
                self.PedObj=s.PedObj;
            end

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end
        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DActor(self);
            s.PedObj=self.PedObj;
            s.PedestrianType=self.PedestrianType;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Scale=self.Scale;
            s.PedMesh=self.PedMesh;
            s.ActorTag=self.ActorTag;
            s.ModelName=self.ModelName;
        end

        function validateInputsImpl(~,X,Y,Yaw)

            if(~isequal(size(X),[1,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidXSize'));
            end
            if(~isequal(size(Y),[1,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidYSize'));
            end
            if(~isequal(size(Yaw),[1,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidYawSize'));
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end
        function[sz1,sz2]=getOutputSizeImpl(~)
            sz1=[1,3];
            sz2=[1,3];
        end
        function[fz1,fz2]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
        end
        function[dt1,dt2]=getOutputDataTypeImpl(~)
            dt1='double';
            dt2='double';
        end
        function[cp1,cp2]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
        end
        function[pn1,pn2]=getOutputNamesImpl(~)

            pn1='Translation';
            pn2='Rotation';
        end
        function icon=getIconImpl(~)
            icon={'Pedestrian'};
        end

        function setInitialPedestrianPosition(self,Position,theta)
            if(self.CoordinateScheme=="SAE")
                Position(:,3)=-Position(:,3);
            else
                Orientation=deg2rad([0,0,theta]);
                Orientation(2)=-Orientation(2);
                Orientation(3)=-Orientation(3);
                Position(2)=-Position(2);
            end


            self.Translation(1,1)=single(Position(1));
            self.Translation(1,2)=single(Position(2));
            self.Translation(1,3)=single(Position(3));
            self.Rotation(1,1)=single(Orientation(2));
            self.Rotation(1,2)=single(Orientation(1));
            self.Rotation(1,3)=single(Orientation(3));
        end
        function setPedestrianPosition(self,X,Y,Yaw)
            if(self.CoordinateScheme=="ISO")
                Yaw=deg2rad(-Yaw);
                Y=-Y;
            end
            self.Translation(1,1)=single(X);
            self.Translation(1,2)=single(Y);
            self.Rotation(1,3)=single(Yaw);
        end

        function checkGroundContact(self,traceEnd,status)
            if(status==sim3d.engine.EngineReturnCode.No_Data)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:vehicleRaytraceNoData'));
            end
            if any(traceEnd(3)>self.HitLocLimit)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:vehicleInitZLocError'));
            end
        end

    end
    methods(Access=public)
        function[Translation,Rotation]=getPosition(self)

            [Translation,Rotation,~]=self.PedObj.readTransform();
        end
    end
end