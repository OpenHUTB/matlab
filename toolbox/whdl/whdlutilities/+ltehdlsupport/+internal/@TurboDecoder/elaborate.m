function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Turbo Decoder');
    topNet.addComment('Five Components:Controller,DataRAM,Iterleaver Address,DecoderCore,OuputControl');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    if blockInfo.sizefromPort
        inportnames{2}='blkSize';
        pidx=3;
    else
        pidx=2;
    end
    inportnames{pidx}='StartIn';
    inportnames{pidx+1}='EndIn';
    inportnames{pidx+2}='validIn';

    outportnames{1}='dataOut';
    outportnames{2}='StartOut';
    outportnames{3}='EndOut';
    outportnames{4}='validOut';



    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateTurboDecoder(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
