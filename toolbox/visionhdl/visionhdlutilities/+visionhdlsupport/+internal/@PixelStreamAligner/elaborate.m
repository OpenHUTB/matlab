function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=visionhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Pixel Stream Aligner');


    [inSig,outSig]=visionhdlsupport.internal.expandpixelcontrolbus(topNet);

    inportnames{1}='pixel';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';
    inportnames{7}='refPixel';
    inportnames{8}='refHStartIn';
    inportnames{9}='refHEndIn';
    inportnames{10}='refVStartIn';
    inportnames{11}='refVEndIn';
    inportnames{12}='refValidIn';


    outportnames{1}='pixelOut';
    outportnames{2}='refPixelOut';
    outportnames{3}='hStartOut';
    outportnames{4}='hEndOut';
    outportnames{5}='vStartOut';
    outportnames{6}='vEndOut';
    outportnames{7}='validOut';


    for ii=1:12
        inSig(ii).Name=inportnames{ii};
    end

    for ii=1:7
        outSig(ii).Name=outportnames{ii};
    end



    this.elaboratePixelStreamAligner(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
