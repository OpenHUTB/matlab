classdef(Sealed,Hidden)VariantBlockType





    enumeration
        INVALID,MODEL,VARIANT_SUBSYSTEM,MODEL_VARIANT,VARIANT_SOURCE,VARIANT_SINK,VARIANT_SIMULINK_FUNCTION,VARIANT_IRT_SUBSYSTEM
    end

    methods(Access=public)

        function isModel=isModel(obj)
            isModel=(obj==Simulink.variant.reducer.VariantBlockType.MODEL);
        end

        function isVSS=isVariantSubsystem(obj)
            isVSS=(obj==Simulink.variant.reducer.VariantBlockType.VARIANT_SUBSYSTEM);
        end

        function isMdlVar=isModelVariant(obj)
            isMdlVar=(obj==Simulink.variant.reducer.VariantBlockType.MODEL_VARIANT);
        end

        function isVarSrc=isVariantSource(obj)
            isVarSrc=(obj==Simulink.variant.reducer.VariantBlockType.VARIANT_SOURCE);
        end

        function isVarSnk=isVariantSink(obj)
            isVarSnk=(obj==Simulink.variant.reducer.VariantBlockType.VARIANT_SINK);
        end

        function isVarSLFcn=isVariantSimulinkFunction(obj)
            isVarSLFcn=(obj==Simulink.variant.reducer.VariantBlockType.VARIANT_SIMULINK_FUNCTION);
        end

        function isVarIRTSubsys=isVariantIRTSubsystem(obj)
            isVarIRTSubsys=(obj==Simulink.variant.reducer.VariantBlockType.VARIANT_IRT_SUBSYSTEM);
        end

    end

end
