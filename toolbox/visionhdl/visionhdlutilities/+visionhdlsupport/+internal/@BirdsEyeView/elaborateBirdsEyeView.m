function elaborateBirdsEyeView(this,topNet,blockInfo,inSignals,outSignals)












    dataIn=inSignals(1);
    dataRate=dataIn.SimulinkRate;
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);


    dataOut=outSignals(1);
    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);


    inputWL=dataIn.Type.WordLength;
    inputFL=dataIn.Type.FractionLength;
    inType=dataIn.Type;
    booleanT=pir_boolean_t;
    readCounterType=pir_ufixpt_t(ceil(log2(blockInfo.MaxBufferSize)),0);
    FSMType=pir_ufixpt_t(2,0);
    sigInfo.inType=inType;
    sigInfo.booleanT=booleanT;
    sigInfo.inputWL=inputWL;
    sigInfo.inputFL=inputFL;
    sigInfo.readCounterType=readCounterType;
    sigInfo.dataRate=dataRate;
    sigInfo.FSMType=FSMType;
    intermediateCalcType=pir_ufixpt_t(28,-10);



    inPortNames={'pixelIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn'}';
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    inPortTypes=[inType,booleanT,booleanT,booleanT,booleanT,booleanT];
    outPortNames={'pixelOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    outPortTypes=[inType,booleanT,booleanT,booleanT,booleanT,booleanT];



    rowCounter=topNet.addSignal2('Type',readCounterType,'Name','rowCounterIn');
    vEndOutCG=topNet.addSignal2('Type',booleanT,'Name','vEndOutCG');
    vEndOutCGD=topNet.addSignal2('Type',booleanT,'Name','vEndOutCGD');
    lockRow=topNet.addSignal2('Type',booleanT,'Name','lockRow');;
    LockedInFrame=topNet.addSignal2('Type',booleanT,'Name','LockedInFrame');
    NotLocked=topNet.addSignal2('Type',booleanT,'Name','NotLocked');;
    lockRow.SimulinkRate=dataIn.SimulinkRate;

    pirelab.getLogicComp(topNet,LockedInFrame,NotLocked,'not');
    pirelab.getLogicComp(topNet,[hStartIn,NotLocked],lockRow,'and');
    rowCounter.SimulinkRate=dataIn.SimulinkRate;

    rowCounterComp=pirelab.getCounterComp(topNet,...
    [vEndOut,lockRow],...
    rowCounter,...
    'Free running',...
    0,...
    1,...
    [],...
    true,...
    false,...
    true,...
    false,...
    'RunLengthDecodeCount');
    rowCounterComp.addComment('Row Counter');




    birdsEyeFSMIn=[vEndOut,validIn,rowCounter,vStartIn];

    push=topNet.addSignal2('Type',booleanT,'Name','push');
    pop=topNet.addSignal2('Type',booleanT,'Name','pop');
    FSMState=topNet.addSignal2('Type',FSMType,'Name','FSMState');


    birdsEyeFSMOut=[push,pop,LockedInFrame,FSMState];

    birdsEyeFSMNet=this.elaborateBirdsEyeViewFSM(topNet,blockInfo,sigInfo,dataRate);
    pirelab.instantiateNetwork(topNet,birdsEyeFSMNet,birdsEyeFSMIn,birdsEyeFSMOut,'Birds-Eye FSM');



    readAddress=topNet.addSignal2('Type',readCounterType,'Name','ReadAddress');
    LineBufferDataOut=topNet.addSignal2('Type',inType,'Name','LineBufferDataOut');
    PreDataOut=topNet.addSignal2('Type',inType,'Name','PreDataOut');
    LineBufferCountOut=topNet.addSignal2('Type',readCounterType,'Name','LineBufferCountOUT');
    dataInDelay=topNet.addSignal2('Type',inType,'Name','LineBufferDataOut');

    pirelab.getIntDelayComp(topNet,dataIn,dataInDelay,3);


    readAddress.SimulinkRate=dataIn.SimulinkRate;
    vEndOutCGD.SimulinkRate=dataIn.SimulinkRate;


    lBufIn=[dataInDelay,push,readAddress,vEndOutCGD];
    lBufOut=[LineBufferDataOut,LineBufferCountOut];


    lBufNet=this.elaborateBirdsEyeViewLineBuffer(topNet,blockInfo,sigInfo,dataRate);
    pirelab.instantiateNetwork(topNet,lBufNet,lBufIn,lBufOut,'Input Buffer');




    hStartOutCG=topNet.addSignal2('Type',booleanT,'Name','hStartOutCG');
    hStartOutCGD=topNet.addSignal2('Type',booleanT,'Name','hStartOutCGD');

    hEndOutCG=topNet.addSignal2('Type',booleanT,'Name','hEndOutCG');
    vStartOutCG=topNet.addSignal2('Type',booleanT,'Name','vStartOutCG');
    validOutCG=topNet.addSignal2('Type',booleanT,'Name','validOutCG');
    EnableReadCompute=topNet.addSignal2('Type',booleanT,'Name','EnableReadCompute');
    EnableBetweenLines=topNet.addSignal2('Type',booleanT,'Name','EnableBetweenLines');
    ColumnCountReset=topNet.addSignal2('Type',booleanT,'Name','ColumnCountReset');
    ColumnCountEnable=topNet.addSignal2('Type',booleanT,'Name','ColumnCountEnable');
    BetweenLines=topNet.addSignal2('Type',booleanT,'Name','BetweenLines');


    BlankingCounter=topNet.addSignal2('Type',readCounterType,'Name','BlankingCounter');
    BlankingCounterD=topNet.addSignal2('Type',readCounterType,'Name','BlankingCounterD');
    ColumnCountOut=topNet.addSignal2('Type',readCounterType,'Name','ColumnCountOut');
    ColumnCountOutDELAY=topNet.addSignal2('Type',readCounterType,'Name','ColumnCountOut');

    BlankingCounter.SimulinkRate=dataIn.SimulinkRate;
    ColumnCountOut.SimulinkRate=dataIn.SimulinkRate;


    pirelab.getUnitDelayComp(topNet,BlankingCounter,BlankingCounterD);

    controlGenIn=[FSMState,BlankingCounterD,ColumnCountOut];
    controlGenOut=[hStartOutCG,hEndOutCG,vStartOutCG,vEndOutCG,validOutCG,EnableReadCompute,EnableBetweenLines,ColumnCountEnable,ColumnCountReset];

    controlGenNet=this.elaborateControlSignalGeneration(topNet,blockInfo,sigInfo,dataRate);
    pirelab.instantiateNetwork(topNet,controlGenNet,controlGenIn,controlGenOut,'Control Signal Generation');

    ColumnCount=pirelab.getCounterComp(topNet,...
    [ColumnCountReset,ColumnCountEnable],...
    ColumnCountOut,...
    'Free running',...
    0,...
    1,...
    [],...
    true,...
    false,...
    true,...
    false,...
    'Column Counter');
    ColumnCount.addComment('Column Count');



    NotValid=topNet.addSignal2('Type',booleanT,'Name','NotValid');
    pirelab.getIntDelayComp(topNet,ColumnCountOut,ColumnCountOutDELAY,4);

    pirelab.getUnitDelayComp(topNet,hStartOutCG,hStartOutCGD);
    pirelab.getUnitDelayComp(topNet,vEndOutCG,vEndOutCGD);

    readAddressGenIn=[hStartOutCGD,ColumnCountOutDELAY,vEndOutCGD];
    readAddressGenOut=[readAddress];

    readAddressGenNet=this.elaborateReadAddressGenNet(topNet,blockInfo,sigInfo,dataRate);
    pirelab.instantiateNetwork(topNet,readAddressGenNet,readAddressGenIn,readAddressGenOut,'Read Address Generation');

    pirelab.getLogicComp(topNet,validOutCG,NotValid,'not');

    pirelab.getUnitDelayResettableComp(topNet,LineBufferDataOut,dataOut,NotValid);
    pirelab.getUnitDelayComp(topNet,hStartOutCG,hStartOut);
    pirelab.getUnitDelayComp(topNet,hEndOutCG,hEndOut);
    pirelab.getUnitDelayComp(topNet,vStartOutCG,vStartOut);
    pirelab.getUnitDelayComp(topNet,vEndOutCG,vEndOut);
    pirelab.getUnitDelayComp(topNet,validOutCG,validOut);



    blankingCountNetIn=[hStartIn,hEndIn,FSMState];
    blankingCountNetOut=[BlankingCounter];


    blankingCountNet=this.elaborateBlankingCountNet(topNet,blockInfo,sigInfo,dataRate);
    pirelab.instantiateNetwork(topNet,blankingCountNet,blankingCountNetIn,blankingCountNetOut,'Blanking Counter Network');

































