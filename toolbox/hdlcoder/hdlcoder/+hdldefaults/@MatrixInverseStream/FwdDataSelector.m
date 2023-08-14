
function FwdDataSelector(~,hN,FwdDataSelInSigs,FwdDataSelOutSigs,hBoolT,...
    hInputDataT,slRate)


    hFwdDataSelN=pirelab.createNewNetwork(...
    'Name','FwdDataSelector',...
    'InportNames',{'diagOutData','nonDiagOutValid','nonDiagOutData'},...
    'InportTypes',[hInputDataT,hBoolT,hInputDataT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'fwdData'},...
    'OutportTypes',hInputDataT);

    hFwdDataSelN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdDataSelN.PirOutputSignals)
        hFwdDataSelN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdDataSelNinSigs=hFwdDataSelN.PirInputSignals;
    hFwdDataSelNoutSigs=hFwdDataSelN.PirOutputSignals;

    pirelab.getSwitchComp(hFwdDataSelN,...
    [hFwdDataSelNinSigs(3),hFwdDataSelNinSigs(1)],...
    hFwdDataSelNoutSigs(1),...
    hFwdDataSelNinSigs(2),'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.instantiateNetwork(hN,hFwdDataSelN,FwdDataSelInSigs,...
    FwdDataSelOutSigs,[hFwdDataSelN.Name,'_inst']);
end

