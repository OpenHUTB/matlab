classdef PassThroughCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,~)
            customLayer=coder.internal.layer.PassThroughLayer(layerComp.getName());
        end

    end
end
