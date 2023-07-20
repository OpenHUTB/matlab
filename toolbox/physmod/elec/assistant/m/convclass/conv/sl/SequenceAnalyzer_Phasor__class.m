classdef SequenceAnalyzer_Phasor__class<ConvClass&handle



    properties

        OldParam=struct(...
        )


        OldDropdown=struct(...
        'seq',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Sequence Analyzer (Phasor)'
        NewPath='elec_conv_sl_SequenceAnalyzer_Phasor_/SequenceAnalyzer_Phasor_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SequenceAnalyzer_Phasor__class()
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
