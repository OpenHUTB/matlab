function nfpOptions=getNFPBlockInfo(this)




    nfpLatencyStr=getImplParams(this,'LatencyStrategy');
    nfpOptions.Latency=int8(0);

    if isempty(nfpLatencyStr)
        nfpOptions.Latency=int8(0);
    elseif strcmpi(nfpLatencyStr,'Max')
        nfpOptions.Latency=int8(1);
    elseif strcmpi(nfpLatencyStr,'Min')
        nfpOptions.Latency=int8(2);
    elseif strcmpi(nfpLatencyStr,'Zero')
        nfpOptions.Latency=int8(3);
    elseif strcmpi(nfpLatencyStr,'Custom')
        nfpOptions.Latency=int8(4);
    end

    nfpOptions.CustomLatency=int8(0);


    if nfpOptions.Latency==int8(4)
        customLatency=getImplParams(this,'NFPCustomLatency');
        if~isempty(customLatency)
            nfpOptions.CustomLatency=int8(customLatency);
        end
    end

    nfpDenormalsStr=getImplParams(this,'HandleDenormals');
    nfpOptions.Denormals=int8(0);

    if isempty(nfpDenormalsStr)
        nfpOptions.Denormals=int8(0);
    elseif strcmpi(nfpDenormalsStr,'on')
        nfpOptions.Denormals=int8(1);
    elseif strcmpi(nfpDenormalsStr,'off')
        nfpOptions.Denormals=int8(2);
    end

    nfpMantissaStrategy=getImplParams(this,'MantissaMultiplyStrategy');
    nfpOptions.MantMul=int8(0);

    if isempty(nfpMantissaStrategy)
        nfpOptions.MantMul=int8(0);
    elseif strcmpi(nfpMantissaStrategy,'FullMultiplier')
        nfpOptions.MantMul=int8(1);
    elseif strcmpi(nfpMantissaStrategy,'PartMultiplierPartAddShift')
        nfpOptions.MantMul=int8(2);
    elseif strcmpi(nfpMantissaStrategy,'NoMultiplierFullAddShift')
        nfpOptions.MantMul=int8(3);
    end
