classdef ConvCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.conv_layer_comp';


        compKind='convlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ConvCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ConvCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)

            if isa(layer,'nnet.cnn.layer.Convolution2DLayer')

                paddingSize=iGetPaddingSizeFromInputSize(layer,converter.NetworkInfo);

                comp.setFilterSizeH(layer.FilterSize(1));
                comp.setFilterSizeW(layer.FilterSize(2));
                comp.setNumChannels(layer.NumChannels(1));
                comp.setNumFilters(layer.NumFilters(1));
                comp.setStrideH(layer.Stride(1));
                comp.setStrideW(layer.Stride(2));
                comp.setPaddingH_Top(paddingSize(1));
                comp.setPaddingH_Bottom(paddingSize(2));
                comp.setPaddingW_Left(paddingSize(3));
                comp.setPaddingW_Right(paddingSize(4));
                comp.setDilationFactorH(layer.DilationFactor(1));
                comp.setDilationFactorW(layer.DilationFactor(2));
                comp.setNumGroups(size(layer.NumFilters,2));


                fusedDLTLayerIndices=converter.transformProperties.getConvBatchnormFusedDLTLayerIndices(layer);
                for idx=1:numel(fusedDLTLayerIndices)
                    comp.addFusedDLTLayerIdx(int32(fusedDLTLayerIndices(idx)));
                end

            else



                assert(isa(layer,'nnet.cnn.layer.FullyConnectedLayer'));

                internalLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
                weightDims=size(internalLayer{1}.Weights.Value);
                comp.setFilterSizeH(weightDims(1));
                comp.setFilterSizeW(weightDims(2));
                comp.setNumChannels(weightDims(3));
                comp.setNumFilters(weightDims(4));
                comp.setStrideH(1);
                comp.setStrideW(1);
                comp.setPaddingH_Top(0);
                comp.setPaddingH_Bottom(0);
                comp.setPaddingW_Left(0);
                comp.setPaddingW_Right(0);
                comp.setNumGroups(1);
            end

            fileNames=converter.getParameterFileNames(layer.Name);
            weightsFile=fileNames{1};
            biasFile=fileNames{2};

            comp.setWeightsFile(weightsFile);
            comp.setBiasFile(biasFile);
        end

        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

            if(strcmpi(validator.getTargetLib(),'arm-compute-mali'))
                if((layer.PaddingSize(1)~=layer.PaddingSize(3))||(layer.PaddingSize(2)~=layer.PaddingSize(4)))
                    errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_paddingsize','arm-compute-mali',layer.Name);
                    validator.handleError(layer,errorMessage);
                end
            end


            if~isnumeric(layer.PaddingValue)||(layer.PaddingValue~=0)
                errorMessage=message('dlcoder_spkg:cnncodegen:PaddingValueNotSupported',layer.Name,class(layer));
                validator.handleError(layer,errorMessage);
            end

        end

        function saveFiles(layer,fileSaver)

            weightsFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.WeightsFileNamePostfix);
            weightsFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            weightsFile,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            biasFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.BiasFileNamePostfix);
            biasFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            biasFile,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            fileSaver.setParameterFileNamesMap(layer.Name,{weightsFile,biasFile});

            internalLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);

            saveQuantizedLearnables=...
            dltargets.internal.isQuantizedDLTLayer(...
            fileSaver.NetworkInfo.LayerExecutionSpecification,layer.Name);

            if isa(layer,'nnet.cnn.layer.Convolution2DLayer')
                weights=layer.Weights;
                weights=dltargets.internal.permuteHyperParameters(weights);

            else
                assert(isa(layer,'nnet.cnn.layer.FullyConnectedLayer'));





                weightDims=size(internalLayer{1}.Weights.Value);

                weights=dltargets.internal.compbuilder.ConvCompBuilder.permuteFCLayerWeights(...
                weightDims(1),weightDims(2),layer.Weights);
            end

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,...
            fileSaver.Precision,weightsFile,weights);


            bias=layer.Bias;
            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,...
            fileSaver.Precision,biasFile,bias);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'FilterSize',layer.FilterSize,...
            'NumChannels',layer.NumChannels,'NumFilters',layer.NumFilters,...
            'Stride',layer.Stride,'PaddingSize',layer.PaddingSize,...
            'DilationFactor',layer.DilationFactor,'PaddingValue',layer.PaddingValue);
        end
    end

    methods(Static,Access=private)
        function weights=permuteFCLayerWeights(filterH,filterW,weights)



            weights=weights';
            numWeights=numel(weights);


            weights=reshape(weights,filterH,filterW,numWeights/filterH/filterW);
            weights=permute(weights,[2,1,3]);

        end
    end
end


function paddingSize=iGetPaddingSizeFromInputSize(layer,networkInfo)

    ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
    ilayer=ilayer{1};

    layerInfo=networkInfo.getLayerInfo(layer.Name);
    actualInputSize=layerInfo.inputSizes;

    actualInputSize=actualInputSize{1};

    actualInputSize=actualInputSize(1:2);
    paddingSize=iCalculatePaddingSizeFromInputSize(...
    ilayer.PaddingMode,ilayer.PaddingSize,...
    ilayer.EffectiveFilterSize,ilayer.Stride,actualInputSize);
end


function paddingSize=iCalculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize)
    paddingSize=deep.internal.sdk.padding.calculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize);
end
