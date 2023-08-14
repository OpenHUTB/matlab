function latencyInfo=getLatencyInfo(this,hC)



    impl=getFunctionImpl(this,hC);
    if(~isempty(impl))
        latencyInfo=impl.getLatencyInfo(hC);
    else

        latencyInfo=SqrtBitsetLatency(this,hC);
    end

