function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Polar Decoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='StartIn';
    inportnames{3}='EndIn';
    inportnames{4}='validIn';

    if blockInfo.configFromPort
        inportnames{5}='K';
        inportnames{6}='E';
    end

    if blockInfo.rntiFromPort
        inportnames{end}='RNTI';
    end

    outportnames{1}='dataOut';
    outportnames{2}='StartOut';
    outportnames{3}='EndOut';
    outportnames{4}='validOut';
    outportnames{5}='err';
    outportnames{6}='nextBlock';

    if blockInfo.debugPortsEn
        outportnames{7}='decLlr';
        outportnames{8}='decLlrValid';
    end



    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaboratePolarDecoder(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
