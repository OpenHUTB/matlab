function latencyInfo=getLatencyInfo(this,hC)















    latencyInfo=this.baseGetLatencyInfo(hC);


    latencyInfo.inputDelay=latencyInfo.outputDelay;
    latencyInfo.outputDelay=0;


