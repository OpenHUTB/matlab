function newNet=elaborateTopLevel(this,hN,hC,blockInfo)









    inportNames={'dataIn','validIn','request'};

    if blockInfo.ReadyPort
        outportNames={'dataOut','validOut','ready'};
    else
        outportNames={'dataOut','validOut'};
    end

    newNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames);





    dataIn=newNet.PirInputSignals(1);
    validIn=newNet.PirInputSignals(2);
    request=newNet.PirInputSignals(3);

    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);

    if blockInfo.ReadyPort
        ready=newNet.PirOutputSignals(3);
    else
        ready=newNet.addSignal(pir_boolean_t,'ready');
    end







    phaseWordLength=max(1,ceil(log2(blockInfo.InterpolationFactor)));
    phaseType=pir_fixpt_t(0,phaseWordLength,0);

    phase=newNet.addSignal(phaseType,'controllerPhaseOut');
    phaseValid=newNet.addSignal(pir_boolean_t,'controllerValidOut');
    filterValidOut=newNet.addSignal(pir_boolean_t,'filterValidOut');
    readyReg=newNet.addSignal(pir_boolean_t,'readyReg');
    dataValid=newNet.addSignal(pir_boolean_t,'dataValid');

    requestFilter=newNet.addSignal(pir_boolean_t,'requestReg');






    dataRate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=dataRate;
    validOut.SimulinkRate=dataRate;
    ready.SimulinkRate=dataRate;


    pirelab.getUnitDelayComp(newNet,request,requestFilter,'requestUnitDelay',1);


    pirelab.getBitwiseOpComp(newNet,[validIn,readyReg],dataValid,'AND');


    controllerNet=this.elaborateController(newNet,blockInfo,phaseType);
    pirelab.instantiateNetwork(newNet,controllerNet,...
    [dataValid;request],...
    [phase;phaseValid;ready],...
    'controllerInst');


    filterNet=this.elaborateFilter(newNet,blockInfo,dataIn.Type,dataOut.Type,phaseType);
    pirelab.instantiateNetwork(newNet,filterNet,...
    [dataIn;dataValid;phase;phaseValid;requestFilter],...
    [dataOut,filterValidOut],...
    'filterInst');


    pirelab.getBitwiseOpComp(newNet,[filterValidOut,requestFilter],validOut,'AND');


    pirelab.getUnitDelayComp(newNet,ready,readyReg,'readyReg',1);


    for k=1:length(newNet.Signals)
        newNet.Signals(k).SimulinkRate=dataRate;
    end

end
