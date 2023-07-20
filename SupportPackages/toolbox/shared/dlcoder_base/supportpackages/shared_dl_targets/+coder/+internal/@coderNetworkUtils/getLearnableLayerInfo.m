function learnableInfo=getLearnableLayerInfo(networkInfo)


















    learnableInfo=struct();


    sortedLayers=networkInfo.SortedLayers;


    sortedInternalLayers=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(sortedLayers);

    numLayers=numel(sortedLayers);


    layerToCompMapInfo=dltargets.internal.LayerToCompMapInfo();
    layerToCompMap=layerToCompMapInfo.getLayersToCompMap();

    learnableCount=0;
    numFCConvertedToConv=0;

    for iLayer=1:numLayers
        externalLayer=sortedLayers(iLayer);


        isNotHandWrittenCustomLayer=false;
        if isa(externalLayer,'nnet.layer.Layer')

            isNotHandWrittenCustomLayer=~dltargets.internal.checkIfOutputLayer(externalLayer)&&...
            ~isKey(layerToCompMap,class(externalLayer));

        end


        isFCConvertedToConv=dltargets.internal.isFCConvertedToConv(externalLayer,networkInfo);
        if isFCConvertedToConv
            numFCConvertedToConv=numFCConvertedToConv+1;

            internalLayer=nnet.cnn.layer.Layer.getInternalLayers(externalLayer);
            weightDims=size(internalLayer{1}.Weights.Value);

            learnableInfo.fcConvertedToConvParams(numFCConvertedToConv,1:4)=weightDims(1:4);
        end


        isWordEmbeddingLayer=isa(externalLayer,'nnet.cnn.layer.WordEmbeddingLayer');

        internalLayer=sortedInternalLayers{iLayer};
        layerLearnables=internalLayer.LearnableParameters;
        if~isempty(layerLearnables)
            numLearnables=numel(layerLearnables);


            learnableInfo.isCustomLayer(learnableCount+1:learnableCount+numLearnables)=isNotHandWrittenCustomLayer;
            learnableInfo.isFCConvertedToConv(learnableCount+1:learnableCount+numLearnables)=isFCConvertedToConv;
            learnableInfo.isWordEmbedLayer(learnableCount+1:learnableCount+numLearnables)=isWordEmbeddingLayer;

            learnableCount=learnableCount+numLearnables;
        end
    end
end
