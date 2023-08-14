function eComp=elaborate(this,hN,hC)




    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('ConvolutionalEncoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);


    inportnames{1}='dataIn';
    outportnames{1}='dataOut';
    if strcmpi(blockInfo.operationMode,'Terminated')
        inportnames{2}='startIn';
        inportnames{3}='endIn';
        inportnames{4}='validIn';

        outportnames{2}='startOut';
        outportnames{3}='endOut';
        outportnames{4}='validOut';


    elseif strcmpi(blockInfo.operationMode,'Truncated')
        inportnames{2}='startIn';
        inportnames{3}='endIn';
        inportnames{4}='validIn';

        if(blockInfo.enbIStPort)
            inportnames{5}='ISt';
        end
        outportnames{2}='startOut';
        outportnames{3}='endOut';
        outportnames{4}='validOut';
        if(blockInfo.enbFStPort)
            outportnames{5}='FSt';
        end
    else
        inportnames{2}='validIn';
        outportnames{2}='validOut';
        if(blockInfo.enbRst)
            inportnames{3}='reset';
        end
    end


    for ii=1:numel(inportnames)
        inSig(ii).name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).name=outportnames{ii};
    end


    this.elabConvEncNetwork(topNet,blockInfo,inSig,outSig);

    eComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
end
