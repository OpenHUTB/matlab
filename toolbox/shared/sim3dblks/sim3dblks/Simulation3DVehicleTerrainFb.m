classdef Simulation3DVehicleTerrainFb<Simulation3DActor&...
Simulation3DHandleMap


    properties(Nontunable)

        PassVehMesh='Muscle car';

        VehColor='Red';

        InitialPos=[0,0,0];

        InitialRot=[0,0,0];

        ActorTag='SimulinkVehicle1';

        CoordinateScheme='ISO';

        MeshPath='';

        TrackWidth=1.38;

        WheelBase=5.5;

        WheelRadius=0.35;

        EnableLightControls logical=false;

        LeftHeadlightOrientation(1,2)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[0,0];

        LeftHeadlightLocation(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[50,0,0];

        RightHeadlightOrientation(1,2)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[0,0];

        RightHeadlightLocation(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[50,0,0];

        HeadligtColor(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=[1,1,1];

        TaillightColor(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=[1,0,0];

        BrakelightColor(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=[1,0,0];

        ReverselightColor(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=[1,0.868,0.3234];

        SignallightColor(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=[1,0.146,0];

        HighBeamIntensity(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=100000;

        LowBeamIntensity(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=60000;

        AttenuationRadius(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=10000;

        HighBeamRadius(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=70;

        LowBeamRadius(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=70;

        BrakelightIntensity(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=500;

        ReverselightIntensity(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=500;

        IndicatorlightIntensity(1,1)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=500;

        MatPath='/MathWorksSimulation/VehicleCommon/Materials/Lights/M_VehicleMatLight.M_VehicleMatLight';
    end


    properties(Hidden,Constant)
        PassVehMeshSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:musclecar',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:sedan',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:sportutilityvehicle',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:smallpickuptruck',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:hatchback',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:boxtruck',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:custom'});
        VehColorSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:red',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:orange',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:yellow',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:blue',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:green',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:white',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:black',...
        'shared_sim3dblks:sim3dblkVehicleWithGroundFollowing:silver'});
        CoordinateSchemeSet=matlab.system.StringSet({'ISO','SAE'});
    end

    properties(Access=private)
VehObj
VehicleType
ActorColor
Translation
Rotation
Scale
LightConfiguration
        HitLocLimit=100000;
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            self.Translation=zeros(5,3,'single');
            self.Rotation=zeros(5,3,'single');
            self.Scale=ones(5,3,'single');

            self.setInitialVehiclePosition(self.InitialPos,self.InitialRot);

            setupImpl@Simulation3DActor(self);
            self.VehicleType=sim3d.utils.internal.StringMap.fwd(self.PassVehMesh);
            self.ActorColor=lower(self.VehColor);
            self.LightConfiguration={};
            if self.EnableLightControls
                self.LightConfiguration=self.generateLightsConfig();
            end
            self.VehObj=sim3d.auto.PassengerVehicle(self.ActorTag,self.VehicleType,...
            'Color',self.ActorColor,...
            'Translation',self.Translation,...
            'Rotation',self.Rotation,...
            'Scale',self.Scale,...
            'Mesh',self.MeshPath,...
            'TrackWidth',self.TrackWidth,...
            'WheelBase',self.WheelBase,...
            'WheelRadius',self.WheelRadius,...
            'LightConfiguration',self.LightConfiguration);
            self.VehObj.setup();
            self.VehObj.reset();
            self.ModelName=['Simulation3DVehicleTerrainFb/',self.ActorTag];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],self.VehObj);
            end
        end
        function[translation,rotation]=stepImpl(self,X,Y,Yaw,steerAngle,wheelRotation,LightStates)
            [~,traceEnd,status]=self.VehObj.VehicleRayTraceRead();
            self.checkGroundContact(traceEnd,status);
            wheelHitZ=traceEnd(2:5,3);
            self.setVehiclePosition(X,Y,Yaw,wheelHitZ,steerAngle,wheelRotation);
            if coder.target('MATLAB')
                if~isempty(self.VehObj)
                    [translation,rotation,~]=self.VehObj.readTransform();
                    translation=double(translation(1,:));
                    rotation=double(rotation(1,:));
                    translation(:,2)=-translation(:,2);
                    rotation(:,1)=-rotation(:,1);
                    rotation=[fliplr(rotation(:,1:2)),-rotation(:,3)];
                    if(self.EnableLightControls)
                        self.VehObj.LightModule.setVehicleLightStatesArray(sim3d.vehicle.VehicleLightingModule.PassVehLightCategories,[LightStates;LightStates(1)||LightStates(2)]);
                    end
                    self.VehObj.writeTransform(single(self.Translation),single(self.Rotation),single(ones(size(self.Translation))));
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

            if isempty(self.VehObj)
                return;
            end

            self.VehObj.delete();
            self.VehObj=[];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],[]);
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.VehicleType=s.VehicleType;
            self.ActorColor=s.ActorColor;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Scale=s.Scale;
            self.PassVehMesh=s.PassVehMesh;
            self.VehColor=s.VehColor;
            self.ActorTag=s.ActorTag;
            self.ModelName=s.ModelName;
            self.LightConfiguration=s.LightConfiguration;
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
            s.Scale=self.Scale;
            s.PassVehMesh=self.PassVehMesh;
            s.VehColor=self.VehColor;
            s.ActorTag=self.ActorTag;
            s.ModelName=self.ModelName;
            s.LightConfiguration=self.LightConfiguration;
        end

        function validateInputsImpl(~,X,Y,Yaw,~,~,LightStates)

            if(~isequal(size(X),[1,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidXSize'));
            end
            if(~isequal(size(Y),[1,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidYSize'));
            end
            if(~isequal(size(Yaw),[1,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidYawSize'));
            end
            if(~isequal(size(LightStates),[6,1]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidLightStatesSize',size(LightStates,1),size(LightStates,2)));
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
            icon={'Vehicle'};
        end
        function setInitialVehiclePosition(self,Position,Rotation)
            if(self.CoordinateScheme=="SAE")
                Position(:,3)=-Position(:,3);
            else
                Rotation=deg2rad(Rotation);
                Position(2)=-Position(2);
                Rotation(2)=-Rotation(2);
                Rotation(3)=-Rotation(3);
            end


            self.Translation(1,1)=single(Position(1));
            self.Translation(1,2)=single(Position(2));
            self.Translation(1,3)=single(Position(3));
            self.Rotation(1,1)=single(Rotation(2));
            self.Rotation(1,2)=single(Rotation(1));
            self.Rotation(1,3)=single(Rotation(3));


            self.Rotation(2:5,1)=0;
            self.Rotation(2:3,3)=0;

        end
        function setVehiclePosition(self,X,Y,Yaw,wheelHitZ,steerAngle,wheelRotation)
            trackW=1.9;
            wheelB=3;
            if(self.VehicleType=="BoxTruck")
                trackW=1.38;
                wheelB=5.5;
            end
            Zcg=mean(wheelHitZ);
            psi=atan(((wheelHitZ(1)-wheelHitZ(2))+(wheelHitZ(3)-wheelHitZ(4)))./trackW./2);
            theta=atan(((wheelHitZ(1)-wheelHitZ(3))+(wheelHitZ(2)-wheelHitZ(4)))./wheelB./2);

            if(self.CoordinateScheme=="ISO")
                Yaw=deg2rad(-Yaw);
                Y=-Y;
            end

            self.Translation(1,1)=single(X);
            self.Translation(1,2)=single(Y);
            self.Translation(1,3)=single(Zcg);
            self.Rotation(1,1)=single(theta);
            self.Rotation(1,2)=single(psi);
            self.Rotation(1,3)=single(Yaw);


            self.Rotation(2,1)=single(wheelRotation);
            self.Rotation(3,1)=single(wheelRotation);
            self.Rotation(4,1)=single(wheelRotation);
            self.Rotation(5,1)=single(wheelRotation);
            self.Rotation(2,3)=single(steerAngle);
            self.Rotation(3,3)=single(steerAngle);
        end

        function checkGroundContact(self,traceEnd,status)
            if(status==sim3d.engine.EngineReturnCode.No_Data)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:vehicleRaytraceNoData'));
            end
            if any(traceEnd(2:5,3)>self.HitLocLimit)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:vehicleInitZLocError'));
            end
        end

    end

    methods(Access=public)
        function[Transformation,Rotation,Scale]=getPosition(self)
            [Transformation,Rotation,Scale]=self.VehObj.readTransform();
        end
    end

    methods(Access=private)
        function LightConfiguration=generateLightsConfig(self)
            LightConfiguration={};
            if(~self.EnableLightControls)
                return;
            end
            self.ApplyCoordinateTransformToLightParams();
            LeftHighBeam=struct(...
            'LightType','PointLight',...
            'Category',"HighBeams",...
            'LightName','LHB',...
            'LightColor',self.HeadligtColor,...
            'Intensity',self.HighBeamIntensity,...
            'SocketName','Lights_Headlight_Left',...
            'RelativeTransform',[self.LeftHeadlightOrientation,0,self.LeftHeadlightLocation],...
            'AttenuationRadius',self.AttenuationRadius);
            RightHighBeam=struct(...
            'LightType','PointLight',...
            'Category',"HighBeams",...
            'LightName','RHB',...
            'LightColor',self.HeadligtColor,...
            'Intensity',self.HighBeamIntensity,...
            'SocketName','Lights_Headlight_Right',...
            'RelativeTransform',[self.RightHeadlightOrientation,0,self.RightHeadlightLocation],...
            'AttenuationRadius',self.AttenuationRadius);
            LeftLowBeam=struct(...
            'LightType','Spotlight',...
            'Category',"LowBeams",...
            'LightName','LLB',...
            'LightColor',self.HeadligtColor,...
            'Intensity',self.LowBeamIntensity,...
            'SocketName','Lights_Headlight_Left',...
            'RelativeTransform',[self.LeftHeadlightOrientation,0,self.LeftHeadlightLocation],...
            'AttenuationRadius',self.AttenuationRadius,...
            'InnerConeAngle',self.LowBeamRadius,...
            'OuterConeAngle',self.LowBeamRadius+10,...
            'ReverseState',false);
            RightLowBeam=struct(...
            'LightType','Spotlight',...
            'Category',"LowBeams",...
            'LightName','RLB',...
            'LightColor',self.HeadligtColor,...
            'Intensity',self.LowBeamIntensity,...
            'SocketName','Lights_Headlight_Right',...
            'RelativeTransform',[self.RightHeadlightOrientation,0,self.RightHeadlightLocation],...
            'AttenuationRadius',self.AttenuationRadius,...
            'InnerConeAngle',self.LowBeamRadius,...
            'OuterConeAngle',self.LowBeamRadius+10,...
            'ReverseState',false);
            HeadlightMat=struct(...
            'LightType',"MatLight",...
            'Category',"MatHeadlights",...
            'MatPath',self.MatPath,...
            'MatSlotName','M_Headlight',...
            'ParamName','LightOn',...
            'ParamOn',5000,...
            'ParamOff',0,...
            'LightColor',self.HeadligtColor,...
            'ReverseState',false);
            TaillightMat=struct(...
            'LightType',"MatLight",...
            'Category',"TailLights",...
            'MatPath',self.MatPath,...
            'MatSlotName','M_TailLight',...
            'ParamName','LightOn',...
            'ParamOn',100,...
            'ParamOff',0,...
            'LightColor',self.TaillightColor,...
            'ReverseState',false,...
            'InitState',true);
            BrakeLight=struct(...
            'LightType',"MatLight",...
            'Category',"BrakeLights",...
            'MatPath',self.MatPath,...
            'MatSlotName','M_Brakelight',...
            'ParamName','LightOn',...
            'ParamOn',self.BrakelightIntensity,...
            'ParamOff',0,...
            'LightColor',self.BrakelightColor,...
            'ReverseState',false);
            ReverseLight=struct(...
            'LightType',"MatLight",...
            'Category',"ReverseLights",...
            'MatPath',self.MatPath,...
            'MatSlotName','M_Reverselight',...
            'ParamName','LightOn',...
            'ParamOn',self.ReverselightIntensity,...
            'ParamOff',0,...
            'LightColor',self.ReverselightColor,...
            'ReverseState',false);
            LeftSignal=struct(...
            'LightType',"MatLight",...
            'Category',"LeftSignals",...
            'MatPath',self.MatPath,...
            'MatSlotName','M_IndicatorlightLeft',...
            'ParamName','LightOn',...
            'ParamOn',self.IndicatorlightIntensity,...
            'ParamOff',0,...
            'LightColor',self.SignallightColor,...
            'ReverseState',false);
            RightSignal=struct(...
            'LightType',"MatLight",...
            'Category',"RightSignals",...
            'MatPath',self.MatPath,...
            'MatSlotName','M_IndicatorlightRight',...
            'ParamName','LightOn',...
            'ParamOn',self.IndicatorlightIntensity,...
            'ParamOff',0,...
            'LightColor',self.SignallightColor,...
            'ReverseState',false);
            LightConfiguration={LeftHighBeam,RightHighBeam,LeftLowBeam,RightLowBeam,HeadlightMat,TaillightMat,BrakeLight,ReverseLight,LeftSignal,RightSignal};
        end

        function ApplyCoordinateTransformToLightParams(self)
            if(self.CoordinateScheme=="SAE")
                self.LeftHeadlightOrientation=rad2deg(self.LeftHeadlightOrientation);
                self.RightHeadlightOrientation=rad2deg(self.RightHeadlightOrientation);
                self.HighBeamRadius=rad2deg(self.HighBeamRadius);
                self.LowBeamRadius=rad2deg(self.LowBeamRadius);
            else
                self.LeftHeadlightOrientation=-self.LeftHeadlightOrientation;
                self.RightHeadlightOrientation=-self.RightHeadlightOrientation;
            end
        end
    end
end