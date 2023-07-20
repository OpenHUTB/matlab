function learnablesOut=permuteLearnables(learnables,layerLearnablesIdx,learnableLayerInfo,customLayers,customLayerIndices)




















%#codegen



    coder.allowpcode('plain');

    coder.internal.prefer_const(layerLearnablesIdx,learnableLayerInfo,customLayers,customLayerIndices);

    learnableLayerNames=fieldnames(learnables);
    numLearnableLayers=numel(learnableLayerNames);

    learnablesOut=struct();

    isRowMajor=coder.isRowMajor;


    if coder.const(isRowMajor)


        formatChangeStr='RowmajorInterleavedToRowmajorPlanar';
        wordEmbedformatChangeStr='RowmajorInterleavedToColmajor';
    else


        formatChangeStr='ColmajorToRowmajorPlanar';
        wordEmbedformatChangeStr='';
    end

    learnableCount=0;
    numFCConvertedToConv=0;

    for iLearnableLayer=1:numLearnableLayers
        learnableLayerName=learnableLayerNames{iLearnableLayer};
        learnablesInLayerName=fieldnames(learnables.(learnableLayerName));
        numLearnablesInLayer=numel(learnablesInLayerName);
        for iLearnablesInLayer=1:numLearnablesInLayer
            learnableCount=learnableCount+1;
            layerLearnable=learnables.(learnableLayerName).(learnablesInLayerName{iLearnablesInLayer});
            if coder.const(learnableLayerInfo.isCustomLayer(learnableCount))
                layer=coder.const(customLayers{layerLearnablesIdx(learnableCount)==customLayerIndices});
                isRowmajorCustomLayer=layer.isRowMajor();
                if coder.const(isRowMajor&&~isRowmajorCustomLayer)


                    customLayerFormatChangeStr='RowmajorInterleavedToColmajor';
                elseif coder.const(~isRowMajor&&isRowmajorCustomLayer)


                    customLayerFormatChangeStr='ColmajorToRowmajorInterleaved';
                else

                    customLayerFormatChangeStr='';
                end
                learnablesOut.(learnableLayerName).(learnablesInLayerName{iLearnablesInLayer})=...
                dltargets.internal.permuteHyperParameters(layerLearnable,coder.const(customLayerFormatChangeStr));
            elseif coder.const(learnableLayerInfo.isWordEmbedLayer(learnableCount))
                learnablesOut.(learnableLayerName).(learnablesInLayerName{iLearnablesInLayer})=...
                dltargets.internal.permuteHyperParameters(layerLearnable,coder.const(wordEmbedformatChangeStr));
            else
                if coder.const(learnableLayerInfo.isFCConvertedToConv(learnableCount)&&...
                    strcmp(learnablesInLayerName{iLearnablesInLayer},'learnable1'))

                    numFCConvertedToConv=numFCConvertedToConv+1;





                    requiredSize=learnableLayerInfo.fcConvertedToConvParams(numFCConvertedToConv,:);
                    weights=reshape(layerLearnable',requiredSize);



                    learnablesOut.(learnableLayerName).(learnablesInLayerName{iLearnablesInLayer})=...
                    dltargets.internal.permuteHyperParameters(weights,coder.const(formatChangeStr));

                else
                    learnablesOut.(learnableLayerName).(learnablesInLayerName{iLearnablesInLayer})=...
                    dltargets.internal.permuteHyperParameters(layerLearnable,coder.const(formatChangeStr));
                end
            end

        end
    end

end