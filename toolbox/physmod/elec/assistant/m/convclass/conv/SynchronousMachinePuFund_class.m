classdef SynchronousMachinePuFund_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalParameters',[],...
        'Stator',[],...
        'Field',[],...
        'Dampers2',[],...
        'Dampers1',[],...
        'Mechanical',[],...
        'PolePairs',[],...
        'InitialConditions',[],...
        'Saturation',[],...
        'LoadFlowParameters',[],...
        'TsPowergui',[],...
        'TsBlock',[],...
        'Pref',[],...
        'Qref',[],...
        'Qmin',[],...
        'Qmax',[],...
        'PLF',[],...
        'QLF',[]...
        )


        OldDropdown=struct(...
        'PresetModel',[],...
        'MechanicalLoad',[],...
        'RotorType',[],...
        'Units',[],...
        'IterativeModel',[],...
        'IterativeDiscreteModel',[],...
        'BusType',[],...
        'ShowDetailedParameters',[],...
        'MeasurementBus',[],...
        'SetSaturation',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'VRated',[],...
        'FRated',[],...
        'Ra',[],...
        'Ll',[],...
        'L0',[],...
        'Ladu',[],...
        'Laqu',[],...
        'Rfd',[],...
        'Lfd',[],...
        'R1d',[],...
        'L1d',[],...
        'R1q',[],...
        'L1q',[],...
        'R2q',[],...
        'L2q',[],...
        'H',[],...
        'Dpu',[],...
        'nPolePairs',[]...
        )


        NewDerivedParam=struct(...
        'J',[],...
        'D',[],...
        'baseIfd',[],...
        'saturation_ifd',[],...
        'saturation_Vag',[],...
        'fElectrical0',[],...
        'wrm0',[],...
        'thm0',[],...
        'pu_psid0',[],...
        'pu_psiq0',[],...
        'pu_psifd0',[],...
        'pu_psi1d0',[],...
        'pu_psi1q0',[],...
        'pu_psi2q0',[],...
        'si2pu_i',[],...
        'pu2si_wm',[]...
        )


        NewDropdown=struct(...
        'saturation_option',[]...
        )


        BlockOption={...
        {'MechanicalLoad','Mechanical power Pm';'RotorType','Salient-pole'},'PmSalient';...
        {'MechanicalLoad','Mechanical power Pm';'RotorType','Round'},'PmRound';...
        {'MechanicalLoad','Speed w';'RotorType','Salient-pole'},'wSalient';...
        {'MechanicalLoad','Speed w';'RotorType','Round'},'wRound';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Salient-pole'},'RotationalPortSalient';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Round'},'RotationalPortRound';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Machines/Synchronous Machine pu Fundamental'
        NewPath='elec_conv_SynchronousMachinePuFund/SynchronousMachinePuFund'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,1);
            obj.NewDirectParam.VRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,2);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,3);

            obj.NewDirectParam.Ra=ConvClass.mapDirect(obj.OldParam.Stator,1);
            obj.NewDirectParam.Ll=ConvClass.mapDirect(obj.OldParam.Stator,2);
            obj.NewDirectParam.L0=ConvClass.mapDirect(obj.OldParam.Stator,2);
            obj.NewDirectParam.Ladu=ConvClass.mapDirect(obj.OldParam.Stator,3);
            obj.NewDirectParam.Laqu=ConvClass.mapDirect(obj.OldParam.Stator,4);
            obj.NewDirectParam.Rfd=ConvClass.mapDirect(obj.OldParam.Field,1);
            obj.NewDirectParam.Lfd=ConvClass.mapDirect(obj.OldParam.Field,2);

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                obj.NewDirectParam.R1d=ConvClass.mapDirect(obj.OldParam.Dampers1,1);
                obj.NewDirectParam.L1d=ConvClass.mapDirect(obj.OldParam.Dampers1,2);
                obj.NewDirectParam.R1q=ConvClass.mapDirect(obj.OldParam.Dampers1,3);
                obj.NewDirectParam.L1q=ConvClass.mapDirect(obj.OldParam.Dampers1,4);
            case 'Round'
                obj.NewDirectParam.R1d=ConvClass.mapDirect(obj.OldParam.Dampers2,1);
                obj.NewDirectParam.L1d=ConvClass.mapDirect(obj.OldParam.Dampers2,2);
                obj.NewDirectParam.R1q=ConvClass.mapDirect(obj.OldParam.Dampers2,3);
                obj.NewDirectParam.L1q=ConvClass.mapDirect(obj.OldParam.Dampers2,4);
                obj.NewDirectParam.R2q=ConvClass.mapDirect(obj.OldParam.Dampers2,5);
                obj.NewDirectParam.L2q=ConvClass.mapDirect(obj.OldParam.Dampers2,6);
            otherwise

            end

            switch obj.OldDropdown.MechanicalLoad
            case{'Mechanical power Pm','Mechanical rotational port'}
                obj.NewDirectParam.H=ConvClass.mapDirect(obj.OldParam.Mechanical,1);
                obj.NewDirectParam.Dpu=ConvClass.mapDirect(obj.OldParam.Mechanical,2);
                obj.NewDirectParam.nPolePairs=ConvClass.mapDirect(obj.OldParam.Mechanical,3);
            case 'Speed w'
                obj.NewDirectParam.nPolePairs=obj.OldParam.PolePairs;
            otherwise

            end
        end


        function obj=SynchronousMachinePuFund_class(MechanicalLoad,NominalParameters,Stator,Mechanical,...
            PolePairs,InitialConditions,Saturation,SetSaturation,...
            Dampers2,Dampers1,Field,RotorType)
            if nargin>0
                obj.OldDropdown.MechanicalLoad=MechanicalLoad;
                obj.OldParam.NominalParameters=NominalParameters;
                obj.OldParam.Stator=Stator;
                obj.OldParam.Mechanical=Mechanical;
                obj.OldParam.PolePairs=PolePairs;
                obj.OldParam.InitialConditions=InitialConditions;
                obj.OldParam.Saturation=Saturation;
                obj.OldDropdown.SetSaturation=SetSaturation;
                obj.OldParam.Dampers1=Dampers1;
                obj.OldParam.Dampers2=Dampers2;
                obj.OldParam.Field=Field;
                obj.OldDropdown.RotorType=RotorType;
            end
        end

        function obj=objParamMappingDerived(obj)

            SRated=obj.OldParam.NominalParameters(1);
            VRated=obj.OldParam.NominalParameters(2);
            FRated=obj.OldParam.NominalParameters(3);
            switch obj.OldDropdown.MechanicalLoad
            case{'Mechanical power Pm','Mechanical rotational port'}
                H=obj.OldParam.Mechanical(1);
                Dpu=obj.OldParam.Mechanical(2);
                nPolePairs=obj.OldParam.Mechanical(3);
            case 'Speed w'
                nPolePairs=obj.OldParam.PolePairs;
            otherwise

            end

            Yb=ee.internal.perunit.MachineBase(SRated,VRated,FRated,ee.enum.Connection.wye,nPolePairs);

            if strcmp(obj.OldDropdown.MechanicalLoad,'Mechanical rotational port')
                obj.NewDerivedParam.J=H*(2*Yb.torque)/(Yb.wMechanical);
                obj.NewDerivedParam.D=Dpu*(Yb.torque/Yb.wMechanical);
            end


            if SRated<=100e3
                obj.NewDerivedParam.baseIfd=50;
            elseif(SRated>100e3)&&(SRated<=1e6)
                obj.NewDerivedParam.baseIfd=100;
            elseif(SRated>1e6)&&(SRated<=100e6)
                obj.NewDerivedParam.baseIfd=500;
            else
                obj.NewDerivedParam.baseIfd=1000;
            end

            Ll=obj.OldParam.Stator(2);
            Ladu=obj.OldParam.Stator(3);
            Laqu=obj.OldParam.Stator(4);
            Rfd=obj.OldParam.Field(1);
            Lfd=obj.OldParam.Field(2);


            if strcmp(obj.OldDropdown.SetSaturation,'on')
                if obj.OldParam.Saturation(1,1)==0
                    obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray(obj.OldParam.Saturation(1,:)/Ladu);
                    obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray(obj.OldParam.Saturation(2,:));
                else
                    obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray([0,obj.OldParam.Saturation(1,:)/Ladu]);
                    obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray([0,obj.OldParam.Saturation(2,:)]);
                end
            end


            dw=obj.OldParam.InitialConditions(1);
            th=obj.OldParam.InitialConditions(2);
            ia=obj.OldParam.InitialConditions(3);
            ib=obj.OldParam.InitialConditions(4);
            ic=obj.OldParam.InitialConditions(5);
            pha=obj.OldParam.InitialConditions(6);
            phb=obj.OldParam.InitialConditions(7);
            phc=obj.OldParam.InitialConditions(8);
            Vf=obj.OldParam.InitialConditions(9);


            wr0=1+dw/100;
            fElectrical0=wr0*FRated;
            wrm0=wr0*(2*pi*FRated/nPolePairs);
            thm0=th/nPolePairs;

            InitialRotorElecAngle=th*(pi/180);
            shift_3ph=[0,-2*pi/3,2*pi/3];
            electrical_angle_vec_dq=-pi/2+shift_3ph+InitialRotorElecAngle;
            abc2d=(2/3)*cos(electrical_angle_vec_dq);
            abc2q=-(2/3)*sin(electrical_angle_vec_dq);
            pu_ia0=ia*sin(pha*(pi/180));
            pu_ib0=ib*sin(phb*(pi/180));
            pu_ic0=ic*sin(phc*(pi/180));
            pu_id0=abc2d*[pu_ia0;pu_ib0;pu_ic0];
            pu_iq0=abc2q*[pu_ia0;pu_ib0;pu_ic0];

            pu_rc_efd0=Vf/(Ladu/Rfd);
            pu_rc_ifd0=pu_rc_efd0/Rfd;

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                L1d=obj.OldParam.Dampers1(2);
                L1q=obj.OldParam.Dampers1(4);
                pu_psid0=-(Ladu+Ll)*pu_id0+Ladu*pu_rc_ifd0+Ladu*0;
                pu_psiq0=-(Laqu+Ll)*pu_iq0+Laqu*0;
                pu_psifd0=(Ladu+Lfd)*pu_rc_ifd0+Ladu*0-Ladu*pu_id0;
                pu_psi1d0=Ladu*pu_rc_ifd0+(Ladu+L1d)*0-Ladu*pu_id0;
                pu_psi1q0=(Laqu+L1q)*0-Laqu*pu_iq0;
            case 'Round'
                L1d=obj.OldParam.Dampers2(2);
                L1q=obj.OldParam.Dampers2(4);
                L2q=obj.OldParam.Dampers2(6);
                pu_psid0=-(Ladu+Ll)*pu_id0+Ladu*pu_rc_ifd0+Ladu*0;
                pu_psiq0=-(Laqu+Ll)*pu_iq0+Laqu*0+Laqu*0;
                pu_psifd0=(Ladu+Lfd)*pu_rc_ifd0+Ladu*0-Ladu*pu_id0;
                pu_psi1d0=Ladu*pu_rc_ifd0+(Ladu+L1d)*0-Ladu*pu_id0;
                pu_psi1q0=(Laqu+L1q)*0+Laqu*0-Laqu*pu_iq0;
                pu_psi2q0=Laqu*0+(Laqu+L2q)*0-Laqu*pu_iq0;
                obj.NewDerivedParam.pu_psi2q0=pu_psi2q0;
            otherwise

            end

            obj.NewDerivedParam.fElectrical0=fElectrical0;
            obj.NewDerivedParam.wrm0=wrm0;
            obj.NewDerivedParam.thm0=thm0;
            obj.NewDerivedParam.pu_psid0=pu_psid0;
            obj.NewDerivedParam.pu_psiq0=pu_psiq0;
            obj.NewDerivedParam.pu_psifd0=pu_psifd0;
            obj.NewDerivedParam.pu_psi1d0=pu_psi1d0;
            obj.NewDerivedParam.pu_psi1q0=pu_psi1q0;


            obj.NewDerivedParam.si2pu_i=1/Yb.i;
            obj.NewDerivedParam.pu2si_wm=Yb.wMechanical;


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if~strcmp(obj.OldDropdown.PresetModel,'No')
                logObj.addMessage(obj,'OptionNotSupported','Preset model','Preset model');
            end

            if size(obj.OldParam.Stator,2)==5&&...
                obj.OldParam.Stator(5)~=0
                logObj.addMessage(obj,'ParameterNotSupported','Canay inductance');
            end


            switch obj.OldDropdown.SetSaturation
            case 'off'
                obj.NewDropdown.saturation_option='0';
            case 'on'
                obj.NewDropdown.saturation_option='1';
            otherwise

            end
        end
    end

end
