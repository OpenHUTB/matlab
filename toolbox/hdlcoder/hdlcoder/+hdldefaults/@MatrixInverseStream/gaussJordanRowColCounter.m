

function gaussJordanRowColCounter(this,hN,LTRowColCounterInSigs,LTRowColCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo)





    hLTRowColCounterN=pirelab.createNewNetwork(...
    'Name','gaussJordanRowColCounter',...
    'InportNames',{'readEnable','rowFinish','swapDone','invFinish','isDiagZero','swapReadEnable'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,hBoolT,hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,6),...
    'OutportNames',{'rowCount','colCount'},...
    'OutportTypes',[hCounterT,hCounterT]);

    hLTRowColCounterN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hLTRowColCounterN.PirOutputSignals)
        hLTRowColCounterN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTRowColCounterNinSigs=hLTRowColCounterN.PirInputSignals;
    hLTRowColCounterNoutSigs=hLTRowColCounterN.PirOutputSignals;

    readEnable=hLTRowColCounterNinSigs(1);
    rowFinish=hLTRowColCounterNinSigs(2);
    swapDone=hLTRowColCounterNinSigs(3);
    invFinish=hLTRowColCounterNinSigs(4);
    isDiagZero=hLTRowColCounterNinSigs(5);
    swapReadEnable=hLTRowColCounterNinSigs(6);

    rowCount=hLTRowColCounterNoutSigs(1);
    colCount=hLTRowColCounterNoutSigs(2);


    LTRowCounterInSigs=[colCount,rowFinish,invFinish];
    LTRowCounterOutSigs=rowCount;

    this.gaussJordanRowCounter(hLTRowColCounterN,LTRowCounterInSigs,LTRowCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);

    LTColumnCounterInSigs=[rowCount,readEnable,rowFinish,swapDone,invFinish,isDiagZero,swapReadEnable];
    LTColumnCounterOutSigs=colCount;

    this.gaussJordanColumnCounter(hLTRowColCounterN,LTColumnCounterInSigs,LTColumnCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTRowColCounterN,LTRowColCounterInSigs,LTRowColCounterOutSigs,...
    [hLTRowColCounterN.Name,'_inst']);

end
