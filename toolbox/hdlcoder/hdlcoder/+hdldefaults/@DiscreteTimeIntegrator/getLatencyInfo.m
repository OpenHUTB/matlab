function latencyInfo=getLatencyInfo(~,hC)



    latencyInfo.inputDelay=0;
    externalReset=get_param(hC.SimulinkHandle,'ExternalReset');
    if~isempty(externalReset)&&...
        (strcmpi(externalReset,'rising')||strcmpi(externalReset,'falling'))
        latencyInfo.outputDelay=1;
        hC.setImplementationLatency(latencyInfo.outputDelay);
    else
        latencyInfo.outputDelay=0;
    end
    latencyInfo.samplingChange=1;
end
