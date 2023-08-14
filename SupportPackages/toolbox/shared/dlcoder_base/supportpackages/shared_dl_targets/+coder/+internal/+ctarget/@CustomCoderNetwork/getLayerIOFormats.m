function[layerInputFormats,layerOutputFormats]=getLayerIOFormats(obj,layerIndices,networkInfo)




    numLayers=numel(layerIndices);
    layerInputFormats=cell(1,numLayers);
    layerOutputFormats=cell(1,numLayers);
    optimizedLayers=obj.Layers;

    for idx=1:numLayers
        layerIdx=layerIndices(idx);

        layerName=optimizedLayers(layerIdx).Name;
        layerInputFormats{idx}=networkInfo.LayerInfoMap(layerName).inputFormats;
        layerOutputFormats{idx}=networkInfo.LayerInfoMap(layerName).outputFormats;
    end

end
