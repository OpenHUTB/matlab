function layerProperties=parseNetwork(layerGraph)

















    coder.allowpcode('plain');

    layerProperties=struct();
    numStatefulLayers=0;


    connections=layerGraph.HiddenConnections;


    layers=layerGraph.Layers;
    numLayers=numel(layers);

    for idx=1:numLayers
        layer=layers(idx);

        layerProperties.layerObj(idx,1)=layer;
        layerProperties.inputConnections{idx,1}=dltargets.internal.getLayerInputConnections...
        (connections,idx);

        if isa(layer,'coder.internal.layer.RecurrentLayer')
            layerProperties.isStateful(idx,1)=true;
            numStatefulLayers=numStatefulLayers+1;
            layerProperties.statefulIdx(idx)=numStatefulLayers;
        else
            layerProperties.statefulIdx(idx)=-1;
            layerProperties.isStateful(idx,1)=false;
        end
    end

    layerProperties.numLayers=numLayers;
    layerProperties.numStatefulLayers=numStatefulLayers;

end
