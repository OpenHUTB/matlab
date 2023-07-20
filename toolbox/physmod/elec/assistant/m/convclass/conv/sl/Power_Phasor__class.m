classdef Power_Phasor__class<ConvClass&handle



    properties

        OldParam=struct(...
        )


        OldDropdown=struct(...
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
        OldPath='powerlib_meascontrol/Measurements/Power (Phasor)'
        NewPath='elec_conv_sl_Power_Phasor_/Power_Phasor_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Power_Phasor__class()
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
