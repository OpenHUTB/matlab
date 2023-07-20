classdef DLTCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            customLayer=dltargets.internal.getDLTLayerForPIRComp(layerComp,converter.Layers);
        end

        function validate(layer,validator)

            dltargets.internal.checkIfSupportedCustomLayer(layer,validator);
        end
    end
end
