function layer=getDLTLayerForPIRComp(layerComp,dltLayers)





    fusedDLTLayerIndices=layerComp.getFusedDLTLayerIndicesForMatlab;

    if numel(fusedDLTLayerIndices)>1




        fusedDLTLayerIndices=sort(fusedDLTLayerIndices);
        originalDLTLayerIdx=fusedDLTLayerIndices(1);
    else
        originalDLTLayerIdx=fusedDLTLayerIndices(1);
    end

    layer=dltLayers(originalDLTLayerIdx);
end

