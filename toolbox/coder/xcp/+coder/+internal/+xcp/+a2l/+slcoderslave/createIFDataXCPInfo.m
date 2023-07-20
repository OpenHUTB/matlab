






function ifDataXcp=createIFDataXCPInfo(modelName,buildInfo,codeGenFolder,configSet,componentInterface)



    [checkoutSuccess,errmsg]=license('checkout','rtw_embedded_coder');
    if~checkoutSuccess
        DAStudio.error('coder_xcp:a2l:RequiresEmbeddedCoder',errmsg);
    end




    defineMap=coder.internal.xcp.a2l.DefineMapFactory.fromBuildInfo(buildInfo);
    periodicEventList=coder.internal.xcp.a2l.PeriodicEventList(componentInterface);



    transportLayerInfo=...
    coder.internal.xcp.a2l.TransportLayerInfo.getTransportLayerInfoForModel(modelName,...
    configSet,...
    codeGenFolder,...
    defineMap);



    isCompiledWithPWS=defineMap.isKey('PORTABLE_WORDSIZES');
    typeInfo=coder.internal.xcp.getTypeInfo(configSet,isCompiledWithPWS);




    ifDataXcp=asam.mcd2mc.create('IFDataXCPInfo');
    ifDataXcpBuilder=coder.internal.xcp.a2l.slcoderslave.IFDataXCPBuilder();
    ifDataXcpBuilder.build(defineMap,periodicEventList,transportLayerInfo,typeInfo,ifDataXcp);

end
