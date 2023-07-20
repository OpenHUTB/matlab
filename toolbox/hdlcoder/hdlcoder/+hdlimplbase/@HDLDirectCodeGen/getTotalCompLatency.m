function latencyInfo=getTotalCompLatency(this,hC)







    latencyInfo=this.getLatencyInfo(hC);
    latencyInfo.outputDelay=this.getHwModeLatency(hC)+latencyInfo.outputDelay;
