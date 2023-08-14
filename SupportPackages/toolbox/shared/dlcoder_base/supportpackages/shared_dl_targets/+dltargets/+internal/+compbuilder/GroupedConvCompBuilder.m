classdef GroupedConvCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.conv_layer_comp';


        compKind='convlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.GroupedConvCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.GroupedConvCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)

            paddingSize=iGetPaddingSizeFromInputSize(layer,converter.NetworkInfo);

            comp.setFilterSizeH(layer.FilterSize(1));
            comp.setFilterSizeW(layer.FilterSize(2));
            comp.setNumChannels(layer.NumChannelsPerGroup(1));
            comp.setNumFilters(layer.NumFiltersPerGroup(1));
            comp.setStrideH(layer.Stride(1));
            comp.setStrideW(layer.Stride(2));
            comp.setPaddingH_Top(paddingSize(1));
            comp.setPaddingH_Bottom(paddingSize(2));
            comp.setPaddingW_Left(paddingSize(3));
            comp.setPaddingW_Right(paddingSize(4));
            comp.setDilationFactorH(layer.DilationFactor(1));
            comp.setDilationFactorW(layer.DilationFactor(2));


            comp.setNumGroups(layer.NumGroups);

            fileNames=converter.getParameterFileNames(layer.Name);
            weightsFile=fileNames{1};
            biasFile=fileNames{2};
            comp.setWeightsFile(weightsFile);
            comp.setBiasFile(biasFile);


            fusedDLTLayerIndices=converter.transformProperties.getConvBatchnormFusedDLTLayerIndices(layer);

            for idx=1:numel(fusedDLTLayerIndices)
                comp.addFusedDLTLayerIdx(int32(fusedDLTLayerIndices(idx)));
            end

        end

        function validate(layer,validator)


            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);



            if((strcmpi(validator.getTargetLib(),'arm-compute')||strcmpi(validator.getTargetLib(),'arm-compute-mali'))&&layer.NumGroups>2&&(layer.NumChannelsPerGroup(1)>1||layer.NumFiltersPerGroup(1)>1))
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_numGroups',validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end

            if strcmp(validator.getTargetLib(),'arm-compute-mali')&&(str2double(validator.dlcfg.ArmComputeVersion)==19.02)


                if((layer.DilationFactor(1)~=1)||(layer.DilationFactor(2)~=1))
                    errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_dilation_factor',class(layer),'arm-compute-mali','19.02');
                    validator.handleError(layer,errorMessage);
                end
            end

            if(strcmp(validator.getTargetLib(),'arm-compute-mali'))
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

            weights=layer.Weights;
            if(layer.NumGroups==2)
                [h,w,c,f,g]=size(weights);
                newW=reshape(weights,[h,w,c,f*g]);
                [h,w,c,f,g]=size(layer.Bias);
                newB=reshape(layer.Bias,[h,w,c,f*g]);

                dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,weightsFile,...
                dltargets.internal.permuteHyperParameters(newW));

                dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,biasFile,newB);
            else
                dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,weightsFile,...
                dltargets.internal.permuteHyperParameters(weights));

                dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,biasFile,layer.Bias);
            end
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'FilterSize',layer.FilterSize,...
            'NumFiltersPerGroup',layer.NumFiltersPerGroup,...
            'NumChannelsPerGroup',layer.NumChannelsPerGroup,'Stride',layer.Stride,...
            'PaddingSize',layer.PaddingSize,'NumGroups',layer.NumGroups,...
            'DilationFactor',layer.DilationFactor,'PaddingMode',layer.PaddingMode);
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
