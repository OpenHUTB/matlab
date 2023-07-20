







function designs=getCustomDesignsInNet(net,customDesignMap)

    designs={};

    typeToLayer=containers.Map('KeyType','char','ValueType','any');
    for k=1:numel(net.Layers)
        layer=net.Layers(k);
        layerType=class(layer);
        typeToLayer(layerType)=layer;
    end


    layerTypes=keys(typeToLayer);
    for i=1:numel(layerTypes)
        layerType=layerTypes{i};
        if isKey(customDesignMap,layerType)
            designs{end+1}=customDesignMap(layerType);%#ok
        end
    end

end
