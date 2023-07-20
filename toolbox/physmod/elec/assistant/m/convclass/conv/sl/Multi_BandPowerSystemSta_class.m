classdef Multi_BandPowerSystemSta_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Kg',[],...
        'GL',[],...
        'GI',[],...
        'GH',[],...
        'GLd',[],...
        'TcLF',[],...
        'GId',[],...
        'TcIF',[],...
        'GHd',[],...
        'TcHF',[],...
        'LIM',[],...
        'FreqRange',[]...
        )


        OldDropdown=struct(...
        'OperationMode',[],...
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
        OldPath='powerlib/Machines/Multi-Band Power System Stabilizer'
        NewPath='elec_conv_sl_Multi_BandPowerSystemSta/Multi_BandPowerSystemSta'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Multi_BandPowerSystemSta_class()
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
