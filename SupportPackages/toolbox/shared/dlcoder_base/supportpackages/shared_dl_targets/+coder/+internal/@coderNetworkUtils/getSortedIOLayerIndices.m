










function[sortedInputLayerIndices,sortedOutputLayerIndices,sortedNetworkInputSizes]=getSortedIOLayerIndices(net,inputLayers,outputLayers)





    sortedLayers=dltargets.internal.getSortedLayers(net);


    layerToSortedIdxMap=containers.Map;
    for i=1:numel(sortedLayers)
        layer=sortedLayers(i);
        layerToSortedIdxMap(layer.Name)=i;

    end


    sortedInputLayerIndices=cellfun(@(layer)layerToSortedIdxMap(layer.Name),inputLayers);
    sortedOutputLayerIndices=cellfun(@(layer)layerToSortedIdxMap(layer.Name),outputLayers);
    sortedNetworkInputSizes=dltargets.internal.sharedNetwork.getNetworkInputSizes(net,inputLayers);

end

