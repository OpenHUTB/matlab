function dComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('WLANLDPCDecoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='data';
    inportnames{2}='start';
    inportnames{3}='end';
    inportnames{4}='valid';
    if strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax')
        inportnames{5}='blockLengthIdx';
        inportnames{6}='codeRateIdx';
        if~(strcmpi(blockInfo.SpecifyInputs,'Property'))&&(strcmpi(blockInfo.Termination,'Max'))
            inportnames{7}='iter';
        end
    else
        inportnames{5}='codeRateIdx';
        if~(strcmpi(blockInfo.SpecifyInputs,'Property'))&&(strcmpi(blockInfo.Termination,'Max'))
            inportnames{6}='iter';
        end
    end

    outportnames{1}='decBits';
    outportnames{2}='startOut';
    outportnames{3}='endOut';
    outportnames{4}='validOut';
    if(strcmpi(blockInfo.Termination,'Early'))
        outportnames{5}='actIter';
        if blockInfo.ParityCheckStatus
            outportnames{6}='parityCheck';
            outportnames{7}='nextFrame';
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


    this.elaborateWLANLDPCDecoderNetwork(topNet,blockInfo,inSig,outSig,hC.PirInputSignals(1).SimulinkRate);


    dComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
