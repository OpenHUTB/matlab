function ReadGenNet=elaborateReadAddressGenNet(this,topNet,blockInfo,sigInfo,dataRate)












    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    readCounterType=sigInfo.readCounterType;
    gradtableT=pir_ufixpt_t(ceil(log2(blockInfo.MaxBufferSize))+10,-10);
    offsetBits=32;
    offsetTableT=pir_ufixpt_t(28,-10);
    intermediateCalcType=pir_fixpt_t(0,ceil(log2(blockInfo.MaxBufferSize))+10,-10);

    inPortNames={'hStart','columnCount','FrameReset'}';
    inPortRates=[dataRate,dataRate,dataRate];
    inPortTypes=[booleanT,readCounterType,booleanT];
    outPortNames={'readAddress'};
    outPortTypes=[readCounterType];

    ReadGenNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ReadAddressGenerator',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );




    inSignals=ReadGenNet.PirInputSignals;
    outSignals=ReadGenNet.PirOutputSignals;





    hStart=inSignals(1);
    ColumnCountIn=inSignals(2);
    FrameEnd=inSignals(3);


    ReadAddress=outSignals(1);








    gradBits=16;
    LineLUTCount=ReadGenNet.addSignal2('Type',readCounterType,'Name','LineLUTCount');
    LineLUTCountD=ReadGenNet.addSignal2('Type',readCounterType,'Name','LineLUTCountD');





    gradLUTOut=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','GradientLUTOut');
    gradLUTOutD=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','GradientLUTOutD');

    gradLUTOut.SimulinkRate=hStart.SimulinkRate;


    this.getSimpleLookupComp(ReadGenNet,LineLUTCountD,gradLUTOut,blockInfo.GradientLUT,...
    'GradientLUT','Coefficient table for Gradient Values');










    offsetLUTOut=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','OffsetLUTValue');
    offsetLUTOutD=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','OffsetLUTValueD');

    offsetLUTOut.SimulinkRate=hStart.SimulinkRate;


    this.getSimpleLookupComp(ReadGenNet,LineLUTCountD,offsetLUTOut,blockInfo.OffsetLUT,...
    'OffsetLUT','Coefficient table for Offset Values');










    rowmapLUTOut=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','RowMapLUTValue');
    rowmapLUTOut.SimulinkRate=hStart.SimulinkRate;

    this.getSimpleLookupComp(ReadGenNet,LineLUTCountD,rowmapLUTOut,blockInfo.RowMap,...
    'RowMapLUT','Coefficient table for Row Mapping');






    LineLUTEnable=ReadGenNet.addSignal2('Type',booleanT,'Name','LineLUTEnable');
    LineLUTEnable0=ReadGenNet.addSignal2('Type',booleanT,'Name','LineLUTEnable0');

    LineLUTEnable.SimulinkRate=hStart.SimulinkRate;
    LineLUTEnable0.SimulinkRate=hStart.SimulinkRate;

    RunLengthReset=ReadGenNet.addSignal2('Type',booleanT,'Name','RunLengthReset');
    RunLengthDecodeCounter=ReadGenNet.addSignal2('Type',readCounterType,'Name','RunLengthDecodeCount');

    pirelab.getLogicComp(ReadGenNet,[LineLUTEnable0,FrameEnd],RunLengthReset,'or');


    RunLengthCount=pirelab.getCounterComp(ReadGenNet,...
    [RunLengthReset,hStart],...
    RunLengthDecodeCounter,...
    'Free running',...
    0,...
    1,...
    [],...
    true,...
    false,...
    true,...
    false,...
    'RunLengthDecodeCounter');
    RunLengthCount.addComment('Run-Length Decode Count');

    pirelab.getRelOpComp(ReadGenNet,[RunLengthDecodeCounter,rowmapLUTOut],LineLUTEnable,'==');
    pirelab.getLogicComp(ReadGenNet,[LineLUTEnable,FrameEnd],LineLUTEnable0,'or');


    LineLUTCounter=pirelab.getCounterComp(ReadGenNet,...
    [FrameEnd,LineLUTEnable0],...
    LineLUTCount,...
    'Count Limited',...
    0,...
    1,...
    (length(blockInfo.RowMap)),...
    true,...
    false,...
    true,...
    false,...
    'LineLUTCount');
    LineLUTCounter.addComment('Line LUT Count');

    runDecodeAddress=ReadGenNet.addSignal2('Type',readCounterType,'Name','RunDecodeAddress');
    runDecodeAddressD=ReadGenNet.addSignal2('Type',readCounterType,'Name','RunDecodeAddressD');


    BirdsEyeActivePixels=ReadGenNet.addSignal2('Type',readCounterType,'Name','BirdsEyeActivePixels');
    BirdsEyeActivePixelsD=ReadGenNet.addSignal2('Type',readCounterType,'Name','BirdsEyeActivePixelsD');
    BirdsEyeActivePixelsD.SimulinkRate=ColumnCountIn.SimulinkRate;
    BirdsEyeActivePixels.SimulinkRate=ColumnCountIn.SimulinkRate;



    pirelab.getConstComp(ReadGenNet,BirdsEyeActivePixels,blockInfo.BirdsEyeActivePixels);

    pirelab.getIntDelayComp(ReadGenNet,LineLUTCount,LineLUTCountD,2);
    pirelab.getUnitDelayComp(ReadGenNet,BirdsEyeActivePixels,BirdsEyeActivePixelsD);


    pirelab.getMulComp(ReadGenNet,[LineLUTCountD,BirdsEyeActivePixelsD],runDecodeAddress,'Floor','Wrap');

    readAddressGradient=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','ReadAddressGradient');
    readAddressGradientD=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','ReadAddressGradientD');

    readAddressF=ReadGenNet.addSignal2('Type',readCounterType,'Name','ReadAddressF');
    readAddressOffsetCorrected=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','ReadAddressOffsetCorrected');
    readAddressOffsetCorrectedD=ReadGenNet.addSignal2('Type',intermediateCalcType,'Name','ReadAddressOffsetCorrected');
    ColumnCountInD=ReadGenNet.addSignal2('Type',readCounterType,'Name','ColumnCountInD');

    pirelab.getIntDelayComp(ReadGenNet,ColumnCountIn,ColumnCountInD,2);
    gradLUTOut.SimulinkRate=ColumnCountIn.SimulinkRate;

    pirelab.getUnitDelayComp(ReadGenNet,gradLUTOut,gradLUTOutD);
    pirelab.getMulComp(ReadGenNet,[ColumnCountInD,gradLUTOutD],readAddressGradient,'Floor','Wrap');

    pirelab.getIntDelayComp(ReadGenNet,readAddressGradient,readAddressGradientD,2);
    offsetLUTOut.SimulinkRate=readAddressGradient.SimulinkRate;
    pirelab.getIntDelayComp(ReadGenNet,offsetLUTOut,offsetLUTOutD,2);

    pirelab.getAddComp(ReadGenNet,[readAddressGradientD,offsetLUTOutD],readAddressOffsetCorrected,'Floor','Wrap',readAddressOffsetCorrected.Type);
    pirelab.getIntDelayComp(ReadGenNet,runDecodeAddress,runDecodeAddressD,3);
    pirelab.getUnitDelayComp(ReadGenNet,readAddressOffsetCorrected,readAddressOffsetCorrectedD);
    pirelab.getAddComp(ReadGenNet,[readAddressOffsetCorrectedD,runDecodeAddressD],ReadAddress,'Floor','Wrap');


























