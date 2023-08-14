function latencyOut=dnnfpgafpLatency(latencyIn,kernelDataType,specifyLatency)

    if(strcmp(kernelDataType,'single'))
        latencyOut=int8(latencyIn);
    else
        latencyOut=specifyLatency;
    end

end