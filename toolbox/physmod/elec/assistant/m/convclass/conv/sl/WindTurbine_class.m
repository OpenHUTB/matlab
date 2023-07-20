classdef WindTurbine_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Pnom',[],...
        'Pelec_base',[],...
        'wind_base',[],...
        'P_wind_base',[],...
        'speed_nom',[],...
        'pitch_angle',[],...
        'c1_c6',[],...
        'cp_nom',[],...
        'lambda_nom',[]...
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
        OldPath='re_lib/Wind Generation/Wind Turbine'
        NewPath='elec_conv_sl_WindTurbine/WindTurbine'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=WindTurbine_class()
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
