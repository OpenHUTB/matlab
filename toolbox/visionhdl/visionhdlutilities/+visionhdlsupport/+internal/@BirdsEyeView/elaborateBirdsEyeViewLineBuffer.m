function LineBuffNet=elaborateBirdsEyeViewLineBuffer(this,topNet,blockInfo,sigInfo,dataRate)












    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    readCounterType=sigInfo.readCounterType;



    inPortNames={'pixel','pushIn','readAddress','FrameEnd'}';
    inPortRates=[dataRate,dataRate,dataRate,dataRate];
    inPortTypes=[inType,booleanT,readCounterType,booleanT];
    outPortNames={'pixelOut','CountOut'};
    outPortTypes=[inType,readCounterType];

    LineBuffNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LineBuffer',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );


    inSignals=LineBuffNet.PirInputSignals;
    outSignals=LineBuffNet.PirOutputSignals;



    PixelIn=inSignals(1);
    PushIn=inSignals(2);
    ReadAddress=inSignals(3);
    FrameEnd=inSignals(4);


    PixelOut=outSignals(1);
    CountOut=outSignals(2);


    WriteCounter=LineBuffNet.addSignal2('Type',readCounterType,'Name','WriteCount');

    c1=pirelab.getCounterComp(LineBuffNet,[FrameEnd,PushIn],WriteCounter,'Free running',...
    0,1,[],true,false,true,false,'Write Count',0);



    PushDelay=LineBuffNet.addSignal2('Type',booleanT,'Name','PushDelay');
    pirelab.getUnitDelayComp(LineBuffNet,PushIn,PushDelay);

    RAMDataOut=LineBuffNet.addSignal2('Type',inType,'Name','RAMDataOut');
    PixelInDelay=LineBuffNet.addSignal2('Type',inType,'Name','PixelInDelay');
    WriteCounterDelay=LineBuffNet.addSignal2('Type',readCounterType,'Name','WriteCounterDelay');
    ReadAddressDelay=LineBuffNet.addSignal2('Type',readCounterType,'Name','ReadAddressDelay');

    pirelab.getIntDelayComp(LineBuffNet,PixelIn,PixelInDelay,2);
    pirelab.getIntDelayComp(LineBuffNet,WriteCounter,WriteCounterDelay,2);
    pirelab.getIntDelayComp(LineBuffNet,ReadAddress,ReadAddressDelay,3);



    pirelab.getSimpleDualPortRamComp(LineBuffNet,[PixelIn,WriteCounter,PushIn,ReadAddress],...
    PixelOut);

    pirelab.getDTCComp(LineBuffNet,WriteCounter,CountOut);





