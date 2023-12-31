

function FwdWriteDataBus(~,hN,FwdWrtDataInSigs,FwdWrtDataOutSigs,hBoolT,...
    hInputDataT,slRate,blockInfo)


    hFwdWrtDataN=pirelab.createNewNetwork(...
    'Name','FwdWriteDataBus',...
    'InportNames',{'dataOutValid','dataOut'},...
    'InportTypes',[hBoolT,hInputDataT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtDataFwdSub'},...
    'OutportTypes',FwdWrtDataOutSigs(1).Type);

    hFwdWrtDataN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdWrtDataN.PirOutputSignals)
        hFwdWrtDataN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdWrtDataNinSigs=hFwdWrtDataN.PirInputSignals;
    hFwdWrtDataNoutSigs=hFwdWrtDataN.PirOutputSignals;

    Constant4_out1_s2=l_addSignal(hFwdWrtDataN,'Constant4_out1',hInputDataT,slRate);
    Delay8_out1_s3=l_addSignal(hFwdWrtDataN,'Delay8_out1',hInputDataT,slRate);
    Switch6_out1_s4=l_addSignal(hFwdWrtDataN,'Switch6_out1',hInputDataT,slRate);


    pirelab.getConstComp(hFwdWrtDataN,...
    Constant4_out1_s2,...
    single(0),...
    'Constant4','on',1,'','','');

    pirelab.getIntDelayComp(hFwdWrtDataN,...
    Switch6_out1_s4,...
    Delay8_out1_s3,...
    1,'Delay8',...
    single(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(hFwdWrtDataN,...
    [hFwdWrtDataNinSigs(2),Constant4_out1_s2],...
    Switch6_out1_s4,...
    hFwdWrtDataNinSigs(1),'Switch6',...
    '~=',0,'Floor','Wrap');

    DataOutArray=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize
        DataOutArray(itr)=Delay8_out1_s3;
    end


    pirelab.getMuxComp(hFwdWrtDataN,...
    DataOutArray(1:end),...
    hFwdWrtDataNoutSigs(1),...
    'concatenate');


    pirelab.instantiateNetwork(hN,hFwdWrtDataN,FwdWrtDataInSigs,...
    FwdWrtDataOutSigs,[hFwdWrtDataN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
