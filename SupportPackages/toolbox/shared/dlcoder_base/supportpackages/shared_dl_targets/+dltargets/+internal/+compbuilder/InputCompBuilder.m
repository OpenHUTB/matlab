classdef InputCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.input_layer_comp';


        compKind='inputlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.InputCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.InputCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)
            inputSizeToLayer=converter.NetworkInfo.InputLayerNameToInputSizeMap(layer.Name);

            comp.setHeight(inputSizeToLayer(1));
            comp.setWidth(inputSizeToLayer(2));
            comp.setChannels(inputSizeToLayer(3));
            comp.setBatchSize(inputSizeToLayer(4));
            comp.setNorm(layer.Normalization);
            inputNamesIdx=converter.NetworkInfo.InputLayerNameToInputNamesIdxMap(layer.Name);
            comp.setInputNamesIndex(int32(inputNamesIdx));
        end

        function validate(layer,validator)
            dltargets.internal.isValidInputNormalization(layer,validator);
            dltargets.internal.validateSplitComplexInputs(layer,validator);
        end

        function aStruct=toStruct(layer)


            aStruct=struct('Class',class(layer),'Name',layer.Name,'InputSize',layer.InputSize,...
            'Normalization',layer.Normalization,'NormalizationDimension',layer.NormalizationDimension);
            if isa(layer,'nnet.cnn.layer.ImageInputLayer')
                aStruct.DataAugmentation=layer.DataAugmentation;
            end
        end
    end
end
