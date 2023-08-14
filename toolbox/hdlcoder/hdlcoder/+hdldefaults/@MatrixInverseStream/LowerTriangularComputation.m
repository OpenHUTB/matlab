

function LowerTriangularComputation(this,hN,LTCompInSigs,LTCompOutSigs,...
    slRate,blockInfo)



    hLTCompN=pirelab.createNewNetwork(...
    'Name','LowerTriangularComputation',...
    'InportNames',{'storeDone','rdData'},...
    'InportTypes',[LTCompInSigs(1).Type,LTCompInSigs(2).Type],...
    'InportRates',[slRate,slRate],...
    'OutportNames',{'lowerTriangEnb','lowerTriangDone','wrtEnbLT','wrtAddrLT',...
    'wrtDataLT','rdAddrLT'},...
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

    lowerTriangEnb=hLTCompNoutSigs(1);
    lowerTriangDone=hLTCompNoutSigs(2);
    wrtEnbLT=hLTCompNoutSigs(3);
    wrtAddrLT=hLTCompNoutSigs(4);
    wrtDataLT=hLTCompNoutSigs(5);
    rdAddrLT=hLTCompNoutSigs(6);


    if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
        'FractionLength',0);
    else
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
        'FractionLength',0);
    end

    if blockInfo.RowSize>1
        hAddrT=pir_fixpt_t(false,ceil(log2(blockInfo.RowSize)),0);
    else
        hAddrT=pir_fixpt_t(false,1,0);
    end

    hBoolT=pir_boolean_t;
    hInputDataT=pir_single_t;




    colCountS=l_addSignal(hLTCompN,'colCount',hCounterT,slRate);
    rowCountS=l_addSignal(hLTCompN,'rowCount',hCounterT,slRate);
    diagValidInS=l_addSignal(hLTCompN,'diagValidIn',hBoolT,slRate);
    nonDiagValidInS=l_addSignal(hLTCompN,'nonDiagValidIn',hBoolT,slRate);
    rowDoneS=l_addSignal(hLTCompN,'rowDone',hBoolT,slRate);
    diagValidOutS=l_addSignal(hLTCompN,'diagValidOut',hBoolT,slRate);
    diagDataOutS=l_addSignal(hLTCompN,'diagDataOut',hInputDataT,slRate);
    nonDiagValidOutS=l_addSignal(hLTCompN,'nonDiagValidOut',hBoolT,slRate);
    nonDiagDataOutS=l_addSignal(hLTCompN,'nonDiagDataOut',hInputDataT,slRate);
    reciprocalValidS=l_addSignal(hLTCompN,'reciprocalValid',hBoolT,slRate);
    reciprocalDataS=l_addSignal(hLTCompN,'reciprocalData',hInputDataT,slRate);
    writeCountS=l_addSignal(hLTCompN,'writeCount',hCounterT,slRate);



    LTProcControlInSigs=[storeDone,rowDoneS];
    LTProcControlOutSigs=[lowerTriangDone,lowerTriangEnb,...
    colCountS,diagValidInS,nonDiagValidInS,rowCountS];

    this.LTProcessController(hLTCompN,LTProcControlInSigs,...
    LTProcControlOutSigs,slRate,blockInfo);


    LTDiagNonDiagProcessingInSigs=[diagValidInS,nonDiagValidInS,rdData,...
    rowCountS];
    LTDiagNonDiagProcessingOutSigs=[rowDoneS,diagDataOutS,diagValidOutS,nonDiagDataOutS,...
    nonDiagValidOutS,reciprocalValidS,reciprocalDataS];

    this.LTDiagNonDiagProcessing(hLTCompN,LTDiagNonDiagProcessingInSigs,...
    LTDiagNonDiagProcessingOutSigs,hCounterT,hAddrT,hBoolT,hInputDataT,slRate,blockInfo);


    LTMemwriteCounterInSigs=[rowDoneS,diagValidOutS,nonDiagValidOutS];
    LTMemwriteCounterOutSigs=writeCountS;

    this.LTMemwriteCounter(hLTCompN,LTMemwriteCounterInSigs,LTMemwriteCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    LTMemoryControlInSigs=[lowerTriangEnb,colCountS,rowCountS,...
    writeCountS,diagDataOutS,diagValidOutS,nonDiagValidOutS,...
    nonDiagDataOutS,reciprocalValidS,reciprocalDataS];
    LTMemoryControlOutSigs=[wrtEnbLT,wrtAddrLT,...
    wrtDataLT,rdAddrLT];

    this.LTMemoryControl(hLTCompN,LTMemoryControlInSigs,LTMemoryControlOutSigs,...
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
