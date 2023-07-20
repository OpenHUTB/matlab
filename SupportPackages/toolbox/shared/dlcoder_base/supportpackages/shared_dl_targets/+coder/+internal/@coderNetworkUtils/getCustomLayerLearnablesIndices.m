function customLayerLearnableIdx=getCustomLayerLearnablesIndices(net)





















    sortedLayers=dltargets.internal.getSortedLayers(net);


    sortedInternalLayers=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(sortedLayers);

    numLayers=numel(sortedLayers);


    layerToCompMapInfo=dltargets.internal.LayerToCompMapInfo();
    layerToCompMap=layerToCompMapInfo.getLayersToCompMap();

    customLayerLearnableIdx=zeros();

    learnableCount=0;
    iCustomLayer=0;


    for iLayer=1:numLayers
        externalLayer=sortedLayers(iLayer);


        isNotHandWrittenCustomLayer=false;
        if isa(externalLayer,'nnet.layer.Layer')

            iCustomLayer=iCustomLayer+1;
            isNotHandWrittenCustomLayer=~dltargets.internal.checkIfOutputLayer(externalLayer)&&...
            ~isKey(layerToCompMap,class(externalLayer));

        end

        internalLayer=sortedInternalLayers{iLayer};
        layerLearnables=internalLayer.LearnableParameters;
        if~isempty(layerLearnables)
            numLearnables=numel(layerLearnables);
            if isNotHandWrittenCustomLayer
                customLayerLearnableIdx(learnableCount+1:learnableCount+numLearnables)=iCustomLayer;
            else
                customLayerLearnableIdx(learnableCount+1:learnableCount+numLearnables)=-1;
            end
            learnableCount=learnableCount+numLearnables;
        end
    end
end
