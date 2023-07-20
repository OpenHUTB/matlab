function[net,finalDelay]=elabDF2(~,topNet,blockInfo,sectionNum)




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
    'Name',sprintf('BiquadDF2Section%d',sectionNum),...
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

    stateType=net.getType('FixedPoint','Signed',true,...
    'WordLength',blockInfo.accumTypeWL,...
    'FractionLength',blockInfo.accumTypeFL);
    stateWL=stateType.WordLength;
    stateFL=stateType.FractionLength;

    numCoeffWL=blockInfo.numCoeffWL;
    numCoeffFL=blockInfo.numCoeffFL;
    denCoeffWL=blockInfo.denCoeffWL;
    denCoeffFL=blockInfo.denCoeffFL;

    numProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',stateWL+numCoeffWL,...
    'FractionLength',stateFL+numCoeffFL);
    numSumType=net.getType('FixedPoint','Signed',true,...
    'WordLength',numProdType.WordLength+3,...
    'FractionLength',numProdType.FractionLength);

    denProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',stateWL+denCoeffWL,...
    'FractionLength',stateFL+denCoeffFL);
    denSumType=net.getType('FixedPoint','Signed',true,...
    'WordLength',denProdType.WordLength+3,...
    'FractionLength',denProdType.FractionLength);

    inReg=net.addSignal(inputType,'inReg');
    inReg.SimulinkRate=dataRate;
    inValidReg=net.addSignal(ctrlType,'inValidReg');
    inValidReg.SimulinkRate=dataRate;
    state1=net.addSignal(stateType,'state1');
    state2=net.addSignal(stateType,'state2');
    state1.SimulinkRate=dataRate;
    state2.SimulinkRate=dataRate;

    denSum1=net.addSignal(denSumType,'denSum1');
    denSum1.SimulinkRate=dataRate;
    denSum2=net.addSignal(denSumType,'denSum2');
    denSum2.SimulinkRate=dataRate;
    denProd1=net.addSignal(denProdType,'denProd1');
    denProd2=net.addSignal(denProdType,'denProd2');

    denOut=net.addSignal(stateType,'denOut');

    numSum1=net.addSignal(numSumType,'numSum1');
    numSum2=net.addSignal(numSumType,'numSum2');
    numSum2Dly=net.addSignal(numSumType,'numSum2Dly');
    numSumReg=net.addSignal(numSumType,'numSumReg');

    numPrePipe1=net.addSignal(stateType,'numPrePipe1');
    numPrePipe1.SimulinkRate=dataRate;
    numPrePipe2=net.addSignal(stateType,'numPrePipe2');
    numPrePipe2.SimulinkRate=dataRate;
    numPrePipe3=net.addSignal(stateType,'numPrePipe3');
    numPrePipe3.SimulinkRate=dataRate;

    numProd1=net.addSignal(numProdType,'numProd1');
    numProd2=net.addSignal(numProdType,'numProd2');
    numProd3=net.addSignal(numProdType,'numProd3');

    numPostPipe1=net.addSignal(numProdType,'numPostPipe1');
    numPostPipe1.SimulinkRate=dataRate;
    numPostPipe2=net.addSignal(numProdType,'numPostPipe2');
    numPostPipe2.SimulinkRate=dataRate;
    numPostPipe3=net.addSignal(numProdType,'numPostPipe3');
    numPostPipe3.SimulinkRate=dataRate;
    numPostPipe1Dly=net.addSignal(numProdType,'numPostPipe1Dly');
    numPostPipe1Dly.SimulinkRate=dataRate;

    outConvert=net.addSignal(outputType,'convertOut');




    pirelab.getUnitDelayComp(net,dataIn,inReg,'InRegister');
    pirelab.getUnitDelayComp(net,validIn,inValidReg,'InValidRegister');
    finalDelay=1;

    pirelab.getUnitDelayEnabledComp(net,denOut,state1,inValidReg,'State1Reg');
    pirelab.getUnitDelayEnabledComp(net,state1,state2,inValidReg,'State2Reg');

    pirelab.getAddComp(net,[inReg,denSum2],denSum1);
    pirelab.getAddComp(net,[denProd1,denProd2],denSum2);

    pirelab.getDTCComp(net,denSum1,denOut,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);

    pirelab.getGainComp(net,state1,denProd1,-blockInfo.denCoeffs(sectionNum,1),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getGainComp(net,state2,denProd2,-blockInfo.denCoeffs(sectionNum,2),...
    blockInfo.gainMode,blockInfo.gainOptimMode);


    pirelab.getUnitDelayComp(net,denOut,numPrePipe1,'numPreReg1');
    pirelab.getUnitDelayComp(net,state1,numPrePipe2,'numPreReg2');
    pirelab.getUnitDelayComp(net,state2,numPrePipe3,'numPreReg3');
    finalDelay=finalDelay+1;

    pirelab.getGainComp(net,numPrePipe1,numProd1,blockInfo.numCoeffs(sectionNum,1),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getGainComp(net,numPrePipe2,numProd2,blockInfo.numCoeffs(sectionNum,2),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getGainComp(net,numPrePipe3,numProd3,blockInfo.numCoeffs(sectionNum,3),...
    blockInfo.gainMode,blockInfo.gainOptimMode);

    pirelab.getUnitDelayComp(net,numProd1,numPostPipe1,'numPostReg1');
    pirelab.getUnitDelayComp(net,numProd2,numPostPipe2,'numPostReg2');
    pirelab.getUnitDelayComp(net,numProd3,numPostPipe3,'numPostReg3');
    finalDelay=finalDelay+1;

    pirelab.getUnitDelayComp(net,numPostPipe1,numPostPipe1Dly,'numDlyReg1');
    finalDelay=finalDelay+1;

    pirelab.getAddComp(net,[numPostPipe1Dly,numSum2Dly],numSum1);

    pirelab.getAddComp(net,[numPostPipe2,numPostPipe3],numSum2);
    pirelab.getUnitDelayComp(net,numSum2,numSum2Dly,'numSumDlyReg2');


    pirelab.getUnitDelayComp(net,numSum1,numSumReg,'numSumReg');
    pirelab.getDTCComp(net,numSumReg,outConvert,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    pirelab.getUnitDelayComp(net,outConvert,dataOut,'outputReg');
    finalDelay=finalDelay+2;
    pirelab.getIntDelayComp(net,validIn,validOut,finalDelay);

end
