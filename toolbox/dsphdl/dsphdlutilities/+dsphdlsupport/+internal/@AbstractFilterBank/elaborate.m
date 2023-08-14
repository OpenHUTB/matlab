function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);

    inportnames{1}='dataIn';
    inIndex=2;
    if blockInfo.inMode(1)
        inportnames{inIndex}='validIn';
        inIndex=inIndex+1;
    end
    if blockInfo.inMode(2)
        inportnames{inIndex}='syncReset';
        inIndex=inIndex+1;
    end


    outportnames{1}='dataOut';
    outIndex=2;

    outportnames{outIndex}='validOut';

    FilterBankImpl=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );
    FilterBankImpl.addComment('Filter Bank');


    this.elabHDLFilterBank(FilterBankImpl,blockInfo);



    for loop=2:length(hC.PirInputSignals)
        hC.PirInputSignals(loop).SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
    end
    nComp=pirelab.instantiateNetwork(hN,FilterBankImpl,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
