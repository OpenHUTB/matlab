function memUnitNet=elaborateMemUnit(~,topNet,blockInfo,dataRate)


    WINDLEN=blockInfo.WindowLength;
    WINDLENM1=WINDLEN-1;
    WORDLEN=blockInfo.wordSize;
    FRACLEN=blockInfo.fracSize;
    VECLEN=blockInfo.vecSize;
    ALPHASIZE=blockInfo.alphaSize;
    BIT0IND=blockInfo.bit0indices;
    BIT1IND=blockInfo.bit1indices;

    DELAYLEN=1;
    K=blockInfo.ConstrLen;
    INPWL=WORDLEN+floor(log2(VECLEN))+floor(log2(K-1))+2;
    OUTWL=INPWL;

    boolType=pir_boolean_t();
    inDataType=pir_sfixpt_t(OUTWL,FRACLEN);
    inVecType=pirelab.getPirVectorType(inDataType,2^VECLEN);
    outDataType=pir_sfixpt_t(OUTWL,FRACLEN);
    outVecType=pirelab.getPirVectorType(outDataType,ALPHASIZE);
    addrType=pir_ufixpt_t(8,0);



    inportNames={'gamma0','gamma1','alphaPrev0','alphaPrev1','wrAddr','validOutG','validOutA','rdAddr'};
    inTypes=[inVecType,inVecType,outVecType,outVecType,addrType,boolType,boolType,addrType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'gamma0RAM','gamma1RAM','alpha0RAM','alpha1RAM','validOut'};
    outTypes=[inVecType,inVecType,outVecType,outVecType,boolType];

    memUnitNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','memUnitNetwork',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    gamma0=memUnitNet.PirInputSignals(1);
    gamma1=memUnitNet.PirInputSignals(2);
    alphaPrev0=memUnitNet.PirInputSignals(3);
    alphaPrev1=memUnitNet.PirInputSignals(4);
    wrAddr=memUnitNet.PirInputSignals(5);
    validOutG=memUnitNet.PirInputSignals(6);
    validOutA=memUnitNet.PirInputSignals(7);
    rdAddr=memUnitNet.PirInputSignals(8);


    gamma0RAM=memUnitNet.PirOutputSignals(1);
    gamma1RAM=memUnitNet.PirOutputSignals(2);
    alpha0RAM=memUnitNet.PirOutputSignals(3);
    alpha1RAM=memUnitNet.PirOutputSignals(4);
    validOut=memUnitNet.PirOutputSignals(5);

    wrAddrDel=newDataSignal(memUnitNet,'wrAddrDel',addrType,dataRate);
    wrAddrDel1=newDataSignal(memUnitNet,'wrAddrDel1',addrType,dataRate);
    rdAddrDel=newDataSignal(memUnitNet,'rdAddrDel',addrType,dataRate);
    rdAddrDel1=newDataSignal(memUnitNet,'rdAddrDel1',addrType,dataRate);

    pirelab.getIntDelayComp(memUnitNet,wrAddr,wrAddrDel,DELAYLEN+2,'wrAddr_register',0);
    pirelab.getIntDelayComp(memUnitNet,rdAddr,rdAddrDel,DELAYLEN+2,'rdAddr_register',0);
    pirelab.getIntDelayComp(memUnitNet,wrAddrDel,wrAddrDel1,0,'wrAddr_register_forAlpha',0);
    pirelab.getIntDelayComp(memUnitNet,rdAddrDel,rdAddrDel1,0,'rdAddr_register_forAlpha',0);



    ramcomp1=pirelab.getSimpleDualPortRamComp(memUnitNet,[gamma0,wrAddrDel,validOutG,rdAddrDel],...
    gamma0RAM,'RAM for gamma0',2^VECLEN,-1,[],'','','none');
    ramcomp1.addComment('simple dualport RAM');

    ramcomp2=pirelab.getSimpleDualPortRamComp(memUnitNet,[gamma1,wrAddrDel,validOutG,rdAddrDel],...
    gamma1RAM,'RAM for gamma1',2^VECLEN,-1,[],'','','none');
    ramcomp2.addComment('simple dualport RAM');

    ramcomp3=pirelab.getSimpleDualPortRamComp(memUnitNet,[alphaPrev0,wrAddrDel1,validOutA,rdAddrDel1],...
    alpha0RAM,'RAM for alpha0',ALPHASIZE,-1,[],'','','none');
    ramcomp3.addComment('simple dualport RAM');

    ramcomp4=pirelab.getSimpleDualPortRamComp(memUnitNet,[alphaPrev1,wrAddrDel1,validOutA,rdAddrDel1],...
    alpha1RAM,'RAM for alpha1',ALPHASIZE,-1,[],'','','none');
    ramcomp4.addComment('simple dualport RAM');


    count=newDataSignal(memUnitNet,'count',addrType,dataRate);
    pirelab.getCounterComp(memUnitNet,validOutA,count,...
    'Count limited',...
    0.0,...
    1.0,...
    WINDLEN-1,...
    false,...
    false,...
    true,...
    false,...
    'InputCounter');

    loadSig=newControlSignal(memUnitNet,'loadSig',dataRate);
    loadSig1=newControlSignal(memUnitNet,'loadSig1',dataRate);
    loadSigReg=newControlSignal(memUnitNet,'loadSigReg',dataRate);
    loadSigRegN=newControlSignal(memUnitNet,'loadSigRegN',dataRate);
    pirelab.getCompareToValueComp(memUnitNet,count,loadSig,'==',WINDLENM1);
    pirelab.getIntDelayComp(memUnitNet,loadSig,loadSigReg,1,'',0);
    pirelab.getLogicComp(memUnitNet,loadSigReg,loadSigRegN,'not');
    pirelab.getLogicComp(memUnitNet,[loadSig,loadSigRegN],loadSig1,'and');


    outCount=newDataSignal(memUnitNet,'outCount',addrType,dataRate);
    outCntEnb=newControlSignal(memUnitNet,'outCntEnb',dataRate);
    zeroSig=newDataSignal(memUnitNet,'zeroSig',addrType,dataRate);
    pirelab.getConstComp(memUnitNet,zeroSig,0);
    pirelab.getCounterComp(memUnitNet,[loadSig,zeroSig,outCntEnb],outCount,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    false,...
    true,...
    true,...
    false,...
    'OutputCounter1');
    pirelab.getCompareToValueComp(memUnitNet,outCount,outCntEnb,'<',WINDLEN);
    pirelab.getIntDelayComp(memUnitNet,outCntEnb,validOut,1,'OutValidReg',0);

    function signal=newDataSignal(memUnitNet,name,inType,rate)
        signal=memUnitNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end

    function signal=newControlSignal(memUnitNet,name,rate)
        controlType=pir_ufixpt_t(1,0);
        signal=memUnitNet.addSignal(controlType,name);
        signal.SimulinkRate=rate;
    end

end

