classdef Three_PhaseOLTCPhaseShif_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalParameters',[],...
        'RXpu',[],...
        'RXm',[],...
        'NumberOfTaps',[],...
        'InitialTap',[],...
        'TapSelectionTime',[],...
        'Iout_init',[]...
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
        OldPath='factslib/Transformers/Three-Phase OLTC Phase Shifting Transformer Delta-Hexagonal (Phasor Type)'
        NewPath='elec_conv_Three_PhaseOLTCPhaseShif/Three_PhaseOLTCPhaseShif'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
