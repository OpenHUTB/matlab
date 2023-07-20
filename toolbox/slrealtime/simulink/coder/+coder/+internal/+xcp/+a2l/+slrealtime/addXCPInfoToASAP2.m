function addXCPInfoToASAP2(modelName,a2lFileFullPath,mapFileFullPath,includeXCPInfo,usingUserCustomizationObj)







    try
        appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
        tg=slrealtime(appContext.selectedTarget);
    catch

        tg=slrealtime;
    end
    ipAddress=tg.TargetSettings.address;
    port=tg.TargetSettings.xcpPort;



    transportLayerInfo=coder.internal.xcp.a2l.UdpTransportLayerInfo(...
    ipAddress,port);

    cDesc=coder.getCodeDescriptor(modelName);

    periodicEventList=coder.internal.xcp.a2l.slrealtime.PeriodicEventList(cDesc);

    ifDataXcp=asam.mcd2mc.create('IFDataXCPInfo');

    ifDataXcpBuilder=coder.internal.xcp.a2l.slrealtime.IFDataXCPBuilder();
    ifDataXcpBuilder.build(periodicEventList,transportLayerInfo,ifDataXcp);



    if~isempty(which('slrealtime.internal.cal.getPageSwitchingSegments'))
        segments=slrealtime.internal.cal.getPageSwitchingSegments(cDesc);
    else
        segments=[];
    end


    coder.internal.xcp.a2l.slrealtime.writeA2LWithECUAddressIFDataXCP(a2lFileFullPath,...
    mapFileFullPath,ifDataXcp,segments,includeXCPInfo,usingUserCustomizationObj);

end


