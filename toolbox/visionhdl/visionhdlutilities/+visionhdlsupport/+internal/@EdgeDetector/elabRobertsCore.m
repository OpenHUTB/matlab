function robertscoreNet=elabRobertsCore(~,topNet,blockInfo,dataRate)






    ctrlType=pir_boolean_t();
    robertscoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','RobertsCore',...
    'InportNames',{'pixelInVec','ShiftEnb'},...
    'InportTypes',[blockInfo.pixelInVecDT,ctrlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'G45','G135'},...
    'OutportTypes',[blockInfo.gradType,blockInfo.gradType]);


    pixelInVec=robertscoreNet.PirInputSignals(1);
    ShiftEnb=robertscoreNet.PirInputSignals(2);


    pixelInSplit=pixelInVec.split;
    pixelIn1=pixelInSplit.PirOutputSignals(1);
    pixelIn2=pixelInSplit.PirOutputSignals(2);

    G45Out=robertscoreNet.PirOutputSignals(1);
    G135Out=robertscoreNet.PirOutputSignals(2);


    PInType=pixelIn1.Type;
    p1S1=robertscoreNet.addSignal(PInType,'pixel1Shift');
    p2S1=robertscoreNet.addSignal(PInType,'pixel2Shift');
    pirelab.getUnitDelayEnabledComp(robertscoreNet,pixelIn1,p1S1,ShiftEnb,'p1Shift',false,'',false);
    pirelab.getUnitDelayEnabledComp(robertscoreNet,pixelIn2,p2S1,ShiftEnb,'p2Shift',false,'',false);

    p1S2=robertscoreNet.addSignal(PInType,'pixel1Shift2');
    p2S2=robertscoreNet.addSignal(PInType,'pixel2Shift2');
    pirelab.getUnitDelayEnabledComp(robertscoreNet,p1S1,p1S2,ShiftEnb,'p1Shift2',false,'',false);
    pirelab.getUnitDelayEnabledComp(robertscoreNet,p2S1,p2S2,ShiftEnb,'p2Shift2',false,'',false);

    SubType=robertscoreNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',PInType.WordLength+1,...
    'FractionLength',PInType.FractionLength);
    DTCType=robertscoreNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',PInType.WordLength+1,...
    'FractionLength',PInType.FractionLength-1);


    adder1=robertscoreNet.addSignal(SubType,'sub1');
    pirelab.getSubComp(robertscoreNet,[p2S2,p1S1],adder1);
    dtc1=robertscoreNet.addSignal(DTCType,'dtc1');
    G45Div2=pirelab.getDTCComp(robertscoreNet,adder1,dtc1,'Floor','Saturate','SI');
    G45Div2.addComment('G45: Right-shift 1 bit to perform division by 2');
    dtc1D=robertscoreNet.addSignal(DTCType,'dtc1Delay');
    pirelab.getUnitDelayComp(robertscoreNet,dtc1,dtc1D);
    G45=pirelab.getDTCComp(robertscoreNet,dtc1D,G45Out,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    G45.addComment('G45: Cast to the specified gradient data type. Full precision if outputing binary image only');


    adder2=robertscoreNet.addSignal(SubType,'sub2');
    pirelab.getSubComp(robertscoreNet,[p2S1,p1S2],adder2);
    dtc2=robertscoreNet.addSignal(DTCType,'dtc2');
    G135Div2=pirelab.getDTCComp(robertscoreNet,adder2,dtc2,'Floor','Saturate','SI');
    G135Div2.addComment('G135: Right-shift 1 bit to perform division by 2');
    dtc2D=robertscoreNet.addSignal(DTCType,'dtc2Delay');
    pirelab.getUnitDelayComp(robertscoreNet,dtc2,dtc2D);
    G135=pirelab.getDTCComp(robertscoreNet,dtc2D,G135Out,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    G135.addComment('G135: Cast to the specified gradient data type. Full precision if outputing binary image only');



