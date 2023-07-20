

function FwdMemWriteControl(this,hN,FwdMemWrtControlInSigs,FwdMemWrtControlOutSigs,...
    hBoolT,hCounterT,hAddrT,hInputDataT,slRate,blockInfo)



    hFwdMemWrtControlN=pirelab.createNewNetwork(...
    'Name','FwdMemWriteControl',...
    'InportNames',{'fwdDataValid','fwdData','fwdSubDone'},...
    'InportTypes',[hBoolT,hInputDataT,hBoolT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'wrtEnbFwdSub','wrtAddrFwdSub','wrtDataFwdSub'},...
    'OutportTypes',[FwdMemWrtControlOutSigs(1).Type,...
    FwdMemWrtControlOutSigs(2).Type,...
    FwdMemWrtControlOutSigs(3).Type]);

    hFwdMemWrtControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdMemWrtControlN.PirOutputSignals)
        hFwdMemWrtControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdMemWrtControlNinSigs=hFwdMemWrtControlN.PirInputSignals;
    hFwdMemWrtControlNoutSigs=hFwdMemWrtControlN.PirOutputSignals;



    rowCountOutS=l_addSignal(hFwdMemWrtControlN,'rowCountOut',hCounterT,slRate);
    colCountOutS=l_addSignal(hFwdMemWrtControlN,'colCountOut',hCounterT,slRate);


    FwdWrtEnbInSigs=[colCountOutS,rowCountOutS,hFwdMemWrtControlNinSigs(1)];
    FwdWrtEnbOutSigs=hFwdMemWrtControlNoutSigs(1);

    this.FwdWriteEnable(hFwdMemWrtControlN,FwdWrtEnbInSigs,FwdWrtEnbOutSigs,hBoolT,...
    hCounterT,slRate,blockInfo);



    FwdWrtAddrInSigs=[rowCountOutS,colCountOutS];
    FwdWrtAddrOutSigs=hFwdMemWrtControlNoutSigs(2);

    this.FwdWriteAddress(hFwdMemWrtControlN,FwdWrtAddrInSigs,FwdWrtAddrOutSigs,...
    hBoolT,hAddrT,hCounterT,slRate,blockInfo);


    FwdCntOutInSigs=[hFwdMemWrtControlNinSigs(1),hFwdMemWrtControlNinSigs(3)];
    FwdCntOutOutSigs=[colCountOutS,rowCountOutS];

    this.FwdOutRowColCounters(hFwdMemWrtControlN,FwdCntOutInSigs,FwdCntOutOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    FwdWrtDataInSigs=[hFwdMemWrtControlNinSigs(1),hFwdMemWrtControlNinSigs(2)];
    FwdWrtDataOutSigs=hFwdMemWrtControlNoutSigs(3);

    this.FwdWriteDataBus(hFwdMemWrtControlN,FwdWrtDataInSigs,FwdWrtDataOutSigs,hBoolT,...
    hInputDataT,slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hFwdMemWrtControlN,FwdMemWrtControlInSigs,...
    FwdMemWrtControlOutSigs,[hFwdMemWrtControlN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
