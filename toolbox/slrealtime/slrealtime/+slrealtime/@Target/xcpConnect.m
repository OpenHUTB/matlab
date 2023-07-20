function xcpConnect(this)





    appName=this.tc.ModelProperties.Application;



    if~isempty(this.xcp)
        this.xcpDisconnect();
    end

    slrealtime.internal.connectivity.registerShutdown();

    try
        this.xcp=slrealtime.internal.connectivity.XcpTargetConnection(...
        this.TargetSettings.address,...
        this.TargetSettings.xcpPort);
    catch ME
        this.xcpDisconnect();
        slrealtime.internal.throw.Warning('slrealtime:target:applicationConnectionFailed',appName,this.TargetSettings.name,ME.message);
        return;
    end
    assert(~isempty(this.xcp));




    xcpExtractFromApp(this,appName);




    if this.LogCANBus
        this.setupCANBusLogging();
    end




    this.validateInstrumentList();
end
