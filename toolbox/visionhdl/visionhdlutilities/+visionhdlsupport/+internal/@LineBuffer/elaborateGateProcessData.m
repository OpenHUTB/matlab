function gateProcessNet=elaborateGateProcessData(~,topNet,blockInfo,sigInfo,dataRate,M)





    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;
    countT=sigInfo.countT;


    inPortNames={'processDataIn','validIn','dumping','outputData'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate];
    outPortNames={'processData','dumpOrValid'};
    outPortTypes=[booleanT,booleanT];



    gateProcessNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','GateProcessData',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=gateProcessNet.PirInputSignals;
    processDataIn=inSignals(1);
    validIn=inSignals(2);
    dumping=inSignals(3);
    outputData=inSignals(4);


    outSignals=gateProcessNet.PirOutputSignals;
    processData=outSignals(1);
    dumpOrValid=outSignals(2);


    validREG=gateProcessNet.addSignal2('Type',booleanT,'Name','validREG');
    pirelab.getUnitDelayComp(gateProcessNet,validIn,validREG);

    validOrDumping=gateProcessNet.addSignal2('Type',booleanT,'Name','validOrDumping');
    pirelab.getLogicComp(gateProcessNet,[validREG,dumping],validOrDumping,'or');

    processValid=gateProcessNet.addSignal2('Type',booleanT,'Name','processValid');
    pirelab.getLogicComp(gateProcessNet,[processDataIn,validOrDumping],processValid,'and');

    processNull=gateProcessNet.addSignal2('Type',booleanT,'Name','processNull');
    pirelab.getConstComp(gateProcessNet,processNull,0);

    pirelab.getSwitchComp(gateProcessNet,[processNull,processValid],processData,outputData);
    pirelab.getWireComp(gateProcessNet,validOrDumping,dumpOrValid);

























