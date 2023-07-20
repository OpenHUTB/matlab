function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=visionhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('HV Counter');


    [inSig,outSig]=visionhdlsupport.internal.expandpixelcontrolbus(topNet);

    inportnames{1}='hStartIn';
    inportnames{2}='hEndIn';
    inportnames{3}='vStartIn';
    inportnames{4}='vEndIn';
    inportnames{5}='validIn';

    outportnames{1}='hCount';
    outportnames{2}='vCount';
    outportnames{3}='hStartOut';
    outportnames{4}='hEndOut';
    outportnames{5}='vStartOut';
    outportnames{6}='vEndOut';
    outportnames{7}='validOut';


    for ii=1:5
        inSig(ii).Name=inportnames{ii};
    end

    for ii=1:7
        outSig(ii).Name=outportnames{ii};
    end



    this.elaborateHVCounter(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
