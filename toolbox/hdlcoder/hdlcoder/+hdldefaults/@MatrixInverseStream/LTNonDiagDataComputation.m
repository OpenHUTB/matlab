

function LTNonDiagDataComputation(this,hN,LTNonDiagDataComputationInSigs,LTNonDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,hCounterT,hAddrT,slRate,blockInfo)


    hLTNonDiagDataComputationN=pirelab.createNewNetwork(...
    'Name','LTNonDiagDataComputation',...
    'InportNames',{'nonDiagValidIn','rowCount','rowDone','readDataNonDiag'},...
    'InportTypes',[hBoolT,hCounterT,hBoolT,LTNonDiagDataComputationInSigs(4).Type],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'nonDiagValidOut','nonDiagDataOut'},...
    'OutportTypes',[hBoolT,hInputDataT]);

    hLTNonDiagDataComputationN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTNonDiagDataComputationN.PirOutputSignals)
        hLTNonDiagDataComputationN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTNonDiagDataComputationNinSigs=hLTNonDiagDataComputationN.PirInputSignals;
    hLTNonDiagDataComputationNoutSigs=hLTNonDiagDataComputationN.PirOutputSignals;

    nonDiagCountS=l_addSignal(hLTNonDiagDataComputationN,'nonDiagCount',hAddrT,slRate);
    nonDiagCountValidS=l_addSignal(hLTNonDiagDataComputationN,'nonDiagCountValid',hBoolT,slRate);


    NonDiagCounterInSigs=[hLTNonDiagDataComputationNinSigs(3),nonDiagCountValidS];
    NonDiagCounterOutSigs=nonDiagCountS;

    this.NonDiagCounter(hLTNonDiagDataComputationN,NonDiagCounterInSigs,NonDiagCounterOutSigs,...
    hBoolT,hAddrT,slRate,blockInfo);


    NonDiagEleComputationInSigs=[nonDiagCountS,hLTNonDiagDataComputationNinSigs(3),...
    hLTNonDiagDataComputationNinSigs(1),hLTNonDiagDataComputationNinSigs(2),...
    hLTNonDiagDataComputationNinSigs(4)];
    NonDiagEleComputationOutSigs=[hLTNonDiagDataComputationNoutSigs(1),hLTNonDiagDataComputationNoutSigs(2),...
    nonDiagCountValidS];

    this.NonDiagEleComputation(hLTNonDiagDataComputationN,NonDiagEleComputationInSigs,NonDiagEleComputationOutSigs,...
    hBoolT,hAddrT,hCounterT,hInputDataT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTNonDiagDataComputationN,LTNonDiagDataComputationInSigs,...
    LTNonDiagDataComputationOutSigs,[hLTNonDiagDataComputationN.Name,'_inst']);
end



function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


