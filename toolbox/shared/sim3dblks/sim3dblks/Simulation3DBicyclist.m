classdef Simulation3DBicyclist<Simulation3DActor&Simulation3DHandleMap




    properties(Nontunable)

        Scale=[1,1,1];

        InitialPos=[0,0,0];

        InitialRot=[0,0,0];

        ActorTag='Bicyclist1';

        CoordinateScheme='ISO';
    end
    properties(Hidden,Constant)
        CoordinateSchemeSet=matlab.system.StringSet({'ISO','SAE'});
    end
    properties(Access=private)
BicObj
Translation
Rotation
        HitLocLimit=100000;
        ModelName=[];
    end
    methods(Access=protected)
        function setupImpl(self)

            self.Translation=zeros(1,3,'single');
            self.Rotation=zeros(1,3,'single');

            self.setInitialBicyclistPosition(self.InitialPos,self.InitialRot);

            setupImpl@Simulation3DActor(self);
            self.BicObj=sim3d.pedestrians.Bicyclist(self.ActorTag,...
            'Translation',self.Translation,...
            'Rotation',self.Rotation,...
            'Scale',self.Scale);
            self.BicObj.setup();
            self.BicObj.reset();
            self.ModelName=['Simulation3DBicyclist/',self.ActorTag];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/BicObj'],self.BicObj);
            end
        end

        function[translation,rotation]=stepImpl(self,X,Y,Yaw)
            self.setBicyclistPosition(X,Y,Yaw);
            if coder.target('MATLAB')
                if~isempty(self.BicObj)
                    [translation,rotation]=getPosition(self);
                    translation=double(translation(1,:));
                    rotation=double(rotation(1,:));
                    translation(2)=-translation(2);
                    rotation=[rotation(1:2),rotation(3)-pi];
                    self.BicObj.step(single(self.Translation(1)),single(self.Translation(2)),single(self.Rotation(3)));
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

            if isempty(self.BicObj)
                return;
            end

            self.BicObj.delete();
            self.BicObj=[];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/BicObj'],[]);
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Scale=s.Scale;
            self.ActorTag=s.ActorTag;
            self.ModelName=s.ModelName;
            if self.loadflag
                self.BicObj=self.Sim3dSetGetHandle([self.ModelName,'/BicObj']);
            else
                self.BicObj=s.BicObj;
            end

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end
        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DActor(self);
            s.BicObj=self.BicObj;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Scale=self.Scale;
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
            icon={'Bicyclist'};
        end

        function setInitialBicyclistPosition(self,Position,Rotation)
            if(self.CoordinateScheme=="SAE")
                Position(:,3)=-Position(:,3);
            else
                Rotation=deg2rad(Rotation);
                Position(2)=-Position(2);
                Rotation(2)=-Rotation(2);
                Rotation(3)=-Rotation(3);
            end


            self.Translation(1)=single(Position(1));
            self.Translation(2)=single(Position(2));
            self.Translation(3)=single(Position(3));
            self.Rotation(1)=single(Rotation(2));
            self.Rotation(2)=single(Rotation(1));
            self.Rotation(3)=single(Rotation(3));
        end
        function setBicyclistPosition(self,X,Y,Yaw)
            if(self.CoordinateScheme=="ISO")
                Yaw=deg2rad(-Yaw);
                Y=-Y;
            end

            self.Translation(1)=single(X);
            self.Translation(2)=single(Y);
            self.Rotation(3)=single(Yaw);
        end

        function checkGroundContact(self,traceEnd,status)
            if(status==sim3d.engine.EngineReturnCode.No_Data)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:vehicleRaytraceNoData'));
            end
            if any(traceEnd(:,3)>self.HitLocLimit)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:vehicleInitZLocError'));
            end
        end
    end


    methods(Access=public)
        function[Translation,Rotation]=getPosition(self)

            [Translation,Rotation,~]=self.BicObj.readTransform();
        end
    end
end