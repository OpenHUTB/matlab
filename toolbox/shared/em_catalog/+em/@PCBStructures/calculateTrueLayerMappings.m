function layermappings=calculateTrueLayerMappings(obj,fullLayerMap)
    metalLayerIndx=find(cellfun(@(x)isa(x,'antenna.Shape'),obj.Layers)==1);
    layermap=1:numel(metalLayerIndx);
    mapObj=containers.Map(metalLayerIndx,layermap);
    layermappings=fullLayerMap;
    if size(fullLayerMap,2)==2
        for i=1:size(fullLayerMap,1)
            layermappings(i,:)=[mapObj(fullLayerMap(i,1)),mapObj(fullLayerMap(i,2))];
        end
    else
        for i=1:size(fullLayerMap,1)
            layermappings(i,:)=mapObj(fullLayerMap(i));
        end
    end

end