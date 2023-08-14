function SGNet=elabPixelFormatter(~,topNet,~,dataRate)







    inportnames={'YIn','CbIn','CrIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    outportnames={'YOut','CbOut','CrOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};


    insignals=topNet.PirInputSignals;
    pixelIn=insignals(1);
    pixelInSplit=pixelIn.split;
    dataType=pixelInSplit.PirOutputSignal(1).Type;

    ctrlType=pir_boolean_t();
    SGNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PixelFormatter',...
    'InportNames',inportnames,...
    'InportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);


    YIn=SGNet.PirInputSignals(1);
    CbIn=SGNet.PirInputSignals(2);
    CrIn=SGNet.PirInputSignals(3);
    hStartIn=SGNet.PirInputSignals(4);
    hEndIn=SGNet.PirInputSignals(5);
    vStartIn=SGNet.PirInputSignals(6);
    vEndIn=SGNet.PirInputSignals(7);
    validIn=SGNet.PirInputSignals(8);

    YOut=SGNet.PirOutputSignals(1);
    CbOut=SGNet.PirOutputSignals(2);
    CrOut=SGNet.PirOutputSignals(3);
    hStartOut=SGNet.PirOutputSignals(4);
    hEndOut=SGNet.PirOutputSignals(5);
    vStartOut=SGNet.PirOutputSignals(6);
    vEndOut=SGNet.PirOutputSignals(7);
    validOut=SGNet.PirOutputSignals(8);


    ResetNext=SGNet.addSignal(ctrlType,'CounterOut');
    pirelab.getLogicComp(SGNet,[hStartIn,validIn],ResetNext,'and');

    CounterSig=SGNet.addSignal(ctrlType,'CounterOut');
    CounterNotSig=SGNet.addSignal(ctrlType,'CounterOutNot');

    CounterEn=SGNet.addSignal(ctrlType,'CounterEnable');
    pirelab.getLogicComp(SGNet,[ResetNext,validIn],CounterEn,'or');

    trueconst=SGNet.addSignal(ctrlType,'consttrue');
    pirelab.getConstComp(SGNet,trueconst,true);
    CounterIn=SGNet.addSignal(ctrlType,'CounterInput');
    pirelab.getSwitchComp(SGNet,[CounterNotSig,trueconst],CounterIn,ResetNext);


    pirelab.getUnitDelayEnabledComp(SGNet,CounterIn,CounterSig,CounterEn,...
    'Counter',true,'',false);
    pirelab.getLogicComp(SGNet,CounterSig,CounterNotSig,'not');

    EnableLatch=SGNet.addSignal(ctrlType,'EnableLatch');
    pirelab.getLogicComp(SGNet,[ResetNext,CounterNotSig],EnableLatch,'or');

    Enable=SGNet.addSignal(ctrlType,'Enable');
    pirelab.getLogicComp(SGNet,[validIn,EnableLatch],Enable,'and');


    CbInReg=SGNet.addSignal(dataType,'CbInReg');
    pirelab.getUnitDelayEnabledComp(SGNet,CbIn,CbInReg,Enable);
    CbOutNext=SGNet.addSignal(dataType,'CbOutNext');
    pirelab.getSwitchComp(SGNet,[CbInReg,CbIn],CbOutNext,EnableLatch);
    pirelab.getUnitDelayComp(SGNet,CbOutNext,CbOut);


    CrInReg=SGNet.addSignal(dataType,'CrInReg');
    pirelab.getUnitDelayEnabledComp(SGNet,CrIn,CrInReg,Enable);
    CrOutNext=SGNet.addSignal(dataType,'CrOutNext');
    pirelab.getSwitchComp(SGNet,[CrInReg,CrIn],CrOutNext,EnableLatch);
    pirelab.getUnitDelayComp(SGNet,CrOutNext,CrOut);


    regcomp=pirelab.getIntDelayComp(SGNet,YIn,YOut,1,'Y');
    regcomp.addComment('delay YIn');
    regcomp=pirelab.getIntDelayComp(SGNet,hStartIn,hStartOut,1,'hStart');
    regcomp.addComment('delay hStartIn');
    regcomp=pirelab.getIntDelayComp(SGNet,hEndIn,hEndOut,1,'hEnd');
    regcomp.addComment('delay hEndIn');
    regcomp=pirelab.getIntDelayComp(SGNet,vStartIn,vStartOut,1,'vStart');
    regcomp.addComment('delay vStartIn');
    regcomp=pirelab.getIntDelayComp(SGNet,vEndIn,vEndOut,1,'vEnd');
    regcomp.addComment('delay vEndIn');
    regcomp=pirelab.getIntDelayComp(SGNet,validIn,validOut,1,'valid');
    regcomp.addComment('delay validIn');


