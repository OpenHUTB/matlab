function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Generalized Symbol Demodulator');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    Inpind=1;
    inportnames{Inpind}='dataIn';
    Inpind=Inpind+1;
    if(strcmpi(blockInfo.ModulationSource,'Input port'))
        if(strcmpi(blockInfo.OutputType,'Scalar'))
            inportnames{Inpind}='validIn';
            Inpind=Inpind+1;
        else
            inportnames{Inpind}='startIn';
            inportnames{Inpind+1}='endIn';
            inportnames{Inpind+2}='validIn';
            Inpind=Inpind+3;
        end
        inportnames{Inpind}='modSelIn';
        Inpind=Inpind+1;
    else
        inportnames{Inpind}='validIn';
        Inpind=Inpind+1;
    end
    if(blockInfo.NoiseVariance)
        inportnames{Inpind}='nVarIn';
    end

    Outind=1;
    outportnames{Outind}='dataOut';
    Outind=Outind+1;
    if(strcmpi(blockInfo.ModulationSource,'Input port'))
        if(strcmpi(blockInfo.OutputType,'Scalar'))
            outportnames{Outind}='validOut';
            Outind=Outind+1;
        else
            outportnames{Outind}='startOut';
            outportnames{Outind+1}='endOut';
            outportnames{Outind+2}='validOut';
            Outind=Outind+3;
        end
    else
        outportnames{Outind}='validOut';
        Outind=Outind+1;
    end
    if strcmpi(blockInfo.OutputType,'Scalar')
        outportnames{Outind}='readyOut';
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateGenSymbolDemodulatorNetwork(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
