function latencyInfo=getLatencyInfo(this,hC)





    blockInfo=getBlockInfo(this,hC);
    if(strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))
        iterNum=hC.PirOutputSignals(1).Type.BaseType.Wordlength;
    else
        Input1WordLength=hC.PirInputSignals(1).Type.BaseType.Wordlength;
        iterNum=Input1WordLength+abs(blockInfo.fractiondiff);
    end


    if strcmpi(blockInfo.pipeline,'on')
        if(strcmpi(blockInfo.latencyStrategy,'MAX'))
            outputDelay=iterNum+4;
        elseif(strcmpi(blockInfo.latencyStrategy,'CUSTOM'))
            outputDelay=blockInfo.customLatency;
        else
            outputDelay=0;
        end
    else
        outputDelay=0;
    end

    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;


