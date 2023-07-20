function dComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('NR LDPC Decoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='data';
    inportnames{2}='start';
    inportnames{3}='end';
    inportnames{4}='valid';
    inportnames{5}='bgn';
    inportnames{6}='liftsize';

    if strcmpi(blockInfo.SpecifyInputs,'Input port')
        inportnames{7}='iter';
        if blockInfo.RateCompatible
            inportnames{8}='numRows';
        end
    else
        if blockInfo.RateCompatible
            inportnames{7}='numRows';
        end
    end

    outportnames{1}='decBits';
    outportnames{2}='startOut';
    outportnames{3}='endOut';
    outportnames{4}='validOut';
    outportnames{5}='liftSize';

    if(strcmpi(blockInfo.Termination,'early'))
        outportnames{6}='actIter';
        if blockInfo.ParityCheckStatus
            outportnames{7}='parityCheck';
            outportnames{8}='nextFrame';
        else
            outportnames{7}='nextFrame';
        end
    else
        if blockInfo.ParityCheckStatus
            outportnames{6}='parityCheck';
            outportnames{7}='nextFrame';
        else
            outportnames{6}='nextFrame';
        end
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateLDPCDecoderNetwork(topNet,blockInfo,inSig,outSig,hC.PirInputSignals(1).SimulinkRate);


    dComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
