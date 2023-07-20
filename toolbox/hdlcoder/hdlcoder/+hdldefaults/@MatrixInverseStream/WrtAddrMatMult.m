

function WrtAddrMatMult(~,hN,WrtAddrMultInSigs,WrtAddrMultOutSigs,...
    slRate,blockInfo)


    hWrtAddrMultN=pirelab.createNewNetwork(...
    'Name','WrtAddrMatMult',...
    'InportNames',{'rowCountOut','colCountOut'},...
    'InportTypes',[WrtAddrMultInSigs(1).Type,WrtAddrMultInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtAddrMatMult'},...
    'OutportTypes',WrtAddrMultOutSigs(1).Type);

    hWrtAddrMultN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtAddrMultN.PirOutputSignals)
        hWrtAddrMultN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtAddrMultNinSigs=hWrtAddrMultN.PirInputSignals;
    hWrtAddrMultNoutSigs=hWrtAddrMultN.PirOutputSignals;


    hBoolT=pir_boolean_t;


    if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
        'FractionLength',0);
    else
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
        'FractionLength',0);
    end


    if blockInfo.RowSize>1
        hAddrT=hWrtAddrMultN.getType('FixedPoint','Signed',false,'WordLength',...
        ceil(log2(blockInfo.RowSize)),'FractionLength',0);
    else
        hAddrT=hWrtAddrMultN.getType('FixedPoint','Signed',false,'WordLength',...
        1,'FractionLength',0);
    end


    rowCountOut=hWrtAddrMultNinSigs(1);
    colCountOut=hWrtAddrMultNinSigs(2);
    wrtAddrMatMult=hWrtAddrMultNoutSigs(1);

    Constant2_out1_s6=l_addSignal(hWrtAddrMultN,'Constant2_out1',hCounterT,slRate);

    Subtract1_out1_s12=l_addSignal(hWrtAddrMultN,'Subtract1_out1',hAddrT,slRate);
    Subtract2_out1_s13=l_addSignal(hWrtAddrMultN,'Subtract2_out1',hAddrT,slRate);

    pirelab.getConstComp(hWrtAddrMultN,...
    Constant2_out1_s6,...
    1,...
    'Constant2','on',0,'','','');


    pirelab.getAddComp(hWrtAddrMultN,...
    [colCountOut,Constant2_out1_s6],...
    Subtract1_out1_s12,...
    'Floor','Wrap','Subtract1',hCounterT,'+-');


    pirelab.getAddComp(hWrtAddrMultN,...
    [rowCountOut,Constant2_out1_s6],...
    Subtract2_out1_s13,...
    'Floor','Wrap','Subtract2',hCounterT,'+-');

    AddrOut=hdlhandles(blockInfo.RowSize,1);

    CompareToConstantS=hdlhandles(blockInfo.RowSize,1);
    SwitchS=hdlhandles(blockInfo.RowSize,1);


    for itr=1:blockInfo.RowSize

        suffix=['_',int2str(itr)];
        CompareToConstantS(itr)=l_addSignal(hWrtAddrMultN,['CompareToConstant',suffix],hBoolT,slRate);
        SwitchS(itr)=l_addSignal(hWrtAddrMultN,['Switch',suffix],hAddrT,slRate);

        pirelab.getCompareToValueComp(hWrtAddrMultN,...
        rowCountOut,...
        CompareToConstantS(itr),...
        '==',itr,...
        sprintf(['Compare\nTo Constant',suffix]),0);

        pirelab.getSwitchComp(hWrtAddrMultN,...
        [Subtract1_out1_s12,Subtract2_out1_s13],...
        SwitchS(itr),...
        CompareToConstantS(itr),['Switch',suffix],...
        '~=',0,'Floor','Wrap');

        AddrOut(itr)=SwitchS(itr);

    end

    pirelab.getMuxComp(hWrtAddrMultN,...
    AddrOut(1:end),...
    wrtAddrMatMult,...
    'concatenate');



    pirelab.instantiateNetwork(hN,hWrtAddrMultN,WrtAddrMultInSigs,...
    WrtAddrMultOutSigs,[hWrtAddrMultN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


