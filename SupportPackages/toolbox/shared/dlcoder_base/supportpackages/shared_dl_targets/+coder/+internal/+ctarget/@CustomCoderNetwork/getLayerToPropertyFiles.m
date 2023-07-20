function propertiesToFile=getLayerToPropertyFiles(obj,layerName)










    if isKey(obj.LayerToPropertyFilesMap,layerName)
        propertiesToFile=obj.LayerToPropertyFilesMap(layerName);
    else
        propertiesToFile={};
    end

end
