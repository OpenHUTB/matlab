function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('CCSDS Reed-Solomon Decoder Block');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='StartIn';
    inportnames{3}='EndIn';
    inportnames{4}='validIn';


    if blockInfo.NumCorrErrPort
        outportnames{1}='dataOut';
        outportnames{2}='StartOut';
        outportnames{3}='EndOut';
        outportnames{4}='validOut';
        outportnames{5}='errOut';
        outportnames{6}='numCorrErr';
        outportnames{7}='nextFrame';
    else
        outportnames{1}='dataOut';
        outportnames{2}='StartOut';
        outportnames{3}='EndOut';
        outportnames{4}='validOut';
        outportnames{5}='errOut';
        outportnames{6}='nextFrame';
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateCCSDSRSDecoderNetwork(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
