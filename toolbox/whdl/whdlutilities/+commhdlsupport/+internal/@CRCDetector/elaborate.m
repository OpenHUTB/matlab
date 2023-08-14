function nComp=elaborate(this,hN,hC)




    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('CRC Detector');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='startIn';
    inportnames{3}='endIn';
    inportnames{4}='validIn';

    outportnames{1}='dataOut';
    outportnames{2}='startOut';
    outportnames{3}='endOut';
    outportnames{4}='validOut';
    outportnames{5}='err';


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateCRCDetector(topNet,blockInfo,inSig,outSig);


    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);
end