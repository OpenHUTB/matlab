classdef Simulation3DPhysVehicle<Simulation3DActor&...
Simulation3DHandleMap


    properties(Nontunable)

        PassVehMesh='Muscle car';

        VehColor='Red';

        InitialPos=[0,0,0];

        InitialRot=[0,0,0];

        ActorTag='SimulinkPhysVehicle1';

        CoordinateScheme='SAE';

        MeshPath='';

        Mass=1500;

        Cd=0.3;

        TrackWidth=1.80;

        ChassisHeight=1.5;

        WheelBase=1.4;

        IvehScale=[1,1,1];

        CgOffset=[0,0,0];

        TrqCrv=[0,300,400,0];

        SpdCrv=[0,1000,5500,8000];

        MaxRPM=10000;

        Jmot=1;

        bEngMax=0.15;

        bEngMin=2;

        bEngN=0.35;

        DrivetrainType='Rear Wheel Drive';

        DiffType='Limited Slip';

        TransType='Automatic';

        FrontRearSplit=0.5;

        ClutchGain=10;

        tShift=0.5;

        tMinShift=2.0;

        UpShiftPts=[0.15,0.65,0.65,0.65,0.65];

        DownShiftPts=[0.15,0.5,0.5,0.5,0.5];

        G=[-1,0,1,2,3,4,5];

        N=[-4,4,2,1.5,1.1,1.0];

        NDiff=4.0;

        EnableFrontSteer(1,1)logical=true;

        EnableRearSteer(1,1)logical=false;

        PctAck=100.0;

        SteerSpdFctTbl=[1,0.8,0.7];

        SteerVehSpdBpts=[0,60,120];

        FrntWhlRadius=0.30;

        FrntWhlMass=20;

        FrntWhlDamping=0.25;

        FrntWhlMaxSteer=70;

        FrntTireMaxLatLoadFactor=2.0;

        FrntTireLatStiff=17;

        FrntTireLongStiff=1000;

        RearWhlRadius=0.30;

        RearWhlMass=20;

        RearWhlDamping=0.25;

        RearWhlMaxSteer=70;

        RearTireMaxLatLoadFactor=2.0;

        RearTireLatStiff=17;

        RearTireLongStiff=1000;

        FrntWhlHndBrkEnable(1,1)logical=true;

        RearWhlHndBrkEnable(1,1)logical=true;

        FrntWhlMaxTrq=1500;

        RearWhlMaxTrq=1500;

        FrntWhlMaxHndBrkTrq=3000;

        RearWhlMaxHndBrkTrq=1500;

        lambda_mu=1.0;

        FrntSuspFOffset=[0,0,0];

        FrntSuspMaxComp=.01;

        FrntSuspMaxExt=.01;

        FrntSuspNatFreq=7;

        FrntSuspDamping=1;

        RearSuspFOffset=[0,0,0];

        RearSuspMaxComp=.01;

        RearSuspMaxExt=.01;

        RearSuspNatFreq=7;

        RearSuspDamping=1;

        EnableLightControls(1,1)logical=false;

        LeftHeadlightOrientation(1,2)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[0,0];

        LeftHeadlightLocation(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[50,0,0];

        RightHeadlightOrientation(1,2)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[0,0];

        RightHeadlightLocation(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=[50,0,0];

        HeadlightColor(1,3)double{mustBeFinite,mustBeReal,mustBeNonmissing,mustBeNonnegative}=[1,1,1];

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

    properties(Hidden=true,Constant=true,Access=private)
        ConstantNumberOfOutports=true;
    end

    properties(Hidden,Constant)
        PassVehMeshSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkVehicle:musclecar',...
        'shared_sim3dblks:sim3dblkVehicle:sedan',...
        'shared_sim3dblks:sim3dblkVehicle:sportutilityvehicle',...
        'shared_sim3dblks:sim3dblkVehicle:smallpickuptruck',...
        'shared_sim3dblks:sim3dblkVehicle:hatchback',...
        'shared_sim3dblks:sim3dblkVehicle:boxtruck',...
        'shared_sim3dblks:sim3dblkVehicle:custom'});
        VehColorSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkVehicle:red',...
        'shared_sim3dblks:sim3dblkVehicle:orange',...
        'shared_sim3dblks:sim3dblkVehicle:yellow',...
        'shared_sim3dblks:sim3dblkVehicle:blue',...
        'shared_sim3dblks:sim3dblkVehicle:green',...
        'shared_sim3dblks:sim3dblkVehicle:white',...
        'shared_sim3dblks:sim3dblkVehicle:black',...
        'shared_sim3dblks:sim3dblkVehicle:silver'});
        CoordinateSchemeSet=matlab.system.StringSet({'ISO','SAE'});
        DrivetrainTypeSet=matlab.system.StringSet({'Rear Wheel Drive','Front Wheel Drive','All Wheel Drive'});
        DiffTypeSet=matlab.system.StringSet({'Limited Slip','Open'});
        TransTypeSet=matlab.system.StringSet({'Automatic','Manual'});
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
            self.Translation=zeros(1,3,'single');
            self.Rotation=zeros(1,3,'single');
            self.Scale=ones(1,3,'single');
            self.setInitialVehiclePosition(self.InitialPos,self.InitialRot);
            setupImpl@Simulation3DActor(self);
            self.VehicleType=sim3d.utils.internal.StringMap.fwd(self.PassVehMesh);
            self.ActorColor=lower(self.VehColor);
            self.LightConfiguration={};

            self.LightConfiguration=self.generateLightsConfig();

            vehicleProperties=sim3d.auto.PhysVehicle.getPhysVehicleProperties();
            vehicleProperties.Mass=self.Mass;
            vehicleProperties.Cd=self.Cd;
            vehicleProperties.CgOffset=self.CgOffset;
            vehicleProperties.IvehScale=self.IvehScale;
            vehicleProperties.ChassisHeight=self.ChassisHeight;
            vehicleProperties.MaxRPM=self.MaxRPM;
            vehicleProperties.DrivetrainType=string(self.DrivetrainType);
            vehicleProperties.DiffType=string(self.DiffType);
            vehicleProperties.Jmot=self.Jmot;
            vehicleProperties.bEngMax=self.bEngMax;
            vehicleProperties.bEngMin=self.bEngMin;
            vehicleProperties.bEngN=self.bEngN;
            vehicleProperties.NDiff=self.NDiff;
            vehicleProperties.ClutchGain=self.ClutchGain;
            vehicleProperties.tShift=self.tShift;
            vehicleProperties.tMinShift=self.tMinShift;
            vehicleProperties.DownShiftPts=self.DownShiftPts;
            vehicleProperties.UpShiftPts=self.UpShiftPts;
            vehicleProperties.N=self.N;
            vehicleProperties.G=int32(self.G);
            vehicleProperties.FrontRearSplit=self.FrontRearSplit;
            vehicleProperties.TrqCrv=self.TrqCrv;
            vehicleProperties.SpdCrv=self.SpdCrv;
            vehicleProperties.EnableFrontSteer=self.EnableFrontSteer;
            vehicleProperties.EnableRearSteer=self.EnableRearSteer;
            vehicleProperties.PctAck=self.PctAck;
            vehicleProperties.SteerCrv=self.SteerSpdFctTbl;
            vehicleProperties.SteerSpdCrv=self.SteerVehSpdBpts;
            vehicleProperties.FrntWhlRadius=self.FrntWhlRadius;
            vehicleProperties.FrntWhlMass=self.FrntWhlMass;
            vehicleProperties.FrntWhlDamping=self.FrntWhlDamping;
            vehicleProperties.FrntWhlMaxSteer=self.FrntWhlMaxSteer;
            vehicleProperties.FrntTireMaxLatLoadFactor=self.FrntTireMaxLatLoadFactor;
            vehicleProperties.FrntTireLatStiff=self.FrntTireLatStiff;
            vehicleProperties.FrntTireLongStiff=self.FrntTireLongStiff;
            vehicleProperties.RearWhlRadius=self.RearWhlRadius;
            vehicleProperties.RearWhlMass=self.RearWhlMass;
            vehicleProperties.RearWhlDamping=self.RearWhlDamping;
            vehicleProperties.RearWhlMaxSteer=self.RearWhlMaxSteer;
            vehicleProperties.RearTireMaxLatLoadFactor=self.RearTireMaxLatLoadFactor;
            vehicleProperties.RearTireLongStiff=self.RearTireLongStiff;
            vehicleProperties.FrntWhlHndBrkEnable=self.FrntWhlHndBrkEnable;
            vehicleProperties.RearWhlHndBrkEnable=self.RearWhlHndBrkEnable;
            vehicleProperties.FrntWhlMaxTrq=self.FrntWhlMaxTrq;
            vehicleProperties.RearWhlMaxTrq=self.RearWhlMaxTrq;
            vehicleProperties.FrntWhlMaxHndBrkTrq=self.FrntWhlMaxHndBrkTrq;
            vehicleProperties.RearWhlMaxHndBrkTrq=self.RearWhlMaxHndBrkTrq;
            vehicleProperties.lambda_mu=self.lambda_mu;
            vehicleProperties.FrntSuspFOffset=self.FrntSuspFOffset;
            vehicleProperties.FrntSuspMaxComp=self.FrntSuspMaxComp;
            vehicleProperties.FrntSuspMaxExt=self.FrntSuspMaxExt;
            vehicleProperties.FrntSuspNatFreq=self.FrntSuspNatFreq;
            vehicleProperties.FrntSuspDamping=self.FrntSuspDamping;
            vehicleProperties.RearSuspFOffset=self.RearSuspFOffset;
            vehicleProperties.RearSuspMaxComp=self.RearSuspMaxComp;
            vehicleProperties.RearSuspMaxExt=self.RearSuspMaxExt;
            vehicleProperties.RearSuspNatFreq=self.RearSuspNatFreq;
            vehicleProperties.RearSuspDamping=self.RearSuspDamping;
            if strcmp(self.TransType,'Automatic')
                vehicleProperties.AutoTrans=true;
            else
                vehicleProperties.AutoTrans=false;
            end
            self.VehObj=sim3d.auto.PhysVehicle(self.ActorTag,self.VehicleType,...
            vehicleProperties,...
            'Color',self.ActorColor,...
            'Translation',self.Translation,...
            'Rotation',self.Rotation,...
            'Scale',self.Scale,...
            'Mesh',self.MeshPath,...
            'LightConfiguration',self.LightConfiguration...
            );


            self.VehObj.setup();
            self.VehObj.reset();
            self.ModelName=['Simulation3DPhysVehicle/',self.ActorTag];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],self.VehObj);
            end
        end
        function[vehicleDispFdbk,vehicleVelFdbk,vehicleAccelFdbk,xbar,DCM,drivelineFdbk,tireFdbk]=stepImpl(self,steerCmd,acclCmd,decelCmd,gearCmd,hndbrkCmd,LightStates)
            if coder.target('MATLAB')
                if~isempty(self.VehObj)
                    [translation,rotation,~]=self.VehObj.readTransform();
                    translation=double(translation(1,:));
                    rotation=double(rotation(1,:));
                    vehicleDispFdbk=[translation;rotation];
                    [inertVel,bodyVel,bodyAccel,bodyAngVel,bodyAngAcc,xbar]=self.VehObj.readChassis();
                    vehicleVelFdbk=double([inertVel(1,:);bodyVel(1,:);bodyAngVel(1,:)]);
                    vehicleAccelFdbk=double([bodyAccel(1,:);bodyAngAcc(1,:)]);
                    xbar=double(xbar(1,:));
                    DCM=angle2dcm(rotation(3),rotation(2),rotation(1));
                    [EngSpd,TransGear]=self.VehObj.readDriveline();
                    drivelineFdbk=double([EngSpd;TransGear]);
                    [TireForce,WheelTorque,TireSlip]=self.VehObj.readTires();
                    tireFdbk=double([TireForce(1:3,1:4);WheelTorque(1,:);TireSlip(1:2,1:4)]);

                    self.VehObj.LightModule.setVehicleLightStatesArray(sim3d.vehicle.VehicleLightingModule.PassVehLightCategories,[LightStates;LightStates(1)||LightStates(2)]);

                    self.VehObj.write(single(steerCmd),single(acclCmd),single(decelCmd),single(gearCmd),boolean(hndbrkCmd));
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
            self.DiffType=s.DiffType;
            self.TransType=s.TransType;
            self.DrivetrainType=s.DrivetrainType;
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
            s.DiffType=self.DiffType;
            s.TransType=self.TransType;
            s.DrivetrainType=self.DrivetrainType;
        end

        function num=getNumOutputsImpl(~)
            num=7;
        end

        function[sz1,sz2,sz3,sz4,sz5,sz6,sz7]=getOutputSizeImpl(~)
            sz1=[2,3];
            sz2=[3,3];
            sz3=[2,3];
            sz4=[1,3];
            sz5=[3,3];
            sz6=[2,1];
            sz7=[6,4];
        end
        function[fz1,fz2,fz3,fz4,fz5,fz6,fz7]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
            fz3=true;
            fz4=true;
            fz5=true;
            fz6=true;
            fz7=true;
        end
        function[dt1,dt2,dt3,dt4,dt5,dt6,dt7]=getOutputDataTypeImpl(~)
            dt1='double';
            dt2='double';
            dt3='double';
            dt4='double';
            dt5='double';
            dt6='double';
            dt7='double';
        end
        function[cp1,cp2,cp3,cp4,cp5,cp6,cp7]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
            cp3=false;
            cp4=false;
            cp5=false;
            cp6=false;
            cp7=false;
        end
        function[pn1,pn2,pn3,pn4,pn5,pn6,pn7]=getOutputNamesImpl(~)

            pn1='DispFdbk';
            pn2='VelFdbk';
            pn3='AccelFdbk';
            pn4='xbar';
            pn5='DCM';
            pn6='drivelineFdbk';
            pn7='tireFdbk';
        end
        function icon=getIconImpl(~)
            icon={'Physical Vehicle'};
        end
        function setInitialVehiclePosition(self,Position,Rotation)
            if(self.CoordinateScheme=="SAE")
                Position(:,3)=-Position(:,3);
            else
                Rotation=(Rotation);
                Position(2)=-Position(2);
                Rotation(2)=-Rotation(2);
                Rotation(3)=-Rotation(3);
            end


            self.Translation(1,1)=single(Position(1));
            self.Translation(1,2)=single(Position(2));
            self.Translation(1,3)=single(Position(3));
            self.Rotation(1,1)=single(Rotation(1));
            self.Rotation(1,2)=single(Rotation(2));
            self.Rotation(1,3)=single(Rotation(3));
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




            self.ApplyCoordinateTransformToLightParams();
            LeftHighBeam=struct(...
            'LightType','Spotlight',...
            'Category',"HighBeams",...
            'LightName','LHB',...
            'LightColor',self.HeadlightColor,...
            'Intensity',self.HighBeamIntensity,...
            'SocketName','Lights_Headlight_Left',...
            'RelativeTransform',[self.LeftHeadlightOrientation,0,self.LeftHeadlightLocation],...
            'AttenuationRadius',self.AttenuationRadius,...
            'InnerConeAngle',self.HighBeamRadius,...
            'OuterConeAngle',self.HighBeamRadius+10,...
            'ReverseState',false);
            RightHighBeam=struct(...
            'LightType','Spotlight',...
            'Category',"HighBeams",...
            'LightName','RHB',...
            'LightColor',self.HeadlightColor,...
            'Intensity',self.HighBeamIntensity,...
            'SocketName','Lights_Headlight_Right',...
            'RelativeTransform',[self.RightHeadlightOrientation,0,self.RightHeadlightLocation],...
            'AttenuationRadius',self.AttenuationRadius,...
            'InnerConeAngle',self.HighBeamRadius,...
            'OuterConeAngle',self.HighBeamRadius+10,...
            'ReverseState',false);
            LeftLowBeam=struct(...
            'LightType','Spotlight',...
            'Category',"LowBeams",...
            'LightName','LLB',...
            'LightColor',self.HeadlightColor,...
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
            'LightColor',self.HeadlightColor,...
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
            'LightColor',self.HeadlightColor,...
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
        function dcm=angle2dcm(angles)
            cang=cos(angles);
            sang=sin(angles);
            r11=cang(:,2).*cang(:,1);
            r12=cang(:,2).*sang(:,1);
            r13=-sang(:,2);
            r21=sang(:,3).*sang(:,2).*cang(:,1)-cang(:,3).*sang(:,1);
            r22=sang(:,3).*sang(:,2).*sang(:,1)+cang(:,3).*cang(:,1);
            r23=sang(:,3).*cang(:,2);
            r31=cang(:,3).*sang(:,2).*cang(:,1)+sang(:,3).*sang(:,1);
            r32=cang(:,3).*sang(:,2).*sang(:,1)-sang(:,3).*cang(:,1);
            r33=cang(:,3).*cang(:,2);
            a=[r11,r21,r31,r12,r22,r32,r13,r23,r33];
            b=a.';
            dcm=reshape(b,3,3,[]);
        end
    end
end