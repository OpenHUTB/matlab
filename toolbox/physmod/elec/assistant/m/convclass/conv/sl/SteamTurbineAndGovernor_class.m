classdef SteamTurbineAndGovernor_class<ConvClass&handle



    properties

        OldParam=struct(...
        'reg1',[],...
        'reg2',[],...
        'reg3',[],...
        'N',[],...
        'turb1',[],...
        'turb2',[],...
        'HA',[],...
        'KA',[],...
        'DA',[],...
        'ini1',[],...
        'ini2',[]...
        )


        OldDropdown=struct(...
        'gentype',[]...
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
        OldPath='powerlib/Machines/Steam Turbine and Governor'
        NewPath='elec_conv_sl_SteamTurbineAndGovernor/SteamTurbineAndGovernor'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SteamTurbineAndGovernor_class()
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
