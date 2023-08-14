function dComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('DVBS2 LDPC Decoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='startIn';
    inportnames{3}='endIn';
    inportnames{4}='validIn';
    inputPortInd=5;
    if(strcmpi(blockInfo.FECFrameSource,'Property'))
        if(strcmpi(blockInfo.CodeRateSource,'Input port'))
            inportnames{inputPortInd}='codeRateIdx';
            inputPortInd=inputPortInd+1;
        end
    else
        inportnames{inputPortInd}='fecFrameType';
        inputPortInd=inputPortInd+1;
        inportnames{inputPortInd}='codeRateIdx';
        inputPortInd=inputPortInd+1;
    end
    if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
        inportnames{inputPortInd}='iter';
    end

    outportnames{1}='dataOut';
    outportnames{2}='startOut';
    outportnames{3}='endOut';
    outportnames{4}='validOut';
    if(strcmpi(blockInfo.Termination,'Early'))
        outportnames{5}='actIter';
        if blockInfo.ParityCheckStatus
            outportnames{5}='parityCheck';
            outportnames{6}='nextFrame';
        else
            outportnames{6}='nextFrame';
        end
    else
        if blockInfo.ParityCheckStatus
            outportnames{5}='parityCheck';
            outportnames{6}='nextFrame';
        else
            outportnames{5}='nextFrame';
        end
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateDVBS2LDPCDecoderNetwork(topNet,blockInfo,inSig,outSig,hC.PirInputSignals(1).SimulinkRate);


    dComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
