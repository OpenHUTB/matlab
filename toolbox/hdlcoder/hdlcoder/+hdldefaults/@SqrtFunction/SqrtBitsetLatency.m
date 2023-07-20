function latencyInfo=SqrtBitsetLatency(this,hC)


    sqrtInfo=getBlockInfo(this,hC.SimulinkHandle);
    outSigned=hC.PirOutputSignals(1).Type.BaseType.Signed;
    outputWL=hC.PirOutputSignals(1).Type.BaseType.WordLength;
    outputFL=-hC.PirOutputSignals(1).Type.BaseType.FractionLength;

    inputWL=hC.PirInputSignals(1).Type.BaseType.WordLength;
    inputFL=-hC.PirInputSignals(1).Type.BaseType.FractionLength;


    if outSigned
        k=outputWL-1;
    else
        k=outputWL;
    end


    if strcmpi(sqrtInfo.algorithm,'UseMultiplier')
        algorithmMultOn=true;

    else
        algorithmMultOn=false;
    end

    if(~algorithmMultOn)
        inputIntL=inputWL-inputFL;
        outputIntL=ceil(inputIntL/2);
        newoutWL=outputIntL+outputFL;
        k=min(k,newoutWL);
    end

    if(k<=0)
        k=1;
    end

    if strcmpi(sqrtInfo.pipeline,'on')
        if(strcmpi(sqrtInfo.latencyStrategy,'MAX')||strcmpi(sqrtInfo.latencyStrategy,'inherit'))
            outputDelay=k+2;
        elseif(strcmpi(sqrtInfo.latencyStrategy,'MIN'))

            outputDelay=floor((k+2)/2);
        elseif(strcmpi(sqrtInfo.latencyStrategy,'CUSTOM'))
            outputDelay=sqrtInfo.customLatency;
        else
            outputDelay=0;
        end
    else
        outputDelay=0;
    end
    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;


