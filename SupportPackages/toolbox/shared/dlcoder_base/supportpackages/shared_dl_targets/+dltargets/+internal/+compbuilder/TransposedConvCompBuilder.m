classdef TransposedConvCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.transposedconv_layer_comp';


        compKind='transposedconvlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.TransposedConvCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.TransposedConvCompBuilder.compKind;
        end

        function validate(layer,validator)
            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

            if(strcmp(validator.getTargetLib(),'arm-compute')&&(str2double(validator.dlcfg.ArmComputeVersion)<18.11))
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_convolutiontype','TransposedConvolution2D',class(layer),'18.11');
                validator.handleError(layer,errorMessage);
            end


            supportedTargetLibs=["cudnn","tensorrt","mkldnn","onednn","arm-compute"];
            if(layer.CroppingSize(1)~=layer.CroppingSize(2))||(layer.CroppingSize(3)~=layer.CroppingSize(4))
                if~any(strcmp(validator.getTargetLib(),supportedTargetLibs))
                    errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_croppingsize',validator.getTargetLib());
                    validator.handleError(layer,errorMessage);
                end
            end


            internalLayer=layer.getInternalLayers(layer);
            outputSizeOffset=internalLayer{1}.OutputSizeOffset;

            unsupportedTargetsForoutputSizeOffset=["mkldnn","onednn","tensorrt"];
            if any(outputSizeOffset~=0)&&any(strcmpi(validator.getTargetLib(),unsupportedTargetsForoutputSizeOffset))
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_outputSizeOffset',validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end
        end

        function comp=convert(layer,converter,comp)


            internalLayer=layer.getInternalLayers(layer);
            outputSizeOffset=internalLayer{1}.OutputSizeOffset;

            comp.setFilterSizeH(layer.FilterSize(1));
            comp.setFilterSizeW(layer.FilterSize(2));
            comp.setNumChannels(layer.NumChannels(1));
            comp.setNumFilters(layer.NumFilters(1));
            comp.setStrideH(layer.Stride(1));
            comp.setStrideW(layer.Stride(2));
            comp.setPaddingH_Top(layer.CroppingSize(1));
            comp.setPaddingH_Bottom(layer.CroppingSize(2));
            comp.setPaddingW_Left(layer.CroppingSize(3));
            comp.setPaddingW_Right(layer.CroppingSize(4));
            comp.setOutputSizeOffset_H(outputSizeOffset(1));
            comp.setOutputSizeOffset_W(outputSizeOffset(2));

            fileNames=converter.getParameterFileNames(layer.Name);
            weightsFile=fileNames{1};
            biasFile=fileNames{2};

            comp.setWeightsFile(weightsFile);
            comp.setBiasFile(biasFile);
        end

        function saveFiles(layer,fileSaver)
            weightsFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.WeightsFileNamePostfix);
            weightsFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            weightsFile,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            biasFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.BiasFileNamePostfix);
            biasFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            biasFile,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            fileSaver.setParameterFileNamesMap(layer.Name,{weightsFile,biasFile});

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,weightsFile,...
            dltargets.internal.permuteHyperParameters(layer.Weights));

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,biasFile,layer.Bias);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'FilterSize',layer.FilterSize,...
            'NumChannels',layer.NumChannels,'NumFilters',layer.NumFilters,...
            'Stride',layer.Stride,'CroppingSize',layer.CroppingSize);
        end
    end
end
