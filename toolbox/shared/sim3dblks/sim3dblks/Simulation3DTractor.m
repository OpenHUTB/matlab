classdef Simulation3DTractor<Simulation3DActor&...
Simulation3DHandleMap





    properties
        Translation(7,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=zeros(7,3);
        Rotation(7,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=zeros(7,3);
    end

    properties(Nontunable)

        Mesh='Conventional tractor';

        TractorColor='Red';

        ActorTag='SimulinkVehicle1';
    end

    properties(Hidden,Constant)
        MeshSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkTractor:conventionaltractor',...
        'shared_sim3dblks:sim3dblkTractor:cabovertractor'});
        TractorColorSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkTractor:red',...
        'shared_sim3dblks:sim3dblkTractor:orange',...
        'shared_sim3dblks:sim3dblkTractor:yellow',...
        'shared_sim3dblks:sim3dblkTractor:blue',...
        'shared_sim3dblks:sim3dblkTractor:green',...
        'shared_sim3dblks:sim3dblkTractor:white',...
        'shared_sim3dblks:sim3dblkTractor:black',...
        'shared_sim3dblks:sim3dblkTractor:silver'});
    end

    properties(Access=private)
VehObj
VehicleType
ActorColor
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            self.VehicleType=sim3d.utils.internal.StringMap.fwd(self.Mesh);
            self.ActorColor=lower(self.TractorColor);

            self.VehObj=sim3d.auto.Tractor(self.ActorTag,self.VehicleType,...
            'Color',self.ActorColor,...
            'Translation',self.Translation,...
            'Rotation',self.Rotation);
            self.VehObj.setup();
            self.VehObj.reset();
            self.ModelName=['Simulation3DTractor/',self.ActorTag];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],self.VehObj);
            end
        end

        function stepImpl(self,translation,rotation)

            translation(:,3)=-translation(:,3);
            rotation=[fliplr(rotation(:,1:2)),rotation(:,3)];
            if coder.target('MATLAB')
                if~isempty(self.VehObj)
                    self.VehObj.writeTransform(single(translation),single(rotation),single(ones(size(translation))));
                end
            end
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'terminating')
                if coder.target('MATLAB')
                    if~isempty(self.VehObj)
                        self.VehObj.delete();
                        self.VehObj=[];
                        if self.loadflag
                            self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],[]);
                        end
                    end
                end
            end
        end

        function resetImpl(~)

        end

        function loadObjectImpl(self,s,wasInUse)
            self.VehicleType=s.VehicleType;
            self.ActorColor=s.ActorColor;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Mesh=s.Mesh;
            self.TractorColor=s.TractorColor;
            self.ActorTag=s.ActorTag;
            self.ModelName=s.ModelName;
            if self.loadflag
                self.VehObj=self.Sim3dSetGetHandle([self.ModelName,'/VehObj']);
            else
                self.VehObj=s.VehObj;
            end
            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DActor(self);
            s.VehObj=self.VehObj;
            s.VehicleType=self.VehicleType;
            s.ActorColor=self.ActorColor;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Mesh=self.Mesh;
            s.TractorColor=self.TractorColor;
            s.ActorTag=self.ActorTag;
            s.ModelName=self.ModelName;
        end
        function icon=getIconImpl(~)
            icon={'Tractor'};
        end

        function[nrows,ncols]=getInputPortSize(~)

            nrows=7;
            ncols=3;
        end

        function validateInputsImpl(self,translation,rotation)
            [nrows,ncols]=getInputPortSize(self);
            translationSize=size(translation);
            rotationSize=size(rotation);
            if(~isequal(translationSize,[nrows,ncols]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidTranslationSize',nrows,ncols));
            end
            if(~isequal(rotationSize,[nrows,ncols]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidRotationSize',nrows,ncols));
            end
        end
    end

    methods(Access=public)
        function[Transformation,Rotation,Scale]=getPosition(self)
            [Transformation,Rotation,Scale]=self.VehObj.readTransform();
        end
    end
end

