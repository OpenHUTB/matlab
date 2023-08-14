function nComp=elaborate(this,hN,hC)




    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Reed-Solomon Encoder Block');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='StartIn';
    inportnames{3}='EndIn';
    inportnames{4}='validIn';

    outportnames{1}='dataOut';
    outportnames{2}='StartOut';
    outportnames{3}='EndOut';
    outportnames{4}='validOut';
    outportnames{5}='nextFrame';


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end





    this.elaborateRSEncoderNetwork(topNet,blockInfo,inSig,outSig);


    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);
