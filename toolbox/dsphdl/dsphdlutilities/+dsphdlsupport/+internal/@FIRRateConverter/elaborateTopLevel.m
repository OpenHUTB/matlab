function newNet=elaborateTopLevel(this,hN,hC,blockInfo)










    inportNames={'dataIn','validIn'};


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


    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);

    if blockInfo.ReadyPort
        ready=newNet.PirOutputSignals(3);
    else
        ready=newNet.addSignal(pir_boolean_t,'ready');
    end







    phaseWordLength=max(1,ceil(log2(blockInfo.InterpolationFactor)));
    phaseType=pir_fixpt_t(0,phaseWordLength,0);

    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_WORDLENGTH=dataInType.wordsize;
    DATAIN_FRACTIONLENGTH=dataInType.binarypoint;
    DATAIN_SIGN=dataInType.issigned;
    NUMCHANNEL=dataInType.vector(1);

    phase=newNet.addSignal(phaseType,'controllerPhaseOut');
    phaseValid=newNet.addSignal(pir_boolean_t,'controllerValidOut');
    filterValidOut=newNet.addSignal(pir_boolean_t,'filterValidOut');
    readyReg=newNet.addSignal(pir_boolean_t,'readyReg');
    dataValid=newNet.addSignal(pir_boolean_t,'dataValid');
    readySM=newNet.addSignal(pir_boolean_t,'readySM');
    dinSM=newNet.addSignal(dataIn.Type,'dinSM');
    dinVldSM=newNet.addSignal(pir_boolean_t,'dinVldSM');
    countReached=newNet.addSignal(pir_boolean_t,'countReached');







    dataRate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=dataRate;
    validOut.SimulinkRate=dataRate;
    ready.SimulinkRate=dataRate;


    if blockInfo.InterpolationFactor>blockInfo.DecimationFactor

        firRdyLogic=elaborateFIRReadyLogic(this,newNet,dataRate,...
        dataIn,validIn,countReached,'',...
        readySM,dinSM,dinVldSM,...
        DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH,floor(blockInfo.InterpolationFactor/blockInfo.DecimationFactor),NUMCHANNEL);


        pirelab.instantiateNetwork(newNet,firRdyLogic,[dataIn,validIn,countReached,''],...
        [readySM,dinSM,dinVldSM],...
        'firRdyLogic');


        pirelab.getWireComp(newNet,dinVldSM,dataValid);
        pirelab.getWireComp(newNet,readySM,ready);


    else

        pirelab.getWireComp(newNet,validIn,dataValid);
        pirelab.getWireComp(newNet,dataIn,dinSM);
        pirelab.getConstComp(newNet,readySM,true);
        pirelab.getWireComp(newNet,readySM,ready);

    end





    controllerNet=this.elaborateController(newNet,blockInfo,phaseType);
    pirelab.instantiateNetwork(newNet,controllerNet,...
    dataValid,...
    [phase;phaseValid;countReached],...
    'controllerInst');


    filterNet=this.elaborateFilter(newNet,blockInfo,dataIn.Type,dataOut.Type,phaseType);
    pirelab.instantiateNetwork(newNet,filterNet,...
    [dinSM;dataValid;phase;phaseValid],...
    [dataOut,filterValidOut],...
    'filterInst');


    pirelab.getWireComp(newNet,filterValidOut,validOut);


    pirelab.getUnitDelayComp(newNet,ready,readyReg,'readyReg',1);


    for k=1:length(newNet.Signals)
        newNet.Signals(k).SimulinkRate=dataRate;
    end

end
