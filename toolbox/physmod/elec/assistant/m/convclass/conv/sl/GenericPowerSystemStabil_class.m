classdef GenericPowerSystemStabil_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tsensor',[],...
        'K',[],...
        'Twashout',[],...
        'Tleadlag1',[],...
        'Tleadlag2',[],...
        'VSlimits',[],...
        'Vinit',[],...
        'FreqRange',[]...
        )


        OldDropdown=struct(...
        'Plot_On',[],...
        'MagdB_On',[]...
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
        OldPath='powerlib/Machines/Generic Power System Stabilizer'
        NewPath='elec_conv_sl_GenericPowerSystemStabil/GenericPowerSystemStabil'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=GenericPowerSystemStabil_class()
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
