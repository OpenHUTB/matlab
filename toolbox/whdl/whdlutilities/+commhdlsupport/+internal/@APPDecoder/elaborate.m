function topComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Gamma Computation');

    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='llrC';
    inportnames{2}='llrU';
    inportnames{3}='StartIn';
    inportnames{4}='EndIn';
    inportnames{5}='validIn';

    if strcmpi(blockInfo.DisableAprOut,'on')
        outportnames{1}='llrU';
        outportnames{2}='StartOut';
        outportnames{3}='EndOut';
        outportnames{4}='validOut';
    else
        outportnames{1}='llrU';
        outportnames{2}='llrC';
        outportnames{3}='StartOut';
        outportnames{4}='EndOut';
        outportnames{5}='validOut';
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateAPPDecoder(topNet,blockInfo,inSig,outSig);

    topComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
