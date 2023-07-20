

function NonDiagDataSelector(~,hN,NonDiagDataSelectorInSigs,...
    NonDiagDataSelectorOutSigs,hCounterT,hInputDataT,slRate,blockInfo)


    hNonDiagDataSelectorN=pirelab.createNewNetwork(...
    'Name','NonDiagDataSelector',...
    'InportNames',{'rowCount','readDataSel'},...
    'InportTypes',[hCounterT,NonDiagDataSelectorInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'nonDiagDataIn'},...
    'OutportTypes',hInputDataT);

    hNonDiagDataSelectorN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hNonDiagDataSelectorN.PirOutputSignals)
        hNonDiagDataSelectorN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hNonDiagDataSelectorNinSigs=hNonDiagDataSelectorN.PirInputSignals;
    hNonDiagDataSelectorNoutSigs=hNonDiagDataSelectorN.PirOutputSignals;


    hInputDataT=pir_single_t;

    Constant_out1_s2=l_addSignal(hNonDiagDataSelectorN,'Constant_out1',hInputDataT,slRate);


    if blockInfo.RowSize>2
        dataSelSplitS=hNonDiagDataSelectorNinSigs(2).split;
        dataSelSplitOutS=dataSelSplitS.PirOutputSignals;
    else
        dataSelSplitS=hNonDiagDataSelectorNinSigs(2);
        dataSelSplitOutS=dataSelSplitS;
    end
    pirelab.getConstComp(hNonDiagDataSelectorN,...
    Constant_out1_s2,...
    single(0),...
    'Constant','on',1,'','','');

    pirelab.getMultiPortSwitchComp(hNonDiagDataSelectorN,...
    [hNonDiagDataSelectorNinSigs(1),Constant_out1_s2,(dataSelSplitOutS(1:end))',...
    Constant_out1_s2],hNonDiagDataSelectorNoutSigs(1),...
    1,'One-based contiguous','Floor','Wrap',sprintf('Multiport\nSwitch'),[]);



    pirelab.instantiateNetwork(hN,hNonDiagDataSelectorN,NonDiagDataSelectorInSigs,...
    NonDiagDataSelectorOutSigs,[hNonDiagDataSelectorN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
