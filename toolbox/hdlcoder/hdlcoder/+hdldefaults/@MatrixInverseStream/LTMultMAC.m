

function LTMultMAC(this,hN,LTMultMACInSigs,LTMultMACOutSigs,hBoolT,hCounterT,...
    hInputDataT,slRate,blockInfo)


    hLTMultMACN=pirelab.createNewNetwork(...
    'Name','LTMultMAC',...
    'InportNames',{'rowCountReg','colCountReg','matMultEnbReg','rdData'},...
    'InportTypes',[hCounterT,hCounterT,hBoolT,...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0])],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'prodData','prodValid','colCountOut',...
    'rowCountOut','invDone'},...
    'OutportTypes',[hInputDataT,hBoolT,hCounterT,hCounterT,hBoolT]);

    hLTMultMACN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTMultMACN.PirOutputSignals)
        hLTMultMACN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTMultMACNinSigs=hLTMultMACN.PirInputSignals;
    hLTMultMACNoutSigs=hLTMultMACN.PirOutputSignals;


    Delay_out1_s4=l_addSignal(hLTMultMACN,'Delay_out1',hBoolT,slRate);

    pirelab.getIntDelayComp(hLTMultMACN,...
    hLTMultMACNinSigs(3),...
    Delay_out1_s4,...
    1,'Delay',...
    false,...
    0,0,[],0,0);





    MatMultSubInSigs=[hLTMultMACNinSigs(2),hLTMultMACNinSigs(1),...
    Delay_out1_s4,hLTMultMACNinSigs(4)];
    MatMultSubOutSigs=[hLTMultMACNoutSigs(1),hLTMultMACNoutSigs(2)];

    this.MatMultSubsystem(hLTMultMACN,MatMultSubInSigs,MatMultSubOutSigs,...
    slRate,blockInfo);


    LTMultProcCntInSigs=hLTMultMACNoutSigs(2);
    LTMultProcCntOutSigs=[hLTMultMACNoutSigs(3),hLTMultMACNoutSigs(4),...
    hLTMultMACNoutSigs(5)];

    this.LTMultProcCounters(hLTMultMACN,LTMultProcCntInSigs,LTMultProcCntOutSigs,...
    slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hLTMultMACN,LTMultMACInSigs,LTMultMACOutSigs,...
    [hLTMultMACN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


