

function RdAddrLowerTriang(~,hN,RdAddrLTInSigs,RdAddrLTOutSigs,hBoolT,hCounterT,...
    hAddrT,slRate,blockInfo)


    hRdAddrLTN=pirelab.createNewNetwork(...
    'Name','RdAddrLowerTriang',...
    'InportNames',{'lowerTriangEnb','colCount'},...
    'InportTypes',[hBoolT,hCounterT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'rdAddrLT'},...
    'OutportTypes',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0]));

    hRdAddrLTN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hRdAddrLTN.PirOutputSignals)
        hRdAddrLTN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hRdAddrLTNinSigs=hRdAddrLTN.PirInputSignals;
    hRdAddrLTNoutSigs=hRdAddrLTN.PirOutputSignals;


    Constant_out1_s2=l_addSignal(hRdAddrLTN,'Constant_out1',hCounterT,slRate);
    Constant1_out1_s3=l_addSignal(hRdAddrLTN,'Constant1_out1',hAddrT,slRate);
    Subtract_out1_s4=l_addSignal(hRdAddrLTN,'Subtract_out1',hAddrT,slRate);
    Switch_out1_s5=l_addSignal(hRdAddrLTN,'Switch_out1',hAddrT,slRate);


    pirelab.getConstComp(hRdAddrLTN,...
    Constant_out1_s2,...
    1,...
    'Constant','on',0,'','','');


    pirelab.getConstComp(hRdAddrLTN,...
    Constant1_out1_s3,...
    0,...
    'Constant1','on',1,'','','');


    pirelab.getAddComp(hRdAddrLTN,...
    [hRdAddrLTNinSigs(2),Constant_out1_s2],...
    Subtract_out1_s4,...
    'Floor','Wrap','Subtract',hCounterT,'+-');


    pirelab.getSwitchComp(hRdAddrLTN,...
    [Subtract_out1_s4,Constant1_out1_s3],...
    Switch_out1_s5,...
    hRdAddrLTNinSigs(1),'Switch',...
    '~=',0,'Floor','Wrap');

    RdAddrOut=hdlhandles(blockInfo.RowSize+1,1);
    for itr=1:blockInfo.RowSize+1
        RdAddrOut(itr)=Switch_out1_s5;
    end

    pirelab.getMuxComp(hRdAddrLTN,...
    RdAddrOut(1:end),...
    hRdAddrLTNoutSigs(1),...
    'concatenate');


    pirelab.instantiateNetwork(hN,hRdAddrLTN,RdAddrLTInSigs,RdAddrLTOutSigs,...
    [hRdAddrLTN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


