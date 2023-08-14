

function RdAddrMatMult(~,hN,RdAddrMultInSigs,RdAddrMultOutSigs,...
    slRate,blockInfo)


    hRdAddrMultN=pirelab.createNewNetwork(...
    'Name','RdAddrMatMult',...
    'InportNames',{'matMultEnb','colCount'},...
    'InportTypes',[RdAddrMultInSigs(1).Type,RdAddrMultInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'rdAddrMatMult'},...
    'OutportTypes',RdAddrMultOutSigs(1).Type);

    hRdAddrMultN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hRdAddrMultN.PirOutputSignals)
        hRdAddrMultN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hRdAddrMultNinSigs=hRdAddrMultN.PirInputSignals;
    hRdAddrMultNoutSigs=hRdAddrMultN.PirOutputSignals;


    if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
        'FractionLength',0);
    else
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
        'FractionLength',0);
    end

    if blockInfo.RowSize>1
        hAddrT=hRdAddrMultN.getType('FixedPoint','Signed',false,'WordLength',...
        ceil(log2(blockInfo.RowSize)),'FractionLength',0);
    else
        hAddrT=hRdAddrMultN.getType('FixedPoint','Signed',false,'WordLength',...
        1,'FractionLength',0);
    end

    matMultEnb=hRdAddrMultNinSigs(1);
    colCount=hRdAddrMultNinSigs(2);
    rdAddrMatMult=hRdAddrMultNoutSigs(1);

    Constant_out1_s2=l_addSignal(hRdAddrMultN,'Constant_out1',hCounterT,slRate);
    Constant1_out1_s3=l_addSignal(hRdAddrMultN,'Constant1_out1',hAddrT,slRate);
    Subtract_out1_s4=l_addSignal(hRdAddrMultN,'Subtract_out1',hAddrT,slRate);
    Switch_out1_s5=l_addSignal(hRdAddrMultN,'Switch_out1',hAddrT,slRate);


    pirelab.getConstComp(hRdAddrMultN,...
    Constant_out1_s2,...
    1,...
    'Constant','on',0,'','','');


    pirelab.getConstComp(hRdAddrMultN,...
    Constant1_out1_s3,...
    0,...
    'Constant1','on',1,'','','');



    pirelab.getAddComp(hRdAddrMultN,...
    [colCount,Constant_out1_s2],...
    Subtract_out1_s4,...
    'Floor','Wrap','Subtract',hAddrT,'+-');


    pirelab.getSwitchComp(hRdAddrMultN,...
    [Subtract_out1_s4,Constant1_out1_s3],...
    Switch_out1_s5,...
    matMultEnb,'Switch',...
    '~=',0,'Floor','Wrap');

    RdAddrArray=hdlhandles(blockInfo.RowSize,1);
    for itr=1:blockInfo.RowSize
        RdAddrArray(itr)=Switch_out1_s5;

    end

    pirelab.getMuxComp(hRdAddrMultN,...
    RdAddrArray(1:end),...
    rdAddrMatMult,...
    'concatenate');


    pirelab.instantiateNetwork(hN,hRdAddrMultN,RdAddrMultInSigs,...
    RdAddrMultOutSigs,[hRdAddrMultN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
