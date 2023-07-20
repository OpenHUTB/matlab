function setDelayTags(this,hPreElabC,hPostElabC)



    if hPreElabC==hPostElabC
        return;
    end



    latencyInfo=this.getTotalCompLatency(hPreElabC);

    if latencyInfo.outputDelay>0
        hPostElabC.setOutputDelay(latencyInfo.outputDelay);
    end

    if latencyInfo.inputDelay>0
        hPostElabC.setInputDelay(latencyInfo.inputDelay);
    end

    if latencyInfo.samplingChange<-1||latencyInfo.samplingChange>1
        hPostElabC.setSamplingChange(latencyInfo.samplingChange);
    end


    if latencyInfo.outputDelay>0||latencyInfo.inputDelay>0
        hPostElabC.setLatencyValue(latencyInfo.outputDelay+latencyInfo.inputDelay);
    end
