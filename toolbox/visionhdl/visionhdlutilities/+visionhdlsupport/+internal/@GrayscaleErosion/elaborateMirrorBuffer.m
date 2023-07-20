function mirrorNet=elaborateMirrorBuffer(this,topNet,blockInfo,sigInfo,inRate)











    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    controlType=sigInfo.controlType;



    inPortNames={'dataIn','hStartIn','PingPongControl','validIn','modK'};
    inPortTypes=[inType,boolType,controlType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate,inRate];
    outPortNames={'dataOut'};
    outPortTypes=inType;


    mirrorNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MirrorBuffer',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    mirrorNet.addComment('Mirror Buffer - Ping Pong FIFO Output in address reversed order');



    inSignals=mirrorNet.PirInputSignals;
    dataIn=inSignals(1);
    hStartIn=inSignals(2);
    PingPongControl=inSignals(3);
    validIn=inSignals(4);
    modK=inSignals(5);


    outSignals=mirrorNet.PirOutputSignals;
    dataOut=outSignals(1);



    controlUpper=mirrorNet.addSignal2('Type',boolType,'Name','ControlUpper');
    controlLower=mirrorNet.addSignal2('Type',boolType,'Name','ControlLower');

    pirelab.getBitSliceComp(mirrorNet,PingPongControl,controlUpper,1,1);
    pirelab.getBitSliceComp(mirrorNet,PingPongControl,controlLower,0,0);





    mirrorFIFONet=this.elaborateMirrorFIFO(mirrorNet,blockInfo,sigInfo,inRate);


    pushFIFO1REG=mirrorNet.addSignal2('Type',boolType,'Name','pushFIFO1');
    pushFIFO1=mirrorNet.addSignal2('Type',boolType,'Name','pushFIFO1');
    popFIFO1=mirrorNet.addSignal2('Type',boolType,'Name','popFIFO1');
    popFIFO1REG=mirrorNet.addSignal2('Type',boolType,'Name','popFIFO1');
    pushFIFO2=mirrorNet.addSignal2('Type',boolType,'Name','pushFIFO2');
    pushFIFO2S=mirrorNet.addSignal2('Type',boolType,'Name','pushFIFO2S');
    pushFIFO2REG=mirrorNet.addSignal2('Type',boolType,'Name','pushFIFO2REG');
    popFIFO2=mirrorNet.addSignal2('Type',boolType,'Name','popFIFO2');
    popFIFO2S=mirrorNet.addSignal2('Type',boolType,'Name','popFIFO2S');
    popFIFO2REG=mirrorNet.addSignal2('Type',boolType,'Name','popFIFO2REG');


    pirelab.getLogicComp(mirrorNet,[controlUpper,validIn],pushFIFO1,'and');
    pirelab.getLogicComp(mirrorNet,[pushFIFO2,validIn],pushFIFO2S,'and');
    pirelab.getLogicComp(mirrorNet,[popFIFO2,popFIFO2],popFIFO2S,'and');
    pirelab.getLogicComp(mirrorNet,[controlLower,controlLower],popFIFO1,'and');

    pirelab.getUnitDelayComp(mirrorNet,popFIFO2,popFIFO2REG);
    pirelab.getUnitDelayComp(mirrorNet,pushFIFO2S,pushFIFO2REG);
    PingFIFOIn=[dataIn,hStartIn,pushFIFO2REG,popFIFO2REG,modK];
    PingFIFOOut=mirrorNet.addSignal2('Type',inType,'Name','PingFIFOOut');
    PingFIFO=pirelab.instantiateNetwork(mirrorNet,mirrorFIFONet,PingFIFOIn,PingFIFOOut,'PingFIFO');
    PingFIFO.addComment('Ping FIFO');




    pirelab.getLogicComp(mirrorNet,pushFIFO1,pushFIFO2,'not');
    pirelab.getLogicComp(mirrorNet,popFIFO1,popFIFO2,'not');

    pirelab.getUnitDelayComp(mirrorNet,pushFIFO1,pushFIFO1REG);
    pirelab.getUnitDelayComp(mirrorNet,popFIFO1,popFIFO1REG);
    PongFIFOIn=[dataIn,hStartIn,pushFIFO1REG,popFIFO1REG,modK];
    PongFIFOOut=mirrorNet.addSignal2('Type',inType,'Name','PongFIFOOut');
    PongFIFO=pirelab.instantiateNetwork(mirrorNet,mirrorFIFONet,PongFIFOIn,PongFIFOOut,'PongFIFO');
    PongFIFO.addComment('Pong FIFO');



    outputSELREG=mirrorNet.addSignal2('Type',boolType,'Name','outputSELREG');



    pirelab.getIntDelayComp(mirrorNet,controlLower,outputSELREG,3);
    pirelab.getSwitchComp(mirrorNet,[PingFIFOOut,PongFIFOOut],dataOut,outputSELREG);




















