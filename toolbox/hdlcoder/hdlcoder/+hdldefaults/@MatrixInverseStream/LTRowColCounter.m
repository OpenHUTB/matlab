
function LTRowColCounter(this,hN,LTRowColCounterInSigs,LTRowColCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo)


    hLTRowColCounterN=pirelab.createNewNetwork(...
    'Name','LTRowColCounter',...
    'InportNames',{'readEnable','rowDone'},...
    'InportTypes',[hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'rowCount','colCount'},...
    'OutportTypes',[hCounterT,hCounterT]);

    hLTRowColCounterN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTRowColCounterN.PirOutputSignals)
        hLTRowColCounterN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTRowColCounterNinSigs=hLTRowColCounterN.PirInputSignals;
    hLTRowColCounterNoutSigs=hLTRowColCounterN.PirOutputSignals;


    LTRowCounterInSigs=hLTRowColCounterNinSigs(2);
    LTRowCounterOutSigs=hLTRowColCounterNoutSigs(1);

    this.LTRowCounter(hLTRowColCounterN,LTRowCounterInSigs,LTRowCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);

    LTColumnCounterInSigs=[hLTRowColCounterNoutSigs(1),hLTRowColCounterNinSigs(1)];
    LTColumnCounterOutSigs=hLTRowColCounterNoutSigs(2);

    this.LTColumnCounter(hLTRowColCounterN,LTColumnCounterInSigs,LTColumnCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTRowColCounterN,LTRowColCounterInSigs,LTRowColCounterOutSigs,...
    [hLTRowColCounterN.Name,'_inst']);

end
