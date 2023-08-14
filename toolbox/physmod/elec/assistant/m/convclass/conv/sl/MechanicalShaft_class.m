classdef MechanicalShaft_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ksh',[],...
        'Bsh',[]...
        )


        OldDropdown=struct(...
        'PresetModel',[]...
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
        OldPath='electricdrivelib/Shafts and speed reducers/Mechanical Shaft'
        NewPath='elec_conv_sl_MechanicalShaft/MechanicalShaft'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=MechanicalShaft_class()
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
