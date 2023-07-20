classdef SpeedReducer_class<ConvClass&handle



    properties

        OldParam=struct(...
        'i',[],...
        'Jrdh',[],...
        'eff',[],...
        'Ksh',[],...
        'Bsh',[],...
        'Ksl',[],...
        'Bsl',[]...
        )


        OldDropdown=struct(...
        'PresetModel',[]...
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
        OldPath='electricdrivelib/Shafts and speed reducers/Speed Reducer'
        NewPath='elec_conv_sl_SpeedReducer/SpeedReducer'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SpeedReducer_class()
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
