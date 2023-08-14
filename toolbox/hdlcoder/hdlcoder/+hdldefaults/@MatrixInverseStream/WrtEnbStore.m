

function WrtEnbStore(~,hN,WrtEnbStoreInSigs,WrtEnbStoreOutSigs,...
    slRate,blockInfo)



    hWrtEnbStoreN=pirelab.createNewNetwork(...
    'Name','WrEnbStore',...
    'InportNames',{'validIn','rowCount'},...
    'InportTypes',[WrtEnbStoreInSigs(1).Type,WrtEnbStoreInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtEnbStore'},...
    'OutportTypes',WrtEnbStoreOutSigs(1).Type);

    hWrtEnbStoreN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtEnbStoreN.PirOutputSignals)
        hWrtEnbStoreN.PirOutputSignals(ii).SimulinkRate=slRate;
    end


    hWrtEnbStoreNinSigs=hWrtEnbStoreN.PirInputSignals;
    hWrtEnbStoreNoutSigs=hWrtEnbStoreN.PirOutputSignals;

    validIn=hWrtEnbStoreNinSigs(1);
    rowCount=hWrtEnbStoreNinSigs(2);

    wrtEnbStore=hWrtEnbStoreNoutSigs(1);

    LogicalOut=hdlhandles(blockInfo.RowSize,1);


    hBoolT=pir_boolean_t;
    compareToConstant=hdlhandles(blockInfo.RowSize,1);
    LogicalOperator=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize
        suffix=['_',int2str(itr)];
        compareToConstant(itr)=l_addSignal(hWrtEnbStoreN,['compareToConstant',suffix],hBoolT,slRate);
        LogicalOperator(itr)=l_addSignal(hWrtEnbStoreN,['LogicalOperator',suffix],hBoolT,slRate);

        pirelab.getCompareToValueComp(hWrtEnbStoreN,...
        rowCount,...
        compareToConstant(itr),...
        '==',itr,...
        sprintf(['compareToConstant',suffix]),0);

        pirelab.getLogicComp(hWrtEnbStoreN,...
        [validIn,compareToConstant(itr)],...
        LogicalOperator(itr),...
        'and',['LogicalOperator',suffix]);
        LogicalOut(itr)=LogicalOperator(itr);
    end

    pirelab.getMuxComp(hWrtEnbStoreN,...
    LogicalOut(1:end),...
    wrtEnbStore,...
    'concatenate');



    pirelab.instantiateNetwork(hN,hWrtEnbStoreN,WrtEnbStoreInSigs,...
    WrtEnbStoreOutSigs,[hWrtEnbStoreN.Name,'_inst']);
end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
