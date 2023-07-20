function networkInfo=optimizeNetwork(networkInfo,dlConfig,transformProperties)








    if~strcmp(dlConfig.TargetLibrary,'tensorrt')
        if dlcoderfeature('FCToConvLayer')||dlcoderfeature('FCBNReLUToFusedConvLayer')

            FCBNReLUonlyXformFlag=dlcoderfeature('FCBNReLUToFusedConvLayer')&&~dlcoderfeature('FCToConvLayer');






            networkInfo=dltargets.internal.optimizations.FCToConvLayer(networkInfo,FCBNReLUonlyXformFlag);
        end
    end

    if dlConfig.OptimizationConfig.ConvBatchNormFusion&&~(strcmp(dlConfig.TargetLibrary,"none")...
        &&dlcoderfeature('RuntimeLoad'))


        networkInfo=dltargets.internal.optimizations.convBatchNormLayerFusion(networkInfo,transformProperties);
    end

end
