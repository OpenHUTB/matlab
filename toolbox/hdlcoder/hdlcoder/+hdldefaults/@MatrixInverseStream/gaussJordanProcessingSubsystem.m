

function gaussJordanProcessingSubsystem(this,hN,LTCompInSigs,LTCompOutSigs,...
    slRate,blockInfo)





    hLTCompN=pirelab.createNewNetwork(...
    'Name','gaussJordanProcessingSubsystem',...
    'InportNames',{'storeDone','rdData'},...
    'InportTypes',[LTCompInSigs(1).Type,LTCompInSigs(2).Type],...
    'InportRates',[slRate,slRate],...
    'OutportNames',{'processingEnb','wrtEnbLT','wrtAddrLT',...
    'wrtDataLT','rdAddrLT','invFinish'},...
    'OutportTypes',[LTCompOutSigs(1).Type,LTCompOutSigs(2).Type,...
    LTCompOutSigs(3).Type,LTCompOutSigs(4).Type,...
    LTCompOutSigs(5).Type,LTCompOutSigs(6).Type]);

    hLTCompN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTCompN.PirOutputSignals)
        hLTCompN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTCompNinSigs=hLTCompN.PirInputSignals;
    hLTCompNoutSigs=hLTCompN.PirOutputSignals;


    storeDone=hLTCompNinSigs(1);
    rdData=hLTCompNinSigs(2);

    processingEnb=hLTCompNoutSigs(1);
    wrtEnbLT=hLTCompNoutSigs(2);
    wrtAddrLT=hLTCompNoutSigs(3);
    wrtDataLT=hLTCompNoutSigs(4);
    rdAddrLT=hLTCompNoutSigs(5);
    invFinish=hLTCompNoutSigs(6);


    hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.MatrixSize))+1,...
    'FractionLength',0);

    if blockInfo.MatrixSize>1
        hAddrT=pir_fixpt_t(false,ceil(log2(blockInfo.MatrixSize)),0);
    else
        hAddrT=pir_fixpt_t(false,1,0);
    end

    hBoolT=pir_boolean_t;

    hInputDataT=LTCompInSigs(2).Type.BaseType;

    if blockInfo.MatrixSize==1
        hArrayT=hInputDataT;
    else
        hArrayT=pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize,0]);
    end


    swapDone=l_addSignal(hLTCompN,'swapDone',hBoolT,slRate);
    swapEnb=l_addSignal(hLTCompN,'swapEnb',hBoolT,slRate);
    isDiagZero=l_addSignal(hLTCompN,'isDiagZero',hBoolT,slRate);
    rowFinish=l_addSignal(hLTCompN,'rowFinish',hBoolT,slRate);
    colCount=l_addSignal(hLTCompN,'colCount',hCounterT,slRate);
    diagValidIn=l_addSignal(hLTCompN,'diagValidIn',hBoolT,slRate);
    nonDiagValidIn=l_addSignal(hLTCompN,'nonDiagValidIn',hBoolT,slRate);
    rowCount=l_addSignal(hLTCompN,'rowCount',hCounterT,slRate);
    swapReadEnable=l_addSignal(hLTCompN,'swapReadEnable',hBoolT,slRate);
    nonDiagValidOut=l_addSignal(hLTCompN,'nonDiagValidOut',hBoolT,slRate);
    nonDiagDataOut1=l_addSignal(hLTCompN,'dataOut1',hInputDataT,slRate);
    diagValidOut=l_addSignal(hLTCompN,'diagValidOut',hBoolT,slRate);
    swapDataOut1=l_addSignal(hLTCompN,'swapDataOut1',hArrayT,slRate);
    swapAddrOut=l_addSignal(hLTCompN,'swapAddrOut',hCounterT,slRate);
    swapEnableOut=l_addSignal(hLTCompN,'swapEnableOut',hBoolT,slRate);
    rowCountOut=l_addSignal(hLTCompN,'rowCountOut',hCounterT,slRate);
    colCountOut=l_addSignal(hLTCompN,'colCountOut',hCounterT,slRate);
    swapDataOut2=l_addSignal(hLTCompN,'swapDataOut2',hArrayT,slRate);
    nonDiagDataOut2=l_addSignal(hLTCompN,'dataOut2',hInputDataT,slRate);
    diagDataOut1=l_addSignal(hLTCompN,'diagDataOut1',hInputDataT,slRate);
    diagDataOut2=l_addSignal(hLTCompN,'diagDataOut2',hInputDataT,slRate);



    LTProcControlInSigs=[invFinish,swapDone,storeDone,swapEnb,isDiagZero,rowFinish];
    LTProcControlOutSigs=[processingEnb,colCount,diagValidIn,nonDiagValidIn,rowCount,swapReadEnable];

    this.gaussJordanProcessController(hLTCompN,LTProcControlInSigs,...
    LTProcControlOutSigs,slRate,blockInfo);


    LTDiagNonDiagProcessingInSigs=[diagValidIn,nonDiagValidIn,rdData,...
    rowCount,colCount,swapReadEnable];

    LTDiagNonDiagProcessingOutSigs=[nonDiagValidOut,nonDiagDataOut1,diagValidOut,...
    swapDataOut1,swapAddrOut,swapEnb,...
    swapEnableOut,rowCountOut,colCountOut,...
    swapDataOut2,nonDiagDataOut2,diagDataOut1,swapDone,...
    diagDataOut2,isDiagZero,rowFinish,invFinish];

    this.gaussJordanDiagNonDiagProcessing(hLTCompN,LTDiagNonDiagProcessingInSigs,...
    LTDiagNonDiagProcessingOutSigs,hCounterT,hBoolT,hInputDataT,slRate,blockInfo);



    LTMemoryControlInSigs=[processingEnb,colCount,nonDiagValidOut,...
    nonDiagDataOut1,diagValidOut,swapDataOut1,swapAddrOut,...
    swapEnb,swapEnableOut,rowCountOut,colCountOut,swapDataOut2,...
    nonDiagDataOut2,diagDataOut1,diagDataOut2];
    LTMemoryControlOutSigs=[wrtEnbLT,wrtAddrLT,...
    wrtDataLT,rdAddrLT];

    this.gaussJordanMemoryControl(hLTCompN,LTMemoryControlInSigs,LTMemoryControlOutSigs,...
    hBoolT,hAddrT,hCounterT,hInputDataT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTCompN,LTCompInSigs,LTCompOutSigs,...
    [hLTCompN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


