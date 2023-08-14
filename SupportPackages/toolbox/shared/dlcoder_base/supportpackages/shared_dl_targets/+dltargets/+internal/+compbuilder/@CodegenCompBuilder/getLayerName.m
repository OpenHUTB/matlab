function str=getLayerName(layer,layerType)
    token=split(layerType,'.');
    assert(~isempty(token));
    str=char(token(end));
    if~isempty(layer.Name)
        str=[str,' ',layer.Name];
    end
end