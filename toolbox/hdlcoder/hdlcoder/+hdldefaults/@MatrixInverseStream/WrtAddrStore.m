
function WrtAddrStore(~,hN,WrtAddrStoreInSigs,WrtAddrStoreOutSigs,...
    slRate,blockInfo)



    hWrtAddrStoreN=pirelab.createNewNetwork(...
    'Name','WrAddrStore',...
    'InportNames',{'colCount','validIn'},...
    'InportTypes',[WrtAddrStoreInSigs(1).Type,WrtAddrStoreInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtAddrStore'},...
    'OutportTypes',WrtAddrStoreOutSigs(1).Type);

    hWrtAddrStoreN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtAddrStoreN.PirOutputSignals)
        hWrtAddrStoreN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtAddrStoreNinSigs=hWrtAddrStoreN.PirInputSignals;
    hWrtAddrStoreNoutSigs=hWrtAddrStoreN.PirOutputSignals;


    colCount=hWrtAddrStoreNinSigs(1);
    validIn=hWrtAddrStoreNinSigs(2);

    wrtAddrStore=hWrtAddrStoreNoutSigs(1);



    if blockInfo.RowSize>1
        hAddrT=pir_fixpt_t(false,ceil(log2(blockInfo.RowSize)),0);
    else
        hAddrT=pir_fixpt_t(false,1,0);
    end


    if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
        'FractionLength',0);
    else
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
        'FractionLength',0);
    end


    Constant_out1_s2=l_addSignal(hWrtAddrStoreN,'Constant_out1',hCounterT,slRate);
    Constant1_out1_s3=l_addSignal(hWrtAddrStoreN,'Constant1_out1',hAddrT,slRate);
    Subtract_out1_s4=l_addSignal(hWrtAddrStoreN,'Subtract_out1',hAddrT,slRate);
    Switch_out1_s5=l_addSignal(hWrtAddrStoreN,'Switch_out1',hAddrT,slRate);


    pirelab.getConstComp(hWrtAddrStoreN,...
    Constant_out1_s2,...
    1,...
    'Constant','on',0,'','','');


    pirelab.getConstComp(hWrtAddrStoreN,...
    Constant1_out1_s3,...
    0,...
    'Constant1','on',1,'','','');

    pirelab.getAddComp(hWrtAddrStoreN,...
    [colCount,Constant_out1_s2],...
    Subtract_out1_s4,...
    'Floor','Wrap','Subtract',hAddrT,'+-');

    pirelab.getSwitchComp(hWrtAddrStoreN,...
    [Subtract_out1_s4,Constant1_out1_s3],...
    Switch_out1_s5,...
    validIn,'Switch',...
    '~=',0,'Floor','Wrap');

    AddrOut=hdlhandles(blockInfo.RowSize,1);
    for itr=1:blockInfo.RowSize
        AddrOut(itr)=Switch_out1_s5;
    end

    pirelab.getMuxComp(hWrtAddrStoreN,...
    AddrOut(1:end),...
    wrtAddrStore,...
    'concatenate');


    pirelab.instantiateNetwork(hN,hWrtAddrStoreN,WrtAddrStoreInSigs,...
    WrtAddrStoreOutSigs,[hWrtAddrStoreN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
