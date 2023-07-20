function coreNet=elabCore(this,topNet,blockInfo,dataRate)
    coreOrder=blockInfo.coreOrder;
    nMax=blockInfo.nMax;
    listLength=blockInfo.listLength;
    boolType=pir_boolean_t();
    decType=blockInfo.decType;
    betaVecType=pirelab.createPirArrayType(decType,[1,coreOrder]);
    betaReordType=pirelab.createPirArrayType(decType,[1,coreOrder-1]);
    intLlrType=blockInfo.intLlrType;
    intLlrVecType=pirelab.createPirArrayType(intLlrType,[1,coreOrder]);
    llrReordType=pirelab.createPirArrayType(intLlrType,[1,coreOrder-1]);
    stageType=blockInfo.stageType;
    blockType=blockInfo.blockType;
    concatBetaType=blockInfo.concatBetaType;
    pathType=blockInfo.pathType;
    betaPathType=pirelab.createPirArrayType(pathType,[1,nMax]);
    contPathsType=pirelab.createPirArrayType(pathType,[1,listLength]);
    decVecType=pirelab.createPirArrayType(decType,[1,listLength]);
    metricType=blockInfo.metricType;
    intLlrSatLim=blockInfo.intLlrSatLim;


    inportNames={'llrLowerIn','llrUpperIn','llrSrc','beta','betaSrc','mode'};
    inTypes=[intLlrVecType,intLlrVecType,decType,betaVecType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'llrLowerOut','llrUpperOut','llrLeaf'};
    outTypes=[intLlrVecType,intLlrVecType,intLlrType];

    coreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DecoderCore',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    llrLowerIn=coreNet.PirInputSignals(1);
    llrUpperIn=coreNet.PirInputSignals(2);
    llrSrc=coreNet.PirInputSignals(3);
    beta=coreNet.PirInputSignals(4);
    betaSrc=coreNet.PirInputSignals(5);
    mode=coreNet.PirInputSignals(6);

    llrLowerOut=coreNet.PirOutputSignals(1);
    llrUpperOut=coreNet.PirOutputSignals(2);
    llrLeaf=coreNet.PirOutputSignals(3);

    llrLowerIn_reg=coreNet.addSignal(intLlrVecType,'llrLowerIn_reg');
    llrUpperIn_reg=coreNet.addSignal(intLlrVecType,'llrUpperIn_reg');
    mode_reg=coreNet.addSignal(boolType,'mode_reg');

    pirelab.getUnitDelayComp(coreNet,llrLowerIn,llrLowerIn_reg);
    pirelab.getUnitDelayComp(coreNet,llrUpperIn,llrUpperIn_reg);
    pirelab.getUnitDelayComp(coreNet,mode,mode_reg);

    betaReordIdx=[];
    for ii=0:log2(coreOrder)-1
        betaReordIdx=[betaReordIdx,1:2^ii];%#ok
    end

    betaReord=coreNet.addSignal(betaReordType,'betaReord');
    pirelab.getSelectorComp(coreNet,beta,betaReord,'one-based',...
    {'Index vector (dialog)','Index vector (dialog)'},...
    {1,betaReordIdx},...
    {'Inherit from "Index"','Inherit from "Index"'},'2');

    betaCatConst=coreNet.addSignal(decType,'betaCatConst');
    betaCatConst.SimulinkRate=dataRate;
    pirelab.getConstComp(coreNet,betaCatConst,0);

    betaReordCat=coreNet.addSignal(betaVecType,'betaReordCat');
    pirelab.getConcatenateComp(coreNet,[betaReord,betaCatConst],betaReordCat,'Multidimensional array',2);


    betaSel=coreNet.addSignal(betaVecType,'betaSel');
    pirelab.getMultiPortSwitchComp(coreNet,[betaSrc,betaReordCat,beta],betaSel,1);

    betaSel_reg=coreNet.addSignal(betaVecType,'betaSel_reg');
    pirelab.getUnitDelayComp(coreNet,betaSel,betaSel_reg);


    sgnType=pir_ufixpt_t(1,0);
    sgnVecType=pirelab.createPirArrayType(sgnType,[1,coreOrder]);
    lowerSgn=coreNet.addSignal(sgnVecType,'lowerSgn');
    upperSgn=coreNet.addSignal(sgnVecType,'upperSign');
    pirelab.getBitSliceComp(coreNet,llrLowerIn_reg,lowerSgn,intLlrType.WordLength-1,intLlrType.WordLength-1);
    pirelab.getBitSliceComp(coreNet,llrUpperIn_reg,upperSgn,intLlrType.WordLength-1,intLlrType.WordLength-1);

    sgnXor=coreNet.addSignal(sgnVecType,'sgnXor');
    pirelab.getLogicComp(coreNet,[lowerSgn,upperSgn],sgnXor,'xor');

    lowerAbs=coreNet.addSignal(intLlrVecType,'lowerAbs');
    upperAbs=coreNet.addSignal(intLlrVecType,'upperAbs');
    pirelab.getAbsComp(coreNet,llrLowerIn_reg,lowerAbs);
    pirelab.getAbsComp(coreNet,llrUpperIn_reg,upperAbs);

    testa=pirelab.demuxSignal(coreNet,lowerAbs);
    testb=pirelab.demuxSignal(coreNet,upperAbs);

    for ii=1:coreOrder
        tempMinAbs(ii)=coreNet.addSignal(intLlrType,['tempMinAbs_',num2str(ii-1)]);%#ok
        pirelab.getMinMaxComp(coreNet,[testa(ii),testb(ii)],tempMinAbs(ii),'llrMin','min');
    end

    minAbs=coreNet.addSignal(intLlrVecType,'minAbs');
    pirelab.getConcatenateComp(coreNet,tempMinAbs,minAbs,'Multidimensional array',2);

    negMinAbs=coreNet.addSignal(intLlrVecType,'negMinAbs');
    pirelab.getUnaryMinusComp(coreNet,minAbs,negMinAbs);

    leftOut=coreNet.addSignal(intLlrVecType,'leftOut');
    pirelab.getMultiPortSwitchComp(coreNet,[sgnXor,minAbs,negMinAbs],leftOut,2);


    negLlrLowerIn_reg=coreNet.addSignal(intLlrVecType,'negLlrLowerIn');
    pirelab.getUnaryMinusComp(coreNet,llrLowerIn_reg,negLlrLowerIn_reg);

    llrLowerInSel=coreNet.addSignal(intLlrVecType,'llrLowerInSel');
    pirelab.getMultiPortSwitchComp(coreNet,[betaSel_reg,llrLowerIn_reg,negLlrLowerIn_reg],llrLowerInSel,2);

    llrSum=coreNet.addSignal(intLlrVecType,'llrSum');
    pirelab.getAddComp(coreNet,[llrLowerInSel,llrUpperIn_reg],llrSum,'Floor','Saturate');

    rightOut=coreNet.addSignal(intLlrVecType,'rightOut');
    pirelab.getSaturateComp(coreNet,llrSum,rightOut,-intLlrSatLim,intLlrSatLim);


    leftRightSel=coreNet.addSignal(intLlrVecType,'leftRightSel');
    pirelab.getMultiPortSwitchComp(coreNet,[mode_reg,leftOut,rightOut],leftRightSel,1);

    leftRightSel_reg=coreNet.addSignal(intLlrVecType,'leftRightSel_reg');
    pirelab.getUnitDelayComp(coreNet,leftRightSel,leftRightSel_reg);

    llrLowerReordIdx=[1,3,4,7,8,9,10,0,1,2,3,4,5,6,7]+1;
    llrUpperReordIdx=[2,5,6,11,12,13,14,8,9,10,11,12,13,14,15]+1;

    llrLowerReord=coreNet.addSignal(llrReordType,'llrLowerReord');
    llrUpperReord=coreNet.addSignal(llrReordType,'llrUpperReord');
    pirelab.getSelectorComp(coreNet,leftRightSel_reg,llrLowerReord,'one-based',...
    {'Index vector (dialog)','Index vector (dialog)'},...
    {1,llrLowerReordIdx},...
    {'Inherit from "Index"','Inherit from "Index"'},'2');
    pirelab.getSelectorComp(coreNet,leftRightSel_reg,llrUpperReord,'one-based',...
    {'Index vector (dialog)','Index vector (dialog)'},...
    {1,llrUpperReordIdx},...
    {'Inherit from "Index"','Inherit from "Index"'},'2');

    llrCatConst=coreNet.addSignal(intLlrType,'llrCatConst');
    llrCatConst.SimulinkRate=dataRate;
    pirelab.getConstComp(coreNet,llrCatConst,0);

    llrLowerReordCat=coreNet.addSignal(intLlrVecType,'llrLowerReordCat');
    llrUpperReordCat=coreNet.addSignal(intLlrVecType,'llrUpperReordCat');
    pirelab.getConcatenateComp(coreNet,[llrLowerReord,llrCatConst],llrLowerReordCat,'Multidimensional array',2);
    pirelab.getConcatenateComp(coreNet,[llrUpperReord,llrCatConst],llrUpperReordCat,'Multidimensional array',2);

    pirelab.getMultiPortSwitchComp(coreNet,[llrSrc,leftRightSel_reg,llrLowerReordCat],llrLowerOut,1);
    pirelab.getMultiPortSwitchComp(coreNet,[llrSrc,leftRightSel_reg,llrUpperReordCat],llrUpperOut,1);

    pirelab.getSelectorComp(coreNet,leftRightSel,llrLeaf,'one-based',...
    {'Index vector (dialog)','Index vector (dialog)'},...
    {1,1},...
    {'Inherit from "Index"','Inherit from "Index"'},'2');
end
