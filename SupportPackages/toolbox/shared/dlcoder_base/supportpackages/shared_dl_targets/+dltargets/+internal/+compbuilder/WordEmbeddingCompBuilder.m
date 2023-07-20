classdef WordEmbeddingCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.word_embedding_layer_comp';


        compKind='customlayer';


        cppClassName='MWWordEmbeddingLayer';


        createMethodName='createWordEmbeddingLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.WordEmbeddingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.WordEmbeddingCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.WordEmbeddingCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.WordEmbeddingCompBuilder.createMethodName;
        end

        function validate(layer,validator)
            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function comp=convert(layer,converter,comp)
            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.addCreateMethodArg(int32(layer.Dimension));
            comp.addCreateMethodArg(int32(layer.NumWords));

            fileNames=converter.getParameterFileNames(layer.Name);
            weightsFile=fileNames{1};

            comp.addCreateMethodArg(weightsFile);
            comp.addLearnable('Weights');
        end

        function saveFiles(layer,fileSaver)

            weightsFile=strcat(fileSaver.getFilePrefix,layer.Name,fileSaver.WeightsFileNamePostfix);
            weightsFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            weightsFile,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            fileSaver.setParameterFileNamesMap(layer.Name,{weightsFile});

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,weightsFile,layer.Weights);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Dimension',layer.Dimension,...
            'NumWords',layer.NumWords);
        end
    end
end
