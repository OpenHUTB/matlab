function dComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('CCSDS LDPC Decoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='startIn';
    inportnames{3}='endIn';
    inportnames{4}='validIn';
    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        if strcmpi(blockInfo.SpecifyInputs,'Input port')
            inportnames{5}='numIter';
        end
    else
        inportnames{5}='blockLen';
        inportnames{6}='codeRate';
        if strcmpi(blockInfo.SpecifyInputs,'Input port')
            inportnames{7}='numIter';
        end
    end

    outportnames{1}='dataOut';
    outportnames{2}='startOut';
    outportnames{3}='endOut';
    outportnames{4}='validOut';
    if strcmpi(blockInfo.Termination,'Early')
        outportnames{5}='iterOut';
        if blockInfo.ParityCheckStatus
            outportnames{6}='parCheckOut';
            outportnames{7}='nextFrame';
        else
            outportnames{6}='nextFrame';
        end
    else
        if blockInfo.ParityCheckStatus
            outportnames{5}='parCheckOut';
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

    this.elaborateCCSDSLDPCDecoderNetwork(topNet,blockInfo,inSig,outSig,hC.PirInputSignals(1).SimulinkRate);


    dComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end


