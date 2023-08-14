function nameToLayer=getNameToLayerMap(layerArray)
    nameToLayer=containers.Map;
    for k=1:numel(layerArray)
        name=layerArray(k).Name;
        assert(~isempty(name));
        assert(~isKey(nameToLayer,name));
        nameToLayer(name)=k;
    end
end