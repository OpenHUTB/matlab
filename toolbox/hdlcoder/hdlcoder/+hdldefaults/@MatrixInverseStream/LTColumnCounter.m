
function LTColumnCounter(~,hN,LTColumnCounterInSigs,LTColumnCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo)



    hLTColumnCounterN=pirelab.createNewNetwork(...
    'Name','LTColumnCounter',...
    'InportNames',{'rowCount','enable'},...
    'InportTypes',[hCounterT,hBoolT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'colCount'},...
    'OutportTypes',hCounterT);

    hLTColumnCounterN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTColumnCounterN.PirOutputSignals)
        hLTColumnCounterN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTColumnCounterNinSigs=hLTColumnCounterN.PirInputSignals;
    hLTColumnCounterNoutSigs=hLTColumnCounterN.PirOutputSignals;

    LogicalOperator_out1_s3=l_addSignal(hLTColumnCounterN,sprintf('Logical\nOperator_out1'),hBoolT,slRate);
    RelationalOperator_out1_s4=l_addSignal(hLTColumnCounterN,sprintf('Relational\nOperator_out1'),hBoolT,slRate);


    pirelab.getCounterComp(hLTColumnCounterN,...
    [LogicalOperator_out1_s3,hLTColumnCounterNinSigs(2)],...
    hLTColumnCounterNoutSigs(1),...
    'Count limited',1,1,blockInfo.RowSize,1,0,1,0,'HDL Counter',1);



    pirelab.getLogicComp(hLTColumnCounterN,...
    [RelationalOperator_out1_s4,hLTColumnCounterNinSigs(2)],...
    LogicalOperator_out1_s3,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getRelOpComp(hLTColumnCounterN,...
    [hLTColumnCounterNoutSigs(1),hLTColumnCounterNinSigs(1)],...
    RelationalOperator_out1_s4,...
    '==',0,sprintf('Relational\nOperator'));


    pirelab.instantiateNetwork(hN,hLTColumnCounterN,LTColumnCounterInSigs,LTColumnCounterOutSigs,...
    [hLTColumnCounterN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
