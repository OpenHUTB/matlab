classdef HydraulicTurbineAndGover_class<ConvClass&handle



    properties

        OldParam=struct(...
        'sm',[],...
        'gate',[],...
        'reg',[],...
        'hyd',[],...
        'dref',[],...
        'po',[]...
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
        OldPath='powerlib/Machines/Hydraulic Turbine and Governor'
        NewPath='elec_conv_sl_HydraulicTurbineAndGover/HydraulicTurbineAndGover'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=HydraulicTurbineAndGover_class()
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
