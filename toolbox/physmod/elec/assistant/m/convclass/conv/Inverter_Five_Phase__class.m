classdef Inverter_Five_Phase__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ts',[],...
        'SnubberResistance',[],...
        'SnubberCapacitance',[],...
        'Ron',[],...
        'ForwardVoltages',[],...
        'GTOparameters',[],...
        'IGBTParameters',[],...
        'SourceFrequency',[],...
        'Ls',[],...
        'Flux',[],...
        'Resistance',[],...
        'p',[]...
        )


        OldDropdown=struct(...
        'detailLevel',[],...
        'Device',[],...
        'Measurements',[],...
        'converterType',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='electricdrivelib/Fundamental Drive Blocks/Inverter (Five-Phase)'
        NewPath='elec_conv_Inverter_Five_Phase_/Inverter_Five_Phase_'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
