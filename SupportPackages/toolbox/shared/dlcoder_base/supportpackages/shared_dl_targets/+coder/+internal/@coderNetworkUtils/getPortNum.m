





function portid=getPortNum(layer,portname)
    internalLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
    portid=internalLayer{1}.outputName2Index(portname);
end
