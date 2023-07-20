

function LTDiagNonDiagProcessing(this,hN,LTDiagNonDiagProcessingInSigs,LTDiagNonDiagProcessingOutSigs,...
    hCounterT,hAddrT,hBoolT,hInputDataT,slRate,blockInfo)



    hLTDiagNonDiagProcessingN=pirelab.createNewNetwork(...
    'Name','LTDiagNonDiagProcessing',...
    'InportNames',{'diagValidIn','nonDiagValidIn','readData','rowCount'},...
    'InportTypes',[hBoolT,hBoolT,LTDiagNonDiagProcessingInSigs(3).Type,hCounterT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'rowDone','diagDataOut','diagValidOut','nonDiagDataOut',...
    'nonDiagValidOut','reciprocalValid','reciprocalData'},...
    'OutportTypes',[hBoolT,hInputDataT,hBoolT,hInputDataT,hBoolT,hBoolT,hInputDataT]);

    hLTDiagNonDiagProcessingN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTDiagNonDiagProcessingN.PirOutputSignals)
        hLTDiagNonDiagProcessingN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTDiagNonDiagProcessingNinSigs=hLTDiagNonDiagProcessingN.PirInputSignals;
    hLTDiagNonDiagProcessingNoutSigs=hLTDiagNonDiagProcessingN.PirOutputSignals;



    if blockInfo.RowSize>1
        readDataInS=l_addSignal(hLTDiagNonDiagProcessingN,'readDataIn',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize,0]),slRate);
    else
        readDataInS=l_addSignal(hLTDiagNonDiagProcessingN,'readDataIn',...
        hInputDataT,slRate);
    end

    diagDataInS=l_addSignal(hLTDiagNonDiagProcessingN,'diagDataIn',hInputDataT,slRate);

    if blockInfo.RowSize>1
        readDataNonDiagS=l_addSignal(hLTDiagNonDiagProcessingN,'readDataNonDiag',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize,0]),slRate);
    else
        readDataNonDiagS=l_addSignal(hLTDiagNonDiagProcessingN,'readDataNonDiag',...
        hInputDataT,slRate);
    end

    DiagDataSelectorInSigs=[hLTDiagNonDiagProcessingNinSigs(4),readDataInS];
    DiagDataSelectorOutSigs=diagDataInS;

    this.DiagDataSelector(hLTDiagNonDiagProcessingN,DiagDataSelectorInSigs,DiagDataSelectorOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo);


    LTDiagDataComputationInSigs=[hLTDiagNonDiagProcessingNinSigs(1),diagDataInS,...
    hLTDiagNonDiagProcessingNoutSigs(5),hLTDiagNonDiagProcessingNoutSigs(4)];
    LTDiagDataComputationOutSigs=[hLTDiagNonDiagProcessingNoutSigs(3),hLTDiagNonDiagProcessingNoutSigs(2),...
    hLTDiagNonDiagProcessingNoutSigs(1),hLTDiagNonDiagProcessingNoutSigs(6),...
    hLTDiagNonDiagProcessingNoutSigs(7)];

    this.LTDiagDataComputation(hLTDiagNonDiagProcessingN,LTDiagDataComputationInSigs,LTDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,slRate);


    LTNonDiagDataComputationInSigs=[hLTDiagNonDiagProcessingNinSigs(2),hLTDiagNonDiagProcessingNinSigs(4),...
    hLTDiagNonDiagProcessingNoutSigs(1),readDataNonDiagS];
    LTNonDiagDataComputationOutSigs=[hLTDiagNonDiagProcessingNoutSigs(5),hLTDiagNonDiagProcessingNoutSigs(4)];

    this.LTNonDiagDataComputation(hLTDiagNonDiagProcessingN,LTNonDiagDataComputationInSigs,LTNonDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,hCounterT,hAddrT,slRate,blockInfo);

    MemReadDataS=hLTDiagNonDiagProcessingNinSigs(3).split;


    pirelab.getMuxComp(hLTDiagNonDiagProcessingN,...
    MemReadDataS.PirOutputSignals(2:end),...
    readDataNonDiagS,...
    'concatenate');


    pirelab.getMuxComp(hLTDiagNonDiagProcessingN,...
    MemReadDataS.PirOutputSignals(1:end-1),...
    readDataInS,...
    'concatenate');



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
