

function gaussJordanDiagNonDiagProcessing(this,hN,LTDiagNonDiagProcessingInSigs,LTDiagNonDiagProcessingOutSigs,...
    hCounterT,hBoolT,hInputDataT,slRate,blockInfo)





    hLTDiagNonDiagProcessingN=pirelab.createNewNetwork(...
    'Name','gaussJordanDiagNonDiagProcessing',...
    'InportNames',{'diagValidIn','nonDiagValidIn','readData','rowCount','colCount','swapReadEnable'},...
    'InportTypes',[hBoolT,hBoolT,LTDiagNonDiagProcessingInSigs(3).Type,hCounterT,hCounterT,hBoolT],...
    'InportRates',slRate*ones(1,6),...
    'OutportNames',{'nonDiagValidOut','dataOut1','diagValidOut','swapDataOut1',...
    'swapAddrOut','swapEnb','swapEnableOut','rowCountOut','colCountOut','swapDataOut2',...
    'dataOut2','diagDataOut1','swapDone','diagDataOut2','isDiagZero','rowFinish','invFinish'},...
    'OutportTypes',[hBoolT,hInputDataT,hBoolT,LTDiagNonDiagProcessingOutSigs(4).Type,...
    LTDiagNonDiagProcessingOutSigs(5).Type,hBoolT,LTDiagNonDiagProcessingOutSigs(7).Type,...
    hCounterT,hCounterT,LTDiagNonDiagProcessingOutSigs(10).Type,...
    hInputDataT,hInputDataT,hBoolT,hInputDataT,hBoolT,hBoolT,hBoolT]);

    hLTDiagNonDiagProcessingN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTDiagNonDiagProcessingN.PirOutputSignals)
        hLTDiagNonDiagProcessingN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTDiagNonDiagProcessingNinSigs=hLTDiagNonDiagProcessingN.PirInputSignals;
    hLTDiagNonDiagProcessingNoutSigs=hLTDiagNonDiagProcessingN.PirOutputSignals;



    diagValidIn=hLTDiagNonDiagProcessingNinSigs(1);
    nonDiagValidIn=hLTDiagNonDiagProcessingNinSigs(2);
    readData=hLTDiagNonDiagProcessingNinSigs(3);
    rowCount=hLTDiagNonDiagProcessingNinSigs(4);
    colCount=hLTDiagNonDiagProcessingNinSigs(5);
    swapReadEnable=hLTDiagNonDiagProcessingNinSigs(6);

    nonDiagValidOut=hLTDiagNonDiagProcessingNoutSigs(1);
    nonDiagDataOut1=hLTDiagNonDiagProcessingNoutSigs(2);
    diagValidOut=hLTDiagNonDiagProcessingNoutSigs(3);
    swapDataOut1=hLTDiagNonDiagProcessingNoutSigs(4);
    swapAddrOut=hLTDiagNonDiagProcessingNoutSigs(5);
    swapEnb=hLTDiagNonDiagProcessingNoutSigs(6);
    swapEnableOut=hLTDiagNonDiagProcessingNoutSigs(7);
    rowCountOut=hLTDiagNonDiagProcessingNoutSigs(8);
    colCountOut=hLTDiagNonDiagProcessingNoutSigs(9);
    swapDataOut2=hLTDiagNonDiagProcessingNoutSigs(10);
    nonDiagDataOut2=hLTDiagNonDiagProcessingNoutSigs(11);
    diagDataOut1=hLTDiagNonDiagProcessingNoutSigs(12);
    swapDone=hLTDiagNonDiagProcessingNoutSigs(13);
    diagDataOut2=hLTDiagNonDiagProcessingNoutSigs(14);
    isDiagZero=hLTDiagNonDiagProcessingNoutSigs(15);
    rowFinish=hLTDiagNonDiagProcessingNoutSigs(16);
    invFinish=hLTDiagNonDiagProcessingNoutSigs(17);





    if blockInfo.MatrixSize>1
        readDataIn=l_addSignal(hLTDiagNonDiagProcessingN,'readDataIn',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize,0]),slRate);
    else
        readDataIn=l_addSignal(hLTDiagNonDiagProcessingN,'readDataIn',...
        hInputDataT,slRate);
    end

    diagDataIn=l_addSignal(hLTDiagNonDiagProcessingN,'diagDataIn',hInputDataT,slRate);
    reciprocalValid=l_addSignal(hLTDiagNonDiagProcessingN,'reciprocalValid',hBoolT,slRate);
    reciprocalData=l_addSignal(hLTDiagNonDiagProcessingN,'reciprocalData',hInputDataT,slRate);



    pirTyp1=pir_boolean_t;



    CompareToConstant_out1_s6=l_addSignal(hLTDiagNonDiagProcessingN,sprintf('Compare\nTo Constant_out1'),pirTyp1,slRate);

    LogicalOperator_out1_s18=l_addSignal(hLTDiagNonDiagProcessingN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);





    pirelab.getCounterComp(hLTDiagNonDiagProcessingN,...
    [CompareToConstant_out1_s6,LogicalOperator_out1_s18],...
    rowCountOut,...
    'Count limited',1,1,blockInfo.MatrixSize,1,0,1,0,'HDL Counter',1);



    pirelab.getCompareToValueComp(hLTDiagNonDiagProcessingN,...
    rowCountOut,...
    CompareToConstant_out1_s6,...
    '==',blockInfo.MatrixSize,...
    sprintf('Compare\nTo Constant'),0);



    pirelab.getLogicComp(hLTDiagNonDiagProcessingN,...
    [nonDiagValidOut,diagValidOut],...
    LogicalOperator_out1_s18,...
    'or',sprintf('Logical\nOperator'));


    pirelab.getSelectorComp(hLTDiagNonDiagProcessingN,...
    readData,...
    readDataIn,...
    'One-based',{'Index vector (dialog)'},...
    {1:blockInfo.MatrixSize},...
    {'1'},'1',...
    'Selector');



    DiagDataSelectorInSigs=[rowCount,readDataIn];
    DiagDataSelectorOutSigs=diagDataIn;

    this.gaussJordanDiagDataSelector(hLTDiagNonDiagProcessingN,DiagDataSelectorInSigs,DiagDataSelectorOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo);


    LTDiagDataComputationInSigs=[diagValidIn,diagDataIn,swapDone];
    LTDiagDataComputationOutSigs=[reciprocalValid,reciprocalData];

    this.gaussJordanDiagDataInpGen(hLTDiagNonDiagProcessingN,LTDiagDataComputationInSigs,LTDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,slRate);


    gaussJordanSwapLogicInSigs=[diagValidIn,rowCount,readData,colCount,swapReadEnable];
    gaussJordanSwapLogicOutSigs=[swapDataOut1,swapAddrOut,swapEnb,swapEnableOut,swapDone,isDiagZero,swapDataOut2];

    this.gaussJordanSwappingLogic(hLTDiagNonDiagProcessingN,gaussJordanSwapLogicInSigs,gaussJordanSwapLogicOutSigs,hInputDataT,hBoolT,hCounterT,slRate,blockInfo);



    LTNonDiagDataComputationInSigs=[reciprocalValid,reciprocalData,rowCount,readData,nonDiagValidIn,colCount];
    LTNonDiagDataComputationOutSigs=[nonDiagValidOut,nonDiagDataOut1,diagValidOut,rowFinish,colCountOut,invFinish,nonDiagDataOut2,diagDataOut1,diagDataOut2];

    this.gaussJordanDiagNonDiagDataComputation(hLTDiagNonDiagProcessingN,LTNonDiagDataComputationInSigs,LTNonDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,hCounterT,slRate,blockInfo);






    pirelab.instantiateNetwork(hN,hLTDiagNonDiagProcessingN,LTDiagNonDiagProcessingInSigs,...
    LTDiagNonDiagProcessingOutSigs,[hLTDiagNonDiagProcessingN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
