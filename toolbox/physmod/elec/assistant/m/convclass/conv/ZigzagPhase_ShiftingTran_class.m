classdef ZigzagPhase_ShiftingTran_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalPower',[],...
        'PrimaryVoltage',[],...
        'SecondaryVoltage',[],...
        'Winding1',[],...
        'Winding2',[],...
        'Winding3',[],...
        'RmLm',[],...
        'Rm',[],...
        'Saturation',[],...
        'InitialFluxes',[]...
        )


        OldDropdown=struct(...
        'SecondaryConnection',[],...
        'Measurements',[],...
        'UNITS',[],...
        'SetSaturation',[],...
        'SetInitialFlux',[],...
        'MoreParameters',[],...
        'BreakLoop',[],...
        'DataType',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'VRated1',[],...
        'VRated2',[],...
        'VRated3',[],...
        'FRated',[],...
        'phaseShift',[],...
        'phi_specify',[],...
        'phi_priority',[]...
        )


        NewDerivedParam=struct(...
        'pu_Rw1',[],...
        'pu_Xl1',[],...
        'pu_Rw2',[],...
        'pu_Xl2',[],...
        'pu_Rw3',[],...
        'pu_Xl3',[],...
        'pu_Rm',[],...
        'pu_Xm',[],...
        'current_data',[],...
        'magnetic_flux_data',[],...
        'phi',[]...
        )


        NewDropdown=struct(...
        'interconnection_option',[],...
        'deltaconnection_option',[],...
        'saturation_option',[]...
        )


        BlockOption={...
        {'SecondaryConnection','Y'},'Y';...
        {'SecondaryConnection','Yn'},'Yn';...
        {'SecondaryConnection','Yg'},'Yg';...
        {'SecondaryConnection','Delta D1(-30 deg.)'},'D';...
        {'SecondaryConnection','Delta D11(+30 deg.)'},'D';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Zigzag Phase-Shifting Transformer'
        NewPath='elec_conv_ZigzagPhase_ShiftingTran/ZigzagPhase_ShiftingTran'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalPower,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalPower,2);
            obj.NewDirectParam.VRated1=obj.OldParam.PrimaryVoltage;
            obj.NewDirectParam.VRated2=ConvClass.mapDirect(obj.OldParam.SecondaryVoltage,1);
            obj.NewDirectParam.VRated3=ConvClass.mapDirect(obj.OldParam.SecondaryVoltage,1);
            obj.NewDirectParam.phaseShift=ConvClass.mapDirect(obj.OldParam.SecondaryVoltage,2);

            if strcmp(obj.OldDropdown.SetSaturation,'on')
                obj.NewDirectParam.phi_specify='on';
                obj.NewDirectParam.phi_priority='high';
            end
        end


        function obj=ZigzagPhase_ShiftingTran_class(UNITS,NominalPower,PrimaryVoltage,SecondaryVoltage,...
            Winding1,Winding2,Winding3,RmLm,Rm,...
            Saturation,InitialFluxes,SetSaturation,SetInitialFlux)
            if nargin>0
                obj.OldDropdown.UNITS=UNITS;
                obj.OldParam.NominalPower=NominalPower;
                obj.OldParam.PrimaryVoltage=PrimaryVoltage;
                obj.OldParam.SecondaryVoltage=SecondaryVoltage;
                obj.OldParam.Winding1=Winding1;
                obj.OldParam.Winding2=Winding2;
                obj.OldParam.Winding3=Winding3;
                obj.OldParam.RmLm=RmLm;
                obj.OldParam.Rm=Rm;
                obj.OldDropdown.SetSaturation=SetSaturation;
                obj.OldDropdown.SetInitialFlux=SetInitialFlux;
                obj.OldParam.Saturation=Saturation;
                obj.OldParam.InitialFluxes=InitialFluxes;
            end
        end

        function obj=objParamMappingDerived(obj)

            SRated=obj.OldParam.NominalPower(1);
            FRated=obj.OldParam.NominalPower(2);
            VRated1=obj.OldParam.PrimaryVoltage;
            VRated2=obj.OldParam.SecondaryVoltage(1);
            phaseShift=abs(obj.OldParam.SecondaryVoltage(2));


            Vbase1=VRated1/sqrt(3);
            Ibase1=SRated/3/Vbase1;
            Phibase1=Vbase1/(2*pi*FRated);
            Zbase1=Vbase1/Ibase1;
            Lbase1=Zbase1/(2*pi*FRated);


            Vzigbase=Vbase1*sind(120-phaseShift)/sind(60);
            Vzagbase=Vbase1*sind(phaseShift)/sind(60);
            Izigbase=SRated/3/Vzigbase;
            Zzigbase=Vzigbase/Izigbase;
            Lzigbase=Zzigbase/(2*pi*FRated);
            Phizigbase=Vzigbase/(2*pi*FRated);






            Vbase2Y=VRated2/sqrt(3);
            Ibase2Y=SRated/3/Vbase2Y;
            Zbase2Y=Vbase2Y/Ibase2Y;
            Lbase2Y=Zbase2Y/(2*pi*FRated);


            Vbase2D=VRated2;
            Ibase2D=SRated/3/Vbase2D;
            Zbase2D=Vbase2D/Ibase2D;
            Lbase2D=Zbase2D/(2*pi*FRated);

            switch obj.OldDropdown.UNITS
            case 'pu'
                obj.NewDerivedParam.pu_Rw1=max(obj.OldParam.Winding1(1)*(Vzigbase/Vbase1)^2...
                +obj.OldParam.Winding2(1)*(Vzagbase/Vbase1)^2,1e-5);
                obj.NewDerivedParam.pu_Xl1=max(obj.OldParam.Winding1(2)*(Vzigbase/Vbase1)^2...
                +obj.OldParam.Winding2(2)*(Vzagbase/Vbase1)^2,1e-5);
                obj.NewDerivedParam.pu_Rw2=max(obj.OldParam.Winding3(1),1e-5);
                obj.NewDerivedParam.pu_Xl2=max(obj.OldParam.Winding3(2),1e-5);
                obj.NewDerivedParam.pu_Rw3=max(obj.OldParam.Winding3(1),1e-5);
                obj.NewDerivedParam.pu_Xl3=max(obj.OldParam.Winding3(2),1e-5);

                if strcmp(obj.OldDropdown.SetSaturation,'on')
                    obj.NewDerivedParam.pu_Rm=min(obj.OldParam.Rm*(Vzigbase/Vbase1)^2,1e9);
                    obj.NewDerivedParam.pu_Xm=min(obj.OldParam.RmLm(2)*(Vzigbase/Vbase1)^2,1e9);
                    obj.NewDerivedParam.current_data=obj.OldParam.Saturation(:,1)'*Izigbase/Ibase1;
                    obj.NewDerivedParam.magnetic_flux_data=obj.OldParam.Saturation(:,2)'*Phizigbase/Phibase1;
                    obj.NewDerivedParam.phi=-obj.OldParam.InitialFluxes*Phizigbase/Phibase1;
                else
                    obj.NewDerivedParam.pu_Rm=min(obj.OldParam.RmLm(1)*(Vzigbase/Vbase1)^2,1e9);
                    obj.NewDerivedParam.pu_Xm=min(obj.OldParam.RmLm(2)*(Vzigbase/Vbase1)^2,1e9);
                end

            case 'SI'
                obj.NewDerivedParam.pu_Rw1=max((obj.OldParam.Winding1(1)+obj.OldParam.Winding2(1))/Zbase1,1e-5);
                obj.NewDerivedParam.pu_Xl1=max((obj.OldParam.Winding1(2)+obj.OldParam.Winding2(2))/Lbase1,1e-5);
                obj.NewDerivedParam.pu_Rw2=max(obj.OldParam.Winding3(1)/Zbase2D,1e-5);
                obj.NewDerivedParam.pu_Xl2=max(obj.OldParam.Winding3(2)/Lbase2D,1e-5);
                obj.NewDerivedParam.pu_Rw3=max(obj.OldParam.Winding3(1)/Zbase2Y,1e-5);
                obj.NewDerivedParam.pu_Xl3=max(obj.OldParam.Winding3(2)/Lbase2Y,1e-5);

                if strcmp(obj.OldDropdown.SetSaturation,'on')
                    obj.NewDerivedParam.pu_Rm=min((obj.OldParam.Rm/Zzigbase)*(Vzigbase/Vbase1)^2,1e9);
                    obj.NewDerivedParam.pu_Xm=min((obj.OldParam.RmLm(2)/Lzigbase)*(Vzigbase/Vbase1)^2,1e9);
                    obj.NewDerivedParam.current_data=obj.OldParam.Saturation(:,1)'/(Ibase1*sqrt(2));
                    obj.NewDerivedParam.magnetic_flux_data=obj.OldParam.Saturation(:,2)'/(Phibase1*sqrt(2));
                    obj.NewDerivedParam.phi=-obj.OldParam.InitialFluxes/(Phibase1*sqrt(2));
                else
                    obj.NewDerivedParam.pu_Rm=min((obj.OldParam.RmLm(1)/Zzigbase)*(Vzigbase/Vbase1)^2,1e9);
                    obj.NewDerivedParam.pu_Xm=min((obj.OldParam.RmLm(2)/Lzigbase)*(Vzigbase/Vbase1)^2,1e9);
                end

            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'Phase voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Phase voltages');
            case 'Phase currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Phase currents');
            case 'Fluxes and excitation currents (Imag + IRm)'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Fluxes and excitation currents (Imag + IRm)');
            case 'Fluxes and magnetization currents (Imag)'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Fluxes and magnetization currents (Imag)');
            case 'All measurements (V I Fluxes)'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All measurements (V I Fluxes)');
            end

            if strcmp(obj.OldDropdown.SetSaturation,'on')
                obj.NewDropdown.saturation_option='2';
            else
                obj.NewDropdown.saturation_option='1';
            end


            obj.NewDropdown.interconnection_option='2';

            switch obj.OldDropdown.SecondaryConnection
            case 'Delta D1(-30 deg.)'
                obj.NewDropdown.deltaconnection_option='1';
            case 'Delta D11(+30 deg.)'
                obj.NewDropdown.deltaconnection_option='2';
            otherwise
                obj.NewDropdown.deltaconnection_option='1';
            end
        end
    end

end
