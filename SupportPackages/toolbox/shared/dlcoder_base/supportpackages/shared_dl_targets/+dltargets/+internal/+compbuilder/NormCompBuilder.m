classdef NormCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.norm_layer_comp';


        compKind='normlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.NormCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.NormCompBuilder.compKind;
        end

        function comp=convert(layer,~,comp)

            comp.setWindowSize(layer.WindowChannelSize);
            comp.setAlpha(layer.Alpha);
            comp.setBeta(layer.Beta);
            comp.setK(layer.K);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'WindowChannelSize',layer.WindowChannelSize,...
            'Alpha',layer.Alpha,'Beta',layer.Beta,'K',layer.K);
        end
        function validate(layer,validator)
            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);
        end
    end
end
