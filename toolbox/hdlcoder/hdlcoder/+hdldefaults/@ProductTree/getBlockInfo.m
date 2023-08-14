function[rndMode,satMode,dspMode,nfpOptions]=getBlockInfo(this,hC,slbh)


    rndMode=get_param(slbh,'RndMeth');
    if strcmpi(get_param(slbh,'DoSatur'),'on')
        satMode='Saturate';
    else
        satMode='Wrap';
    end


    dspModeStr=getImplParams(this,'DSPStyle');
    dspMode=int8(0);
    if isempty(dspModeStr)
        dspMode=int8(0);
    elseif strcmpi(dspModeStr,'on')
        dspMode=int8(1);
    elseif strcmpi(dspModeStr,'off')
        dspMode=int8(2);
    end


    nfpLatencyStr=getImplParams(this,'Latency Strategy');
    nfpOptions.Latency=int8(0);

    if isempty(nfpLatencyStr)
        nfpOptions.Latency=int8(0);
    elseif strcmpi(nfpLatencyStr,'MAX')
        nfpOptions.Latency=int8(1);
    elseif strcmpi(nfpLatencyStr,'MIN')
        nfpOptions.Latency=int8(2);
    elseif strcmpi(nfpLatencyStr,'ZERO')
        nfpOptions.Latency=int8(3);
    end

    nfpMantMulStr=getImplParams(this,'Mantissa Multiplier Strategy');
    nfpOptions.MantMul=int8(0);

    if isempty(nfpMantMulStr)
        nfpOptions.MantMul=int8(0);
    elseif strcmpi(nfpMantMulStr,'Full Multiplier')
        nfpOptions.MantMul=int8(1);
    elseif strcmpi(nfpMantMulStr,'Part Multiplier Part AddShift')
        nfpOptions.MantMul=int8(2);
    elseif strcmpi(nfpMantMulStr,'No Multiplier Full AddShift')
        nfpOptions.MantMul=int8(3);
    end

    nfpDenormalsStr=getImplParams(this,'Handle Denormals');
    nfpOptions.Denormals=int8(0);

    if isempty(nfpDenormalsStr)
        nfpOptions.Denormals=int8(0);
    elseif strcmpi(nfpDenormalsStr,'on')
        nfpOptions.Denormals=int8(1);
    elseif strcmpi(nfpDenormalsStr,'off')
        nfpOptions.Denormals=int8(2);
    end

    nfpRadixStr=getImplParams(this,'DivisionAlgorithm');
    if isempty(nfpRadixStr)||contains(nfpRadixStr,'2')
        nfpOptions.Radix=int32(2);
    else
        nfpOptions.Radix=int32(4);
    end

    v=this.validateDSPStyle(hC);
    if(numel(v)>1)
        dspMode=int8(0);
    end
end
