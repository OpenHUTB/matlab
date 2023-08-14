classdef BatchNormalizationCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.batch_norm_layer_comp';


        compKind='batchnormlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.BatchNormalizationCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.BatchNormalizationCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)

            comp.setEpsilon(layer.Epsilon);
            comp.setNumChannels(layer.NumChannels);

            fileNames=converter.getParameterFileNames(layer.Name);
            scaleFile=fileNames{1};
            offsetFile=fileNames{2};
            meanFile=fileNames{3};
            varianceFile=fileNames{4};

            comp.setScaleFile(scaleFile);
            comp.setOffsetFile(offsetFile);
            comp.setMeanFile(meanFile);
            comp.setVarianceFile(varianceFile);
        end

        function saveFiles(layer,fileSaver)

            scaleFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            strcat(fileSaver.getFilePrefix,layer.Name,'_scale.bin'),...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);
            offsetFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            strcat(fileSaver.getFilePrefix,layer.Name,'_offset.bin'),...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);
            meanFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            strcat(fileSaver.getFilePrefix,layer.Name,'_trainedMean.bin'),...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);
            varianceFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            strcat(fileSaver.getFilePrefix,layer.Name,'_trainedVariance.bin'),...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            fileSaver.setParameterFileNamesMap(layer.Name,{scaleFile,offsetFile,meanFile,varianceFile});

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,scaleFile,layer.Scale);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,offsetFile,layer.Offset);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,meanFile,layer.TrainedMean);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,varianceFile,layer.TrainedVariance);

        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Epsilon',layer.Epsilon,...
            'NumChannels',layer.NumChannels);
        end
    end
end
