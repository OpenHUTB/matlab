
function DiagDataSelector(~,hN,DiagDataSelectorInSigs,DiagDataSelectorOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo)



    hDiagDataSelectorN=pirelab.createNewNetwork(...
    'Name','DiagDataSelector',...
    'InportNames',{'rowCount','readDataIn'},...
    'InportTypes',[hCounterT,DiagDataSelectorInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'diagDataIn'},...
    'OutportTypes',hInputDataT);

    hDiagDataSelectorN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hDiagDataSelectorN.PirOutputSignals)
        hDiagDataSelectorN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hDiagDataSelectorNinSigs=hDiagDataSelectorN.PirInputSignals;
    hDiagDataSelectorNoutSigs=hDiagDataSelectorN.PirOutputSignals;

    Constant_out1_s2=l_addSignal(hDiagDataSelectorN,'Constant_out1',hInputDataT,slRate);

    if blockInfo.RowSize>1
        DiagRdData=hDiagDataSelectorNinSigs(2).split;
        DiagRdDataSplitS=DiagRdData.PirOutputSignals;
    else
        DiagRdData=hDiagDataSelectorNinSigs(2);
        DiagRdDataSplitS=DiagRdData;
    end
    pirelab.getConstComp(hDiagDataSelectorN,...
    Constant_out1_s2,...
    single(0),...
    'Constant','on',1,'','','');

    pirelab.getMultiPortSwitchComp(hDiagDataSelectorN,...
    [hDiagDataSelectorNinSigs(1),(DiagRdDataSplitS(1:end))',Constant_out1_s2],...
    hDiagDataSelectorNoutSigs(1),...
    1,'One-based contiguous','Floor','Wrap',sprintf('Multiport\nSwitch'),[]);


    pirelab.instantiateNetwork(hN,hDiagDataSelectorN,DiagDataSelectorInSigs,...
    DiagDataSelectorOutSigs,[hDiagDataSelectorN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
