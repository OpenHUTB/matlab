classdef VectorController_WFSM__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ts',[],...
        'kpfl',[],...
        'kifl',[],...
        'flc_lpf',[],...
        'flc_sat',[],...
        'mag_hvt',[],...
        'mag_v',[],...
        'mag_tot',[],...
        'fnv',[],...
        'h',[],...
        'Tvect',[],...
        'Rs',[],...
        'p',[],...
        'daf',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Vector Controller (WFSM)'
        NewPath='elec_conv_sl_VectorController_WFSM_/VectorController_WFSM_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=VectorController_WFSM__class()
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
