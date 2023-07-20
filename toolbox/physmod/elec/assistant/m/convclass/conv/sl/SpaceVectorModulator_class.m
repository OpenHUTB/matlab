classdef SpaceVectorModulator_class<ConvClass&handle



    properties

        OldParam=struct(...
        'fc_bus',[],...
        'car_freq',[],...
        'TsMLIV',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'detailLevel',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Space Vector Modulator'
        NewPath='elec_conv_sl_SpaceVectorModulator/SpaceVectorModulator'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SpaceVectorModulator_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
