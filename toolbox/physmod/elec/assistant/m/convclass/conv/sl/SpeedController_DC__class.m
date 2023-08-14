classdef SpeedController_DC__class<ConvClass&handle



    properties

        OldParam=struct(...
        'wb',[],...
        'ramp',[],...
        'Is',[],...
        'Kp',[],...
        'Ki',[],...
        'lim',[],...
        'fcw',[],...
        'sampling',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'driveType',[],...
        'nbQuadrantsRect',[],...
        'nbQuadrantsChop',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Speed Controller (DC)'
        NewPath='elec_conv_sl_SpeedController_DC_/SpeedController_DC_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SpeedController_DC__class()
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
