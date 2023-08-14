function latencyInfo=getLatencyInfo(this,hC)





    impl=getFunctionImpl(this,hC);

    if isempty(impl)

        blockInfo=getBlockInfo(this,hC);


        in1WL=hC.PirInputSignals(1).Type.BaseType.WordLength;
        in2WL=hC.PirInputSignals(2).Type.BaseType.WordLength;
        numPipeStages=ceil(log2(min(in1WL,in2WL)));
        if(strcmpi(blockInfo.latencyStrategy,'MAX'))
            outputDelay=numPipeStages;
        elseif(strcmpi(blockInfo.latencyStrategy,'CUSTOM'))
            outputDelay=blockInfo.customLatency;
        else
            outputDelay=0;
        end

        latencyInfo.inputDelay=0;
        latencyInfo.outputDelay=outputDelay;
        latencyInfo.samplingChange=1;

    else
        latencyInfo=impl.getLatencyInfo(hC);
    end
end


