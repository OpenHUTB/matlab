
function WrtDataStore(~,hN,WrtDataStoreInSigs,WrtDataStoreOutSigs,...
    slRate,blockInfo)



    hWrtDataStoreN=pirelab.createNewNetwork(...
    'Name','WrDataStore',...
    'InportNames',{'validIn','dataIn'},...
    'InportTypes',[WrtDataStoreInSigs(1).Type,WrtDataStoreInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtDataStore'},...
    'OutportTypes',WrtDataStoreOutSigs(1).Type);

    hWrtDataStoreN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtDataStoreN.PirOutputSignals)
        hWrtDataStoreN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtDataStoreNinSigs=hWrtDataStoreN.PirInputSignals;
    hWrtDataStoreNoutSigs=hWrtDataStoreN.PirOutputSignals;


    validIn=hWrtDataStoreNinSigs(1);
    dataIn=hWrtDataStoreNinSigs(2);

    wrtDataStore=hWrtDataStoreNoutSigs(1);


    hInputDataT=pir_single_t;


    Constant_out1_s2=l_addSignal(hWrtDataStoreN,'Constant_out1',hInputDataT,slRate);
    Switch_out1_s3=l_addSignal(hWrtDataStoreN,'Switch_out1',hInputDataT,slRate);


    pirelab.getConstComp(hWrtDataStoreN,...
    Constant_out1_s2,...
    single(0),...
    'Constant','on',1,'','','');

    pirelab.getSwitchComp(hWrtDataStoreN,...
    [dataIn,Constant_out1_s2],...
    Switch_out1_s3,...
    validIn,'Switch',...
    '~=',0,'Floor','Wrap');

    DataOut=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize
        DataOut(itr)=Switch_out1_s3;
    end

    pirelab.getMuxComp(hWrtDataStoreN,...
    DataOut(1:end),...
    wrtDataStore,...
    'concatenate');


    pirelab.instantiateNetwork(hN,hWrtDataStoreN,WrtDataStoreInSigs,...
    WrtDataStoreOutSigs,[hWrtDataStoreN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
