

function LTRowCounter(~,hN,LTRowCounterInSigs,LTRowCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo)


    hLTRowCounterN=pirelab.createNewNetwork(...
    'Name','LTRowCounter',...
    'InportNames',{'enable'},...
    'InportTypes',hBoolT,...
    'InportRates',slRate,...
    'OutportNames',{'rowCount'},...
    'OutportTypes',hCounterT);

    hLTRowCounterN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTRowCounterN.PirOutputSignals)
        hLTRowCounterN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTRowCounterNinSigs=hLTRowCounterN.PirInputSignals;
    hLTRowCounterNoutSigs=hLTRowCounterN.PirOutputSignals;

    CompareToConstant_out1_s1=l_addSignal(hLTRowCounterN,sprintf('Compare\nTo Constant_out1'),hBoolT,slRate);
    LogicalOperator_out1_s3=l_addSignal(hLTRowCounterN,sprintf('Logical\nOperator_out1'),hBoolT,slRate);


    pirelab.getCounterComp(hLTRowCounterN,...
    [LogicalOperator_out1_s3,hLTRowCounterNinSigs(1)],...
    hLTRowCounterNoutSigs(1),...
    'Count limited',1,1,blockInfo.RowSize,1,0,1,0,'HDL Counter',1);

    pirelab.getCompareToValueComp(hLTRowCounterN,...
    hLTRowCounterNoutSigs(1),...
    CompareToConstant_out1_s1,...
    '==',blockInfo.RowSize,...
    sprintf('Compare\nTo Constant'),0);

    pirelab.getLogicComp(hLTRowCounterN,...
    [CompareToConstant_out1_s1,hLTRowCounterNinSigs(1)],...
    LogicalOperator_out1_s3,...
    'and',sprintf('Logical\nOperator'));


    pirelab.instantiateNetwork(hN,hLTRowCounterN,LTRowCounterInSigs,LTRowCounterOutSigs,...
    [hLTRowCounterN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
