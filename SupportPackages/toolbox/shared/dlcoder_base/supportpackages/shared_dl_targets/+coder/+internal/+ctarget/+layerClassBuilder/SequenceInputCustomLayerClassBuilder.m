classdef SequenceInputCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.InputCustomLayerClassBuilder




    methods(Static,Access=public)
        function validate(layer,validator)
            coder.internal.ctarget.layerClassBuilder.InputCustomLayerClassBuilder.validate(...
            layer,validator);
            dltargets.internal.isValidSequenceInputDimensions(layer,validator);
            dltargets.internal.validateSplitComplexInputs(layer,validator);
        end
    end
end
