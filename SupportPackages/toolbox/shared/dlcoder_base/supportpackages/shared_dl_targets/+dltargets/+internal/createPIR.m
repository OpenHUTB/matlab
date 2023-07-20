function[gp,layerToCompMap,connectivity]=createPIR(networkInfo,networkClassName,codegendir,...
    codegentarget,dlcfg,transformProperties,rowMajorCustomLayerNames,dlCodegenOptionsCallback)






    layers=networkInfo.SortedLayers;

    n=numel(layers);
    assert(n~=0,'Input network is empty.');

    numNetworkInputs=numel(networkInfo.InputNames);
    numNetworkOutputs=numel(networkInfo.OutputNames);

    p=dnn_pir('CNNNetwork');
    hN=p.addNetwork(numNetworkInputs,numNetworkOutputs);
    p.setTopNetwork(hN);
    hN.setIsDlnetwork(networkInfo.IsDLNetwork);



    converter=dltargets.internal.compbuilder.CodegenLayerConverter(networkInfo,...
    hN,networkClassName,transformProperties,...
    dlcfg.TargetLibrary,codegentarget,codegendir,...
    rowMajorCustomLayerNames);
    layerToCompMap=converter.convert();


    connectivity=networkInfo.Connections;
    dltargets.internal.connectDnnNetwork(connectivity,hN,networkInfo,layerToCompMap);


    dltargets.internal.setCalibrationInfoForTensorRT(dlCodegenOptionsCallback,hN,codegentarget,codegendir,networkClassName,dlcfg,networkInfo.NetworkIdentifier);

    gp=dnn_pir;
end


