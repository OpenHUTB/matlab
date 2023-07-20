

function MatMultMemoryControl(this,hN,MatMultMemControlInSigs,MatMultMemControlOutSigs,...
    hBoolT,hCounterT,hInputDataT,slRate,blockInfo)


    hMatMultMemControlN=pirelab.createNewNetwork(...
    'Name','MatMultMemoryControl',...
    'InportNames',{'colCount','matMultEnb','prodData','prodValid',...
    'colCountOut','rowCountOut'},...
    'InportTypes',[hCounterT,hBoolT,hInputDataT,hBoolT,...
    hCounterT,hCounterT],...
    'InportRates',slRate*ones(1,6),...
    'OutportNames',{'rdAddrMatMult','wrtEnbMatMult','wrtAddrMatMult',...
    'wrtDataMatMult'},...
    'OutportTypes',[MatMultMemControlOutSigs(1).Type,...
    MatMultMemControlOutSigs(2).Type,...
    MatMultMemControlOutSigs(3).Type,...
    MatMultMemControlOutSigs(4).Type]);

    hMatMultMemControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMatMultMemControlN.PirOutputSignals)
        hMatMultMemControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMatMultMemControlNinSigs=hMatMultMemControlN.PirInputSignals;
    hMatMultMemControlNoutSigs=hMatMultMemControlN.PirOutputSignals;


    colCount=hMatMultMemControlNinSigs(1);
    matMultEnb=hMatMultMemControlNinSigs(2);
    prodData=hMatMultMemControlNinSigs(3);
    prodValid=hMatMultMemControlNinSigs(4);
    colCountOut=hMatMultMemControlNinSigs(5);
    rowCountOut=hMatMultMemControlNinSigs(6);

    rdAddrMatMult=hMatMultMemControlNoutSigs(1);
    wrtEnbMatMult=hMatMultMemControlNoutSigs(2);
    wrtAddrMatMult=hMatMultMemControlNoutSigs(3);
    wrtDataMatMult=hMatMultMemControlNoutSigs(4);


    RdAddrMultInSigs=[matMultEnb,colCount];
    RdAddrMultOutSigs=rdAddrMatMult;

    this.RdAddrMatMult(hMatMultMemControlN,RdAddrMultInSigs,RdAddrMultOutSigs,...
    slRate,blockInfo);


    WrtEnbMultInSigs=[rowCountOut,prodValid,colCountOut];
    WrtEnbMultOutSigs=wrtEnbMatMult;

    this.WrtEnbMatMult(hMatMultMemControlN,WrtEnbMultInSigs,WrtEnbMultOutSigs,...
    slRate,blockInfo);



    WrtAddrMultInSigs=[rowCountOut,colCountOut];
    WrtAddrMultOutSigs=wrtAddrMatMult;

    this.WrtAddrMatMult(hMatMultMemControlN,WrtAddrMultInSigs,WrtAddrMultOutSigs,...
    slRate,blockInfo);


    WrtDataMultInSigs=[prodValid,prodData];
    WrtDataMultOutSigs=wrtDataMatMult;

    this.WrtDataMatMult(hMatMultMemControlN,WrtDataMultInSigs,WrtDataMultOutSigs,...
    slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hMatMultMemControlN,MatMultMemControlInSigs,...
    MatMultMemControlOutSigs,[hMatMultMemControlN.Name,'_inst']);


end

