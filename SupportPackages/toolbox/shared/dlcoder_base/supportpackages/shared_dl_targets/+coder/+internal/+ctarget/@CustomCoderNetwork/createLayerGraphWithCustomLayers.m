function modifiedLayerGraph=createLayerGraphWithCustomLayers(pirLayerComps,...
    networkInfo,buildContext,quantizationSpec)















    converter=coder.internal.ctarget.layerClassBuilder.CustomLayerClassConverter(pirLayerComps,networkInfo,...
    buildContext,quantizationSpec,'none');
    layerArray=converter.doit();

    fusedConnections=coder.internal.ctarget.CustomCoderNetwork.getConnectionsFromPIRComps(pirLayerComps);
    modifiedLayerGraph=toposort(nnet.cnn.LayerGraph(layerArray,fusedConnections));
end
