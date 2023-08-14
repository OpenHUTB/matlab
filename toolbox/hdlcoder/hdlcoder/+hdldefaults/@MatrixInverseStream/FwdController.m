

function FwdController(this,hN,FwdControlInSigs,FwdControlOutSigs,hBoolT,hCounterT,...
    slRate,blockInfo)


    hFwdControlN=pirelab.createNewNetwork(...
    'Name','FwdController',...
    'InportNames',{'forwardDone','lowerTriangDone','rowProcDone'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'fwdSubEnb','rowCount','colCount','diagonalEn','nonDiagonalEn'},...
    'OutportTypes',[hBoolT,hCounterT,hCounterT,hBoolT,hBoolT]);

    hFwdControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdControlN.PirOutputSignals)
        hFwdControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdControlNinSigs=hFwdControlN.PirInputSignals;
    hFwdControlNoutSigs=hFwdControlN.PirOutputSignals;



    startPulseS=l_addSignal(hFwdControlN,'startPulse',hBoolT,slRate);




    TriggerLogicInSigs=[hFwdControlNinSigs(2),hFwdControlNinSigs(1)];
    TriggerLogicOutSigs=[hFwdControlNoutSigs(1),startPulseS];

    this.TriggerLogic(hFwdControlN,TriggerLogicInSigs,TriggerLogicOutSigs,hBoolT,slRate);



    DataEnbInSigs=[hFwdControlNoutSigs(1),startPulseS,hFwdControlNinSigs(3),hFwdControlNinSigs(1)];
    DataEnbOutSigs=[hFwdControlNoutSigs(2),hFwdControlNoutSigs(3),...
    hFwdControlNoutSigs(4),hFwdControlNoutSigs(5)];

    this.DataEnableBlock(hFwdControlN,DataEnbInSigs,DataEnbOutSigs,hBoolT,hCounterT,...
    slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hFwdControlN,FwdControlInSigs,FwdControlOutSigs,...
    [hFwdControlN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


