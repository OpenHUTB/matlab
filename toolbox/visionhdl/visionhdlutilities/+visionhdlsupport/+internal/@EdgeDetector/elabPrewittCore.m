function prewittcoreNet=elabPrewittCore(~,topNet,blockInfo,dataRate)





    pixelInType=topNet.PirInputSignals(1).Type;
    ctrlType=pir_boolean_t();
    prewittcoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PrewittCore',...
    'InportNames',{'pixelInVec','ShiftEnb'},...
    'InportTypes',[blockInfo.pixelInVecDT,ctrlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'Gv','Gh'},...
    'OutportTypes',[blockInfo.gradType,blockInfo.gradType]);


    pixelInVec=prewittcoreNet.PirInputSignals(1);
    ShiftEnb=prewittcoreNet.PirInputSignals(2);


    pixelInSplit=pixelInVec.split;
    pixelIn1=pixelInSplit.PirOutputSignals(1);
    pixelIn2=pixelInSplit.PirOutputSignals(2);
    pixelIn3=pixelInSplit.PirOutputSignals(3);

    GvOut=prewittcoreNet.PirOutputSignals(1);
    GhOut=prewittcoreNet.PirOutputSignals(2);



    p1S1=prewittcoreNet.addSignal(pixelInType,'pixel1Shift');
    p2S1=prewittcoreNet.addSignal(pixelInType,'pixel2Shift');
    p3S1=prewittcoreNet.addSignal(pixelInType,'pixel3Shift');
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,pixelIn1,p1S1,ShiftEnb,'p1Shift',false,'',false);
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,pixelIn2,p2S1,ShiftEnb,'p2Shift',false,'',false);
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,pixelIn3,p3S1,ShiftEnb,'p3Shift',false,'',false);


    p1S2=prewittcoreNet.addSignal(pixelInType,'pixel1Shift2');
    p2S2=prewittcoreNet.addSignal(pixelInType,'pixel2Shift2');
    p3S2=prewittcoreNet.addSignal(pixelInType,'pixel3Shift2');
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,p1S1,p1S2,ShiftEnb,'p1Shift2',false,'',false);
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,p2S1,p2S2,ShiftEnb,'p2Shift2',false,'',false);
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,p3S1,p3S2,ShiftEnb,'p3Shift2',false,'',false);


    p1S3=prewittcoreNet.addSignal(pixelInType,'pixel1Shift3');
    p2S3=prewittcoreNet.addSignal(pixelInType,'pixel2Shift3');
    p3S3=prewittcoreNet.addSignal(pixelInType,'pixel3Shift3');
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,p1S2,p1S3,ShiftEnb,'p1Shift3',false,'',false);
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,p2S2,p2S3,ShiftEnb,'p2Shift3',false,'',false);
    pirelab.getUnitDelayEnabledComp(prewittcoreNet,p3S2,p3S3,ShiftEnb,'p3Shift3',false,'',false);

    Adder1Type=prewittcoreNet.getType('FixedPoint',...
    'Signed',pixelInType.Signed,...
    'WordLength',pixelInType.WordLength+1,...
    'FractionLength',pixelInType.FractionLength);

    Adder2Type=prewittcoreNet.getType('FixedPoint',...
    'Signed',pixelInType.Signed,...
    'WordLength',pixelInType.WordLength+2,...
    'FractionLength',pixelInType.FractionLength);

    SubDT=prewittcoreNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',pixelInType.WordLength+3,...
    'FractionLength',pixelInType.FractionLength);

    MulDT=prewittcoreNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',SubDT.WordLength+16,...
    'FractionLength',SubDT.FractionLength-18);


    Gvadder1=prewittcoreNet.addSignal(Adder1Type,'GvAdder1');
    pirelab.getAddComp(prewittcoreNet,[p1S3,p2S3],Gvadder1);
    Gvadder1Delay=prewittcoreNet.addSignal(Adder1Type,'GvAdder1Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Gvadder1,Gvadder1Delay);
    p3S3Delay=prewittcoreNet.addSignal(pixelInType,'pixel3Shift3Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,p3S3,p3S3Delay);
    Gvadder2=prewittcoreNet.addSignal(Adder2Type,'GvAdder2');
    pirelab.getAddComp(prewittcoreNet,[Gvadder1Delay,p3S3Delay],Gvadder2);
    Gvadder2Delay=prewittcoreNet.addSignal(Adder2Type,'GvAdder2Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Gvadder2,Gvadder2Delay);

    Gvadder3=prewittcoreNet.addSignal(Adder1Type,'GvAdder3');
    pirelab.getAddComp(prewittcoreNet,[p2S1,p3S1],Gvadder3);
    Gvadder3Delay=prewittcoreNet.addSignal(Adder1Type,'GvAdder3Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Gvadder3,Gvadder3Delay);
    p1S1Delay=prewittcoreNet.addSignal(pixelInType,'pixel1ShiftDelay');
    pirelab.getUnitDelayComp(prewittcoreNet,p1S1,p1S1Delay);
    Gvadder4=prewittcoreNet.addSignal(Adder2Type,'GvAdder4');
    pirelab.getAddComp(prewittcoreNet,[Gvadder3Delay,p1S1Delay],Gvadder4);
    Gvadder4Delay=prewittcoreNet.addSignal(Adder2Type,'GvAdder4Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Gvadder4,Gvadder4Delay);

    Gvadder5=prewittcoreNet.addSignal(SubDT,'GvAdder5');
    pirelab.getSubComp(prewittcoreNet,[Gvadder2Delay,Gvadder4Delay],Gvadder5);
    Gvadder5Delay=prewittcoreNet.addSignal(SubDT,'GvAdder5Delay');
    pirelab.getIntDelayComp(prewittcoreNet,Gvadder5,Gvadder5Delay,3);


    Ghadder1=prewittcoreNet.addSignal(Adder1Type,'GhAdder1');
    pirelab.getAddComp(prewittcoreNet,[p3S1,p3S2],Ghadder1);
    Ghadder1Delay=prewittcoreNet.addSignal(Adder1Type,'GhAdder1Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Ghadder1,Ghadder1Delay);
    Ghadder2=prewittcoreNet.addSignal(Adder2Type,'GhAdder2');
    pirelab.getAddComp(prewittcoreNet,[Ghadder1Delay,p3S3Delay],Ghadder2);
    Ghadder2Delay=prewittcoreNet.addSignal(Adder2Type,'GhAdder2Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Ghadder2,Ghadder2Delay);

    Ghadder3=prewittcoreNet.addSignal(Adder1Type,'GhAdder3');
    pirelab.getAddComp(prewittcoreNet,[p1S2,p1S3],Ghadder3);
    Ghadder3Delay=prewittcoreNet.addSignal(Adder1Type,'GhAdder3Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Ghadder3,Ghadder3Delay);
    Ghadder4=prewittcoreNet.addSignal(Adder2Type,'GhAdder4');
    pirelab.getAddComp(prewittcoreNet,[Ghadder3Delay,p1S1Delay],Ghadder4);
    Ghadder4Delay=prewittcoreNet.addSignal(Adder2Type,'GhAdder4Delay');
    pirelab.getUnitDelayComp(prewittcoreNet,Ghadder4,Ghadder4Delay);

    Ghadder5=prewittcoreNet.addSignal(SubDT,'GhAdder5');
    pirelab.getSubComp(prewittcoreNet,[Ghadder2Delay,Ghadder4Delay],Ghadder5);
    Ghadder5Delay=prewittcoreNet.addSignal(SubDT,'GhAdder5Delay');
    pirelab.getIntDelayComp(prewittcoreNet,Ghadder5,Ghadder5Delay,3);


    coeffvalue=fi(1/6,0,16,18,'RoundingMethod',blockInfo.RoundingMethod,'OverflowAction',blockInfo.OverflowAction);


    GvMul=prewittcoreNet.addSignal(MulDT,'GvMul');

    pirelab.getGainComp(prewittcoreNet,Gvadder5Delay,GvMul,coeffvalue,3,blockInfo.gainOptimMode);

    GhMul=prewittcoreNet.addSignal(MulDT,'GhMul');

    pirelab.getGainComp(prewittcoreNet,Ghadder5Delay,GhMul,coeffvalue,3,blockInfo.gainOptimMode);

    GvMulDelay=prewittcoreNet.addSignal(MulDT,'GvMulDelay');
    pirelab.getIntDelayComp(prewittcoreNet,GvMul,GvMulDelay,2);
    GhMulDelay=prewittcoreNet.addSignal(MulDT,'GhMulDelay');
    pirelab.getIntDelayComp(prewittcoreNet,GhMul,GhMulDelay,2);

    Gv=pirelab.getDTCComp(prewittcoreNet,GvMulDelay,GvOut,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    Gv.addComment('Gv: Cast to the specified gradient data type. Full precision if outputing binary image only');
    Gh=pirelab.getDTCComp(prewittcoreNet,GhMulDelay,GhOut,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    Gh.addComment('Gh: Cast to the specified gradient data type. Full precision if outputing binary image only');

