classdef AsynchronousMachinePuUni_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalParameters',[],...
        'VoltageRatio',[],...
        'Stator',[],...
        'Rotor',[],...
        'Cage1',[],...
        'Cage2',[],...
        'Lm',[],...
        'Mechanical',[],...
        'PolePairs',[],...
        'InitialConditions',[],...
        'Saturation',[],...
        'LoadFlowParameters',[],...
        'TsPowergui',[],...
        'TsBlock',[],...
        'Pmec',[]...
        )


        OldDropdown=struct(...
        'RotorType',[],...
        'PresetModel',[],...
        'MechanicalLoad',[],...
        'ReferenceFrame',[],...
        'Units',[],...
        'IterativeModel',[],...
        'IterativeDiscreteModel',[],...
        'ShowDetailedParameters',[],...
        'MeasurementBus',[],...
        'SimulateSaturation',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'VRated',[],...
        'FRated',[],...
        'H',[],...
        'Dpu',[],...
        'nPolePairs',[]...
        )


        NewDerivedParam=struct(...
        'pu_Rs',[],...
        'pu_Lls',[],...
        'pu_Rrd',[],...
        'pu_Llrd',[],...
        'pu_Rrd1',[],...
        'pu_Llrd1',[],...
        'pu_Rrd2',[],...
        'pu_Llrd2',[],...
        'pu_Lm',[],...
        'pu_L0',[],...
        'fElectrical0',[],...
        'J',[],...
        'D',[],...
        'wrm0',[],...
        'thm0',[],...
        'pu_psids0',[],...
        'pu_psiqs0',[],...
        'pu_psidr0',[],...
        'pu_psiqr0',[],...
        'pu_psidr10',[],...
        'pu_psiqr10',[],...
        'pu_psidr20',[],...
        'pu_psiqr20',[],...
        'si2pu_i',[],...
        'si2pu_v',[],...
        'pu2si_wm',[],...
        'pu2si_T',[],...
        'pu_saturation_i',[],...
        'pu_saturation_v',[],...
        'base_conv_i',[],...
        'base_conv_v',[]...
        )


        NewDropdown=struct(...
        'saturation_option',[]...
        )


        BlockOption={...
        {'MechanicalLoad','Torque Tm';'RotorType','Squirrel-cage';'ReferenceFrame','Synchronous'},'TmSCSyn';...
        {'MechanicalLoad','Torque Tm';'RotorType','Squirrel-cage';'ReferenceFrame','Stationary'},'TmSCStat';...
        {'MechanicalLoad','Torque Tm';'RotorType','Squirrel-cage';'ReferenceFrame','Rotor'},'TmSCRotor';...
        {'MechanicalLoad','Speed w';'RotorType','Squirrel-cage';'ReferenceFrame','Synchronous'},'wSCSyn';...
        {'MechanicalLoad','Speed w';'RotorType','Squirrel-cage';'ReferenceFrame','Stationary'},'wSCStat';...
        {'MechanicalLoad','Speed w';'RotorType','Squirrel-cage';'ReferenceFrame','Rotor'},'wSCRotor';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Squirrel-cage';'ReferenceFrame','Synchronous'},'RotPortSCSyn';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Squirrel-cage';'ReferenceFrame','Stationary'},'RotPortSCStat';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Squirrel-cage';'ReferenceFrame','Rotor'},'RotPortSCRotor';...
        {'MechanicalLoad','Torque Tm';'RotorType','Wound';'ReferenceFrame','Synchronous'},'TmWoundSyn';...
        {'MechanicalLoad','Torque Tm';'RotorType','Wound';'ReferenceFrame','Stationary'},'TmWoundStat';...
        {'MechanicalLoad','Torque Tm';'RotorType','Wound';'ReferenceFrame','Rotor'},'TmWoundRotor';...
        {'MechanicalLoad','Speed w';'RotorType','Wound';'ReferenceFrame','Synchronous'},'wWoundSyn';...
        {'MechanicalLoad','Speed w';'RotorType','Wound';'ReferenceFrame','Stationary'},'wWoundStat';...
        {'MechanicalLoad','Speed w';'RotorType','Wound';'ReferenceFrame','Rotor'},'wWoundRotor';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Wound';'ReferenceFrame','Synchronous'},'RotPortWoundSyn';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Wound';'ReferenceFrame','Stationary'},'RotPortWoundStat';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Wound';'ReferenceFrame','Rotor'},'RotPortWoundRotor';...
        {'MechanicalLoad','Torque Tm';'RotorType','Double squirrel-cage';'ReferenceFrame','Synchronous'},'TmDSCSyn';...
        {'MechanicalLoad','Torque Tm';'RotorType','Double squirrel-cage';'ReferenceFrame','Stationary'},'TmDSCStat';...
        {'MechanicalLoad','Torque Tm';'RotorType','Double squirrel-cage';'ReferenceFrame','Rotor'},'TmDSCRotor';...
        {'MechanicalLoad','Speed w';'RotorType','Double squirrel-cage';'ReferenceFrame','Synchronous'},'wDSCSyn';...
        {'MechanicalLoad','Speed w';'RotorType','Double squirrel-cage';'ReferenceFrame','Stationary'},'wDSCStat';...
        {'MechanicalLoad','Speed w';'RotorType','Double squirrel-cage';'ReferenceFrame','Rotor'},'wDSCRotor';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Double squirrel-cage';'ReferenceFrame','Synchronous'},'RotPortDSCSyn';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Double squirrel-cage';'ReferenceFrame','Stationary'},'RotPortDSCStat';...
        {'MechanicalLoad','Mechanical rotational port';'RotorType','Double squirrel-cage';'ReferenceFrame','Rotor'},'RotPortDSCRotor';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end


    properties(Constant)
        OldPath='powerlib/Machines/Asynchronous Machine pu Units'
        NewPath='elec_conv_AsynchronousMachinePuUni/AsynchronousMachinePuUni'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,1);
            obj.NewDirectParam.VRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,2);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,3);

            switch obj.OldDropdown.MechanicalLoad
            case{'Torque Tm','Mechanical rotational port'}
                obj.NewDirectParam.H=ConvClass.mapDirect(obj.OldParam.Mechanical,1);
                obj.NewDirectParam.Dpu=ConvClass.mapDirect(obj.OldParam.Mechanical,2);
                obj.NewDirectParam.nPolePairs=ConvClass.mapDirect(obj.OldParam.Mechanical,3);
            case 'Speed w'
                obj.NewDirectParam.nPolePairs=obj.OldParam.PolePairs;
            otherwise

            end
        end


        function obj=AsynchronousMachinePuUni_class(RotorType,MechanicalLoad,ReferenceFrame,SimulateSaturation,...
            NominalParameters,VoltageRatio,Stator,Rotor,Cage1,Cage2,Lm,...
            Mechanical,PolePairs,...
            InitialConditions,Saturation)
            if nargin>0
                obj.OldDropdown.RotorType=RotorType;
                obj.OldDropdown.MechanicalLoad=MechanicalLoad;
                obj.OldDropdown.ReferenceFrame=ReferenceFrame;
                obj.OldDropdown.SimulateSaturation=SimulateSaturation;
                obj.OldParam.NominalParameters=NominalParameters;
                obj.OldParam.VoltageRatio=VoltageRatio;
                obj.OldParam.Stator=Stator;
                obj.OldParam.Rotor=Rotor;
                obj.OldParam.Cage1=Cage1;
                obj.OldParam.Cage2=Cage2;
                obj.OldParam.Lm=Lm;
                obj.OldParam.Mechanical=Mechanical;
                obj.OldParam.PolePairs=PolePairs;
                obj.OldParam.InitialConditions=InitialConditions;
                obj.OldParam.Saturation=Saturation;
            end
        end

        function obj=objParamMappingDerived(obj)

            SRated=obj.OldParam.NominalParameters(1);
            VRated=obj.OldParam.NominalParameters(2);
            FRated=obj.OldParam.NominalParameters(3);
            switch obj.OldDropdown.MechanicalLoad
            case{'Torque Tm','Mechanical rotational port'}
                nPolePairs=obj.OldParam.Mechanical(3);
            case 'Speed w'
                nPolePairs=obj.OldParam.PolePairs;
            otherwise

            end


            Yb=ee.internal.perunit.MachineBase(SRated,VRated,FRated,ee.enum.Connection.wye,nPolePairs);

            Db=ee.internal.perunit.MachineBase(SRated,VRated,FRated,ee.enum.Connection.delta1,nPolePairs);

            if strcmp(obj.OldDropdown.MechanicalLoad,'Mechanical rotational port')
                H=obj.OldParam.Mechanical(1);
                Dpu=obj.OldParam.Mechanical(2);
                obj.NewDerivedParam.J=2*H*Db.torque/Db.wMechanical;
                obj.NewDerivedParam.D=Dpu*Db.torque/Db.wMechanical;
            end

            obj.NewDerivedParam.pu_Rs=obj.OldParam.Stator(1)/3;
            obj.NewDerivedParam.pu_Lls=obj.OldParam.Stator(2)/3;
            obj.NewDerivedParam.pu_Rrd=obj.OldParam.Rotor(1)/3;
            obj.NewDerivedParam.pu_Llrd=obj.OldParam.Rotor(2)/3;
            obj.NewDerivedParam.pu_Rrd1=obj.OldParam.Cage1(1)/3;
            obj.NewDerivedParam.pu_Llrd1=obj.OldParam.Cage1(2)/3;
            obj.NewDerivedParam.pu_Rrd2=obj.OldParam.Cage2(1)/3;
            obj.NewDerivedParam.pu_Llrd2=obj.OldParam.Cage2(2)/3;
            obj.NewDerivedParam.pu_Lm=obj.OldParam.Lm/3;
            obj.NewDerivedParam.pu_L0=obj.OldParam.Stator(2)/3;
            pu_Lls=obj.OldParam.Stator(2)/3;
            pu_Lm=obj.OldParam.Lm/3;
            pu_Lss=pu_Lls+pu_Lm;


            slip=obj.OldParam.InitialConditions(1);
            th=obj.OldParam.InitialConditions(2);
            pu_isa_Y=obj.OldParam.InitialConditions(3);
            pu_isb_Y=obj.OldParam.InitialConditions(4);
            pu_isc_Y=obj.OldParam.InitialConditions(5);
            phsa=obj.OldParam.InitialConditions(6);
            phsb=obj.OldParam.InitialConditions(7);
            phsc=obj.OldParam.InitialConditions(8);

            wr0=1-slip;
            fElectrical0=wr0*FRated;
            wrm0=wr0*Db.wMechanical;
            thm0=th/nPolePairs;
            obj.NewDerivedParam.fElectrical0=fElectrical0;
            obj.NewDerivedParam.wrm0=wrm0;
            obj.NewDerivedParam.thm0=thm0;

            InitialRotorElecAngle=th*(pi/180);
            shift_3ph=[0,-2*pi/3,2*pi/3];
            electrical_angle_vec_dq=shift_3ph+InitialRotorElecAngle;
            abc2d=(2/3)*cos(electrical_angle_vec_dq);
            abc2q=-(2/3)*sin(electrical_angle_vec_dq);
            pu_isa0=pu_isa_Y*sin(phsa*(pi/180))*sqrt(3);
            pu_isb0=pu_isb_Y*sin(phsb*(pi/180))*sqrt(3);
            pu_isc0=pu_isc_Y*sin(phsc*(pi/180))*sqrt(3);
            pu_ids0=abc2d*[pu_isa0;pu_isb0;pu_isc0];
            pu_iqs0=abc2q*[pu_isa0;pu_isb0;pu_isc0];

            switch obj.OldDropdown.RotorType
            case{'Squirrel-cage','Wound'}
                pu_Rrd=obj.OldParam.Rotor(1)/3;
                pu_Llrd=obj.OldParam.Rotor(2)/3;
                pu_Lrr=pu_Llrd+pu_Lm;

                if length(obj.OldParam.InitialConditions)==8
                    MatA=[pu_Lrr,pu_Rrd/slip;...
                    pu_Rrd/slip,-pu_Lrr];
                    MatB=[-pu_Lm*pu_ids0;...
                    pu_Lm*pu_iqs0];
                    pu_idqr=MatA\MatB;
                    pu_idr0=pu_idqr(1);
                    pu_iqr0=pu_idqr(2);
                else
                    pu_ira_Y=obj.OldParam.InitialConditions(9);
                    pu_irb_Y=obj.OldParam.InitialConditions(10);
                    pu_irc_Y=obj.OldParam.InitialConditions(11);
                    phra=obj.OldParam.InitialConditions(12);
                    phrb=obj.OldParam.InitialConditions(13);
                    phrc=obj.OldParam.InitialConditions(14);

                    pu_ira0=pu_ira_Y*sin(phra*(pi/180))*sqrt(3);
                    pu_irb0=pu_irb_Y*sin(phrb*(pi/180))*sqrt(3);
                    pu_irc0=pu_irc_Y*sin(phrc*(pi/180))*sqrt(3);
                    pu_iqr0=2/3*[0,sqrt(3)/2,-sqrt(3)/2]*[pu_ira0;pu_irb0;pu_irc0];
                    pu_idr0=2/3*[1,-0.5,-0.5]*[pu_ira0;pu_irb0;pu_irc0];
                end

                pu_psids0=pu_Lss*pu_ids0+pu_Lm*pu_idr0;
                pu_psiqs0=pu_Lss*pu_iqs0+pu_Lm*pu_iqr0;
                pu_psidr0=pu_Lrr*pu_idr0+pu_Lm*pu_ids0;
                pu_psiqr0=pu_Lrr*pu_iqr0+pu_Lm*pu_iqs0;
                obj.NewDerivedParam.pu_psids0=pu_psids0;
                obj.NewDerivedParam.pu_psiqs0=pu_psiqs0;
                obj.NewDerivedParam.pu_psidr0=pu_psidr0;
                obj.NewDerivedParam.pu_psiqr0=pu_psiqr0;

            case 'Double squirrel-cage'
                pu_Rrd1=obj.OldParam.Cage1(1)/3;
                pu_Rrd2=obj.OldParam.Cage2(1)/3;
                pu_Llrd1=obj.OldParam.Cage1(2)/3;
                pu_Llrd2=obj.OldParam.Cage2(2)/3;
                pu_Lrr1=pu_Llrd1+pu_Lm;
                pu_Lrr2=pu_Llrd2+pu_Lm;

                MatA=[pu_Lrr1,pu_Rrd1/slip,pu_Lm,0;...
                pu_Rrd1/slip,-pu_Lrr1,0,-pu_Lm;...
                pu_Lm,0,pu_Lrr2,pu_Rrd2/slip;...
                0,-pu_Lm,pu_Rrd2/slip,-pu_Lrr2];
                MatB=[-pu_Lm*pu_ids0;...
                pu_Lm*pu_iqs0;...
                -pu_Lm*pu_ids0;...
                pu_Lm*pu_iqs0;];

                pu_idqr1r2=MatA\MatB;
                pu_idr10=pu_idqr1r2(1);
                pu_iqr10=pu_idqr1r2(2);
                pu_idr20=pu_idqr1r2(3);
                pu_iqr20=pu_idqr1r2(4);

                pu_psids0=pu_Lss*pu_ids0+pu_Lm*(pu_idr10+pu_idr20);
                pu_psiqs0=pu_Lss*pu_iqs0+pu_Lm*(pu_iqr10+pu_iqr20);
                pu_psidr10=pu_Lrr1*pu_idr10+pu_Lm*(pu_ids0+pu_idr20);
                pu_psiqr10=pu_Lrr1*pu_iqr10+pu_Lm*(pu_iqs0+pu_iqr20);
                pu_psidr20=pu_Lrr2*pu_idr20+pu_Lm*(pu_ids0+pu_idr10);
                pu_psiqr20=pu_Lrr2*pu_iqr20+pu_Lm*(pu_iqs0+pu_iqr10);
                obj.NewDerivedParam.pu_psids0=pu_psids0;
                obj.NewDerivedParam.pu_psiqs0=pu_psiqs0;
                obj.NewDerivedParam.pu_psidr10=pu_psidr10;
                obj.NewDerivedParam.pu_psiqr10=pu_psiqr10;
                obj.NewDerivedParam.pu_psidr20=pu_psidr20;
                obj.NewDerivedParam.pu_psiqr20=pu_psiqr20;

            otherwise

            end

            obj.NewDerivedParam.si2pu_i=1/Yb.i;
            obj.NewDerivedParam.si2pu_v=1/Yb.v;
            obj.NewDerivedParam.pu2si_wm=Db.wMechanical;
            obj.NewDerivedParam.pu2si_T=Db.torque;
            obj.NewDerivedParam.base_conv_i=1/sqrt(3);
            obj.NewDerivedParam.base_conv_v=sqrt(3);

            if strcmp(obj.OldDropdown.SimulateSaturation,'on')
                if obj.OldParam.Saturation(1,:)==0
                    obj.NewDerivedParam.pu_saturation_i=obj.strictMonoArray(obj.OldParam.Saturation(1,:)*3);
                    obj.NewDerivedParam.pu_saturation_v=obj.strictMonoArray(obj.OldParam.Saturation(2,:)/sqrt(3));
                else
                    obj.NewDerivedParam.pu_saturation_i=obj.strictMonoArray([0,obj.OldParam.Saturation(1,:)*3]);
                    obj.NewDerivedParam.pu_saturation_v=obj.strictMonoArray([0,obj.OldParam.Saturation(2,:)/sqrt(3)]);
                end
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if(~strcmp(obj.OldDropdown.PresetModel,'No'))&&strcmp(obj.OldDropdown.RotorType,'Squirrel-cage')
                logObj.addMessage(obj,'OptionNotSupported','Preset Model','Preset Models');
            end


            switch obj.OldDropdown.SimulateSaturation
            case 'off'
                obj.NewDropdown.saturation_option='0';
            case 'on'
                obj.NewDropdown.saturation_option='1';
            otherwise

            end

            if ischar(obj.OldParam.VoltageRatio)
                VoltageRatioValue=evalin('base',obj.OldParam.VoltageRatio);
            else
                VoltageRatioValue=obj.OldParam.VoltageRatio;
            end

            if VoltageRatioValue~=1
                logObj.addMessage(obj,'CustomMessageNoImport','Only Vrotor/Vstator voltage ratio = 1 is supported');











            end

        end
    end

end
