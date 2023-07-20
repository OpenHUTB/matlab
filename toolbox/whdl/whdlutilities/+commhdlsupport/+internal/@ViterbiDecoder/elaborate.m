function vComp=elaborate(this,hN,hC)




    blockInfo=getBlockInfo(this,hC);

    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('ViterbiDecoder');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    outportnames{1}='dataOut';

    if strcmpi(blockInfo.OperationMode,'Continuous')
        inportnames{2}='validIn';
        if(blockInfo.ErasurePort)
            inportnames{3}='erasureIn';
            if(blockInfo.ResetPort)
                inportnames{4}='reset';
            end
        else
            if(blockInfo.ResetPort)
                inportnames{3}='erasureIn';
            end
        end

        outportnames{2}='validOut';
    else
        inportnames{2}='startIn';
        inportnames{3}='endIn';
        inportnames{4}='validIn';
        if(blockInfo.ErasurePort)
            inportnames{5}='erasureIn';
        end

        outportnames{2}='startOut';
        outportnames{3}='endOut';
        outportnames{4}='validOut';
    end


    for ii=1:numel(inportnames)
        inSig(ii).name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).name=outportnames{ii};
    end


    this.elabViterbiDecoder(topNet,blockInfo,inSig,outSig);

    vComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
end