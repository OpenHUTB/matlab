classdef ConvCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)





            fusedLayerIndices=layerComp.getFusedDLTLayerIndicesForMatlab();
            isConvBatchNorm=numel(fusedLayerIndices)==2;

            if isConvBatchNorm

                assert(isa(converter.Layers(fusedLayerIndices(2)),'nnet.cnn.layer.BatchNormalizationLayer'),...
                'Expected batch normalization layer');


                layer=converter.Layers(fusedLayerIndices(1));
                [weightsFused,biasFused]=coder.internal.layer.convUtils.readConvBatchNormFusionParamsFromFile(layer,...
                converter);
            else
                layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            end

            layerInfoConv=getLayerInfo(converter,layer.Name);
            codegenInputSize=[layerInfoConv.inputSizes{1},converter.getBatchSize()];

            buildContext=converter.BuildContext;

            if isa(layer,'nnet.cnn.layer.Convolution2DLayer')


                actualPaddingSize=dltargets.internal.utils.getPaddingSizeFromInputSize(layer,...
                codegenInputSize);

                if dltargets.internal.isQuantizedDLTLayer(converter.QuantizationSpecification,layer.Name)


                    assert(~isConvBatchNorm,'We only expect convolutions for quantization');

                    [inDataType,outDataType,quantizedLearnables]=...
                    coder.internal.ctarget.layerClassBuilder.utils.getQuantizedParameters(layer,...
                    converter.QuantizationSpecification,converter.FiMathObject);

                    customLayer=coder.internal.layer.quantized.Convolution2DLayer(layer.Name,...
                    quantizedLearnables('Weights'),quantizedLearnables('Bias'),layer.Stride,...
                    actualPaddingSize,layer.DilationFactor,layer.NumFilters,layer.FilterSize,...
                    buildContext,codegenInputSize,inDataType,outDataType);
                else
                    if isConvBatchNorm
                        customLayer=coder.internal.layer.Convolution2DBatchNorm(layer.Name,layer.Weights,...
                        layer.Bias,weightsFused,biasFused,layer.Stride,actualPaddingSize,layer.DilationFactor,...
                        layer.NumFilters,layer.FilterSize,codegenInputSize,buildContext);
                    else
                        customLayer=coder.internal.layer.Convolution2DLayer(layer.Name,layer.Weights,...
                        layer.Bias,layer.Stride,actualPaddingSize,layer.DilationFactor,layer.NumFilters,...
                        layer.FilterSize,codegenInputSize,buildContext);
                    end
                end
            else





                assert(isa(layer,'nnet.cnn.layer.FullyConnectedLayer'));

                internalLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
                weights=internalLayer{1}.Weights.Value;
                weightDims=size(weights);

                actualPaddingSize=[0,0,0,0];
                stride=[1,1];
                dilationFactor=[1,1];
                numFilters=weightDims(4);
                filterSize=weightDims(1:2);

                customLayer=coder.internal.layer.Convolution2DLayer(layer.Name,weights,...
                internalLayer{1}.Bias.Value,stride,actualPaddingSize,dilationFactor,numFilters,...
                filterSize,codegenInputSize,buildContext);

            end
        end

        function validate(layer,validator)


            if~isnumeric(layer.PaddingValue)||(layer.PaddingValue~=0)
                errorMessage=message('dlcoder_spkg:cnncodegen:PaddingValueNotSupported',layer.Name,class(layer));
                validator.handleError(layer,errorMessage);
            end

        end

    end
end
