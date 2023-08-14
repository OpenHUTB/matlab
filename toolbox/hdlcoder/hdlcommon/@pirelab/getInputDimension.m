function dimLen=getInputDimension(tSignalsIn)



    if length(tSignalsIn)==1

        dimLen=pirelab.getVectorTypeInfo(tSignalsIn);
    else

        dimLen=length(tSignalsIn);
    end

end