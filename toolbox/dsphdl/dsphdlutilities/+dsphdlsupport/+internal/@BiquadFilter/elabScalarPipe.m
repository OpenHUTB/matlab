function[net,finalDelay]=elabScalarPipe(this,topNet,blockInfo,sectionNum)




    inportNames={'dataIn','validIn'};
    outportNames={'dataOut','validOut'};

    ctrlType=pir_boolean_t();

    outputType=topNet.getType('FixedPoint','Signed',blockInfo.sectionTypeSign,...
    'WordLength',blockInfo.sectionTypeWL,...
    'FractionLength',blockInfo.sectionTypeFL);
    inputType=topNet.getType('FixedPoint','Signed',blockInfo.sectionTypeSign,...
    'WordLength',blockInfo.sectionTypeWL,...
    'FractionLength',blockInfo.sectionTypeFL);

    net=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('BiquadPipeSection%d',sectionNum),...
    'InportNames',inportNames,...
    'InportTypes',[inputType,ctrlType],...
    'InportRates',repmat(blockInfo.inRate,1,2),...
    'OutportNames',outportNames,...
    'OutportTypes',[outputType,ctrlType]...
    );





    dataIn=net.PirInputSignals(1);
    validIn=net.PirInputSignals(2);
    dataRate=blockInfo.inRate;

    dataOut=net.PirOutputSignals(1);
    validOut=net.PirOutputSignals(2);
    dataOut.SimulinkRate=dataRate;
    validOut.SimulinkRate=dataRate;

    outputTypeWL=blockInfo.sectionTypeWL;
    outputTypeFL=blockInfo.sectionTypeFL;

    denCoeffWL=blockInfo.denCoeffWL;
    denCoeffFL=blockInfo.denCoeffFL;

    denProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',outputTypeWL+denCoeffWL,...
    'FractionLength',outputTypeFL+denCoeffFL);

    state1Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',denProdType.WordLength+1,...
    'FractionLength',denProdType.FractionLength);
    state2Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',denProdType.WordLength,...
    'FractionLength',denProdType.FractionLength);

    inReg=net.addSignal(inputType,'inReg');
    inReg.SimulinkRate=dataRate;
    inValidReg=net.addSignal(ctrlType,'inValidReg');
    inValidReg.SimulinkRate=dataRate;

    delayvalidout=net.addSignal(ctrlType,'delayvalidreg');
    delayvalidout.SimulinkRate=dataRate;
    prevalidout=net.addSignal(ctrlType,'prevalidreg');
    prevalidout.SimulinkRate=dataRate;

    state1=net.addSignal(state1Type,'state1');
    state2=net.addSignal(state2Type,'state2');
    state1.SimulinkRate=dataRate;
    state2.SimulinkRate=dataRate;

    den1InPipe1=net.addSignal(outputType,'den1InPipe1');
    den1InPipe1.SimulinkRate=dataRate;
    den1InPipe2=net.addSignal(outputType,'den1InPipe2');
    den1InPipe2.SimulinkRate=dataRate;
    den1OutPipe1=net.addSignal(denProdType,'den1OutPipe1');
    den1OutPipe1.SimulinkRate=dataRate;

    den2InPipe1=net.addSignal(outputType,'den2InPipe1');
    den2InPipe1.SimulinkRate=dataRate;
    den2InPipe2=net.addSignal(outputType,'den2InPipe2');
    den2InPipe2.SimulinkRate=dataRate;
    den2OutPipe1=net.addSignal(denProdType,'den2OutPipe1');
    den2OutPipe1.SimulinkRate=dataRate;

    denProd1=net.addSignal(denProdType,'denProd1');
    denProd2=net.addSignal(denProdType,'denProd2');

    denOut=net.addSignal(outputType,'denOut');
    denOut.SimulinkRate=dataRate;
    denOutDelay=net.addSignal(outputType,'denOutDelay');
    denOutDelay.SimulinkRate=dataRate;



    pirelab.getUnitDelayComp(net,dataIn,inReg,'InRegister');
    pirelab.getUnitDelayComp(net,validIn,inValidReg,'InValidRegister');
    finalDelay=1;


    [numout,~,numdelay]=elabInlineFIR(this,net,blockInfo,...
    cast(blockInfo.PipeNumerator(sectionNum,:),'like',blockInfo.numCoeffs),...
    inReg,inValidReg,sprintf('Num%d',sectionNum));
    finalDelay=finalDelay+2;


    quantizedNewNumerator=fi(blockInfo.PipeNewNumerator,1,blockInfo.denCoeffs.WordLength);
    [newnumout,~,newnumdelay]=elabInlineFIR(this,net,blockInfo,...
    quantizedNewNumerator(sectionNum,:),...
    numout,inValidReg,sprintf('NumZero%d',sectionNum));
    finalDelay=finalDelay+newnumdelay;




    newNumType=newnumout.Type;
    newNumIntBits=newNumType.WordLength+newNumType.FractionLength;
    state1IntBits=state1Type.WordLength+state1Type.FractionLength;
    denSum1FL=min(state1Type.FractionLength,newNumType.FractionLength);
    denSum1WL=max(newNumIntBits,state1IntBits)-denSum1FL;

    denSum1Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',denSum1WL,...
    'FractionLength',denSum1FL);
    denSum2Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',state2Type.WordLength+1,...
    'FractionLength',state2Type.FractionLength);
    denSum1=net.addSignal(denSum1Type,'denSum1');
    denSum1.SimulinkRate=dataRate;
    denSum2=net.addSignal(denSum2Type,'denSum2');
    denSum2.SimulinkRate=dataRate;

    pirelab.getUnitDelayEnabledComp(net,denSum2,state1,inValidReg,'State1Reg');
    pirelab.getUnitDelayEnabledComp(net,den2OutPipe1,state2,inValidReg,'State2Reg');


    pirelab.getAddComp(net,[newnumout,state1],denSum1);
    pirelab.getAddComp(net,[den1OutPipe1,state2],denSum2);

    pirelab.getDTCComp(net,denSum1,denOut,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);

    combinedSize=blockInfo.PipeLevel*blockInfo.FrameSize;

    pirelab.getUnitDelayEnabledComp(net,denOut,den1InPipe1,inValidReg,'den1InPipeReg1');
    pirelab.getUnitDelayEnabledComp(net,den1InPipe1,den1InPipe2,inValidReg,'den1InPipeReg2');
    pirelab.getGainComp(net,den1InPipe2,denProd1,...
    -fi(blockInfo.PipeDenominator(sectionNum,combinedSize+1),1,denCoeffWL,-denCoeffFL),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getUnitDelayEnabledComp(net,denProd1,den1OutPipe1,inValidReg,'den1OutPipeReg1');

    pirelab.getIntDelayEnabledComp(net,denOut,denOutDelay,inValidReg,3,'den2DelayReg');
    pirelab.getUnitDelayEnabledComp(net,denOutDelay,den2InPipe1,inValidReg,'den2InPipeReg1');
    pirelab.getUnitDelayEnabledComp(net,den2InPipe1,den2InPipe2,inValidReg,'den2InPipeReg2');
    pirelab.getGainComp(net,den2InPipe2,denProd2,...
    -fi(blockInfo.PipeDenominator(sectionNum,2*combinedSize+1),1,denCoeffWL,-denCoeffFL),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getUnitDelayEnabledComp(net,denProd2,den2OutPipe1,inValidReg,'den2OutPipeReg1');

    finalDelay=finalDelay+4;

    pirelab.getIntDelayEnabledComp(net,inValidReg,delayvalidout,inValidReg,finalDelay);
    pirelab.getLogicComp(net,[inValidReg,delayvalidout],prevalidout,'and');


    pirelab.getUnitDelayEnabledComp(net,denOut,dataOut,inValidReg,'outputReg');
    pirelab.getUnitDelayComp(net,prevalidout,validOut,'validoutputreg');

end
