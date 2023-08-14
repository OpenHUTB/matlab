classdef SimplifiedSynchronousMac_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalParameters',[],...
        'Mechanical',[],...
        'InternalRL',[],...
        'InitialConditions',[],...
        'Units',[],...
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
        'ConnectionType',[],...
        'MechanicalLoad',[],...
        'BusType',[],...
        'MeasurementBus',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'VRated',[],...
        'FRated',[],...
        'J',[],...
        'Kd',[],...
        'nPolePairs',[],...
        'R_si',[],...
        'L_si',[]...
        )


        NewDerivedParam=struct(...
        'pu2si_v',[],...
        'pu2si_wm',[],...
        'si2pu_wm',[],...
        'pu2si_Power',[],...
        'pu2si_T',[],...
        'elec2mech',[],...
        'wrm0',[],...
        'thm0',[],...
        'pu_psid0',[],...
        'pu_psiq0',[],...
        'pu_psi00',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'MechanicalLoad','Mechanical power Pm';'ConnectionType','3-wire Y'},'Pm3Y';...
        {'MechanicalLoad','Mechanical power Pm';'ConnectionType','4-wire Y'},'Pm4Y';...
        {'MechanicalLoad','Speed w';'ConnectionType','3-wire Y'},'w3Y';...
        {'MechanicalLoad','Speed w';'ConnectionType','4-wire Y'},'w4Y';...
        {'MechanicalLoad','Mechanical rotational port';'ConnectionType','3-wire Y'},'RotationalPort3Y';...
        {'MechanicalLoad','Mechanical rotational port';'ConnectionType','4-wire Y'},'RotationalPort4Y';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Machines/Simplified Synchronous Machine SI Units'
        NewPath='elec_conv_SimplifiedSynchronousMac/SimplifiedSynchronousMac'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,1);
            obj.NewDirectParam.VRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,2);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalParameters,3);
            obj.NewDirectParam.J=ConvClass.mapDirect(obj.OldParam.Mechanical,1);
            obj.NewDirectParam.Kd=ConvClass.mapDirect(obj.OldParam.Mechanical,2);
            obj.NewDirectParam.nPolePairs=ConvClass.mapDirect(obj.OldParam.Mechanical,3);
            obj.NewDirectParam.R_si=ConvClass.mapDirect(obj.OldParam.InternalRL,1);
            obj.NewDirectParam.L_si=ConvClass.mapDirect(obj.OldParam.InternalRL,2);
        end


        function obj=SimplifiedSynchronousMac_class(NominalParameters,InitialConditions,Mechanical,InternalRL)
            if nargin>0
                obj.OldParam.NominalParameters=NominalParameters;
                obj.OldParam.InitialConditions=InitialConditions;
                obj.OldParam.Mechanical=Mechanical;
                obj.OldParam.InternalRL=InternalRL;
            end
        end

        function obj=objParamMappingDerived(obj)

            SRated=obj.OldParam.NominalParameters(1);
            VRated=obj.OldParam.NominalParameters(2);
            FRated=obj.OldParam.NominalParameters(3);
            nPolePairs=obj.OldParam.Mechanical(3);
            Yb=ee.internal.perunit.MachineBase(SRated,VRated,FRated,ee.enum.Connection.wye,nPolePairs);
            Lpu=obj.OldParam.InternalRL(2)/Yb.L;


            dw=obj.OldParam.InitialConditions(1);
            th=obj.OldParam.InitialConditions(2);
            ia=obj.OldParam.InitialConditions(3);
            ib=obj.OldParam.InitialConditions(4);
            ic=obj.OldParam.InitialConditions(5);
            pha=obj.OldParam.InitialConditions(6);
            phb=obj.OldParam.InitialConditions(7);
            phc=obj.OldParam.InitialConditions(8);


            wr0=1+dw/100;
            wrm0=wr0*Yb.wMechanical;
            thm0=th/nPolePairs;
            pu_ia0=ia*sin(pha*(pi/180))/Yb.i;
            pu_ib0=ib*sin(phb*(pi/180))/Yb.i;
            pu_ic0=ic*sin(phc*(pi/180))/Yb.i;
            electrical_angle_dqTran_vec0=th/180*pi+[0,-2*pi/3,2*pi/3]-pi/2;
            abc2d=(2/3)*sin(electrical_angle_dqTran_vec0);
            abc2q=(2/3)*cos(electrical_angle_dqTran_vec0);
            abc20=(2/3)*[0.5,0.5,0.5];

            pu_id0=abc2d*[pu_ia0,pu_ib0,pu_ic0]';
            pu_iq0=abc2q*[pu_ia0,pu_ib0,pu_ic0]';
            pu_i00=abc20*[pu_ia0,pu_ib0,pu_ic0]';

            pu_psid0=Lpu*pu_id0;
            pu_psiq0=Lpu*pu_iq0;
            pu_psi00=Lpu*pu_i00;


            obj.NewDerivedParam.pu_psid0=pu_psid0;
            obj.NewDerivedParam.pu_psiq0=pu_psiq0;
            obj.NewDerivedParam.pu_psi00=pu_psi00;
            obj.NewDerivedParam.wrm0=wrm0;
            obj.NewDerivedParam.thm0=thm0;


            obj.NewDerivedParam.pu2si_v=Yb.v;
            obj.NewDerivedParam.pu2si_wm=Yb.wMechanical;
            obj.NewDerivedParam.si2pu_wm=1/Yb.wMechanical;
            obj.NewDerivedParam.pu2si_Power=SRated;
            obj.NewDerivedParam.pu2si_T=Yb.torque;
            obj.NewDerivedParam.elec2mech=1/nPolePairs;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
        end
    end

end
