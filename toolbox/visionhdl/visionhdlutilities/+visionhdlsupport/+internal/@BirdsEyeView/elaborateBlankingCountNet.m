function blankingCountNet=elaborateBlankingCountNet(this,topNet,blockInfo,sigInfo,dataRate)












    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    readCounterType=sigInfo.readCounterType;
    FSMType=sigInfo.FSMType;




    inPortNames={'hStart','hEnd','FSMState'}';
    inPortRates=[dataRate,dataRate,dataRate];
    inPortTypes=[booleanT,booleanT,FSMType];
    outPortNames={'BlankingInterval'};
    outPortTypes=readCounterType;

    blankingCountNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BlankingIntervalCompute',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );


    inSignals=blankingCountNet.PirInputSignals;
    outSignals=blankingCountNet.PirOutputSignals;



    hStart=inSignals(1);
    hEnd=inSignals(2);
    FSMState=inSignals(3);



    BlankingInterval=outSignals(1);

    LogicLow=blankingCountNet.addSignal2('Type',booleanT,'Name','LogicLow');
    pirelab.getConstComp(blankingCountNet,LogicLow,0);



    MuxIn=[LogicLow,hEnd];
    MuxOut=blankingCountNet.addSignal2('Type',booleanT,'Name','MuxOut');
    lineEnable=blankingCountNet.addSignal2('Type',booleanT,'Name','LineEnable');
    BetweenLines=blankingCountNet.addSignal2('Type',booleanT,'Name','BetweenLines');

    LockedFrameGatedhStart=blankingCountNet.addSignal2('Type',booleanT,'Name','hStartGate');
    LockedFrameGatedBetweenLines=blankingCountNet.addSignal2('Type',booleanT,'Name','BetweenLinesGate');
    LockedFrame=blankingCountNet.addSignal2('Type',booleanT,'Name','LockedFrame');
    StateConst=blankingCountNet.addSignal2('Type',FSMType,'Name','StateConst');
    pirelab.getConstComp(blankingCountNet,StateConst,2);
    NotLocked=blankingCountNet.addSignal2('Type',booleanT,'Name','LockedFrame');


    pirelab.getRelOpComp(blankingCountNet,[FSMState,StateConst],LockedFrame,'==');



    pirelab.getSwitchComp(blankingCountNet,MuxIn,MuxOut,hEnd);
    pirelab.getLogicComp(blankingCountNet,[hStart,hEnd],lineEnable,'or');
    pirelab.getUnitDelayEnabledComp(blankingCountNet,MuxOut,BetweenLines,lineEnable);

    BlankingIntervalCount=blankingCountNet.addSignal2('Type',readCounterType,...
    'Name','BlankingIntervalCount');

    pirelab.getLogicComp(blankingCountNet,LockedFrame,NotLocked,'not');


    pirelab.getLogicComp(blankingCountNet,[hStart,NotLocked],LockedFrameGatedhStart,'and');
    pirelab.getLogicComp(blankingCountNet,[BetweenLines,NotLocked],LockedFrameGatedBetweenLines,'and');




    BlankingIntervalCounter=pirelab.getCounterComp(blankingCountNet,...
    [LockedFrameGatedhStart,LockedFrameGatedBetweenLines],...
    BlankingIntervalCount,...
    'Free running',...
    0,...
    1,...
    [],...
    true,...
    false,...
    true,...
    false,...
    'BlankingIntervalCount');
    BlankingIntervalCounter.addComment('Blanking Interval Counter');

    REG1=blankingCountNet.addSignal2('Type',readCounterType,'Name','REG1');
    REG2=blankingCountNet.addSignal2('Type',readCounterType,'Name','REG2');
    REG3=blankingCountNet.addSignal2('Type',readCounterType,'Name','REG3');
    REG4=blankingCountNet.addSignal2('Type',readCounterType,'Name','REG4');
    SumOne=blankingCountNet.addSignal2('Type',readCounterType,'Name','SumOne');
    SumTwo=blankingCountNet.addSignal2('Type',readCounterType,'Name','SumTwo');
    TotalSum=blankingCountNet.addSignal2('Type',readCounterType,'Name','TotalSum');


    pirelab.getUnitDelayEnabledComp(blankingCountNet,BlankingIntervalCount,REG1,LockedFrameGatedhStart);
    pirelab.getUnitDelayEnabledComp(blankingCountNet,REG1,REG2,LockedFrameGatedhStart);
    pirelab.getUnitDelayEnabledComp(blankingCountNet,REG2,REG3,LockedFrameGatedhStart);
    pirelab.getUnitDelayEnabledComp(blankingCountNet,REG3,REG4,LockedFrameGatedhStart);

    pirelab.getAddComp(blankingCountNet,[REG1,REG2],SumOne,'Floor','Wrap','SumBlanking');
    pirelab.getAddComp(blankingCountNet,[REG3,REG4],SumTwo,'Floor','Wrap','SumBlanking');
    pirelab.getAddComp(blankingCountNet,[SumOne,SumTwo],TotalSum,'Floor','Wrap','SumBlanking');


    gainFactor=fi(1/4,0,16,16,'RoundingMethod','Floor','OverflowAction',...
    'Wrap');

    pirelab.getGainComp(blankingCountNet,TotalSum,BlankingInterval,gainFactor);






















































