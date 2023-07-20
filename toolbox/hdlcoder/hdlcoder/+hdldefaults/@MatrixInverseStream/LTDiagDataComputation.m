
function LTDiagDataComputation(this,hN,LTDiagDataComputationInSigs,LTDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,slRate)


    hLTDiagDataComputationN=pirelab.createNewNetwork(...
    'Name','LTDiagDataComputation',...
    'InportNames',{'diagValidIn','diagDataIn','nonDiagValidOut','nonDiagDataOut'},...
    'InportTypes',[hBoolT,hInputDataT,hBoolT,hInputDataT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'diagValidOut','diagDataOut','rowDone','reciprocalValid','reciprocalData'},...
    'OutportTypes',[hBoolT,hInputDataT,hBoolT,hBoolT,hInputDataT]);

    hLTDiagDataComputationN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTDiagDataComputationN.PirOutputSignals)
        hLTDiagDataComputationN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTDiagDataComputationNinSigs=hLTDiagDataComputationN.PirInputSignals;
    hLTDiagDataComputationNoutSigs=hLTDiagDataComputationN.PirOutputSignals;


    DiagDataComputationInSigs=[hLTDiagDataComputationNinSigs(1),hLTDiagDataComputationNinSigs(2),...
    hLTDiagDataComputationNinSigs(4),hLTDiagDataComputationNinSigs(3),...
    hLTDiagDataComputationNoutSigs(3)];
    DiagDataComputationOutSigs=[hLTDiagDataComputationNoutSigs(1),hLTDiagDataComputationNoutSigs(2)];

    this.DiagDataComputation(hLTDiagDataComputationN,DiagDataComputationInSigs,...
    DiagDataComputationOutSigs,hBoolT,hInputDataT,slRate);


    LTDiagReciprocalDataInSigs=[hLTDiagDataComputationNoutSigs(1),hLTDiagDataComputationNoutSigs(2)];
    LTDiagReciprocalDataOutSigs=[hLTDiagDataComputationNoutSigs(4),hLTDiagDataComputationNoutSigs(5),...
    hLTDiagDataComputationNoutSigs(3)];

    this.LTDiagReciprocalData(hLTDiagDataComputationN,LTDiagReciprocalDataInSigs,LTDiagReciprocalDataOutSigs,...
    hBoolT,hInputDataT,slRate);



    pirelab.instantiateNetwork(hN,hLTDiagDataComputationN,LTDiagDataComputationInSigs,...
    LTDiagDataComputationOutSigs,[hLTDiagDataComputationN.Name,'_inst']);
end

