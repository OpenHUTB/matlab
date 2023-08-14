function InputMatrixStoreControlGaussJordan(this,hN,...
    MatrixStoreInSigs,MatrixStoreOutSigs,slRate,blockInfo)



    hMatrixStoreN=pirelab.createNewNetwork(...
    'Name','InputMatrixStoreControlGaussJordan',...
    'InportNames',{'validIn','dataIn','outStreamDone'},...
    'InportTypes',[MatrixStoreInSigs(1).Type,MatrixStoreInSigs(2).Type,...
    MatrixStoreInSigs(3).Type],...
    'InportRates',[slRate,slRate,slRate],...
    'OutportNames',{'ready','wrtEnbStore','wrtAddrStore','wrtDataStore',...
    'storeDone'},...
    'OutportTypes',[MatrixStoreOutSigs(1).Type,MatrixStoreOutSigs(2).Type,...
    MatrixStoreOutSigs(3).Type,MatrixStoreOutSigs(4).Type,...
    MatrixStoreOutSigs(5).Type]);

    hMatrixStoreN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hMatrixStoreN.PirOutputSignals)
        hMatrixStoreN.PirOutputSignals(ii).SimulinkRate=slRate;
    end


    hBoolT=pir_boolean_t;

    hCounterT=hMatrixStoreN.getType('FixedPoint','Signed',false,'WordLength',...
    ceil(log2(blockInfo.MatrixSize))+1,'FractionLength',0);


    hMatrixStoreinSigs=hMatrixStoreN.PirInputSignals;
    hMatrixStoreoutSigs=hMatrixStoreN.PirOutputSignals;


    validIn=hMatrixStoreinSigs(1);
    dataIn=hMatrixStoreinSigs(2);
    outStreamDone=hMatrixStoreinSigs(3);

    ready=hMatrixStoreoutSigs(1);
    wrtEnbStore=hMatrixStoreoutSigs(2);
    wrtAddrStore=hMatrixStoreoutSigs(3);
    wrtDataStore=hMatrixStoreoutSigs(4);
    storeDone=hMatrixStoreoutSigs(5);


    vldRdyAndCompS=l_addSignal(hMatrixStoreN,'vldRdyAndComp',hBoolT,slRate);
    rowCountS=l_addSignal(hMatrixStoreN,'rowCount',hCounterT,slRate);
    colCountS=l_addSignal(hMatrixStoreN,'colCount',hCounterT,slRate);


    RowColCounterInSigs=[vldRdyAndCompS,storeDone];
    RowColCounterOutSigs=[rowCountS,colCountS];

    this.RowColCounterStoringGaussJordan(hMatrixStoreN,RowColCounterInSigs,RowColCounterOutSigs,...
    slRate,blockInfo);


    ReadySigGenInSigs=[outStreamDone,rowCountS,colCountS,vldRdyAndCompS];
    ReadySigGenOutSigs=ready;

    this.ReadySignalGeneratorGaussJordan(hMatrixStoreN,ReadySigGenInSigs,ReadySigGenOutSigs,...
    slRate,blockInfo);


    StoringDoneInSigs=[ready,validIn,rowCountS,colCountS];
    StoringDoneOutSigs=storeDone;

    this.StoringDoneGaussJordan(hMatrixStoreN,StoringDoneInSigs,StoringDoneOutSigs,...
    slRate,blockInfo);

    StoreMemControlInSigs=[validIn,ready,rowCountS,colCountS,dataIn];
    StoreMemControlOutSigs=[wrtEnbStore,wrtAddrStore,wrtDataStore];

    this.InputDataStoreMemoryControlGJordan(hMatrixStoreN,StoreMemControlInSigs,...
    StoreMemControlOutSigs,slRate,blockInfo);


    pirelab.getLogicComp(hMatrixStoreN,...
    [ready,validIn],...
    vldRdyAndCompS,...
    'and',sprintf('Logical\nOperator'));


    pirelab.instantiateNetwork(hN,hMatrixStoreN,MatrixStoreInSigs,MatrixStoreOutSigs,...
    [hMatrixStoreN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


