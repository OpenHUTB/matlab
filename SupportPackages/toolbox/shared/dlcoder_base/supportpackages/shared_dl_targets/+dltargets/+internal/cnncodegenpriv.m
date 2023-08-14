function cnncodegenpriv(net,dlcodeConfig,isdlcodegen)




    dltargets.internal.checkoutLicense(dlcodeConfig.DeepLearningConfig.TargetLibrary);


    networkInputSizes=dltargets.internal.getNetworkInputSizes(net,dlcodeConfig.BatchSize);


    networkInfo=dltargets.internal.NetworkInfo(net,networkInputSizes);


    isCnnCodegenWorkflow=true;
    dltargets.internal.sharedNetwork.validateNetworkImpl(net,dlcodeConfig.DeepLearningConfig,...
    networkInfo.LayerInfoMap,isCnnCodegenWorkflow);


    transformProperties=dltargets.internal.TransformProperties(networkInfo,-1);






    quantizationInfo=dltargets.internal.createQuantizerInfo(networkInfo,dlcodeConfig.DeepLearningConfig);


    networkInfo=dltargets.internal.optimizations.optimizeNetwork(networkInfo,dlcodeConfig.DeepLearningConfig,transformProperties);

    [srcs,headers,tfiles]=dltargets.internal.cnngenerate(networkInfo,dlcodeConfig,transformProperties,quantizationInfo);

    if isdlcodegen


        dltargets.internal.dlbuild('dlbuild',srcs,headers,tfiles,dlcodeConfig);
    else

        dltargets.internal.dlbuild('cnnbuild',srcs,headers,tfiles,dlcodeConfig);
    end

end
