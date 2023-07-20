function hAmemRdN=matrixAMemoryReadAddress(~,hRACtlN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    iter=ceil(blockInfo.aColumnSize/blockInfo.dotProductSize);
    hindexCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize/blockInfo.dotProductSize))+1,0);

    hAmemRdN=pirelab.createNewNetwork(...
    'Name','matrixAMemoryReadAddress',...
    'InportNames',{'enable','indexEnb'},...
    'InportTypes',[hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'aRdAddr'},...
    'OutportTypes',hindexCounterT);
    hAmemRdN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hAmemRdN.PirOutputSignals)
        hAmemRdN.PirOutputSignals(ii).SimulinkRate=slRate;
    end


    pirelab.instantiateNetwork(hRACtlN,hAmemRdN,hInSigs,hOutSigs,...
    [hAmemRdN.Name,'_inst']);

    enableS=hAmemRdN.PirInputSignals(1);
    indexEnbS=hAmemRdN.PirInputSignals(2);
    aRdAddrS=hAmemRdN.PirOutputSignals(1);

    logicalZeroFlagS=l_addSignal(hAmemRdN,'logicalZeroFlagS',hindexCounterT,slRate);
    addrS=l_addSignal(hAmemRdN,'addrS',hindexCounterT,slRate);
    pirelab.getConstComp(hAmemRdN,...
    logicalZeroFlagS,...
    0,...
    'Constant','on',1,'','','');

    pirelab.getCounterComp(hAmemRdN,...
    enableS,...
    addrS,...
    'Count limited',0,1,iter-1,0,0,1,0,'addr',0);

    pirelab.getSwitchComp(hAmemRdN,...
    [addrS,logicalZeroFlagS],...
    aRdAddrS,...
    indexEnbS,'Switch',...
    '~=',0,'Floor','Wrap');

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


