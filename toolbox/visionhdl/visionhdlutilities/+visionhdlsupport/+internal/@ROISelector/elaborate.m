function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=visionhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('ROI Selector');


    [inSig,outSig]=visionhdlsupport.internal.expandpixelcontrolbus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';

    outportnames{1}='dataOut';
    outportnames{2}='hStartOut';
    outportnames{3}='hEndOut';
    outportnames{4}='vStartOut';
    outportnames{5}='vEndOut';
    outportnames{6}='validOut';


    for ii=1:6
        inSig(ii).Name=inportnames{ii};
    end

    if blockInfo.RegionsSource==1
        for ii=7:numel(inSig)
            inSig(ii).Name=sprintf('region%d',ii-6);
        end
    end


    if blockInfo.NumberOfRegions==1
        for ii=1:numel(outportnames)
            outSig(ii).Name=outportnames{ii};
        end
    else
        for ii=1:(blockInfo.NumberOfRegions*6)
            outSig(ii).Name=sprintf('%a%d',outportnames{(mod(ii-1,6)+1)},floor((ii-1)/6)+1);
        end
    end


    this.elaborateROISelector(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
