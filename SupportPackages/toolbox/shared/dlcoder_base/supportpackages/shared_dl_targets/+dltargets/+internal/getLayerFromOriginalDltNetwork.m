function layer=getLayerFromOriginalDltNetwork(layerComp,networkInfo)





    originalLayerIndex=layerComp.getSourceDLTLayerIndex();
    assert(originalLayerIndex>0,['Component ',layerComp.getName,' is not part of the original network']);
    originalLayers=networkInfo.OriginalSortedLayerGraph.Layers;
    assert(originalLayerIndex<=numel(originalLayers),['Component ',layerComp.getName,' has invalid DLT layer index'])
    layer=originalLayers(originalLayerIndex);
end
