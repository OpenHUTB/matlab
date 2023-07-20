classdef BridgeFiringUnit_DC__class<ConvClass&handle



    properties

        OldParam=struct(...
        'x4',[],...
        'x9',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'detailLevel',[],...
        'nbPhases',[],...
        'numQuad',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Bridge Firing Unit (DC)'
        NewPath='elec_conv_BridgeFiringUnit_DC_/BridgeFiringUnit_DC_'
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
