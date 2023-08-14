function nameToLayerObj=getNameToLayerObjMap(layerArray)
    nameToLayerObj=containers.Map;
    for k=1:numel(layerArray)
        name=layerArray(k).Name;
        assert(~isempty(name));
        assert(~isKey(nameToLayerObj,name));
        nameToLayerObj(name)=layerArray(k);
    end
end