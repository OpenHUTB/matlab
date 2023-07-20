function dComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Depuncturer');



    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    outportnames{1}='dataOut';

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            inportnames{2}='puncVector';
            inportnames{3}='syncStart';
            inportnames{4}='validIn';
        else
            inportnames{2}='syncPunc';
            inportnames{3}='validIn';
        end

        outportnames{2}='validOut';
        outportnames{3}='erasureOut';

    else
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            inportnames{2}='puncVector';
            inportnames{3}='startIn';
            inportnames{4}='endIn';
            inportnames{5}='validIn';
        else
            inportnames{2}='startIn';
            inportnames{3}='endIn';
            inportnames{4}='validIn';
        end

        outportnames{2}='startOut';
        outportnames{3}='endOut';
        outportnames{4}='validOut';
        outportnames{5}='erasureOut';
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end



    this.elaborateDepuncturerNetwork(topNet,blockInfo,inSig,outSig,hC.PirInputSignals(1).SimulinkRate);


    dComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
