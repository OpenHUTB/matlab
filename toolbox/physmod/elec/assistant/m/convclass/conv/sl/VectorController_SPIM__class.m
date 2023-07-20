classdef VectorController_SPIM__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ts',[],...
        'h',[],...
        'T_bw',[],...
        'F_bw',[],...
        'freq_max',[],...
        'Tvect',[],...
        'Rs',[],...
        'Ra',[],...
        'Rr',[],...
        'Llr',[],...
        'Lms',[],...
        'k',[],...
        'p',[],...
        'in_flux',[]...
        )


        OldDropdown=struct(...
        'controllerType',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Vector Controller (SPIM)'
        NewPath='elec_conv_sl_VectorController_SPIM_/VectorController_SPIM_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=VectorController_SPIM__class()
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
