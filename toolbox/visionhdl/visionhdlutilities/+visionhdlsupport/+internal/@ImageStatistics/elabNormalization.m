function normalNet=elabNormalization(~,topNet,~,sigInfo,dataRate,varFlag)









    lvlFourAccT=sigInfo.lvlFourAccT;
    normalizeT=sigInfo.normalizeT;
    accCountT=sigInfo.accCountT;
    booleanT=sigInfo.booleanT;
    selT=sigInfo.selT;
    tableT=pir_ufixpt_t(18,-17);
    inPortNames={'lvlOneCount','lvlTwoCount','lvlThreeCount','lvlFourCount',...
    'SEL','lvlOneAcc','lvlTwoAcc','lvlThreeAcc','lvlFourAcc','normFlag'};


    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];

    inPortTypes=[accCountT,accCountT,accCountT,accCountT...
    ,selT,lvlFourAccT,lvlFourAccT,lvlFourAccT,lvlFourAccT,booleanT];

    outPortNames={'Normalized'};
    outPortTypes=normalizeT;



    if varFlag==false
        compName='Normalization';
    else
        compName='Normalization_Var';
    end


    normalNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',compName,...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    normalNet.addComment('Time Division Multiplexed Normalization of lvlOne, lvlTwo, lvlThree, lvlFour Accumulation');




    normalCompIn=normalNet.PirInputSignals;


    lvlOneCount=normalCompIn(1);
    lvlTwoCount=normalCompIn(2);
    lvlThreeCount=normalCompIn(3);
    lvlFourCount=normalCompIn(4);
    SEL=normalCompIn(5);
    lvlOneAcc=normalCompIn(6);
    lvlTwoAcc=normalCompIn(7);
    lvlThreeAcc=normalCompIn(8);
    lvlFourAcc=normalCompIn(9);
    normFlag=normalCompIn(10);



    normalCompOut=normalNet.PirOutputSignals;
    normalized=normalCompOut(1);


    accMUXOut=normalNet.addSignal2('Type',lvlFourAccT,'Name','accMUXout','SimulinkRate',dataRate);

    countMUXOut=normalNet.addSignal2('Type',accCountT,'Name','countMUXout','SimulinkRate',dataRate);
    lvlOneCountD=normalNet.addSignal2('Type',accCountT,'Name','lvlOneCountD','SimulinkRate',dataRate);
    lvlTwoCountD=normalNet.addSignal2('Type',accCountT,'Name','lvlTwoCountD','SimulinkRate',dataRate);
    lvlThreeCountD=normalNet.addSignal2('Type',accCountT,'Name','lvlThreeCountD','SimulinkRate',dataRate);
    lvlFourCountD=normalNet.addSignal2('Type',accCountT,'Name','lvlFourCountD','SimulinkRate',dataRate);
    LUTout=normalNet.addSignal2('Type',tableT,'Name','reciprocal','SimulinkRate',dataRate);
    recipPipeOut=normalNet.addSignal2('Type',tableT,'Name','reciprocalPiped','SimulinkRate',dataRate);
    accMUXPipeOut=normalNet.addSignal2('Type',lvlFourAccT,'Name','pipeAccMUXOut','SimulinkRate',dataRate);
    lvlOneAccD=normalNet.addSignal2('Type',lvlFourAccT,'Name','lvlOneAccD','SimulinkRate',dataRate);
    lvlOneAccIn=normalNet.addSignal2('Type',lvlFourAccT,'Name','lvlOneAccIn','SimulinkRate',dataRate);
    recipMultOut=normalNet.addSignal2('Type',normalizeT,'Name','recipMultOut','SimulinkRate',dataRate);
    inpHold=normalNet.addSignal2('Type',booleanT,'SimulinkRate',dataRate);
    inpHoldD=normalNet.addSignal2('Type',booleanT,'SimulinkRate',dataRate);
    inpHoldD3=normalNet.addSignal2('Type',booleanT,'SimulinkRate',dataRate);




    c=pirelab.getUnitDelayEnabledComp(normalNet,lvlOneCount,lvlOneCountD,inpHoldD);
    c.addComment('Delay Balancing on Count Input');
    pirelab.getUnitDelayComp(normalNet,lvlTwoCount,lvlTwoCountD);
    pirelab.getUnitDelayComp(normalNet,lvlThreeCount,lvlThreeCountD);
    pirelab.getUnitDelayComp(normalNet,lvlFourCount,lvlFourCountD);



    recipLUT=ones(1,64)./(1:64);


    [tabledata,tableidx,bpType,oType,fType]=ComputeLUT(recipLUT,18,17,0,6);


    regcomp=pirelab.getLookupNDComp(normalNet,countMUXOut,LUTout,...
    tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table');
    regcomp.addComment('[64x1] LUT of Reciprocal Values')



    countMux=pirelab.getSwitchComp(normalNet,[lvlOneCountD,lvlTwoCountD,lvlThreeCountD,lvlFourCountD],...
    countMUXOut,SEL,'recipMUX');
    countMux.addComment('TDM Counter Input');


    pirelab.getUnitDelayEnabledComp(normalNet,lvlOneAcc,lvlOneAccD,inpHoldD3);
    pirelab.getSwitchComp(normalNet,[lvlOneAccD,lvlOneAcc],lvlOneAccIn,inpHoldD3);


    accumMux=pirelab.getSwitchComp(normalNet,[lvlOneAccIn,lvlTwoAcc,lvlThreeAcc,lvlFourAcc],...
    accMUXOut,SEL,'recipMUX');
    accumMux.addComment('TDM Accumulator Input');


    recipLUT=pirelab.getIntDelayComp(normalNet,LUTout,recipPipeOut,2,'recipPipeline',...
    0);
    recipLUT.addComment('Pipeline Reciprocal Input');



    pirelab.getLogicComp(normalNet,normFlag,inpHold,'not');
    pirelab.getIntDelayComp(normalNet,inpHold,inpHoldD3,2);
    pirelab.getUnitDelayComp(normalNet,inpHold,inpHoldD);


    accMUXOUT=pirelab.getIntDelayComp(normalNet,accMUXOut,accMUXPipeOut,2);


    accMUXOUT.addComment('Pipeline Accumulator Input');


    norm=pirelab.getMulComp(normalNet,[recipPipeOut,accMUXPipeOut],recipMultOut);
    norm.addComment('Normalize Accumulator Input');

    pipeOut=pirelab.getIntDelayComp(normalNet,recipMultOut,...
    normalized,2,'outputPipeline',0);
    pipeOut.addComment('Pipeline Output of Normalization');



    function[tabledata,tableidx,bpType,oType,fType]=ComputeLUT(LUT,Wl,Fl,Si,Addr_Wl)

        oType=fi(0,Si,Wl,Fl);
        fType=fi(0,0,32,31);


        bpType=fi(0,0,Addr_Wl,0);
        tableidx={fi((0:2^Addr_Wl-1),bpType.numerictype)};

        Fsat=fimath('RoundMode','Nearest',...
        'OverflowMode','Saturate',...
        'SumMode','KeepLSB',...
        'SumWordLength',Wl,...
        'SumFractionLength',Fl,...
        'CastBeforeSum',true);

        tabledata=fi(LUT,oType.numerictype,Fsat);




