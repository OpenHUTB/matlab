function[fusedLayersMap,isFusedLayerMap]=createFusedLayersMap(layerComps)


















    fusedLayersMap=containers.Map('KeyType','double','ValueType','any');
    isFusedLayerMap=containers.Map('KeyType','double','ValueType','any');
    numLayers=numel(layerComps);
    for iLayerComp=1:numLayers

        dltLayerIndices=layerComps(iLayerComp).getFusedDLTLayerIndicesForMatlab;
        numDltLayerIndices=numel(dltLayerIndices);

        isLayerInFusedGraph=(numDltLayerIndices==1&&layerComps(iLayerComp).getExistsInLayerGraph)...
        ||numDltLayerIndices>1;



        if isLayerInFusedGraph
            drivingLayerIndex=dltLayerIndices(1);


            for iFusedLayer=1:numDltLayerIndices
                fusedLayersMap(dltLayerIndices(iFusedLayer))=[iLayerComp,iFusedLayer,drivingLayerIndex];
                isFusedLayerMap(dltLayerIndices(iFusedLayer))=numDltLayerIndices>1;
            end
        end
    end

end
