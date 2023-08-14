function pushPopOneNet=elaboratePushPopCounterOne(~,topNet,blockInfo,sigInfo,dataRate)





    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;
    countT=sigInfo.countT;


    inPortNames={'hStartIn','popIn','popEnable','hEndIn'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate];
    outPortNames={'wrAddr','pushOut','rdAddr','popOut','EndofLine'};
    outPortTypes=[countT,booleanT,countT,booleanT,booleanT];



    pushPopOneNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PushPopCounterOne',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=pushPopOneNet.PirInputSignals;
    hStartIn=inSignals(1);
    popIn=inSignals(2);
    popEn=inSignals(3);
    hEndIn=inSignals(4);


    outSignals=pushPopOneNet.PirOutputSignals;
    wrAddr=outSignals(1);
    pushOut=outSignals(2);
    rdAddr=outSignals(3);
    popOut=outSignals(4);
    endOfLine=outSignals(5);

    writeCount=pushPopOneNet.addSignal2('Type',countT,'Name','writeCount');
    writeCountCurrent=pushPopOneNet.addSignal2('Type',countT,'Name','writeCountCurrent');
    writeCountNext=pushPopOneNet.addSignal2('Type',countT,'Name','writeCountNext');
    readCount=pushPopOneNet.addSignal2('Type',countT,'Name','readCount');
    readCountAhead=pushPopOneNet.addSignal2('Type',countT,'Name','readCountAhead');
    constantTwo=pushPopOneNet.addSignal2('Type',countT,'Name','constantTwo');
    readCountCompare=pushPopOneNet.addSignal2('Type',booleanT,'Name','readCountCompare');
    readCountCompare.SimulinkRate=dataRate;

    popTerm1=pushPopOneNet.addSignal2('Type',booleanT,'Name','popTerm1');
    popTerm2=pushPopOneNet.addSignal2('Type',booleanT,'Name','popTerm2');
    InBetween=pushPopOneNet.addSignal2('Type',booleanT,'Name','InBetween');
    InBetweenEn=pushPopOneNet.addSignal2('Type',booleanT,'Name','InBetweenEn');
    InBetweenRegIn=pushPopOneNet.addSignal2('Type',booleanT,'Name','InBetweenRegIn');
    ConstantZero=pushPopOneNet.addSignal2('Type',booleanT,'Name','ConstantZero');
    popContinue=pushPopOneNet.addSignal2('Type',booleanT,'Name','popContinue');
    popContinueP=pushPopOneNet.addSignal2('Type',booleanT,'Name','popContinueP');
    popCounter=pushPopOneNet.addSignal2('Type',booleanT,'Name','popCounter');
    writeStoreEn=pushPopOneNet.addSignal2('Type',booleanT,'Name','writeStoreEn');


    pirelab.getCounterComp(pushPopOneNet,[hStartIn,popIn],writeCount,'Free running',...
    0,1,[],true,false,true,false,'Write Count',0);
    pirelab.getWireComp(pushPopOneNet,writeCount,wrAddr);
    pirelab.getIntDelayComp(pushPopOneNet,hEndIn,writeStoreEn,2);
    pirelab.getUnitDelayEnabledComp(pushPopOneNet,writeCount,writeCountNext,writeStoreEn);
    pirelab.getUnitDelayEnabledComp(pushPopOneNet,writeCountNext,writeCountCurrent,hStartIn);
    pirelab.getRelOpComp(pushPopOneNet,[readCount,writeCountCurrent],popContinue,'<');






    readReset=pushPopOneNet.addSignal2('Type',booleanT,'Name','readReset');
    readResetTerm1=pushPopOneNet.addSignal2('Type',booleanT,'Name','readReset');
    readResetTerm2=pushPopOneNet.addSignal2('Type',booleanT,'Name','readReset');

    pirelab.getRelOpComp(pushPopOneNet,[readCount,writeCountCurrent],readResetTerm1,'==');
    pirelab.getLogicComp(pushPopOneNet,hStartIn,readResetTerm2,'not');
    pirelab.getLogicComp(pushPopOneNet,[readResetTerm1,readResetTerm2,popIn],readReset,'and');


    startOrEnd=pushPopOneNet.addSignal2('Type',booleanT,'Name','startOrEnd');
    pirelab.getLogicComp(pushPopOneNet,[hStartIn,readReset],startOrEnd,'or');
    readPop=pushPopOneNet.addSignal2('Type',booleanT,'Name','readPop');
    popcountless=pushPopOneNet.addSignal2('Type',booleanT,'Name','popcountless');


    pirelab.getUnitDelayEnabledResettableComp(pushPopOneNet,hStartIn,readPop,hStartIn,readReset,'readResetREG',0,'',true,'',-1,true);
    pirelab.getLogicComp(pushPopOneNet,[popContinue,readPop,popCounter],popcountless,'and');



    pirelab.getCounterComp(pushPopOneNet,[startOrEnd,popcountless],readCount,'Free running',...
    0,1,[],true,false,true,false,'Read Count',(2^countT.WordLength)-2);

    pirelab.getLogicComp(pushPopOneNet,[popEn,popContinue],readCountCompare,'and');
    pirelab.getLogicComp(pushPopOneNet,[popIn,readCountCompare],popTerm1,'and');
    pirelab.getConstComp(pushPopOneNet,ConstantZero,0);
    pirelab.getSwitchComp(pushPopOneNet,[hEndIn,ConstantZero],InBetweenRegIn,hStartIn);
    pirelab.getLogicComp(pushPopOneNet,[hStartIn,hEndIn],InBetweenEn,'or');
    pirelab.getUnitDelayEnabledComp(pushPopOneNet,InBetweenRegIn,InBetween,InBetweenEn);
    pirelab.getLogicComp(pushPopOneNet,[readCountCompare,InBetween],popTerm2,'and');
    pirelab.getLogicComp(pushPopOneNet,[popTerm1,popTerm2],popCounter,'or');


    pirelab.getWireComp(pushPopOneNet,popIn,pushOut);
    pirelab.getWireComp(pushPopOneNet,readCount,rdAddr);
    pirelab.getWireComp(pushPopOneNet,popCounter,popOut);
    pirelab.getConstComp(pushPopOneNet,constantTwo,5);
    pirelab.getAddComp(pushPopOneNet,[readCount,constantTwo],readCountAhead,'Floor','Wrap');
    pirelab.getRelOpComp(pushPopOneNet,[readCountAhead,writeCountCurrent],endOfLine,'==');

