function xformedNet=convBatchNormLayerFusion(net,verbose)














    networkWrapper=dltargets.internal.NetworkInfo(net,[]);







    transformProperties=dltargets.internal.TransformProperties(networkWrapper,-1);
    xformedNetworkWrapper=dltargets.internal.optimizations.convBatchNormLayerFusion(networkWrapper,transformProperties);

    if isa(net,'SeriesNetwork')||isa(net,'DAGNetwork')
        xformedNet=assembleNetwork(xformedNetworkWrapper.SortedLayerGraph);
    elseif isa(net,'dlnetwork')
        xformedNet=dlnetwork(xformedNetworkWrapper.SortedLayerGraph);
    end

    if size(xformedNet.Layers,1)~=size(net.Layers,1)
        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:FusedLayers','nnet.cnn.layer.BatchNormalizationLayer','nnet.cnn.layer.Convolution2DLayer'),1,verbose);
    end

end
