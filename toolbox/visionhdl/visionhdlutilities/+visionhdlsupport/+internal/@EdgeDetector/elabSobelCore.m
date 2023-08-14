function sobelcoreNet=elabSobelCore(~,topNet,blockInfo,dataRate)





    pixelInType=topNet.PirInputSignals(1).Type;
    ctrlType=pir_boolean_t();
    sobelcoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','SobelCore',...
    'InportNames',{'pixelInVec','ShiftEnb'},...
    'InportTypes',[blockInfo.pixelInVecDT,ctrlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'Gv','Gh'},...
    'OutportTypes',[blockInfo.gradType,blockInfo.gradType]);


    pixelInVec=sobelcoreNet.PirInputSignals(1);
    ShiftEnb=sobelcoreNet.PirInputSignals(2);


    pixelInSplit=pixelInVec.split;
    pixelIn1=pixelInSplit.PirOutputSignals(1);
    pixelIn2=pixelInSplit.PirOutputSignals(2);
    pixelIn3=pixelInSplit.PirOutputSignals(3);

    GvOut=sobelcoreNet.PirOutputSignals(1);
    GhOut=sobelcoreNet.PirOutputSignals(2);



    p1S1=sobelcoreNet.addSignal(pixelInType,'pixel1Shift');
    p2S1=sobelcoreNet.addSignal(pixelInType,'pixel2Shift');
    p3S1=sobelcoreNet.addSignal(pixelInType,'pixel3Shift');
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,pixelIn1,p1S1,ShiftEnb,'p1Shift',false,'',false);
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,pixelIn2,p2S1,ShiftEnb,'p2Shift',false,'',false);
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,pixelIn3,p3S1,ShiftEnb,'p3Shift',false,'',false);


    p1S2=sobelcoreNet.addSignal(pixelInType,'pixel1Shift2');
    p2S2=sobelcoreNet.addSignal(pixelInType,'pixel2Shift2');
    p3S2=sobelcoreNet.addSignal(pixelInType,'pixel3Shift2');
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,p1S1,p1S2,ShiftEnb,'p1Shift2',false,'',false);
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,p2S1,p2S2,ShiftEnb,'p2Shift2',false,'',false);
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,p3S1,p3S2,ShiftEnb,'p3Shift2',false,'',false);


    p1S3=sobelcoreNet.addSignal(pixelInType,'pixel1Shift3');
    p2S3=sobelcoreNet.addSignal(pixelInType,'pixel2Shift3');
    p3S3=sobelcoreNet.addSignal(pixelInType,'pixel3Shift3');
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,p1S2,p1S3,ShiftEnb,'p1Shift3',false,'',false);
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,p2S2,p2S3,ShiftEnb,'p2Shift3',false,'',false);
    pirelab.getUnitDelayEnabledComp(sobelcoreNet,p3S2,p3S3,ShiftEnb,'p3Shift3',false,'',false);

    Adder1Type=sobelcoreNet.getType('FixedPoint',...
    'Signed',pixelInType.Signed,...
    'WordLength',pixelInType.WordLength+1,...
    'FractionLength',pixelInType.FractionLength);

    Adder2Type=sobelcoreNet.getType('FixedPoint',...
    'Signed',pixelInType.Signed,...
    'WordLength',pixelInType.WordLength+2,...
    'FractionLength',pixelInType.FractionLength);

    Adder3Type=sobelcoreNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',pixelInType.WordLength+3,...
    'FractionLength',pixelInType.FractionLength);

    DTCx2Type=sobelcoreNet.getType('FixedPoint',...
    'Signed',pixelInType.Signed,...
    'WordLength',pixelInType.WordLength,...
    'FractionLength',pixelInType.FractionLength+1);

    DTCd8Type=sobelcoreNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',Adder3Type.WordLength,...
    'FractionLength',Adder3Type.FractionLength-3);


    Gvadder1=sobelcoreNet.addSignal(Adder1Type,'GvAdder1');
    pirelab.getAddComp(sobelcoreNet,[p1S3,p3S3],Gvadder1);
    Gvadder1Delay=sobelcoreNet.addSignal(Adder1Type,'GvAdder1Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Gvadder1,Gvadder1Delay);

    p2S3x2=sobelcoreNet.addSignal(DTCx2Type,'p2S3x2');
    pirelab.getDTCComp(sobelcoreNet,p2S3,p2S3x2,'Floor','Saturate','SI');
    p2S3x2Delay=sobelcoreNet.addSignal(DTCx2Type,'p2S3x2Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,p2S3x2,p2S3x2Delay);

    Gvadder2=sobelcoreNet.addSignal(Adder2Type,'GvAdder2');
    pirelab.getAddComp(sobelcoreNet,[Gvadder1Delay,p2S3x2Delay],Gvadder2);
    Gvadder2Delay=sobelcoreNet.addSignal(Adder2Type,'GvAdder2Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Gvadder2,Gvadder2Delay);

    Gvadder3=sobelcoreNet.addSignal(Adder1Type,'GvAdder3');
    pirelab.getAddComp(sobelcoreNet,[p1S1,p3S1],Gvadder3);
    Gvadder3Delay=sobelcoreNet.addSignal(Adder1Type,'GvAdder3Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Gvadder3,Gvadder3Delay);

    p2S1x2=sobelcoreNet.addSignal(DTCx2Type,'p2Sx2');
    pirelab.getDTCComp(sobelcoreNet,p2S1,p2S1x2,'Floor','Saturate','SI');
    p2S1x2Delay=sobelcoreNet.addSignal(DTCx2Type,'p2Sx2Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,p2S1x2,p2S1x2Delay);

    Gvadder4=sobelcoreNet.addSignal(Adder2Type,'GvAdder4');
    pirelab.getAddComp(sobelcoreNet,[p2S1x2Delay,Gvadder3Delay],Gvadder4);
    Gvadder4Delay=sobelcoreNet.addSignal(Adder2Type,'GvAdder4Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Gvadder4,Gvadder4Delay);

    Gvadder5=sobelcoreNet.addSignal(Adder3Type,'GvAdder5');
    pirelab.getSubComp(sobelcoreNet,[Gvadder2Delay,Gvadder4Delay],Gvadder5);

    Gvdtc1=sobelcoreNet.addSignal(DTCd8Type,'gvdtc1');
    GvDiv8=pirelab.getDTCComp(sobelcoreNet,Gvadder5,Gvdtc1,'Floor','Saturate','SI');
    GvDiv8.addComment('Gv: Right-shift 3 bit to perform divided by 8');
    Gvdtc1Delay=sobelcoreNet.addSignal(DTCd8Type,'gvdtc1Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Gvdtc1,Gvdtc1Delay);

    Gv=pirelab.getDTCComp(sobelcoreNet,Gvdtc1Delay,GvOut,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    Gv.addComment('Gv: Cast to the specified gradient data type. Full precision if outputing binary image only');


    Ghadder1=sobelcoreNet.addSignal(Adder1Type,'GhAdder1');
    pirelab.getAddComp(sobelcoreNet,[p1S1,p1S3],Ghadder1);
    Ghadder1Delay=sobelcoreNet.addSignal(Adder1Type,'GhAdder1Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Ghadder1,Ghadder1Delay);

    p1S2x2=sobelcoreNet.addSignal(DTCx2Type,'p1S2x2');
    pirelab.getDTCComp(sobelcoreNet,p1S2,p1S2x2,'Floor','Saturate','SI');
    p1S2x2Delay=sobelcoreNet.addSignal(DTCx2Type,'p1S2x2Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,p1S2x2,p1S2x2Delay);

    Ghadder2=sobelcoreNet.addSignal(Adder2Type,'GhAdder2');
    pirelab.getAddComp(sobelcoreNet,[p1S2x2Delay,Ghadder1Delay],Ghadder2);
    Ghadder2Delay=sobelcoreNet.addSignal(Adder2Type,'GhAdder2Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Ghadder2,Ghadder2Delay);

    Ghadder3=sobelcoreNet.addSignal(Adder1Type,'GhAdder3');
    pirelab.getAddComp(sobelcoreNet,[p3S1,p3S3],Ghadder3);
    Ghadder3Delay=sobelcoreNet.addSignal(Adder1Type,'GhAdder3Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Ghadder3,Ghadder3Delay);

    p3S2x2=sobelcoreNet.addSignal(DTCx2Type,'p3S2x2');
    pirelab.getDTCComp(sobelcoreNet,p3S2,p3S2x2,'Floor','Saturate','SI');
    p3S2x2Delay=sobelcoreNet.addSignal(DTCx2Type,'p3S2x2Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,p3S2x2,p3S2x2Delay);

    Ghadder4=sobelcoreNet.addSignal(Adder2Type,'GhAdder4');
    pirelab.getAddComp(sobelcoreNet,[p3S2x2Delay,Ghadder3Delay],Ghadder4);
    Ghadder4Delay=sobelcoreNet.addSignal(Adder2Type,'GhAdder4Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Ghadder4,Ghadder4Delay);

    Ghadder5=sobelcoreNet.addSignal(Adder3Type,'GhAdder5');
    pirelab.getSubComp(sobelcoreNet,[Ghadder4Delay,Ghadder2Delay],Ghadder5);

    Ghdtc1=sobelcoreNet.addSignal(DTCd8Type,'ghdtc1');
    GhDiv8=pirelab.getDTCComp(sobelcoreNet,Ghadder5,Ghdtc1,'Floor','Saturate','SI');
    GhDiv8.addComment('Gh: Right-shift 3 bit to perform divided by 8');
    Ghdtc1Delay=sobelcoreNet.addSignal(DTCd8Type,'ghdtc1Delay');
    pirelab.getUnitDelayComp(sobelcoreNet,Ghdtc1,Ghdtc1Delay);

    Gh=pirelab.getDTCComp(sobelcoreNet,Ghdtc1Delay,GhOut,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    Gh.addComment('Gh: Cast to the specified gradient data type. Full precision if outputing binary image only');



