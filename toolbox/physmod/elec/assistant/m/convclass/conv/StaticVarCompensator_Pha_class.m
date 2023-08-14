classdef StaticVarCompensator_Pha_class<ConvClass&handle



    properties

        OldParam=struct(...
        'SystemNominal',[],...
        'Pbase',[],...
        'Qnom',[],...
        'Td',[],...
        'Vref',[],...
        'Xs',[],...
        'Kp_Ki',[],...
        'Bref',[]...
        )


        OldDropdown=struct(...
        'mode',[],...
        'Seq1_Only',[],...
        'ExternalVref',[]...
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
        OldPath='factslib/Power-Electronics Based FACTS/Static Var Compensator (Phasor Type)'
        NewPath='elec_conv_StaticVarCompensator_Pha/StaticVarCompensator_Pha'
    end
    methods
        function obj=objParamMappingDirect(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
