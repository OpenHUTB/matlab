classdef SynchronousMachinePuStan_class<ConvClass&handle


    properties

        OldParam=struct(...
        'NominalParameters',[],...
        'Reactances1',[],...
        'Reactances2',[],...
        'TimeConstants1',[],...
        'TimeConstants2',[],...
        'TimeConstants3',[],...
        'TimeConstants4',[],...
        'TimeConstants5',[],...
        'TimeConstants6',[],...
        'TimeConstants7',[],...
        'TimeConstants8',[],...
        'StatorResistance',[],...
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
        'ShowDetailedParameters',[],...
        'RotorType',[],...
        'Units',[],...
        'MeasurementBus',[],...
        'dAxisTimeConstants',[],...
        'qAxisTimeConstants',[],...
        'SetSaturation',[],...
        'IterativeModel',[],...
        'IterativeDiscreteModel',[],...
        'BusType',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'VRated',[],...
        'FRated',[],...
        'Ra',[],...
        'Xl',[],...
        'X0',[],...
        'Xd',[],...
        'Xq',[],...
        'Xdd',[],...
        'Xqd',[],...
        'Xddd',[],...
        'Xqdd',[],...
        'Td0d',[],...
        'Td0dd',[],...
        'Tdd',[],...
        'Tddd',[],...
        'Tq0d',[],...
        'Tq0dd',[],...
        'Tqd',[],...
        'Tqdd',[],...
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
        'd_option',[],...
        'q_option',[],...
        'saturation_option',[]...
        )


        BlockOption={...
        {'MechanicalLoad','Mechanical power Pm';'RotorType','Salient-pole'},'PmSalient';...
        {'MechanicalLoad','Mechanical power Pm';'RotorType','Round'},'PmRound';...
        {'MechanicalLoad','Speed w';'RotorType','Salient-pole'},'wSalient';...
        {'MechanicalLoad','Speed w';'RotorType','Round'},'wRound';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Salient-pole'},'RotationalPortSalient';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Round'},'RotationalPortRound';...
        };

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end


    properties(Constant)
        OldPath='powerlib/Machines/Synchronous Machine pu Standard'
        NewPath='elec_conv_SynchronousMachinePuStan/SynchronousMachinePuStan'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ra=obj.OldParam.StatorResistance;
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,1);
            obj.NewDirectParam.VRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,2);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,3);

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                obj.NewDirectParam.Xd=ConvClass.mapDirect(obj.OldParam.Reactances2,1);
                obj.NewDirectParam.Xdd=ConvClass.mapDirect(obj.OldParam.Reactances2,2);
                obj.NewDirectParam.Xddd=ConvClass.mapDirect(obj.OldParam.Reactances2,3);
                obj.NewDirectParam.Xq=ConvClass.mapDirect(obj.OldParam.Reactances2,4);
                obj.NewDirectParam.Xqdd=ConvClass.mapDirect(obj.OldParam.Reactances2,5);
                obj.NewDirectParam.Xl=ConvClass.mapDirect(obj.OldParam.Reactances2,6);
                obj.NewDirectParam.X0=ConvClass.mapDirect(obj.OldParam.Reactances2,6);
            case 'Round'
                obj.NewDirectParam.Xd=ConvClass.mapDirect(obj.OldParam.Reactances1,1);
                obj.NewDirectParam.Xdd=ConvClass.mapDirect(obj.OldParam.Reactances1,2);
                obj.NewDirectParam.Xddd=ConvClass.mapDirect(obj.OldParam.Reactances1,3);
                obj.NewDirectParam.Xq=ConvClass.mapDirect(obj.OldParam.Reactances1,4);
                obj.NewDirectParam.Xqd=ConvClass.mapDirect(obj.OldParam.Reactances1,5);
                obj.NewDirectParam.Xqdd=ConvClass.mapDirect(obj.OldParam.Reactances1,6);
                obj.NewDirectParam.Xl=ConvClass.mapDirect(obj.OldParam.Reactances1,7);
                obj.NewDirectParam.X0=ConvClass.mapDirect(obj.OldParam.Reactances1,7);
            otherwise

            end

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                if strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    obj.NewDirectParam.Td0d=ConvClass.mapDirect(obj.OldParam.TimeConstants1,1);
                    obj.NewDirectParam.Td0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants1,2);
                    obj.NewDirectParam.Tq0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants1,3);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    obj.NewDirectParam.Td0d=ConvClass.mapDirect(obj.OldParam.TimeConstants3,1);
                    obj.NewDirectParam.Td0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants3,2);
                    obj.NewDirectParam.Tqdd=ConvClass.mapDirect(obj.OldParam.TimeConstants3,3);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    obj.NewDirectParam.Tdd=ConvClass.mapDirect(obj.OldParam.TimeConstants5,1);
                    obj.NewDirectParam.Tddd=ConvClass.mapDirect(obj.OldParam.TimeConstants5,2);
                    obj.NewDirectParam.Tq0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants5,3);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    obj.NewDirectParam.Tdd=ConvClass.mapDirect(obj.OldParam.TimeConstants7,1);
                    obj.NewDirectParam.Tddd=ConvClass.mapDirect(obj.OldParam.TimeConstants7,2);
                    obj.NewDirectParam.Tqdd=ConvClass.mapDirect(obj.OldParam.TimeConstants7,3);
                end
            case 'Round'
                if strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    obj.NewDirectParam.Td0d=ConvClass.mapDirect(obj.OldParam.TimeConstants2,1);
                    obj.NewDirectParam.Td0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants2,2);
                    obj.NewDirectParam.Tq0d=ConvClass.mapDirect(obj.OldParam.TimeConstants2,3);
                    obj.NewDirectParam.Tq0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants2,4);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    obj.NewDirectParam.Td0d=ConvClass.mapDirect(obj.OldParam.TimeConstants4,1);
                    obj.NewDirectParam.Td0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants4,2);
                    obj.NewDirectParam.Tqd=ConvClass.mapDirect(obj.OldParam.TimeConstants4,3);
                    obj.NewDirectParam.Tqdd=ConvClass.mapDirect(obj.OldParam.TimeConstants4,4);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    obj.NewDirectParam.Tdd=ConvClass.mapDirect(obj.OldParam.TimeConstants6,1);
                    obj.NewDirectParam.Tddd=ConvClass.mapDirect(obj.OldParam.TimeConstants6,2);
                    obj.NewDirectParam.Tq0d=ConvClass.mapDirect(obj.OldParam.TimeConstants6,3);
                    obj.NewDirectParam.Tq0dd=ConvClass.mapDirect(obj.OldParam.TimeConstants6,4);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    obj.NewDirectParam.Tdd=ConvClass.mapDirect(obj.OldParam.TimeConstants8,1);
                    obj.NewDirectParam.Tddd=ConvClass.mapDirect(obj.OldParam.TimeConstants8,2);
                    obj.NewDirectParam.Tqd=ConvClass.mapDirect(obj.OldParam.TimeConstants8,3);
                    obj.NewDirectParam.Tqdd=ConvClass.mapDirect(obj.OldParam.TimeConstants8,4);
                end
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


        function obj=SynchronousMachinePuStan_class(MechanicalLoad,NominalParameters,Mechanical,...
            PolePairs,InitialConditions,Saturation,SetSaturation,...
            RotorType,dAxisTimeConstants,qAxisTimeConstants,...
            Reactances1,Reactances2,...
            TimeConstants1,TimeConstants2,TimeConstants3,TimeConstants4,...
            TimeConstants5,TimeConstants6,TimeConstants7,TimeConstants8)
            if nargin>0
                obj.OldDropdown.MechanicalLoad=MechanicalLoad;
                obj.OldParam.NominalParameters=NominalParameters;
                obj.OldParam.Mechanical=Mechanical;
                obj.OldParam.PolePairs=PolePairs;
                obj.OldParam.Saturation=Saturation;
                obj.OldParam.InitialConditions=InitialConditions;
                obj.OldDropdown.SetSaturation=SetSaturation;
                obj.OldDropdown.RotorType=RotorType;
                obj.OldDropdown.dAxisTimeConstants=dAxisTimeConstants;
                obj.OldDropdown.qAxisTimeConstants=qAxisTimeConstants;
                obj.OldParam.Reactances1=Reactances1;
                obj.OldParam.Reactances2=Reactances2;
                obj.OldParam.TimeConstants1=TimeConstants1;
                obj.OldParam.TimeConstants2=TimeConstants2;
                obj.OldParam.TimeConstants3=TimeConstants3;
                obj.OldParam.TimeConstants4=TimeConstants4;
                obj.OldParam.TimeConstants5=TimeConstants5;
                obj.OldParam.TimeConstants6=TimeConstants6;
                obj.OldParam.TimeConstants7=TimeConstants7;
                obj.OldParam.TimeConstants8=TimeConstants8;
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


            obj.NewDerivedParam.si2pu_i=1/Yb.i;
            obj.NewDerivedParam.pu2si_wm=Yb.wMechanical;

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

            s=ee.internal.machines.createEmptySynchronousStandard();


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
            obj.NewDerivedParam.fElectrical0=fElectrical0;
            obj.NewDerivedParam.wrm0=wrm0;
            obj.NewDerivedParam.thm0=thm0;

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

            switch obj.OldDropdown.RotorType
            case 'Salient-pole'
                s.num_q_dampers=1;
                s.Xd=obj.OldParam.Reactances2(1);
                s.Xdd=obj.OldParam.Reactances2(2);
                s.Xddd=obj.OldParam.Reactances2(3);
                s.Xq=obj.OldParam.Reactances2(4);
                s.Xqdd=obj.OldParam.Reactances2(5);
                s.Xl=obj.OldParam.Reactances2(6);

                if strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    s.d_option=1;
                    s.q_option=1;
                    s.Td0d=obj.OldParam.TimeConstants1(1);
                    s.Td0dd=obj.OldParam.TimeConstants1(2);
                    s.Tq0dd=obj.OldParam.TimeConstants1(3);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    s.d_option=1;
                    s.q_option=2;
                    s.Td0d=obj.OldParam.TimeConstants3(1);
                    s.Td0dd=obj.OldParam.TimeConstants3(2);
                    s.Tqdd=obj.OldParam.TimeConstants3(3);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    s.d_option=2;
                    s.q_option=1;
                    s.Tdd=obj.OldParam.TimeConstants5(1);
                    s.Tddd=obj.OldParam.TimeConstants5(2);
                    s.Tq0dd=obj.OldParam.TimeConstants5(3);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    s.d_option=2;
                    s.q_option=2;
                    s.Tdd=obj.OldParam.TimeConstants7(1);
                    s.Tddd=obj.OldParam.TimeConstants7(2);
                    s.Tqdd=obj.OldParam.TimeConstants7(3);
                end

                [f,DeltaLessThanZero]=ee.internal.machines.convertSynchronousStandard2Fundamental_Perfect(s,Yb.wElectrical);
                Rfd=f.Rfd;
                Ladu=f.Lad;
                Laqu=f.Laq;
                Ll=f.Ll;
                Lfd=f.Lfd;
                L1d=f.L1d;
                L1q=f.L1q;


                if strcmp(obj.OldDropdown.SetSaturation,'on')
                    if obj.OldParam.Saturation(1,1)==0
                        obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray(obj.OldParam.Saturation(1,:)/Ladu);
                        obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray(obj.OldParam.Saturation(2,:));
                    else
                        obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray([0,obj.OldParam.Saturation(1,:)/Ladu]);
                        obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray([0,obj.OldParam.Saturation(2,:)]);
                    end
                end


                pu_rc_efd0=Vf/(Ladu/Rfd);
                pu_rc_ifd0=pu_rc_efd0/Rfd;

                pu_psid0=-(Ladu+Ll)*pu_id0+Ladu*pu_rc_ifd0+Ladu*0;
                pu_psiq0=-(Laqu+Ll)*pu_iq0+Laqu*0;
                pu_psifd0=(Ladu+Lfd)*pu_rc_ifd0+Ladu*0-Ladu*pu_id0;
                pu_psi1d0=Ladu*pu_rc_ifd0+(Ladu+L1d)*0-Ladu*pu_id0;
                pu_psi1q0=(Laqu+L1q)*0-Laqu*pu_iq0;

            case 'Round'
                s.num_q_dampers=2;
                s.Xd=obj.OldParam.Reactances1(1);
                s.Xdd=obj.OldParam.Reactances1(2);
                s.Xddd=obj.OldParam.Reactances1(3);
                s.Xq=obj.OldParam.Reactances1(4);
                s.Xqd=obj.OldParam.Reactances1(5);
                s.Xqdd=obj.OldParam.Reactances1(6);
                s.Xl=obj.OldParam.Reactances1(7);

                if strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    s.d_option=1;
                    s.q_option=1;
                    s.Td0d=obj.OldParam.TimeConstants2(1);
                    s.Td0dd=obj.OldParam.TimeConstants2(2);
                    s.Tq0d=obj.OldParam.TimeConstants2(3);
                    s.Tq0dd=obj.OldParam.TimeConstants2(4);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Open-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    s.d_option=1;
                    s.q_option=2;
                    s.Td0d=obj.OldParam.TimeConstants4(1);
                    s.Td0dd=obj.OldParam.TimeConstants4(2);
                    s.Tqd=obj.OldParam.TimeConstants4(3);
                    s.Tqdd=obj.OldParam.TimeConstants4(4);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Open-circuit')
                    s.d_option=2;
                    s.q_option=1;
                    s.Tdd=obj.OldParam.TimeConstants6(1);
                    s.Tddd=obj.OldParam.TimeConstants6(2);
                    s.Tq0d=obj.OldParam.TimeConstants6(3);
                    s.Tq0dd=obj.OldParam.TimeConstants6(4);
                elseif strcmp(obj.OldDropdown.dAxisTimeConstants,'Short-circuit')&&...
                    strcmp(obj.OldDropdown.qAxisTimeConstants,'Short-circuit')
                    s.d_option=2;
                    s.q_option=2;
                    s.Tdd=obj.OldParam.TimeConstants8(1);
                    s.Tddd=obj.OldParam.TimeConstants8(2);
                    s.Tqd=obj.OldParam.TimeConstants8(3);
                    s.Tqdd=obj.OldParam.TimeConstants8(4);
                end

                [f,DeltaLessThanZero]=ee.internal.machines.convertSynchronousStandard2Fundamental_Perfect(s,Yb.wElectrical);
                Rfd=f.Rfd;
                Ladu=f.Lad;
                Laqu=f.Laq;
                Ll=f.Ll;
                Lfd=f.Lfd;
                L1d=f.L1d;
                L1q=f.L1q;
                L2q=f.L2q;


                if strcmp(obj.OldDropdown.SetSaturation,'on')
                    if obj.OldParam.Saturation(1,1)==0
                        obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray(obj.OldParam.Saturation(1,:)/Ladu);
                        obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray(obj.OldParam.Saturation(2,:));
                    else
                        obj.NewDerivedParam.saturation_ifd=obj.strictMonoArray([0,obj.OldParam.Saturation(1,:)/Ladu]);
                        obj.NewDerivedParam.saturation_Vag=obj.strictMonoArray([0,obj.OldParam.Saturation(2,:)]);
                    end
                end


                pu_rc_efd0=Vf/(Ladu/Rfd);
                pu_rc_ifd0=pu_rc_efd0/Rfd;

                pu_psid0=-(Ladu+Ll)*pu_id0+Ladu*pu_rc_ifd0+Ladu*0;
                pu_psiq0=-(Laqu+Ll)*pu_iq0+Laqu*0+Laqu*0;
                pu_psifd0=(Ladu+Lfd)*pu_rc_ifd0+Ladu*0-Ladu*pu_id0;
                pu_psi1d0=Ladu*pu_rc_ifd0+(Ladu+L1d)*0-Ladu*pu_id0;
                pu_psi1q0=(Laqu+L1q)*0+Laqu*0-Laqu*pu_iq0;
                pu_psi2q0=Laqu*0+(Laqu+L2q)*0-Laqu*pu_iq0;
                obj.NewDerivedParam.pu_psi2q0=pu_psi2q0;

            otherwise

            end

            obj.NewDerivedParam.pu_psid0=pu_psid0;
            obj.NewDerivedParam.pu_psiq0=pu_psiq0;
            obj.NewDerivedParam.pu_psifd0=pu_psifd0;
            obj.NewDerivedParam.pu_psi1d0=pu_psi1d0;
            obj.NewDerivedParam.pu_psi1q0=pu_psi1q0;


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if~strcmp(obj.OldDropdown.PresetModel,'No')
                logObj.addMessage(obj,'OptionNotSupported','Preset model','Preset model');
            end


            switch obj.OldDropdown.dAxisTimeConstants
            case 'Open-circuit'
                obj.NewDropdown.d_option='1';
            case 'Short-circuit'
                obj.NewDropdown.d_option='2';
            otherwise

            end

            switch obj.OldDropdown.qAxisTimeConstants
            case 'Open-circuit'
                obj.NewDropdown.q_option='1';
            case 'Short-circuit'
                obj.NewDropdown.q_option='2';
            otherwise

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

