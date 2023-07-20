function addPipelineInitialSequenceLogic(hN,hInSignals,hOutSignals,pipeline)

    assert(hInSignals.SimulinkRate==hOutSignals.SimulinkRate);
    if(pipeline==0)
        pirelab.getWireComp(hN,hInSignals,hOutSignals);
        return;
    end
    rate=hInSignals.SimulinkRate;
    constIncrType=pir_ufixpt_t(1,0);
    const0OutSig=hN.addSignal(constIncrType,'initconst0');
    const0OutSig.SimulinkRate=rate;
    const1OutSig=hN.addSignal(constIncrType,'initconst1');
    const1OutSig.SimulinkRate=rate;
    incrSig=hN.addSignal(constIncrType,'initincr');
    incrSig.SimulinkRate=rate;
    adderWL=ceil(log2(pipeline+1));
    adderType=pir_ufixpt_t(adderWL,0);
    adderOutSig=hN.addSignal(adderType,'initadder');
    adderOutSig.SimulinkRate=rate;
    delayOutSig=hN.addSignal(adderType,'initstate');
    delayOutSig.SimulinkRate=rate;
    compareOutSig=hN.addSignal(hN.getType('Boolean'),'initcompare');
    compareOutSig.SimulinkRate=rate;
    hConst0=pirelab.getConstComp(hN,const0OutSig,0,'initconst0');
    hConst1=pirelab.getConstComp(hN,const1OutSig,1,'initconst1');
    hSwitchInc=pirelab.getSwitchComp(hN,[const0OutSig,const1OutSig],incrSig,compareOutSig,'initmux','==',1);
    hDelay=pirelab.getIntDelayComp(hN,adderOutSig,delayOutSig,1,'initcounterstate',0);
    hAdder=pirelab.getAddComp(hN,[delayOutSig,incrSig],adderOutSig);
    hCompare=pirelab.getCompareToValueComp(hN,delayOutSig,compareOutSig,'==',pipeline);

    const0VectOutSig=hN.addSignal(hOutSignals.Type,'initconst0vect');
    hConst0Vect=pirelab.getConstComp(hN,const0VectOutSig,0,'initconst0vect');
    hSelSig=compareOutSig;
    hSwitch=pirelab.getSwitchComp(hN,[hInSignals,const0VectOutSig],hOutSignals,hSelSig,'initmux','==',1);



