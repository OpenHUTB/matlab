function[net,finalDelay]=elabDF2T(~,topNet,blockInfo,sectionNum)




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

    inputWL=blockInfo.sectionTypeWL;
    inputFL=blockInfo.sectionTypeFL;

    outputTypeWL=blockInfo.sectionTypeWL;
    outputTypeFL=blockInfo.sectionTypeFL;

    numCoeffWL=blockInfo.numCoeffWL;
    numCoeffFL=blockInfo.numCoeffFL;
    denCoeffWL=blockInfo.denCoeffWL;
    denCoeffFL=blockInfo.denCoeffFL;

    numProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',inputWL+numCoeffWL,...
    'FractionLength',inputFL+numCoeffFL);




    denProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',outputTypeWL+denCoeffWL,...
    'FractionLength',outputTypeFL+denCoeffFL);

    stateWL=max(numProdType.WordLength,denProdType.WordLength)+2;
    stateFL=max(numProdType.FractionLength,denProdType.FractionLength);
    stateType=net.getType('FixedPoint','Signed',true,...
    'WordLength',stateWL,...
    'FractionLength',stateFL);
    denSumType=net.getType('FixedPoint','Signed',true,...
    'WordLength',stateWL,...
    'FractionLength',stateFL);

    inReg=net.addSignal(inputType,'inReg');
    inReg.SimulinkRate=dataRate;
    inValidReg=net.addSignal(ctrlType,'inValidReg');
    inValidReg.SimulinkRate=dataRate;
    inValidRegDly=net.addSignal(ctrlType,'inValidRegDly');
    inValidRegDly.SimulinkRate=dataRate;

    state1=net.addSignal(stateType,'state1');
    state2=net.addSignal(stateType,'state2');
    state1.SimulinkRate=dataRate;
    state2.SimulinkRate=dataRate;

    denSum1=net.addSignal(denSumType,'denSum1');
    denSum1.SimulinkRate=dataRate;
    denSum2a=net.addSignal(denSumType,'denSum2a');
    denSum2a.SimulinkRate=dataRate;
    denSum2b=net.addSignal(denSumType,'denSum2b');
    denSum2b.SimulinkRate=dataRate;
    denSum3=net.addSignal(denSumType,'denSum3');
    denSum3.SimulinkRate=dataRate;


    denProd1=net.addSignal(denProdType,'denProd1');
    denProd2=net.addSignal(denProdType,'denProd2');

    denOut=net.addSignal(outputType,'denOut');






    numPrePipe1=net.addSignal(inputType,'numPrePipe1');
    numPrePipe1.SimulinkRate=dataRate;
    numPrePipe2=net.addSignal(inputType,'numPrePipe2');
    numPrePipe2.SimulinkRate=dataRate;
    numPrePipe3=net.addSignal(inputType,'numPrePipe3');
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



    pirelab.getUnitDelayComp(net,dataIn,inReg,'InRegister');
    pirelab.getUnitDelayComp(net,validIn,inValidReg,'InValidRegister');
    finalDelay=1;


    pirelab.getUnitDelayComp(net,inReg,numPrePipe1,'numPreReg1');
    pirelab.getUnitDelayComp(net,inReg,numPrePipe2,'numPreReg2');
    pirelab.getUnitDelayComp(net,inReg,numPrePipe3,'numPreReg3');
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

    pirelab.getIntDelayComp(net,inValidReg,inValidRegDly,finalDelay-1);

    pirelab.getUnitDelayEnabledComp(net,denSum2a,state1,inValidRegDly,'State1Reg');
    pirelab.getUnitDelayEnabledComp(net,denSum3,state2,inValidRegDly,'State2Reg');


    pirelab.getAddComp(net,[numPostPipe1,state1],denSum1);
    pirelab.getAddComp(net,[denSum2b,denProd1],denSum2a);
    pirelab.getAddComp(net,[numPostPipe2,state2],denSum2b);
    pirelab.getAddComp(net,[numPostPipe3,denProd2],denSum3);

    pirelab.getDTCComp(net,denSum1,denOut,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);

    pirelab.getGainComp(net,denOut,denProd1,-blockInfo.denCoeffs(sectionNum,1),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getGainComp(net,denOut,denProd2,-blockInfo.denCoeffs(sectionNum,2),...
    blockInfo.gainMode,blockInfo.gainOptimMode);

    pirelab.getUnitDelayComp(net,denOut,dataOut,'outputReg');
    finalDelay=finalDelay+1;
    pirelab.getIntDelayComp(net,validIn,validOut,finalDelay);

end
