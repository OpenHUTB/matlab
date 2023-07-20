function FIFONet=elaborateMirrorFIFO(~,topNet,blockInfo,sigInfo,inRate)











    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    countT=sigInfo.countT;



    inPortNames={'dataIn','reset','push','pop','ModK'};
    inPortTypes=[inType,boolType,boolType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate,inRate];
    outPortNames={'dataOut'};
    outPortTypes=inType;


    FIFONet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MirrorFIFO',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    FIFONet.addComment('Mirror FIFO - Buffer Up K Samples and Output in Reversed Order');



    inSignals=FIFONet.PirInputSignals;
    dataIn=inSignals(1);
    reset=inSignals(2);
    pushFIFO=inSignals(3);
    popFIFO=inSignals(4);
    modK=inSignals(5);


    outSignals=FIFONet.PirOutputSignals;
    dataOut=outSignals(1);


    resetREG=FIFONet.addSignal2('Type',boolType,'Name','resetREG');
    pirelab.getUnitDelayComp(FIFONet,reset,resetREG);


    countEnable=FIFONet.addSignal2('Type',boolType,'Name','CountEnable');
    countEnableGate=FIFONet.addSignal2('Type',boolType,'Name','CountEnableGate');
    countEnableGateT=FIFONet.addSignal2('Type',boolType,'Name','CountEnableGateT');
    limit=FIFONet.addSignal2('Type',boolType,'Name','CountEnableGateT');
    lessThan=FIFONet.addSignal2('Type',boolType,'Name','lessThan');
    moreThan=FIFONet.addSignal2('Type',boolType,'Name','lessThan');
    notPush=FIFONet.addSignal2('Type',boolType,'Name','lessThan');
    counterOut=FIFONet.addSignal2('Type',countT,'Name','MirrorCounter');
    pirelab.getCompareToValueComp(FIFONet,counterOut,lessThan,'<',blockInfo.kWidth-1);
    pirelab.getCompareToValueComp(FIFONet,counterOut,moreThan,'>',0);
    pirelab.getLogicComp(FIFONet,[moreThan,popFIFO],countEnable,'and');
    pirelab.getLogicComp(FIFONet,[lessThan,pushFIFO],limit,'and');
    pirelab.getLogicComp(FIFONet,[countEnable,limit],countEnableGate,'or');

    if floor(log2(blockInfo.kWidth))==log2(blockInfo.kWidth)
        pirelab.getCounterComp(FIFONet,[resetREG,countEnableGate,pushFIFO],counterOut,'Count limited',0,1,...
        blockInfo.kWidth-1,true,false,true,true);
    else
        pirelab.getCounterComp(FIFONet,[resetREG,countEnableGate,pushFIFO],counterOut,'Count limited',0,1,...
        blockInfo.kWidth,true,false,true,true);
    end

    dataRAMOut=FIFONet.addSignal2('Type',inType,'Name','DataRAMOut');


    pirelab.getSinglePortRamComp(FIFONet,[dataIn,counterOut,pushFIFO],dataRAMOut);
    dataRAMOut.SimulinkRate=inRate;



    popDelay=FIFONet.addSignal2('Type',boolType,'Name','PopDelay');
    modKREG=FIFONet.addSignal2('Type',boolType,'Name','ModKREG');

    resetDelay=FIFONet.addSignal2('Type',boolType,'Name','ResetDelay');
    outputEnable=FIFONet.addSignal2('Type',boolType,'Name','OutputEnable');


    pirelab.getUnitDelayComp(FIFONet,popFIFO,popDelay);
    pirelab.getUnitDelayComp(FIFONet,modK,modKREG);
    pirelab.getIntDelayComp(FIFONet,reset,resetDelay,3);
    pirelab.getLogicComp(FIFONet,[popDelay,modKREG],outputEnable,'and');

    dataEnableOut=FIFONet.addSignal2('Type',inType,'Name','DataEnableOut');
    outputLow=FIFONet.addSignal2('Type',inType,'Name','OutputLow');
    outputLow.SimulinkRate=inRate;
    pirelab.getConstComp(FIFONet,outputLow,0);

    pirelab.getUnitDelayEnabledResettableComp(FIFONet,dataRAMOut,dataEnableOut,outputEnable,resetDelay,'OutputRegister');

    pirelab.getSwitchComp(FIFONet,[dataEnableOut,outputLow],dataOut,resetDelay);






