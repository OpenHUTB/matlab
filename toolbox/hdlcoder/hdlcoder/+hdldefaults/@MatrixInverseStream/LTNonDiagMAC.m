

function LTNonDiagMAC(this,hN,LTNonDiagMACInSigs,LTNonDiagMACOutSigs,...
    hInputDataT,hAddrT,hBoolT,slRate,blockInfo)


    hLTNonDiagMACN=pirelab.createNewNetwork(...
    'Name','LTNonDiagMAC',...
    'InportNames',{'nonDiagValidIn','nonDiagCount','rowDone','readDataMAC','nonDiagDataOut'},...
    'InportTypes',[hBoolT,hAddrT,hBoolT,LTNonDiagMACInSigs(4).Type,hInputDataT],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'accumOutData'},...
    'OutportTypes',hInputDataT);

    hLTNonDiagMACN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTNonDiagMACN.PirOutputSignals)
        hLTNonDiagMACN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTNonDiagMACNinSigs=hLTNonDiagMACN.PirInputSignals;
    hLTNonDiagMACNoutSigs=hLTNonDiagMACN.PirOutputSignals;


    if blockInfo.RowSize>3
        accumOutVectorS=l_addSignal(hLTNonDiagMACN,'accumOutVector',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize-2,0]),slRate);
    else
        accumOutVectorS=l_addSignal(hLTNonDiagMACN,'accumOutVector',...
        hInputDataT,slRate);
    end

    LTParallelAccumInSigs=[hLTNonDiagMACNinSigs(3),hLTNonDiagMACNinSigs(4),...
    hLTNonDiagMACNinSigs(5),hLTNonDiagMACNinSigs(1)];
    LTParallelAccumOutSigs=accumOutVectorS;

    this.LTParallelAccumulator(hLTNonDiagMACN,LTParallelAccumInSigs,LTParallelAccumOutSigs,...
    hBoolT,hInputDataT,slRate,blockInfo);


    RowAccumSelInSigs=[hLTNonDiagMACNinSigs(2),accumOutVectorS];
    RowAccumSelOutSigs=hLTNonDiagMACNoutSigs(1);

    this.RowAccumulatorSelector(hLTNonDiagMACN,RowAccumSelInSigs,RowAccumSelOutSigs,...
    hAddrT,hInputDataT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTNonDiagMACN,LTNonDiagMACInSigs,...
    LTNonDiagMACOutSigs,[hLTNonDiagMACN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


