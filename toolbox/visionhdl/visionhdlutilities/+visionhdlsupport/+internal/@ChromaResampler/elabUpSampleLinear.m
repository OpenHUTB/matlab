function UpLinearNet=elabUpSampleLinear(~,topNet,blockInfo,dataRate)






    inportnames={'YIn','CbIn','CrIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    outportnames={'YOut','CbOut','CrOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};


    insignals=topNet.PirInputSignals;
    pixelIn=insignals(1);
    pixelInSplit=pixelIn.split;
    dataType=pixelInSplit.PirOutputSignal(1).Type;

    ctrlType=pir_boolean_t();
    UpLinearNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LinearInterpolation',...
    'InportNames',inportnames,...
    'InportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);

    adderOutType=UpLinearNet.getType('FixedPoint',...
    'Signed',false,...
    'WordLength',dataType.WordLength+1,...
    'FractionLength',dataType.FractionLength);


    YIn=UpLinearNet.PirInputSignals(1);
    CbIn=UpLinearNet.PirInputSignals(2);
    CrIn=UpLinearNet.PirInputSignals(3);
    hStartIn=UpLinearNet.PirInputSignals(4);
    hEndIn=UpLinearNet.PirInputSignals(5);
    vStartIn=UpLinearNet.PirInputSignals(6);
    vEndIn=UpLinearNet.PirInputSignals(7);
    validIn=UpLinearNet.PirInputSignals(8);

    YOut=UpLinearNet.PirOutputSignals(1);
    CbOut=UpLinearNet.PirOutputSignals(2);
    CrOut=UpLinearNet.PirOutputSignals(3);
    hStartOut=UpLinearNet.PirOutputSignals(4);
    hEndOut=UpLinearNet.PirOutputSignals(5);
    vStartOut=UpLinearNet.PirOutputSignals(6);
    vEndOut=UpLinearNet.PirOutputSignals(7);
    validOut=UpLinearNet.PirOutputSignals(8);


    validInReg=UpLinearNet.addSignal(ctrlType,'validInReg');
    pirelab.getUnitDelayComp(UpLinearNet,validIn,validInReg);
    pirelab.getUnitDelayComp(UpLinearNet,validInReg,validOut);

    validInNotReg=UpLinearNet.addSignal(ctrlType,'validInNotReg');
    pirelab.getLogicComp(UpLinearNet,validInReg,validInNotReg,'not');

    CounterEn=UpLinearNet.addSignal(ctrlType,'CounterEnable');
    pirelab.getLogicComp(UpLinearNet,[hStartIn,validOut],CounterEn,'or');

    valitOutNot=UpLinearNet.addSignal(ctrlType,'valitOutNot');
    pirelab.getLogicComp(UpLinearNet,validOut,valitOutNot,'not');
    CounterIn=UpLinearNet.addSignal(ctrlType,'CounterInput');
    CounterNotSig=UpLinearNet.addSignal(ctrlType,'CounterNot');
    pirelab.getSwitchComp(UpLinearNet,[CounterNotSig,valitOutNot],CounterIn,hStartIn);


    CounterOut=UpLinearNet.addSignal(ctrlType,'CounterOutput');

    pirelab.getUnitDelayEnabledComp(UpLinearNet,CounterIn,CounterOut,CounterEn,...
    'Counter',true,'',false);
    sel1=UpLinearNet.addSignal(ctrlType,'sel1');
    pirelab.getLogicComp(UpLinearNet,[CounterOut,hStartIn],sel1,'or');

    pirelab.getLogicComp(UpLinearNet,CounterOut,CounterNotSig,'not');

    sel2=UpLinearNet.addSignal(ctrlType,'sel2');
    pirelab.getLogicComp(UpLinearNet,[validIn,validInNotReg,validOut],sel2,'and');


    CbPre=UpLinearNet.addSignal(dataType,'CbPre');
    pirelab.getUnitDelayEnabledComp(UpLinearNet,CbIn,CbPre,validIn);

    CbaddOutSig=UpLinearNet.addSignal(adderOutType,'CbAddOut');
    pirelab.getAddComp(UpLinearNet,[CbIn,CbPre],CbaddOutSig);

    CbaddOutSigF=UpLinearNet.addSignal(adderOutType,'CbAddOutF');
    if(strcmp(blockInfo.RoundingMethod,'Floor')||...
        strcmp(blockInfo.RoundingMethod,'Zero')||...
        strcmp(blockInfo.RoundingMethod,'Convergent'))
        pirelab.getWireComp(UpLinearNet,CbaddOutSig,CbaddOutSigF);
    else
        adderOut11Type=UpLinearNet.getType('FixedPoint',...
        'Signed',false,...
        'WordLength',dataType.WordLength+2,...
        'FractionLength',dataType.FractionLength);
        Offset=UpLinearNet.addSignal(dataType,'Offset');
        pirelab.getConstComp(UpLinearNet,Offset,1);
        CbaddOutSigTemp=UpLinearNet.addSignal(adderOut11Type,'CbAddOut');
        pirelab.getAddComp(UpLinearNet,[CbaddOutSig,Offset],CbaddOutSigTemp);
        pirelab.getBitSliceComp(UpLinearNet,CbaddOutSigTemp,CbaddOutSigF,dataType.WordLength,0);
    end

    CbshiftOut=UpLinearNet.addSignal(adderOutType,'CbShiftOut');
    pirelab.getBitShiftComp(UpLinearNet,CbaddOutSigF,CbshiftOut,'srl',1);
    CbMean=UpLinearNet.addSignal(dataType,'CbMean');
    pirelab.getDTCComp(UpLinearNet,CbshiftOut,CbMean,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    SW1_0=UpLinearNet.addSignal(dataType,'SW1_0');
    pirelab.getUnitDelayEnabledComp(UpLinearNet,CbMean,SW1_0,validIn);

    SW2_0=UpLinearNet.addSignal(dataType,'SW2_0');
    pirelab.getSwitchComp(UpLinearNet,[SW1_0,CbPre],SW2_0,sel1);
    pirelab.getSwitchComp(UpLinearNet,[SW2_0,CbMean],CbOut,sel2);


    CrPre=UpLinearNet.addSignal(dataType,'CrPre');
    pirelab.getUnitDelayEnabledComp(UpLinearNet,CrIn,CrPre,validIn);

    CraddOutSig=UpLinearNet.addSignal(adderOutType,'CrAddOut');
    pirelab.getAddComp(UpLinearNet,[CrIn,CrPre],CraddOutSig);

    CraddOutSigF=UpLinearNet.addSignal(adderOutType,'CrAddOutF');
    if(strcmp(blockInfo.RoundingMethod,'Floor')||...
        strcmp(blockInfo.RoundingMethod,'Zero')||...
        strcmp(blockInfo.RoundingMethod,'Convergent'))
        pirelab.getWireComp(UpLinearNet,CraddOutSig,CraddOutSigF);
    else
        CraddOutSigTemp=UpLinearNet.addSignal(adderOut11Type,'CrAddOut');
        pirelab.getAddComp(UpLinearNet,[CraddOutSig,Offset],CraddOutSigTemp);
        pirelab.getBitSliceComp(UpLinearNet,CraddOutSigTemp,CraddOutSigF,dataType.WordLength,0);
    end

    CrshiftOut=UpLinearNet.addSignal(adderOutType,'CrShiftOut');
    pirelab.getBitShiftComp(UpLinearNet,CraddOutSigF,CrshiftOut,'srl',1);

    CrMean=UpLinearNet.addSignal(dataType,'CrMean');
    pirelab.getDTCComp(UpLinearNet,CrshiftOut,CrMean,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);

    SW3_0=UpLinearNet.addSignal(dataType,'SW3_0');
    pirelab.getUnitDelayEnabledComp(UpLinearNet,CrMean,SW3_0,validIn);

    SW4_0=UpLinearNet.addSignal(dataType,'SW4_0');
    pirelab.getSwitchComp(UpLinearNet,[SW3_0,CrPre],SW4_0,sel1);
    pirelab.getSwitchComp(UpLinearNet,[SW4_0,CrMean],CrOut,sel2);


    regcomp=pirelab.getIntDelayComp(UpLinearNet,YIn,YOut,2,'Y');
    regcomp.addComment('delay YIn');
    regcomp=pirelab.getIntDelayComp(UpLinearNet,hStartIn,hStartOut,2,'hStart');
    regcomp.addComment('delay hStartIn');
    regcomp=pirelab.getIntDelayComp(UpLinearNet,hEndIn,hEndOut,2,'hEnd');
    regcomp.addComment('delay hEndIn');
    regcomp=pirelab.getIntDelayComp(UpLinearNet,vStartIn,vStartOut,2,'vStart');
    regcomp.addComment('delay vStartIn');
    regcomp=pirelab.getIntDelayComp(UpLinearNet,vEndIn,vEndOut,2,'vEnd');
    regcomp.addComment('delay vEndIn');


