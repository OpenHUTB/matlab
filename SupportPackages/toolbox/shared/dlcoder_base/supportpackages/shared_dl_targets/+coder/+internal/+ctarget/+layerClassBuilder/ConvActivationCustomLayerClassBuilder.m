classdef ConvActivationCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function externalCustomLayer=convert(layerComp,converter)





            fusedLayers=converter.Layers(layerComp.getFusedDLTLayerIndicesForMatlab);
            assert(numel(fusedLayers)==2||numel(fusedLayers)==3,...
            "Expected convolution to be fused with only one or two components.");




            activationLayer=fusedLayers(end);

            layerName=layerComp.getName;


            [activationFunctionType,activationParams]=...
            nnet.internal.cnn.util.getActivationFunctionTypeAndParams(activationLayer);

            buildContext=converter.BuildContext;

            if isa(fusedLayers(1),'nnet.cnn.layer.Convolution2DLayer')

                convolutionLayer=fusedLayers(1);
                isConvBatchNormActivation=numel(fusedLayers)==3;
                if isConvBatchNormActivation

                    assert(isa(fusedLayers(2),'nnet.cnn.layer.BatchNormalizationLayer'),...
                    'Expected second layer to be batch normalization');
                    [weightsFused,biasFused]=coder.internal.layer.convUtils.readConvBatchNormFusionParamsFromFile(convolutionLayer,...
                    converter);
                end

                layerInfoConv=getLayerInfo(converter,convolutionLayer.Name);
                codegenInputSize=[layerInfoConv.inputSizes{1},converter.getBatchSize()];


                actualPaddingSize=dltargets.internal.utils.getPaddingSizeFromInputSize(...
                convolutionLayer,codegenInputSize);

                if dltargets.internal.isQuantizedDLTLayer(converter.QuantizationSpecification,...
                    convolutionLayer.Name)

                    assert(~isConvBatchNormActivation,...
                    'Do not expected convolution+batchnorm+activation for quantization');

                    assert(~dltargets.internal.isQuantizedDLTLayer(...
                    converter.QuantizationSpecification,activationLayer.Name),...
                    "Quantizing activation layers is not supported.");

                    [inDataType,outDataType,quantizedLearnables]=...
                    coder.internal.ctarget.layerClassBuilder.utils.getQuantizedParameters(...
                    convolutionLayer,converter.QuantizationSpecification,...
                    converter.FiMathObject);

                    externalCustomLayer=coder.internal.layer.quantized.Convolution2DActivation(...
                    layerName,quantizedLearnables('Weights'),quantizedLearnables('Bias'),...
                    convolutionLayer.Stride,actualPaddingSize,...
                    convolutionLayer.DilationFactor,convolutionLayer.NumFilters,...
                    convolutionLayer.FilterSize,buildContext,activationParams,...
                    activationFunctionType,codegenInputSize,inDataType,outDataType);
                else
                    if isConvBatchNormActivation
                        externalCustomLayer=coder.internal.layer.Convolution2DBatchNormActivation(layerName,...
                        convolutionLayer.Weights,convolutionLayer.Bias,weightsFused,...
                        biasFused,convolutionLayer.Stride,actualPaddingSize,...
                        convolutionLayer.DilationFactor,convolutionLayer.NumFilters,...
                        convolutionLayer.FilterSize,codegenInputSize,buildContext,...
                        activationParams,activationFunctionType);
                    else
                        externalCustomLayer=coder.internal.layer.Convolution2DActivation(layerName,...
                        convolutionLayer.Weights,convolutionLayer.Bias,...
                        convolutionLayer.Stride,actualPaddingSize,...
                        convolutionLayer.DilationFactor,convolutionLayer.NumFilters,...
                        convolutionLayer.FilterSize,codegenInputSize,buildContext,...
                        activationParams,activationFunctionType);
                    end
                end
            else





                assert(isa(fusedLayers(1),'nnet.cnn.layer.FullyConnectedLayer'));

                fcLayer=fusedLayers(1);
                internalFCLayer=nnet.cnn.layer.Layer.getInternalLayers(fcLayer);
                weights=internalFCLayer{1}.Weights.Value;
                weightDims=size(weights);
                bias=internalFCLayer{1}.Bias.Value;

                actualPaddingSize=[0,0,0,0];
                stride=[1,1];
                dilationFactor=[1,1];
                numFilters=weightDims(4);
                filterSize=weightDims(1:2);

                layerInfoFC=getLayerInfo(converter,fcLayer.Name);
                codegenInputSize=layerInfoFC.inputSizes{1};

                externalCustomLayer=coder.internal.layer.Convolution2DActivation(layerName,weights,...
                bias,stride,actualPaddingSize,dilationFactor,numFilters,...
                filterSize,codegenInputSize,buildContext,activationParams,activationFunctionType);

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
