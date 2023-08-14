function pushPopNet=elaboratePushPopCounter(~,topNet,blockInfo,sigInfo,dataRate)





    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    lineStartT=sigInfo.lineStartT;
    countT=sigInfo.countT;


    inPortNames={'hStartIn','popIn','popEnable','hEndIn','writeCountPrev'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT,countT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'wrAddr','pushOut','rdAddr','popOut','EndofLine'};
    outPortTypes=[countT,booleanT,countT,booleanT,booleanT];



    pushPopNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PushPopCounter',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=pushPopNet.PirInputSignals;
    hStartIn=inSignals(1);
    popIn=inSignals(2);
    popEn=inSignals(3);
    hEndIn=inSignals(4);
    writeCountPrev=inSignals(5);

    outSignals=pushPopNet.PirOutputSignals;
    wrAddr=outSignals(1);
    pushOut=outSignals(2);
    rdAddr=outSignals(3);
    popOut=outSignals(4);
    endOfLine=outSignals(5);

    writeCount=pushPopNet.addSignal2('Type',countT,'Name','writeCount');
    writeCountCurrent=pushPopNet.addSignal2('Type',countT,'Name','writeCountCurrent');
    writeCountNext=pushPopNet.addSignal2('Type',countT,'Name','writeCountNext');
    readCount=pushPopNet.addSignal2('Type',countT,'Name','readCount');
    readCountAhead=pushPopNet.addSignal2('Type',countT,'Name','readCountAhead');
    constantTwo=pushPopNet.addSignal2('Type',countT,'Name','constantTwo');
    readCountCompare=pushPopNet.addSignal2('Type',countT,'Name','readCountCompare');

    popTerm1=pushPopNet.addSignal2('Type',booleanT,'Name','popTerm1');
    popTerm2=pushPopNet.addSignal2('Type',booleanT,'Name','popTerm2');
    InBetween=pushPopNet.addSignal2('Type',booleanT,'Name','InBetween');
    InBetweenEn=pushPopNet.addSignal2('Type',booleanT,'Name','InBetweenEn');
    InBetweenRegIn=pushPopNet.addSignal2('Type',booleanT,'Name','InBetweenRegIn');
    ConstantZero=pushPopNet.addSignal2('Type',booleanT,'Name','ConstantZero');
    popContinue=pushPopNet.addSignal2('Type',booleanT,'Name','popContinue');
    popCounter=pushPopNet.addSignal2('Type',booleanT,'Name','popCounter');
    writeStoreEn=pushPopNet.addSignal2('Type',booleanT,'Name','writeStoreEn');
    writeContinue=pushPopNet.addSignal2('Type',booleanT,'Name','writeContinue');
    writeContinueP=pushPopNet.addSignal2('Type',booleanT,'Name','writeContinueP');
    writeEN=pushPopNet.addSignal2('Type',booleanT,'Name','writeEN');
    writePrevREG=pushPopNet.addSignal2('Type',countT,'Name','writePrevREG');






    pirelab.getUnitDelayEnabledComp(pushPopNet,writeCountPrev,writePrevREG,hStartIn);
    pirelab.getRelOpComp(pushPopNet,[writeCount,writePrevREG],writeContinueP,'<=');
    pirelab.getLogicComp(pushPopNet,[writeContinueP,InBetween],writeContinue,'and');
    pirelab.getLogicComp(pushPopNet,[writeContinue,popIn],writeEN,'or');
    pirelab.getCounterComp(pushPopNet,[hStartIn,writeEN],writeCount,'Free running',...
    0,1,[],true,false,true,false,'Write Count',0);
    pirelab.getWireComp(pushPopNet,writeCount,wrAddr);
    pirelab.getIntDelayComp(pushPopNet,hEndIn,writeStoreEn,2);
    pirelab.getUnitDelayEnabledComp(pushPopNet,writeCount,writeCountNext,writeStoreEn);
    pirelab.getUnitDelayEnabledComp(pushPopNet,writeCountNext,writeCountCurrent,hStartIn);
    pirelab.getRelOpComp(pushPopNet,[readCount,writeCountCurrent],popContinue,'<');




    readResetTerm=pushPopNet.addSignal2('Type',booleanT,'Name','readResetTerm');
    readReset=pushPopNet.addSignal2('Type',booleanT,'Name','readReset');
    pirelab.getRelOpComp(pushPopNet,[readCount,writeCountCurrent],readResetTerm,'==');
    pirelab.getLogicComp(pushPopNet,[writeEN,readResetTerm],readReset,'and');



    startOrEnd=pushPopNet.addSignal2('Type',booleanT,'Name','startOrEnd');
    pirelab.getLogicComp(pushPopNet,[hStartIn,readReset],startOrEnd,'or');
    readPop=pushPopNet.addSignal2('Type',booleanT,'Name','readPop');
    popcountless=pushPopNet.addSignal2('Type',booleanT,'Name','popcountless');


    pirelab.getUnitDelayEnabledResettableComp(pushPopNet,hStartIn,readPop,hStartIn,readReset,'readResetREG',0,'',true,'',-1,true);
    pirelab.getLogicComp(pushPopNet,[popContinue,readPop,popCounter],popcountless,'and');



    pirelab.getCounterComp(pushPopNet,[startOrEnd,popcountless],readCount,'Free running',...
    0,1,[],true,false,true,false,'Read Count',(2^countT.WordLength)-2);

    pirelab.getLogicComp(pushPopNet,[popEn,popContinue],readCountCompare,'and');
    pirelab.getLogicComp(pushPopNet,[popIn,readCountCompare],popTerm1,'and');
    pirelab.getConstComp(pushPopNet,ConstantZero,0);
    pirelab.getSwitchComp(pushPopNet,[hEndIn,ConstantZero],InBetweenRegIn,hStartIn);
    pirelab.getLogicComp(pushPopNet,[hStartIn,hEndIn],InBetweenEn,'or');
    pirelab.getUnitDelayEnabledComp(pushPopNet,InBetweenRegIn,InBetween,InBetweenEn);
    pirelab.getLogicComp(pushPopNet,[readCountCompare,InBetween],popTerm2,'and');
    pirelab.getLogicComp(pushPopNet,[popTerm1,popTerm2],popCounter,'or');


    pirelab.getWireComp(pushPopNet,writeEN,pushOut);
    pirelab.getWireComp(pushPopNet,readCount,rdAddr);
    pirelab.getWireComp(pushPopNet,popCounter,popOut);
    pirelab.getConstComp(pushPopNet,constantTwo,5);
    pirelab.getAddComp(pushPopNet,[readCount,constantTwo],readCountAhead,'Floor','Wrap');
    pirelab.getRelOpComp(pushPopNet,[readCountAhead,writeCountCurrent],endOfLine,'==');

