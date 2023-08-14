function accumNet=elabAccumBank(~,topNet,~,sigInfo,dataRate,varFlag)







    inPortNames={'dataIn','normalized','processPixel','lvlOneCount',...
    'lvlTwoEn','lvlTwoCount','lvlThreeEn',...
    'lvlThreeCount','lvlFourEn','lvlFourCount'};

    inPortTypes=[sigInfo.inType,sigInfo.normalizeT,...
    sigInfo.booleanT,sigInfo.accCountT,...
    sigInfo.booleanT,sigInfo.accCountT,...
    sigInfo.booleanT,sigInfo.accCountT,...
    sigInfo.booleanT,sigInfo.accCountT];

    inPortRates=[dataRate,dataRate,...
    dataRate,dataRate,...
    dataRate,dataRate,...
    dataRate,dataRate,...
    dataRate,dataRate];

    outPortNames={'lvlOneAcc','lvlTwoAcc','lvlThreeAcc','lvlFourAcc'};

    outPortTypes=[sigInfo.lvlFourAccT,sigInfo.lvlFourAccT,...
    sigInfo.lvlFourAccT,sigInfo.lvlFourAccT];

    if varFlag==false
        compName='accumulatorBank';
    else
        compName='accumulatorBankVar';
    end

    accumNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',compName,...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    accumNet.addComment('Accumulator Bank - Accumulate over the 64, [64x64], [64x64x64], [64x64x64x64] windows');




    accumBankIn=accumNet.PirInputSignals;
    data=accumBankIn(1);
    normalized=accumBankIn(2);
    processPixel=accumBankIn(3);
    lvlOneCount=accumBankIn(4);
    lvlTwoEn=accumBankIn(5);
    lvlTwoCount=accumBankIn(6);
    lvlThreeEn=accumBankIn(7);
    lvlThreeCount=accumBankIn(8);
    lvlFourEn=accumBankIn(9);
    lvlFourCount=accumBankIn(10);



    accumBankOut=accumNet.PirOutputSignals;
    lvlOneAcc=accumBankOut(1);
    lvlTwoAcc=accumBankOut(2);
    lvlThreeAcc=accumBankOut(3);
    lvlFourAcc=accumBankOut(4);



    dataInD=accumNet.addSignal2('Type',sigInfo.inType,'Name','dataInD');
    dataInDCast=accumNet.addSignal2('Type',sigInfo.lvlOneAccT,'Name','dataInCast');
    lvlOneAdd=accumNet.addSignal2('Type',sigInfo.lvlOneAccT,'Name','lvlOneAdd');
    lvlTwoAdd=accumNet.addSignal2('Type',sigInfo.lvlTwoAccT,'Name','lvlTwoAdd');
    lvlThreeAdd=accumNet.addSignal2('Type',sigInfo.lvlThreeAccT,'Name','lvlThreeAdd');
    lvlFourAdd=accumNet.addSignal2('Type',sigInfo.lvlFourAccT,'Name','lvlFourAdd');
    lvlOneAccDelay=accumNet.addSignal2('Type',sigInfo.lvlOneAccT,'Name','lvlOneAdd');
    lvlTwoAccDelay=accumNet.addSignal2('Type',sigInfo.lvlTwoAccT,'Name','lvlTwoAccDelay');
    lvlThreeAccDelay=accumNet.addSignal2('Type',sigInfo.lvlThreeAccT,'Name','lvlThreeAccDelay');
    lvlFourAccDelay=accumNet.addSignal2('Type',sigInfo.lvlFourAccT,'Name','lvlFourAccDelay');
    lvlOneInitMUXOut=accumNet.addSignal2('Type',sigInfo.lvlOneAccT,'Name','lvlOneInitMuxOut');
    lvlTwoInitMUXOut=accumNet.addSignal2('Type',sigInfo.lvlTwoAccT,'Name','lvlTwoInitMuxOut');
    lvlThreeInitMUXOut=accumNet.addSignal2('Type',sigInfo.lvlThreeAccT,'Name','lvlThreeInitMuxOut');
    lvlFourInitMUXOut=accumNet.addSignal2('Type',sigInfo.lvlFourAccT,'Name','lvlFourInitMuxOut');
    lvlOneReset=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','lvlOneRST');
    lvlTwoReset=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','lvlTwoRST');
    lvlThreeReset=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','lvlThreeRST');
    lvlFourReset=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','lvlFourRST');
    lvlThreeEnD=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','lvlThreeEnD');
    lvlFourEnD=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','lvlFourEnD');
    processPixelD=accumNet.addSignal2('Type',sigInfo.booleanT,'Name','processPixelD');
    lvlTwoAccIn=accumNet.addSignal2('Type',sigInfo.lvlTwoAccT,'Name','lvlTwoAccIn');
    lvlThreeAccIn=accumNet.addSignal2('Type',sigInfo.lvlThreeAccT,'Name','lvlThreeAccIn');
    lvlFourAccIn=accumNet.addSignal2('Type',sigInfo.lvlFourAccT,'Name','lvlFourAccIn');





    IntD1=pirelab.getIntDelayComp(accumNet,data,dataInD,3);
    IntD1.addComment('Delay Balancing');
    ADD1=pirelab.getAddComp(accumNet,[dataInD,lvlOneAccDelay],lvlOneAdd,'Floor','Wrap');
    ADD1.addComment('lvlOne Accumulation');
    pirelab.getDTCComp(accumNet,dataInD,dataInDCast);
    l1=pirelab.getCompareToValueComp(accumNet,lvlOneCount,lvlOneReset,'==',0,'c1',true);
    l1.addComment('Reset at 64 Pixels Accumulated');
    l11=pirelab.getSwitchComp(accumNet,[lvlOneAdd,dataInDCast],lvlOneInitMUXOut,lvlOneReset);
    l11.addComment('Reset lvlOne Accumulator REG to Current Input');
    pirelab.getUnitDelayComp(accumNet,processPixel,processPixelD);
    UDE1=pirelab.getUnitDelayEnabledComp(accumNet,lvlOneInitMUXOut,lvlOneAccDelay,processPixelD);
    UDE1.addComment('Enabled by dataReadFSM');



    DTC1=pirelab.getDTCComp(accumNet,normalized,lvlTwoAccIn,'Floor','Wrap');
    ADD2=pirelab.getAddComp(accumNet,[lvlTwoAccIn,lvlTwoAccDelay],lvlTwoAdd,'Floor','Wrap');
    ADD2.addComment('lvlTwo Accumulation');
    l2=pirelab.getCompareToValueComp(accumNet,lvlTwoCount,lvlTwoReset,'==',0,'c2',true);
    l2.addComment('Reset at 64 Pixels Accumulated');
    l22=pirelab.getSwitchComp(accumNet,[lvlTwoAdd,lvlTwoAccIn],lvlTwoInitMUXOut,lvlTwoReset);
    l22.addComment('Reset lvlTwo Accumulator REG to Current Input');
    UDE2=pirelab.getUnitDelayEnabledComp(accumNet,lvlTwoInitMUXOut,lvlTwoAccDelay,lvlTwoEn);
    UDE2.addComment('Enabled by dataWriteFSM');


    DT2=pirelab.getDTCComp(accumNet,normalized,lvlThreeAccIn,'Floor','Wrap');
    ADD3=pirelab.getAddComp(accumNet,[lvlThreeAccIn,lvlThreeAccDelay],lvlThreeAdd,'Floor','Wrap');
    ADD3.addComment('lvlThree Accumulation');
    l3=pirelab.getCompareToValueComp(accumNet,lvlThreeCount,lvlThreeReset,'==',0,'c3',true);
    l3.addComment('Reset at 64 Pixels Accumulated');
    l33=pirelab.getSwitchComp(accumNet,[lvlThreeAdd,lvlThreeAccIn],lvlThreeInitMUXOut,lvlThreeReset);
    l33.addComment('Reset lvlThree Accumulator REG to Current Input');
    pirelab.getUnitDelayComp(accumNet,lvlThreeEn,lvlThreeEnD);
    UDE3=pirelab.getUnitDelayEnabledComp(accumNet,lvlThreeInitMUXOut,lvlThreeAccDelay,lvlThreeEn);
    UDE3.addComment('Enabled by dataWriteFSM');


    DT3=pirelab.getDTCComp(accumNet,normalized,lvlFourAccIn,'Floor','Wrap');
    ADD4=pirelab.getAddComp(accumNet,[lvlFourAccIn,lvlFourAccDelay],lvlFourAdd,'Floor','Wrap');
    ADD4.addComment('lvlFour Accumulation');
    l4=pirelab.getCompareToValueComp(accumNet,lvlFourCount,lvlFourReset,'==',0,'c3',true);
    l4.addComment('Reset at 64 Pixels Accumulated');
    l44=pirelab.getSwitchComp(accumNet,[lvlFourAdd,lvlFourAccIn],lvlFourInitMUXOut,lvlFourReset);
    l44.addComment('Reset lvlFour Accumulator REG to Current Input');
    pirelab.getUnitDelayComp(accumNet,lvlFourEn,lvlFourEnD);
    UDE4=pirelab.getUnitDelayEnabledComp(accumNet,lvlFourInitMUXOut,lvlFourAccDelay,lvlFourEn);
    UDE4.addComment('Enabled by dataWriteFSM');




    pirelab.getDTCComp(accumNet,lvlOneAccDelay,lvlOneAcc);
    pirelab.getDTCComp(accumNet,lvlTwoAccDelay,lvlTwoAcc);
    pirelab.getDTCComp(accumNet,lvlThreeAccDelay,lvlThreeAcc);
    pirelab.getDTCComp(accumNet,lvlFourAccDelay,lvlFourAcc);


