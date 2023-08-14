function latencyInfo=getLatencyInfo(this,hC)












    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=0;
    latencyInfo.samplingChange=1;

    lat=this.getImplParams('ImplementationLatency');
    if~isempty(lat)&&lat>=0
        latencyInfo.outputDelay=lat;
    end
