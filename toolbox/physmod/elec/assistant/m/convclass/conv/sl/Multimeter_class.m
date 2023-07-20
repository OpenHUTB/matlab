classdef Multimeter_class<ConvClass&handle



    properties

        OldParam=struct(...
        'sel',[],...
        'L',[],...
        'Gain',[],...
        'yselected',[]...
        )


        OldDropdown=struct(...
        'OutputType',[],...
        'PlotAtSimulationStop',[],...
        'PhasorSimulation',[]...
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
        OldPath='powerlib/Measurements/Multimeter'
        NewPath='elec_conv_sl_Multimeter/Multimeter'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Multimeter_class_fixed()
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
