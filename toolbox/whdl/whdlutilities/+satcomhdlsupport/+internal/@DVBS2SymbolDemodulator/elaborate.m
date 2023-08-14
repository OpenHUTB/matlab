function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    topNet=commhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('DVB-S2 Symbol Demodulator');


    [inSig,outSig]=commhdlsupport.internal.expandSampleControlBus(topNet);

    inportnames{1}='dataIn';
    if(strcmpi(blockInfo.OutputType,'Vector'))
        inportnames{2}='startIn';
        inportnames{3}='endIn';
        inportnames{4}='validIn';
        if(strcmpi(blockInfo.ModulationSourceParams,'Input port'))
            inportnames{5}='modIndx';
            inportnames{6}='codeRateIndx';
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                inportnames{7}='nVar';
            end
        else
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                inportnames{5}='nVar';
            end
        end
    else
        inportnames{2}='validIn';
        if(strcmpi(blockInfo.ModulationSourceParams,'Input port'))
            inportnames{3}='modIndx';
            inportnames{4}='codeRateIndx';
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                inportnames{5}='nVar';
            end
        else
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                inportnames{3}='nVar';
            end
        end
    end

    outportnames{1}='dataOut';
    if(strcmpi(blockInfo.OutputType,'Vector'))
        outportnames{2}='startOut';
        outportnames{3}='endOut';
        outportnames{4}='validOut';
    else
        outportnames{2}='validOut';
        outportnames{3}='ready';
    end


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this.elaborateDVBS2SymbolDemodulatorNetwork(topNet,blockInfo,inSig,outSig);

    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);

end
