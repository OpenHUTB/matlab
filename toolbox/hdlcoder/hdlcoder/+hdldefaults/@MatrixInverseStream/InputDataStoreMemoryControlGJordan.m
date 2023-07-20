

function InputDataStoreMemoryControlGJordan(this,hN,StoreMemControlInSigs,...
    StoreMemControlOutSigs,slRate,blockInfo)





    hStoreMemControlN=pirelab.createNewNetwork(...
    'Name','InputDataStoreMemoryControlGJordan',...
    'InportNames',{'validIn','ready','rowCount','colCount','dataIn'},...
    'InportTypes',[StoreMemControlInSigs(1).Type,StoreMemControlInSigs(2).Type,...
    StoreMemControlInSigs(3).Type,StoreMemControlInSigs(4).Type,...
    StoreMemControlInSigs(5).Type],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'wrtEnbStore','wrtAddrStore','wrtDataStore'},...
    'OutportTypes',[StoreMemControlOutSigs(1).Type,StoreMemControlOutSigs(2).Type,...
    StoreMemControlOutSigs(3).Type]);

    hStoreMemControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hStoreMemControlN.PirOutputSignals)
        hStoreMemControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end
    hStoreMemControlNinSigs=hStoreMemControlN.PirInputSignals;
    hStoreMemControlNoutSigs=hStoreMemControlN.PirOutputSignals;


    validIn=hStoreMemControlNinSigs(1);
    ready=hStoreMemControlNinSigs(2);
    rowCount=hStoreMemControlNinSigs(3);
    colCount=hStoreMemControlNinSigs(4);
    dataIn=hStoreMemControlNinSigs(5);

    wrtEnbStore=hStoreMemControlNoutSigs(1);
    wrtAddrStore=hStoreMemControlNoutSigs(2);
    wrtDataStore=hStoreMemControlNoutSigs(3);


    hBoolT=pir_boolean_t;



    vldRdyS=l_addSignal(hStoreMemControlN,'vldRdy',hBoolT,slRate);



    WrtEnbStoreInSigs=[vldRdyS,colCount];
    WrtEnbStoreOutSigs=wrtEnbStore;

    this.WrtEnbStoreGJordan(hStoreMemControlN,WrtEnbStoreInSigs,WrtEnbStoreOutSigs,...
    slRate,blockInfo);

    WrtAddrStoreInSigs=[rowCount,vldRdyS];
    WrtAddrStoreOutSigs=wrtAddrStore;

    this.WrtAddrStoreGJordan(hStoreMemControlN,WrtAddrStoreInSigs,...
    WrtAddrStoreOutSigs,slRate,blockInfo);

    WrtDataStoreInSigs=[vldRdyS,dataIn,rowCount,colCount];
    WrtDataStoreOutSigs=wrtDataStore;

    this.WrtDataStoreGJordan(hStoreMemControlN,WrtDataStoreInSigs,WrtDataStoreOutSigs,...
    slRate,blockInfo);

    pirelab.getLogicComp(hStoreMemControlN,...
    [validIn,ready],...
    vldRdyS,...
    'and',sprintf('Logical\nOperator'));



    pirelab.instantiateNetwork(hN,hStoreMemControlN,StoreMemControlInSigs,...
    StoreMemControlOutSigs,[hStoreMemControlN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


