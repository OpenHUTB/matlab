classdef ClippedReLUCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.clippedrelu_layer_comp';


        compKind='clippedrelulayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ClippedReLUCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ClippedReLUCompBuilder.compKind;
        end


        function comp=convert(layer,~,comp)

            comp.setCeiling(layer.Ceiling);
        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Ceiling',layer.Ceiling);
        end
    end
end
