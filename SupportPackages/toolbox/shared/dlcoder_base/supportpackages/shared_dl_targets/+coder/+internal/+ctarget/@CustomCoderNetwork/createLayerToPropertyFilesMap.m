function layerToPropertyFilesMap=createLayerToPropertyFilesMap(layerGraph,networkName,buildDirectory)








    layerToPropertyFilesMap=containers.Map;

    layers=layerGraph.Layers;
    numLayers=numel(layers);

    for iLayer=1:numLayers
        layer=layers(iLayer);
        propertiesAndFiles=coder.internal.ctarget.CustomCoderNetwork.saveLayerPropertiesToFile(...
        layer,networkName,buildDirectory);
        if~isempty(propertiesAndFiles)
            layerToPropertyFilesMap(layer.Name)=propertiesAndFiles;
        end
    end

end