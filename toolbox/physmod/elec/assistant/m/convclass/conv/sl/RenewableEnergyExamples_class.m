classdef RenewableEnergyExamples_class<ConvClass&handle



    properties

        OldParam=struct(...
        )


        OldDropdown=struct(...
        'ShowInLibBrowser',[]...
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
        OldPath='re_lib/Renewable Energy Examples'
        NewPath='elec_conv_sl_RenewableEnergyExamples/RenewableEnergyExamples'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=RenewableEnergyExamples_class()
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
