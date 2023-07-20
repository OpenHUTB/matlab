classdef SynchronousMachineSIFund_class<ConvClass&handle



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
        'SetSaturation',[],...
        'DisplayVfd',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
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
        'J',[],...
        'D',[],...
        'nPolePairs',[],...
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
        'pu2si_i',[],...
        'pu2si_v',[],...
        'pu2si_Ifd',[],...
        'pu2si_wm',[],...
        'pu2si_Te',[],...
        'pu2si_Power',[],...
        'EfdRotorSide',[]...
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
        OldPath='powerlib/Machines/Synchronous Machine SI Fundamental'
        NewPath='elec_conv_SynchronousMachineSIFund/SynchronousMachineSIFund'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=SynchronousMachineSIFund_class(MechanicalLoad,NominalParameters,Stator,Mechanical,...
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

            Ra_SI=obj.OldParam.Stator(1);
            Ll_SI=obj.OldParam.Stator(2);
            Ladu_SI=obj.OldParam.Stator(3);
            Laqu_SI=obj.OldParam.Stator(4);
            Rfdp_SI=obj.OldParam.Field(1);
            Lfdp_SI=obj.OldParam.Field(2);

            switch obj.OldDropdown.MechanicalLoad
            case{'Mechanical power Pm','Mechanical rotational port'}
                obj.NewDerivedParam.J=obj.OldParam.Mechanical(1);
                obj.NewDerivedParam.D=obj.OldParam.Mechanical(2);
                nPolePairs=obj.OldParam.Mechanical(3);
                obj.NewDerivedParam.nPolePairs=nPolePairs;
            case 'Speed w'
                nPolePairs=obj.OldParam.PolePairs;
                obj.NewDerivedParam.nPolePairs=nPolePairs;
            otherwise

            end


            Yb=ee.internal.perunit.MachineBase(SRated,VRated,FRated,ee.enum.Connection.wye,nPolePairs);


            Ra=Ra_SI/Yb.R;
            Ll=Ll_SI/Yb.L;
            Ladu=Ladu_SI/Yb.L;
            Laqu=Laqu_SI/Yb.L;


            Rfd=Rfdp_SI/Yb.R;
            Lfd=Lfdp_SI/Yb.L;


            if size(obj.OldParam.NominalParameters,2)==4&&...
                obj.OldParam.NominalParameters(4)>0
                IfdNom=obj.OldParam.NominalParameters(4);
            else

                if SRated<=100e3
                    IfdNom=50;
                elseif(SRated>100e3)&&(SRated<=1e6)
                    IfdNom=100;
                elseif(SRated>1e6)&&(SRated<=100e6)
                    IfdNom=500;
                else
                    IfdNom=1000;
                end
            end


            base_fd_Ifd=IfdNom;

            base_rc_ifd=Ladu*IfdNom;
            base_rc_efd=Yb.SRated/base_rc_ifd;
            NsNf=(2/3)*base_rc_ifd/Yb.i;
            NfNs=1/NsNf;


            obj.NewDerivedParam.SRated=SRated;
            obj.NewDerivedParam.VRated=VRated;
            obj.NewDerivedParam.FRated=FRated;
            obj.NewDerivedParam.baseIfd=base_fd_Ifd;

            obj.NewDerivedParam.Ra=Ra;
            obj.NewDerivedParam.Ll=Ll;
            obj.NewDerivedParam.L0=Ll;
            obj.NewDerivedParam.Ladu=Ladu;
            obj.NewDerivedParam.Laqu=Laqu;
            obj.NewDerivedParam.Rfd=Rfd;
            obj.NewDerivedParam.Lfd=Lfd;

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                obj.NewDerivedParam.R1d=obj.OldParam.Dampers1(1)/Yb.R;
                L1d=obj.OldParam.Dampers1(2)/Yb.L;
                obj.NewDerivedParam.L1d=L1d;
                obj.NewDerivedParam.R1q=obj.OldParam.Dampers1(3)/Yb.R;
                L1q=obj.OldParam.Dampers1(4)/Yb.L;
                obj.NewDerivedParam.L1q=L1q;
            case 'Round'
                obj.NewDerivedParam.R1d=obj.OldParam.Dampers2(1)/Yb.R;
                L1d=obj.OldParam.Dampers2(2)/Yb.L;
                obj.NewDerivedParam.L1d=L1d;
                obj.NewDerivedParam.R1q=obj.OldParam.Dampers2(3)/Yb.R;
                L1q=obj.OldParam.Dampers2(4)/Yb.L;
                obj.NewDerivedParam.L1q=L1q;
                obj.NewDerivedParam.R2q=obj.OldParam.Dampers2(5)/Yb.R;
                L2q=obj.OldParam.Dampers2(6)/Yb.L;
                obj.NewDerivedParam.L2q=L2q;
            otherwise

            end


            if strcmp(obj.OldDropdown.SetSaturation,'on')
                if obj.OldParam.Saturation(1,1)==0
                    obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray(obj.OldParam.Saturation(1,:)/base_rc_ifd);
                    obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray(obj.OldParam.Saturation(2,:)/VRated);
                else
                    obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray([0,obj.OldParam.Saturation(1,:)/base_rc_ifd]);
                    obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray([0,obj.OldParam.Saturation(2,:)/VRated]);
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
            pu_ia0=ia*sin(pha*(pi/180))/Yb.i;
            pu_ib0=ib*sin(phb*(pi/180))/Yb.i;
            pu_ic0=ic*sin(phc*(pi/180))/Yb.i;
            pu_id0=abc2d*[pu_ia0;pu_ib0;pu_ic0];
            pu_iq0=abc2q*[pu_ia0;pu_ib0;pu_ic0];
            if size(obj.OldParam.NominalParameters,2)==4&&...
                obj.OldParam.NominalParameters(4)>0
                pu_rc_efd0=Vf/base_rc_efd;
            else
                pu_rc_efd0=Vf/Yb.v;
            end
            pu_rc_ifd0=pu_rc_efd0/Rfd;

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                pu_psid0=-(Ladu+Ll)*pu_id0+Ladu*pu_rc_ifd0+Ladu*0;
                pu_psiq0=-(Laqu+Ll)*pu_iq0+Laqu*0;
                pu_psifd0=(Ladu+Lfd)*pu_rc_ifd0+Ladu*0-Ladu*pu_id0;
                pu_psi1d0=Ladu*pu_rc_ifd0+(Ladu+L1d)*0-Ladu*pu_id0;
                pu_psi1q0=(Laqu+L1q)*0-Laqu*pu_iq0;
            case 'Round'
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


            obj.NewDerivedParam.pu2si_i=Yb.i;
            obj.NewDerivedParam.pu2si_v=Yb.v;
            obj.NewDerivedParam.pu2si_wm=Yb.wMechanical;
            obj.NewDerivedParam.pu2si_Te=Yb.torque;
            obj.NewDerivedParam.pu2si_Power=SRated;
            if size(obj.OldParam.NominalParameters,2)==4&&...
                obj.OldParam.NominalParameters(4)>0
                obj.NewDerivedParam.pu2si_Ifd=base_fd_Ifd;
                obj.NewDerivedParam.EfdRotorSide=1;
            else
                obj.NewDerivedParam.pu2si_Ifd=base_fd_Ifd*(2/3)*NfNs;
                obj.NewDerivedParam.EfdRotorSide=NfNs;
            end


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
