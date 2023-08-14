function forwardBufferNet=elaborateForwardBufferMax(this,topNet,blockInfo,sigInfo,inRate)











    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    countT=sigInfo.countT;



    inPortNames={'dataIn','dataValid','bufferComplete','hStart'};
    inPortTypes=[inType,boolType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate];
    outPortNames={'dataOut'};
    outPortTypes=inType;


    forwardBufferNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ForwardBufferMax',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    forwardBufferNet.addComment('Forward Maximum Buffer');



    inSignals=forwardBufferNet.PirInputSignals;
    dataIn=inSignals(1);
    dataValid=inSignals(2);
    bufferComplete=inSignals(3);
    hStart=inSignals(4);



    outSignals=forwardBufferNet.PirOutputSignals;
    dataOut=outSignals(1);

    writeCount=forwardBufferNet.addSignal2('Type',countT,'Name','WriteCount');
    pirelab.getCounterComp(forwardBufferNet,[hStart,dataValid],writeCount,'Count limited',0,1,blockInfo.kWidth-1,...
    true,false,true,false,'WriteCounter');

    readCount=forwardBufferNet.addSignal2('Type',countT,'Name','ReadCount');
    pirelab.getCounterComp(forwardBufferNet,[hStart,bufferComplete],readCount,'Count limited',...
    0,1,blockInfo.kWidth-1,true,false,true,false,'ReadCounter');

    pirelab.getSimpleDualPortRamComp(forwardBufferNet,[dataIn,writeCount,dataValid,readCount],...
    dataOut,'ForwardBuffer');




























