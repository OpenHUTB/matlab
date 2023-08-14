





function layerid=getLayerId(net,layerName)
    layerNames={net.Layers.Name}';
    layerid=find(strcmp(layerNames,layerName));
    assert(isscalar(layerid),message('dlcoder_spkg:cnncodegen:invalid_layerIdx',layerName));
end
