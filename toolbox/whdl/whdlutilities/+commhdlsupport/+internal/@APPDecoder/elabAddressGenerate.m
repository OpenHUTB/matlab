function addressGenNet=elabAddressGenerate(~,topNet,blockInfo,datarate)

    inDataRate(1)=datarate;
    inDataRate(2)=datarate;
    inDataRate(3)=datarate;
    inDataRate(4)=datarate;
    inDataRate(5)=datarate;

    inportNames={'validIn','endIn','startIn','endFlag','nextFrame'};
    outportNames={'wrAddr','rdAddr','wrAddrOut','rdAddrOut','wrEnOut','loadSig','nextFrameLowTime','lastWinLenSamp','lastWinLenSampReg','lastWind','rstCounter','startOutReg','wrEnOutBeta'};

    boolType=pir_boolean_t();

    inTypes(1)=pir_ufixpt_t(1,0);
    inTypes(2)=pir_ufixpt_t(1,0);
    inTypes(3)=pir_ufixpt_t(1,0);
    inTypes(4)=pir_ufixpt_t(1,0);
    inTypes(5)=pir_ufixpt_t(1,0);

    outTypes(1)=pir_ufixpt_t(8,0);
    outTypes(2)=pir_ufixpt_t(8,0);
    outTypes(3)=pir_ufixpt_t(8,0);
    outTypes(4)=pir_ufixpt_t(8,0);
    outTypes(5)=pir_ufixpt_t(1,0);
    outTypes(6)=pir_ufixpt_t(1,0);
    outTypes(7)=pir_ufixpt_t(8,0);
    outTypes(8)=pir_ufixpt_t(8,0);
    outTypes(9)=pir_ufixpt_t(8,0);
    outTypes(10)=pir_ufixpt_t(1,0);
    outTypes(11)=pir_ufixpt_t(1,0);
    outTypes(12)=pir_ufixpt_t(1,0);
    outTypes(13)=pir_ufixpt_t(1,0);

    WINDLEN=blockInfo.WindowLength;
    WINDLENM1=WINDLEN-1;
    ALPHASIZEM1=blockInfo.alphaSize-1;

    addressGenNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','AddressGenerateNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    validIn=addressGenNet.PirInputSignals(1);
    endIn=addressGenNet.PirInputSignals(2);
    startIn=addressGenNet.PirInputSignals(3);
    endFlag=addressGenNet.PirInputSignals(4);
    nextFrame=addressGenNet.PirInputSignals(5);

    wrAddr=addressGenNet.PirOutputSignals(1);
    rdAddr=addressGenNet.PirOutputSignals(2);
    wrAddrOut=addressGenNet.PirOutputSignals(3);
    rdAddrOut=addressGenNet.PirOutputSignals(4);
    wrEnOut=addressGenNet.PirOutputSignals(5);
    loadSig=addressGenNet.PirOutputSignals(6);
    nextFrameLowTime=addressGenNet.PirOutputSignals(7);
    lastWinLenSamp=addressGenNet.PirOutputSignals(8);
    lastWinLenSampReg=addressGenNet.PirOutputSignals(9);
    lastWind=addressGenNet.PirOutputSignals(10);
    rstCounter=addressGenNet.PirOutputSignals(11);
    startOutReg=addressGenNet.PirOutputSignals(12);
    wrEnOutBeta=addressGenNet.PirOutputSignals(13);

    count=newDataSignal(addressGenNet,'count',outTypes(1),datarate);
    count1=newDataSignal(addressGenNet,'count1',outTypes(1),datarate);
    countReg=newDataSignal(addressGenNet,'countReg',outTypes(1),datarate);
    countPlus1=newDataSignal(addressGenNet,'countPlus1',outTypes(1),datarate);
    rdAddrVal=newDataSignal(addressGenNet,'rdAddrVal',outTypes(1),datarate);
    rdCount=newDataSignal(addressGenNet,'rdCount',outTypes(1),datarate);
    rdCountRev=newDataSignal(addressGenNet,'rdCountRev',outTypes(1),datarate);
    revCount=newDataSignal(addressGenNet,'revCount',outTypes(1),datarate);
    winLenMinus1=newDataSignal(addressGenNet,'winLenMinus1',outTypes(1),datarate);
    nextFrameLowTimeReg=newDataSignal(addressGenNet,'nextFrameLowTimeReg',outTypes(1),datarate);
    lastWinLenReg=newDataSignal(addressGenNet,'lastWinLenReg',outTypes(1),datarate);
    windMinlastWin=newDataSignal(addressGenNet,'windMinlastWin',outTypes(1),datarate);
    windMinlastWinOut=newDataSignal(addressGenNet,'windMinlastWinOut',outTypes(1),datarate);

    countIsZero=newControlSignal(addressGenNet,'countIsZero',datarate);
    countIsZero1=newControlSignal(addressGenNet,'countIsZero1',datarate);
    countGrWin=newControlSignal(addressGenNet,'countGrWin',datarate);
    delayIn=newControlSignal(addressGenNet,'delayIn',datarate);
    writeRev=newControlSignal(addressGenNet,'writeRev',datarate);
    writeRevReg=newControlSignal(addressGenNet,'writeRevReg',datarate);
    lastWindReg=newControlSignal(addressGenNet,'lastWindReg',datarate);
    lastWindRst=newControlSignal(addressGenNet,'lastWindRst',datarate);
    validIn1=newControlSignal(addressGenNet,'validIn1',datarate);
    countRst=newControlSignal(addressGenNet,'countRst',datarate);
    countRstReg=newControlSignal(addressGenNet,'countRstReg',datarate);
    loadSigNOT=addressGenNet.addSignal(boolType,'loadSigNOT');
    loadSig2=addressGenNet.addSignal(boolType,'loadSig2');
    loadSig3=addressGenNet.addSignal(boolType,'loadSig3');
    oneSig=addressGenNet.addSignal(outTypes(1),'oneSig');
    pirelab.getConstComp(addressGenNet,oneSig,1);
    zeroSig=addressGenNet.addSignal(outTypes(1),'zeroSig');
    pirelab.getConstComp(addressGenNet,zeroSig,0);
    startInReg=newControlSignal(addressGenNet,'startInReg',datarate);
    lastWinLen=addressGenNet.addSignal(outTypes(1),'lastWinLen');

    pirelab.getConstComp(addressGenNet,winLenMinus1,WINDLEN-1);

    pirelab.getLogicComp(addressGenNet,[endFlag,validIn],validIn1,'or');

    pirelab.getCounterComp(addressGenNet,[startIn,oneSig,validIn1],count1,...
    'Count limited',...
    0.0,...
    1.0,...
    WINDLEN-1,...
    false,...
    true,...
    true,...
    false,...
    'InputCounter');

    pirelab.getSwitchComp(addressGenNet,[count1,zeroSig],count,startIn);

    pirelab.getAddComp(addressGenNet,[count,oneSig],countPlus1,'Floor','Wrap','');
    pirelab.getCompareToValueComp(addressGenNet,countPlus1,countGrWin,'>',WINDLENM1);


    pirelab.getSwitchComp(addressGenNet,[countPlus1,zeroSig],countReg,countGrWin);

    pirelab.getSubComp(addressGenNet,[winLenMinus1,count],revCount);

    pirelab.getUnitDelayEnabledComp(addressGenNet,revCount,nextFrameLowTimeReg,endIn,'',0);
    pirelab.getSwitchComp(addressGenNet,[nextFrameLowTimeReg,revCount],nextFrameLowTime,endIn);

    pirelab.getUnitDelayEnabledComp(addressGenNet,count,lastWinLenReg,endIn,'',0);

    pirelab.getWireComp(addressGenNet,lastWinLenReg,lastWinLen);

    pirelab.getCompareToValueComp(addressGenNet,count,countIsZero1,'==',WINDLENM1);

    pirelab.getLogicComp(addressGenNet,[countIsZero1,validIn1],countIsZero,'and');

    pirelab.getUnitDelayEnabledResettableComp(addressGenNet,startIn,startInReg,startIn,countIsZero);

    pirelab.getUnitDelayEnabledComp(addressGenNet,delayIn,writeRev,countIsZero);

    pirelab.getLogicComp(addressGenNet,writeRev,delayIn,'not');

    pirelab.getSwitchComp(addressGenNet,[count,revCount],wrAddr,writeRev);

    pirelab.getUnitDelayComp(addressGenNet,writeRev,writeRevReg);
    pirelab.getLogicComp(addressGenNet,[writeRev,writeRevReg],loadSig,'xor');

    endFlagReg=newControlSignal(addressGenNet,'endFlagReg',datarate);
    pirelab.getIntDelayComp(addressGenNet,endFlag,endFlagReg,1,'',0);

    pirelab.getSubComp(addressGenNet,[winLenMinus1,lastWinLen],windMinlastWin);

    swtchCtrl=newControlSignal(addressGenNet,'swtchCtrl',datarate);
    pirelab.getLogicComp(addressGenNet,[countIsZero,endFlag],swtchCtrl,'and');

    pirelab.getSwitchComp(addressGenNet,[zeroSig,windMinlastWin],rdAddrVal,swtchCtrl);


    pirelab.getCounterComp(addressGenNet,[countIsZero,rdAddrVal],rdCount,...
    'Count limited',...
    0.0,...
    1.0,...
    WINDLEN-1,...
    false,...
    true,...
    false,...
    false,...
    'ReadCounter');

    pirelab.getSubComp(addressGenNet,[winLenMinus1,rdCount],rdCountRev);

    pirelab.getSwitchComp(addressGenNet,[rdCount,rdCountRev],rdAddr,writeRev);

    lastWinLenSamp1=addressGenNet.addSignal(outTypes(1),'lastWinLenSamp1');
    lastWinLenSamp2=addressGenNet.addSignal(outTypes(1),'lastWinLenSamp2');
    outCount=addressGenNet.addSignal(outTypes(1),'outCount');
    outCount1=addressGenNet.addSignal(outTypes(1),'outCount1');
    outCountReg=addressGenNet.addSignal(outTypes(1),'outCountReg');
    outCntEnb=addressGenNet.addSignal(boolType,'outCntEnb');
    outCntEnb1=addressGenNet.addSignal(boolType,'outCntEnb1');
    IsLastSample=newControlSignal(addressGenNet,'IsLastSample',datarate);
    eqFlag=newControlSignal(addressGenNet,'eqFlag',datarate);
    cntRst=newControlSignal(addressGenNet,'cntRst',datarate);
    cntRst1=newControlSignal(addressGenNet,'cntRst1',datarate);
    nextFrameNOT=newControlSignal(addressGenNet,'nextFrameNOT',datarate);
    frameDisc=newControlSignal(addressGenNet,'frameDisc',datarate);
    frameDisc1=newControlSignal(addressGenNet,'frameDisc1',datarate);
    endInReg=newControlSignal(addressGenNet,'endInReg',datarate);
    endFlagNOT=newControlSignal(addressGenNet,'endFlagNOT',datarate);


    pirelab.getLogicComp(addressGenNet,[countRst,eqFlag],countRstReg,'and');

    pirelab.getCounterComp(addressGenNet,[countRstReg,loadSig,zeroSig,outCntEnb],outCount,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    true,...
    true,...
    true,...
    false,...
    'OutputCounter1');

    rstReg=newControlSignal(addressGenNet,'rstReg',datarate);


    pirelab.getCompareToValueComp(addressGenNet,outCount,outCntEnb,'<',WINDLEN);

    pirelab.getCounterComp(addressGenNet,[loadSig,zeroSig,outCntEnb1],outCount1,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    false,...
    true,...
    true,...
    false,...
    'OutputCounter1');

    pirelab.getCompareToValueComp(addressGenNet,outCount1,outCntEnb1,'<',WINDLEN);


    startInReg1=newControlSignal(addressGenNet,'startInReg1',datarate);
    startOutReg1=newControlSignal(addressGenNet,'startOutReg1',datarate);
    startOutReg2=newControlSignal(addressGenNet,'startOutReg2',datarate);
    startOutReg3=newControlSignal(addressGenNet,'startOutReg3',datarate);
    pirelab.getIntDelayComp(addressGenNet,startInReg,startInReg1,2,'',0);

    loadNOT=newControlSignal(addressGenNet,'loadNOT',datarate);
    loadRst=newControlSignal(addressGenNet,'loadRst',datarate);

    pirelab.getLogicComp(addressGenNet,loadSig,loadNOT,'not');
    pirelab.getLogicComp(addressGenNet,[loadSig2,loadNOT],loadRst,'and');

    pirelab.getUnitDelayEnabledResettableComp(addressGenNet,startInReg1,startOutReg1,loadSig,loadRst);
    pirelab.getIntDelayComp(addressGenNet,startOutReg1,startOutReg2,1,'',0);
    pirelab.getUnitDelayEnabledComp(addressGenNet,startOutReg2,startOutReg3,loadSig2);
    pirelab.getIntDelayComp(addressGenNet,startOutReg3,startOutReg,ALPHASIZEM1,'',0);

    pipelines=ALPHASIZEM1+3;

    pirelab.getUnitDelayEnabledComp(addressGenNet,lastWinLen,lastWinLenSamp1,loadSig);
    pirelab.getIntDelayComp(addressGenNet,lastWinLenSamp1,lastWinLenSamp,pipelines,'',0);
    pirelab.getUnitDelayEnabledComp(addressGenNet,lastWinLenSamp1,lastWinLenSamp2,loadSig2);
    pirelab.getIntDelayComp(addressGenNet,lastWinLenSamp2,lastWinLenSampReg,pipelines-1,'',0);

    pirelab.getRelOpComp(addressGenNet,[outCount,lastWinLenSamp1],IsLastSample,'==','');
    pirelab.getCompareToValueComp(addressGenNet,lastWinLenSamp1,eqFlag,'~=',WINDLENM1);

    afterEnd=newControlSignal(addressGenNet,'afterEnd',datarate);
    rstReg1=newControlSignal(addressGenNet,'rstReg1',datarate);

    pirelab.getLogicComp(addressGenNet,[afterEnd,IsLastSample],rstReg1,'and');

    pirelab.getLogicComp(addressGenNet,[rstReg1,loadSigNOT],rstReg,'and');

    pirelab.getIntDelayComp(addressGenNet,endIn,endInReg,1,'',0);

    pirelab.getLogicComp(addressGenNet,endFlag,endFlagNOT,'not');
    pirelab.getLogicComp(addressGenNet,[countRst,endFlagNOT],cntRst,'and');


    pirelab.getLogicComp(addressGenNet,nextFrame,nextFrameNOT,'not');
    pirelab.getLogicComp(addressGenNet,[startIn,nextFrameNOT],frameDisc,'and');
    pirelab.getLogicComp(addressGenNet,[frameDisc,eqFlag],frameDisc1,'and');
    pirelab.getLogicComp(addressGenNet,[cntRst,frameDisc1],cntRst1,'or');


    pirelab.getUnitDelayEnabledResettableComp(addressGenNet,endInReg,afterEnd,endInReg,cntRst1,...
    '',0,'',true);

    pirelab.getLogicComp(addressGenNet,[afterEnd,IsLastSample],countRst,'and');


    lastWindCountEnb=newControlSignal(addressGenNet,'lastWindCountEnb',datarate);
    lastWindCount=addressGenNet.addSignal(outTypes(1),'lastWindCount');
    pirelab.getCounterComp(addressGenNet,[rstReg1,zeroSig,lastWindCountEnb],lastWindCount,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    false,...
    true,...
    true,...
    false,...
    'OutputCounter2');
    pirelab.getCompareToValueComp(addressGenNet,lastWindCount,lastWindCountEnb,'<',WINDLEN);

    pirelab.getLogicComp(addressGenNet,[loadSig,endFlag],lastWindReg,'and');
    pirelab.getLogicComp(addressGenNet,[rstReg1,rstReg1],lastWindRst,'or');


    pirelab.getUnitDelayEnabledResettableComp(addressGenNet,lastWindReg,lastWind,lastWindReg,rstCounter,...
    '',0,'',true);

    pirelab.getLogicComp(addressGenNet,loadSig2,loadSigNOT,'not');
    pirelab.getIntDelayComp(addressGenNet,countRst,rstCounter,pipelines,'',0);

    outCountplus1=addressGenNet.addSignal(outTypes(1),'outCountplus1');
    outCntCtrl=addressGenNet.addSignal(boolType,'outCntCtrl');
    pirelab.getAddComp(addressGenNet,[outCount,oneSig],outCountplus1,'Floor','Wrap','');
    pirelab.getCompareToValueComp(addressGenNet,outCountplus1,outCntCtrl,'>=',WINDLEN);

    pirelab.getSwitchComp(addressGenNet,[outCountplus1,zeroSig],outCountReg,outCntCtrl);


    wrEnOutReg=addressGenNet.addSignal(boolType,'wrEnOutReg');
    pirelab.getWireComp(addressGenNet,outCntEnb,wrEnOutReg);
    pirelab.getIntDelayComp(addressGenNet,wrEnOutReg,wrEnOut,pipelines,'',0);
    pirelab.getIntDelayComp(addressGenNet,wrEnOutReg,wrEnOutBeta,3,'',0);



    pirelab.getCompareToValueComp(addressGenNet,outCount1,loadSig2,'==',WINDLENM1);

    countOut=addressGenNet.addSignal(outTypes(1),'countOut');
    cntOutEnb=addressGenNet.addSignal(boolType,'cntOutEnb');
    pirelab.getCounterComp(addressGenNet,[loadSig,zeroSig,cntOutEnb],countOut,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    false,...
    true,...
    true,...
    false,...
    'OutputCounter2');
    pirelab.getCompareToValueComp(addressGenNet,countOut,cntOutEnb,'<',WINDLEN);
    pirelab.getCompareToValueComp(addressGenNet,countOut,loadSig3,'==',WINDLENM1);



    revoutCount=addressGenNet.addSignal(outTypes(1),'revoutCount');
    pirelab.getSubComp(addressGenNet,[winLenMinus1,outCount],revoutCount);
    delayIn1=addressGenNet.addSignal(boolType,'delayIn1');
    writeRevOut=addressGenNet.addSignal(boolType,'writeRevOut');
    pirelab.getUnitDelayEnabledComp(addressGenNet,delayIn1,writeRevOut,loadSig3);
    pirelab.getLogicComp(addressGenNet,writeRevOut,delayIn1,'not');


    writeRevOutReg=addressGenNet.addSignal(boolType,'writeRevOutReg');
    pirelab.getUnitDelayComp(addressGenNet,writeRevOut,writeRevOutReg);
    wrAddrOutReg=addressGenNet.addSignal(outTypes(1),'wrAddrOutReg');
    pirelab.getSwitchComp(addressGenNet,[outCount,revoutCount],wrAddrOutReg,writeRevOut);
    pirelab.getIntDelayComp(addressGenNet,wrAddrOutReg,wrAddrOut,pipelines,'',0);

    rdoutCount=addressGenNet.addSignal(outTypes(1),'rdoutCount');
    rdoutCountRev=addressGenNet.addSignal(outTypes(1),'rdoutCountRev');
    rdAddrOutVal=addressGenNet.addSignal(outTypes(1),'rdAddrOutVal');
    lastWinLenOut=addressGenNet.addSignal(outTypes(1),'lastWinLenOut');

    swtchCtrlOut=addressGenNet.addSignal(boolType,'swtchCtrlOut');
    pirelab.getLogicComp(addressGenNet,[loadSig3,outCntEnb],swtchCtrlOut,'and');

    pirelab.getUnitDelayEnabledComp(addressGenNet,lastWinLen,lastWinLenOut,countRst);

    pirelab.getSubComp(addressGenNet,[winLenMinus1,lastWinLenOut],windMinlastWinOut);
    pirelab.getSwitchComp(addressGenNet,[windMinlastWinOut,zeroSig],rdAddrOutVal,swtchCtrlOut);


    pirelab.getCounterComp(addressGenNet,[loadSig3,rdAddrOutVal],rdoutCount,...
    'Count limited',...
    0.0,...
    1.0,...
    WINDLEN-1,...
    false,...
    true,...
    false,...
    false,...
    'ReadCounter2');

    pirelab.getSubComp(addressGenNet,[winLenMinus1,rdoutCount],rdoutCountRev);

    rdAddrOutReg=addressGenNet.addSignal(outTypes(1),'rdAddrOutReg');
    pirelab.getSwitchComp(addressGenNet,[rdoutCount,rdoutCountRev],rdAddrOutReg,writeRevOut);
    pirelab.getIntDelayComp(addressGenNet,rdAddrOutReg,rdAddrOut,pipelines,'',0);



    function signal=newControlSignal(addressGenNet,name,rate)
        controlType=pir_ufixpt_t(1,0);
        signal=addressGenNet.addSignal(controlType,name);
        signal.SimulinkRate=rate;
    end

    function signal=newDataSignal(addressGenNet,name,inType,rate)
        signal=addressGenNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end

end
