function xformedNet=optimizeNetwork(net,varargin)




    if nargin<2
        verbose=1;
    else
        verbose=varargin{1};
    end



    dnnfpga.validateDLSupportPackage('shared','multiple');

    xformedNet=dnnfpga.compiler.optimizations.removeDropoutLayer(net);
    xformedNet=dnnfpga.compiler.optimizations.flattenCStyleFcLayerFusion(xformedNet,verbose);
    xformedNet=dnnfpga.compiler.optimizations.convBatchNormLayerFusion(xformedNet,verbose);
    xformedNet=dnnfpga.compiler.optimizations.zeroPaddingLayerFusion(xformedNet,verbose);



    xformedNet=dnnfpga.compiler.optimizations.imageBatchNormLayerFusion(xformedNet,verbose);
    xformedNet=dnnfpga.compiler.optimizations.convBatchNormLayerFusion(xformedNet,0);





    xformedNet=dnnfpga.compiler.optimizations.symmetrizeStride(xformedNet,verbose);

end


