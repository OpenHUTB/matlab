function latencyInfo=getLatencyInfo(this,hC)







    latencyInfo.inputDelay=0;


    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end
    latencyInfo.outputDelay=blockInfo.latency;




    latencyInfo.samplingChange=1;


