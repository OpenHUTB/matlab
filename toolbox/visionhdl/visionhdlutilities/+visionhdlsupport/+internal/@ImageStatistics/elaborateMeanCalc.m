function meanNet=elaborateMeanCalc(this,topNet,blockInfo,sigInfo,dataRate)















    dataInVT=sigInfo.dataInVT;


    lvlThreeAccT=sigInfo.lvlThreeAccT;
    lvlFourAccT=sigInfo.lvlFourAccT;
    lvlOneAccVT=sigInfo.lvlOneAccVT;
    lvlTwoAccVT=sigInfo.lvlTwoAccVT;
    lvlThreeAccVT=sigInfo.lvlThreeAccVT;
    lvlFourAccVT=sigInfo.lvlFourAccVT;
    accCountT=sigInfo.accCountT;
    pipeCountT=sigInfo.pipeCountT;
    normalizeT=sigInfo.normalizeT;
    normalizeVT=sigInfo.normalizeVT;
    selT=sigInfo.selT;
    booleanT=sigInfo.booleanT;
    recipT=sigInfo.recipT;


    inPortNames={'dataIn','hStart','hEnd','vStart',...
    'vEnd','validIn'};

    inPortRates=[dataRate,dataRate,dataRate,dataRate...
    ,dataRate,dataRate];

    inPortTypes=[(sigInfo.inType),booleanT,booleanT,booleanT,booleanT,booleanT];

    num=1;

    outPortNames{num}='mean';
    outPortTypes(num)=sigInfo.normalizeT;
    num=num+1;

    if blockInfo.variance||blockInfo.stdDev
        outPortNames{num}='meanSq';
        outPortTypes(num)=sigInfo.normalizeVT;
        num=num+1;
    end
    outPortTypes(num)=sigInfo.booleanT;
    outPortNames{num}='validOut';

    meanNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','calcMean',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );



    inSignals=meanNet.PirInputSignals;
    dataIn=inSignals(1);
    hStart=inSignals(2);
    hEnd=inSignals(3);
    vStart=inSignals(4);
    vEnd=inSignals(5);
    validIn=inSignals(6);


    dataRate=dataIn.SimulinkRate;


    outSignals=meanNet.PirOutputSignals;




    hStartIn=meanNet.addSignal2('Type',booleanT,'Name','hStartIn');
    hEndIn=meanNet.addSignal2('Type',booleanT,'Name','hEndIn');
    vStartIn=meanNet.addSignal2('Type',booleanT,'Name','vStartIn');
    vEndIn=meanNet.addSignal2('Type',booleanT,'Name','vEndIn');
    vEndOut=meanNet.addSignal2('Type',booleanT,'Name','vEndOut');
    vEndOutD=meanNet.addSignal2('Type',booleanT,'Name','vEndOut');
    dataValid=meanNet.addSignal2('Type',booleanT,'Name','dataValid');

    processPixel=meanNet.addSignal2('Type',booleanT,'Name','processPixel');
    lineReset=meanNet.addSignal2('Type',booleanT,'Name','lineReset');
    frameStart=meanNet.addSignal2('Type',booleanT,'Name','frameStart');
    processPixelD=meanNet.addSignal2('Type',booleanT,'Name','processPixelD');
    lineResetD=meanNet.addSignal2('Type',booleanT,'Name','lineResetD');
    frameStartD=meanNet.addSignal2('Type',booleanT,'Name','frameStartD');


    pirelab.getUnitDelayComp(meanNet,hStart,hStartIn);
    pirelab.getUnitDelayComp(meanNet,hEnd,hEndIn);
    pirelab.getUnitDelayComp(meanNet,vStart,vStartIn);
    pirelab.getUnitDelayComp(meanNet,vEnd,vEndIn);
    pirelab.getUnitDelayComp(meanNet,validIn,dataValid);



    inputControlNet=this.elabInputControl(...
    meanNet,blockInfo,sigInfo,dataRate);





    inputControlIn=[hStartIn,hEndIn,vStartIn,vEndIn,dataValid];
    inputControlOut=[processPixel,lineReset,frameStart];

    pirelab.instantiateNetwork(meanNet,inputControlNet,inputControlIn,...
    inputControlOut,'dataReadFSM');



    pirelab.getUnitDelayComp(meanNet,processPixel,processPixelD);
    pirelab.getUnitDelayComp(meanNet,lineReset,lineResetD);


    pirelab.getIntDelayComp(meanNet,vEndIn,vEndOut,2);

    pirelab.getUnitDelayComp(meanNet,vEndOut,vEndOutD);




    recipControlNet=this.elabRecipControl(...
    meanNet,blockInfo,sigInfo,dataRate);




    lvlOneCount=meanNet.addSignal2('Type',accCountT,'Name','lvlOneCount');
    lvlTwoCount=meanNet.addSignal2('Type',accCountT,'Name','lvlTwoCount');
    lvlThreeCount=meanNet.addSignal2('Type',accCountT,'Name','lvlThreeCount');
    lvlFourCount=meanNet.addSignal2('Type',accCountT,'Name','lvlFourCount');
    pipeCount=meanNet.addSignal2('Type',pipeCountT,'Name','pipelineCount');


    lvlTwoEn=meanNet.addSignal2('Type',booleanT,'Name','lvlTwoEn');
    lvlThreeEn=meanNet.addSignal2('Type',booleanT,'Name','lvlThreeEn');
    lvlFourEn=meanNet.addSignal2('Type',booleanT,'Name','lvlFourEn');
    outEn=meanNet.addSignal2('Type',booleanT,'Name','outEn');
    SEL=meanNet.addSignal2('Type',selT,'Name','SEL');
    pipeEn=meanNet.addSignal2('Type',booleanT,'Name','pipeEn');
    pipeRst=meanNet.addSignal2('Type',booleanT,'Name','pipeRst');
    endFlag=meanNet.addSignal2('Type',booleanT,'Name','endFlag');
    endFlagD=meanNet.addSignal2('Type',booleanT,'Name','endFlagD');
    normFlag=meanNet.addSignal2('Type',booleanT,'Name','normFlag');
    countReset=meanNet.addSignal2('Type',booleanT,'Name','countReset');


    pirelab.getLogicComp(meanNet,[frameStart,countReset],frameStartD,'or');
    recipContIn=[vEndOut,vEndOutD,lvlOneCount,lvlTwoCount,lvlThreeCount,lvlFourCount,pipeCount,vStartIn];
    recipContOut=[lvlTwoEn,lvlThreeEn,lvlFourEn,SEL,outEn,pipeRst,pipeEn,endFlag,normFlag,countReset];


    pirelab.instantiateNetwork(meanNet,recipControlNet,...
    recipContIn,recipContOut,'dataWriteFSM');


    C=pirelab.getCounterComp(meanNet,...
    [pipeRst,pipeEn],...
    pipeCount,...
    'Free running',...
    0,...
    1,...
    3,...
    true,...
    false,...
    true,...
    false,...
    'PipelineCounter');
    C.addComment('Normalization Pipeline Counter');

    pirelab.getUnitDelayComp(meanNet,endFlag,endFlagD);



    countNet=this.elabCountBank(meanNet,blockInfo,sigInfo,dataRate);




    countIn=[lineResetD,frameStartD,processPixelD,lvlTwoEn,lvlThreeEn,lvlFourEn,endFlagD];


    countOut=[lvlOneCount,lvlTwoCount,lvlThreeCount,lvlFourCount];


    pirelab.instantiateNetwork(meanNet,countNet,...
    countIn,countOut,'counterBank');



    accumNet=this.elabAccumBank(...
    meanNet,blockInfo,sigInfo,dataRate,false);




    normalized=meanNet.addSignal2('Type',normalizeT,'Name','Normalized');

    accIn=[dataIn,normalized,processPixelD,lvlOneCount,...
    lvlTwoEn,lvlTwoCount,lvlThreeEn,lvlThreeCount,lvlFourEn,lvlFourCount];


    lvlOneAcc=meanNet.addSignal2('Type',lvlFourAccT,'Name','lvlOneAcc');
    lvlTwoAcc=meanNet.addSignal2('Type',lvlFourAccT,'Name','lvlTwoAcc');
    lvlThreeAcc=meanNet.addSignal2('Type',lvlFourAccT,'Name','lvlThreeAcc');
    lvlFourAcc=meanNet.addSignal2('Type',lvlFourAccT,'Name','lvlThreeAcc');


    accOut=[lvlOneAcc,lvlTwoAcc,lvlThreeAcc,lvlFourAcc];



    pirelab.instantiateNetwork(meanNet,accumNet,...
    accIn,accOut,'accumulatorBank');


    if blockInfo.variance||blockInfo.stdDev

        sigInfoVar.inType=dataInVT;
        sigInfoVar.normalizeT=normalizeVT;
        sigInfoVar.booleanT=booleanT;
        sigInfoVar.accCountT=accCountT;
        sigInfoVar.lvlOneAccT=lvlOneAccVT;
        sigInfoVar.lvlTwoAccT=lvlTwoAccVT;
        sigInfoVar.lvlThreeAccT=lvlThreeAccVT;
        sigInfoVar.lvlFourAccT=lvlFourAccVT;

        accumNetVar=this.elabAccumBank(...
        meanNet,blockInfo,sigInfoVar,dataRate,true);




        normalizedVar=meanNet.addSignal2('Type',normalizeVT,'Name','Normalized');
        dataInSquare=meanNet.addSignal2('Type',dataInVT,'Name','dataInSquare');

        pirelab.getMulComp(meanNet,[dataIn,dataIn],dataInSquare,'Floor','Wrap');

        accInVar=[dataInSquare,normalizedVar,processPixelD,lvlOneCount,...
        lvlTwoEn,lvlTwoCount,lvlThreeEn,lvlThreeCount,lvlFourEn,lvlFourCount];


        lvlOneAccVar=meanNet.addSignal2('Type',lvlFourAccVT,'Name','lvlOneAccVar');
        lvlTwoAccVar=meanNet.addSignal2('Type',lvlFourAccVT,'Name','lvlTwoAccVar');
        lvlThreeAccVar=meanNet.addSignal2('Type',lvlFourAccVT,'Name','lvlThreeAccVar');
        lvlFourAccVar=meanNet.addSignal2('Type',lvlFourAccVT,'Name','lvlFourAccVar');


        accOutVar=[lvlOneAccVar,lvlTwoAccVar,lvlThreeAccVar,lvlFourAccVar];



        pirelab.instantiateNetwork(meanNet,accumNetVar,...
        accInVar,accOutVar,'accumulatorBankVar');

    end




    normalNet=this.elabNormalization(...
    meanNet,blockInfo,sigInfo,dataRate,false);




    normalIn=[lvlOneCount,lvlTwoCount,lvlThreeCount,lvlFourCount,SEL,lvlOneAcc,lvlTwoAcc,lvlThreeAcc,lvlFourAcc,normFlag];


    normalOut=normalized;


    pirelab.instantiateNetwork(meanNet,normalNet,...
    normalIn,normalOut,'normalization');




    if blockInfo.variance||blockInfo.stdDev

        sigInfoVar.lvlThreeAccT=lvlThreeAccVT;
        sigInfoVar.normalizeT=normalizeVT;
        sigInfoVar.accCountT=accCountT;
        sigInfoVar.recipT=recipT;
        sigInfoVar.selT=selT;


        normalNet=this.elabNormalization(...
        meanNet,blockInfo,sigInfoVar,dataRate,true);


        normalInVar=[lvlOneCount,lvlTwoCount,lvlThreeCount,lvlFourCount,SEL,lvlOneAccVar,lvlTwoAccVar,lvlThreeAccVar,lvlFourAccVar,normFlag];


        normalOutVar=normalizedVar;


        pirelab.instantiateNetwork(meanNet,normalNet,...
        normalInVar,normalOutVar,'normalizationVar');

    end

    num=1;
    pirelab.getUnitDelayEnabledComp(meanNet,normalized,outSignals(num),outEn);

    num=num+1;

    if blockInfo.variance||blockInfo.stdDev

        pirelab.getUnitDelayEnabledComp(meanNet,normalizedVar,outSignals(num),outEn);
        num=num+1;
    end
    pirelab.getUnitDelayComp(meanNet,outEn,outSignals(num));







