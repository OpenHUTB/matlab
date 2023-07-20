

function layerToBuilderMap=populatePrototypedLayerToBuilderMap()




    layerToBuilderMap=containers.Map;
    layerToBuilderMap('nnet.cnn.layer.GroupedConvolution2DLayer')='GroupedConvCustomLayerClassBuilder';
end
