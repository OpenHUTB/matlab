function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);

    inportnames{1}='dataIn';
    index=2;
    if blockInfo.inMode(1)
        inportnames{index}='validIn';
        index=index+1;
    end
    if blockInfo.inMode(2)
        inportnames{index}='softReset';
        index=index+1;
    end


    outportnames{1}='dataOut';
    index=2;

    outportnames{index}='validOut';

    FilterBankImpl=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );
    FilterBankImpl.addComment('Filter Bank');


    this.elaborateHDLFilterBank(FilterBankImpl,blockInfo);



    for loop=2:length(hC.PirInputSignals)
        hC.PirInputSignals(loop).SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
    end
    nComp=pirelab.instantiateNetwork(hN,FilterBankImpl,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
