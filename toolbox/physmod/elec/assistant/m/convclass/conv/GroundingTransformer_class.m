classdef GroundingTransformer_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalPower',[],...
        'NominalVoltage',[],...
        'ZeroSequenceImpedance_pu',[],...
        'MagnetizationBranch_pu',[],...
        'ZeroSequenceImpedance_SI',[],...
        'MagnetizationBranch_SI',[]...
        )


        OldDropdown=struct(...
        'UNITS',[],...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'VRated',[],...
        'SRated',[],...
        'FRated',[],...
        'pu_Rw',[],...
        'pu_Xl',[],...
        'pu_Rm',[],...
        'pu_Xm',[],...
        'si_Rw',[],...
        'si_Ll',[],...
        'si_Rm',[],...
        'si_Lm',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'Unit',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Grounding Transformer '
        NewPath='elec_conv_GroundingTransformer/GroundingTransformer'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.VRated=obj.OldParam.NominalVoltage;
            obj.NewDirectParam.SRated=ConvClass.mapDirect(obj.OldParam.NominalPower,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalPower,2);

            switch obj.OldDropdown.UNITS
            case 'pu'
                obj.NewDirectParam.pu_Rw=ConvClass.mapDirect(obj.OldParam.ZeroSequenceImpedance_pu,1);
                obj.NewDirectParam.pu_Xl=ConvClass.mapDirect(obj.OldParam.ZeroSequenceImpedance_pu,2);
                obj.NewDirectParam.pu_Rm=ConvClass.mapDirect(obj.OldParam.MagnetizationBranch_pu,1);
                obj.NewDirectParam.pu_Xm=ConvClass.mapDirect(obj.OldParam.MagnetizationBranch_pu,2);
            case 'SI'
                obj.NewDirectParam.si_Rw=ConvClass.mapDirect(obj.OldParam.ZeroSequenceImpedance_SI,1);
                obj.NewDirectParam.si_Ll=ConvClass.mapDirect(obj.OldParam.ZeroSequenceImpedance_SI,2);
                obj.NewDirectParam.si_Rm=ConvClass.mapDirect(obj.OldParam.MagnetizationBranch_SI,1);
                obj.NewDirectParam.si_Lm=ConvClass.mapDirect(obj.OldParam.MagnetizationBranch_SI,2);
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Voltages');
            case 'Currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Currents');
            case 'All voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All voltages and currents');
            end

            switch obj.OldDropdown.UNITS
            case 'pu'
                obj.NewDropdown.Unit='1';
            case 'SI'
                obj.NewDropdown.Unit='2';
            end
        end
    end

end
