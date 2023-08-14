classdef Chopper_class<ConvClass&handle



    properties

        OldParam=struct(...
        'SnubberResistance',[],...
        'SnubberCapacitance',[],...
        'Ron',[],...
        'ForwardVoltages',[],...
        'IGBTParameters',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'detailLevel',[],...
        'numQuad',[],...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Chopper'
        NewPath='elec_conv_Chopper/Chopper'
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
