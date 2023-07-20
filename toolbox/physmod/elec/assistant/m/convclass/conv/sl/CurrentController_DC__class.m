classdef CurrentController_DC__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Pb',[],...
        'Vb',[],...
        'Kp',[],...
        'Ki',[],...
        'fci',[],...
        'F',[],...
        'lim',[],...
        'sampling',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'driveType',[],...
        'detailLevel',[],...
        'numQuadChop',[],...
        'numQuadRect',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Current Controller (DC)'
        NewPath='elec_conv_sl_CurrentController_DC_/CurrentController_DC_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=CurrentController_DC__class()
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
