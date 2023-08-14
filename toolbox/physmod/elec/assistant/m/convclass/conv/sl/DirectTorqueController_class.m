classdef DirectTorqueController_class<ConvClass&handle



    properties

        OldParam=struct(...
        'T_bw',[],...
        'kp_Te',[],...
        'ki_Te',[],...
        'F_bw',[],...
        'kp_Flux',[],...
        'ki_Flux',[],...
        'Ts_DTFC',[],...
        'Ts',[],...
        'freq_max',[],...
        'car_freq',[],...
        'fc_bus',[],...
        'Rss',[],...
        'in_flux',[],...
        'p',[]...
        )


        OldDropdown=struct(...
        'modulationType',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Direct Torque Controller'
        NewPath='elec_conv_sl_DirectTorqueController/DirectTorqueController'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=DirectTorqueController_class()
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
