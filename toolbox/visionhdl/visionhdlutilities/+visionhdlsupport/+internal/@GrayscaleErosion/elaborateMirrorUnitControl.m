function mirrorControlNet=elaborateMirrorUnitControl(this,topNet,blockInfo,sigInfo,inRate)








    boolType=pir_boolean_t();
    CtrlType=sigInfo.controlType;
    countT=sigInfo.countT;


    inPortNames={'reset','validIn'};
    inPortTypes=[boolType,boolType];
    inPortRates=[inRate,inRate];
    outPortNames={'ModK','ControlOut'};
    outPortTypes=[boolType,CtrlType];


    mirrorControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MirrorUnitControl',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    mirrorControlNet.addComment('Mirror Buffer - Ping Pong FIFO Output in address reversed order');



    inSignals=mirrorControlNet.PirInputSignals;
    reset=inSignals(1);
    validIn=inSignals(2);




    outSignals=mirrorControlNet.PirOutputSignals;
    ModK=outSignals(1);
    ControlOut=outSignals(2);



    modKCount=mirrorControlNet.addSignal2('Type',countT,'Name','ModKCount');

    pirelab.getCounterComp(mirrorControlNet,[reset,validIn],modKCount,'Count limited',0,1,...
    blockInfo.kWidth-1,true,false,true,false,'ControlCounter');

    ModKS=mirrorControlNet.addSignal2('Type',boolType,'Name','ModKS');


    pirelab.getCompareToValueComp(mirrorControlNet,modKCount,ModKS,'==',(blockInfo.kWidth)-1);
    pirelab.getWireComp(mirrorControlNet,ModKS,ModK);

    BitEnable=mirrorControlNet.addSignal2('Type',boolType,'Name','BitEnable');
    NewHighBit=mirrorControlNet.addSignal2('Type',boolType,'Name','NewHighBit');
    NewLowBit=mirrorControlNet.addSignal2('Type',boolType,'Name','NewLowBit');
    HighBit=mirrorControlNet.addSignal2('Type',boolType,'Name','HighBit');
    LowBit=mirrorControlNet.addSignal2('Type',boolType,'Name','LowBit');
    FlipHighBit=mirrorControlNet.addSignal2('Type',boolType,'Name','FlipHighBit');
    FlipBitLow=mirrorControlNet.addSignal2('Type',boolType,'Name','FlipBitLow');
    ConstantFalse=mirrorControlNet.addSignal2('Type',boolType,'Name','ConstantFalse');
    ConstantTrue=mirrorControlNet.addSignal2('Type',boolType,'Name','ConstantTrue');

    pirelab.getConstComp(mirrorControlNet,ConstantFalse,false);
    pirelab.getConstComp(mirrorControlNet,ConstantTrue,true);


    pirelab.getLogicComp(mirrorControlNet,[ModKS,reset],BitEnable,'or');
    pirelab.getUnitDelayEnabledComp(mirrorControlNet,NewHighBit,HighBit,BitEnable);
    pirelab.getLogicComp(mirrorControlNet,HighBit,FlipHighBit,'not');
    pirelab.getSwitchComp(mirrorControlNet,[FlipHighBit,ConstantFalse],NewHighBit,reset);

    pirelab.getSwitchComp(mirrorControlNet,[FlipBitLow,ConstantTrue],NewLowBit,reset);
    pirelab.getUnitDelayEnabledComp(mirrorControlNet,NewLowBit,LowBit,BitEnable);
    pirelab.getLogicComp(mirrorControlNet,LowBit,FlipBitLow,'not');


    pirelab.getBitConcatComp(mirrorControlNet,[HighBit,LowBit],ControlOut);























