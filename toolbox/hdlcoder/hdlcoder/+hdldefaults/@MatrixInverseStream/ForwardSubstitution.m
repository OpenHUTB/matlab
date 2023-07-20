

function ForwardSubstitution(this,hN,FwdSubInSigs,FwdSubOutSigs,hBoolT,hInputDataT,...
    hAddrT,hCounterT,slRate,blockInfo)



    hFwdSubN=pirelab.createNewNetwork(...
    'Name','ForwardSubstitution',...
    'InportNames',{'lowerTriangDone','rdData'},...
    'InportTypes',[hBoolT,pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0])],...
    'InportRates',[slRate,slRate],...
    'OutportNames',{'fwdSubEnb','fwdSubDone','wrEnbFwdSub','wrAddrFwdSub','wrDataFwdSub','rdAddrFwdSub'},...
    'OutportTypes',[hBoolT,hBoolT,FwdSubOutSigs(3).Type,...
    FwdSubOutSigs(4).Type,...
    FwdSubOutSigs(5).Type,...
    FwdSubOutSigs(6).Type]);

    hFwdSubN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdSubN.PirOutputSignals)
        hFwdSubN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdSubNinSigs=hFwdSubN.PirInputSignals;
    hFwdSubNoutSigs=hFwdSubN.PirOutputSignals;


    rowProcDoneS=l_addSignal(hFwdSubN,'rowProcDone',hBoolT,slRate);
    rowCountS=l_addSignal(hFwdSubN,'rowCount',hCounterT,slRate);
    colCountS=l_addSignal(hFwdSubN,'colCount',hCounterT,slRate);
    diagonalEnS=l_addSignal(hFwdSubN,'diagonalEn',hBoolT,slRate);
    nonDiagonalEnS=l_addSignal(hFwdSubN,'nonDiagonalEn',hBoolT,slRate);
    reciprocalRdEnS=l_addSignal(hFwdSubN,'reciprocalRdEn',hBoolT,slRate);
    mRdEnS=l_addSignal(hFwdSubN,'mRdEn',hBoolT,slRate);
    fwdDataValidS=l_addSignal(hFwdSubN,'fwdDataValid',hBoolT,slRate);
    fwdDataS=l_addSignal(hFwdSubN,'fwdData',hInputDataT,slRate);




    FwdControlInSigs=[hFwdSubNoutSigs(2),hFwdSubNinSigs(1),rowProcDoneS];
    FwdControlOutSigs=[hFwdSubNoutSigs(1),rowCountS,colCountS,diagonalEnS,nonDiagonalEnS];

    this.FwdController(hFwdSubN,FwdControlInSigs,FwdControlOutSigs,hBoolT,hCounterT,slRate,blockInfo);


    FwdMemRdAddrInSigs=[rowCountS,colCountS,diagonalEnS,nonDiagonalEnS];
    FwdMemRdAddrOutSigs=[reciprocalRdEnS,mRdEnS,hFwdSubNoutSigs(6)];

    this.FwdMemReadAddr(hFwdSubN,FwdMemRdAddrInSigs,FwdMemRdAddrOutSigs,hBoolT,...
    hCounterT,hAddrT,slRate,blockInfo);


    FwdProcessingInSigs=[rowCountS,reciprocalRdEnS,mRdEnS,hFwdSubNinSigs(2)];
    FwdProcessingOutSigs=[hFwdSubNoutSigs(2),fwdDataValidS,fwdDataS,rowProcDoneS];

    this.FwdDataProcessing(hFwdSubN,FwdProcessingInSigs,FwdProcessingOutSigs,hBoolT,...
    hCounterT,hInputDataT,slRate,blockInfo);


    FwdMemWrtControlInSigs=[fwdDataValidS,fwdDataS,hFwdSubNoutSigs(2)];
    FwdMemWrtControlOutSigs=[hFwdSubNoutSigs(3),hFwdSubNoutSigs(4),hFwdSubNoutSigs(5)];

    this.FwdMemWriteControl(hFwdSubN,FwdMemWrtControlInSigs,FwdMemWrtControlOutSigs,...
    hBoolT,hCounterT,hAddrT,hInputDataT,slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hFwdSubN,FwdSubInSigs,FwdSubOutSigs,...
    [hFwdSubN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


