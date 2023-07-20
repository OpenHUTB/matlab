%#codegen


function[layerIndices,fusedLayerOffsetIndices]=getFusedLayerIndices(obj,layerIndices)












    coder.allowpcode('plain');


    fusedLayerOffsetIndices=coder.nullcopy(zeros(size(layerIndices)));
    for iActivation=1:numel(layerIndices)

        iFusedLayerMap=obj.FusedLayersMap(layerIndices(iActivation));
        layerIndices(iActivation)=iFusedLayerMap(1);
        fusedLayerOffsetIndices(iActivation)=iFusedLayerMap(2);
    end

end
