classdef RegulationSwitch_class<ConvClass&handle



    properties

        OldParam=struct(...
        'P',[],...
        'V',[],...
        'Ra',[],...
        'Laf',[],...
        'Von',[],...
        'Ron',[],...
        'lim',[],...
        'sampling',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'driveType',[],...
        'Swk',[],...
        'nbQuadrantsRect',[],...
        'nbQuadrantsChop',[],...
        'modeSelection',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Regulation Switch'
        NewPath='elec_conv_sl_RegulationSwitch/RegulationSwitch'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=RegulationSwitch_class()
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
