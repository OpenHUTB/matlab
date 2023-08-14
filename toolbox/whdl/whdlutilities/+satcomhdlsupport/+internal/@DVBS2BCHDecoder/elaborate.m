function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('DVB-S2 BCH Decoder Block');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='StartIn';
    inportnames{3}='EndIn';
    inportnames{4}='validIn';
    if strcmp(blockInfo.CodeRateSource,'Input port')
        inportnames{5}='codeRateInd';
    end

    if blockInfo.NumErrorsOutputPort
        outportnames{1}='dataOut';
        outportnames{2}='StartOut';
        outportnames{3}='EndOut';
        outportnames{4}='validOut';
        outportnames{5}='numErrors';
        outportnames{6}='nextFrame';
    else
        outportnames{1}='dataOut';
        outportnames{2}='StartOut';
        outportnames{3}='EndOut';
        outportnames{4}='validOut';
        outportnames{5}='nextFrame';
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateDVBS2BCHDecoderNetwork(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
