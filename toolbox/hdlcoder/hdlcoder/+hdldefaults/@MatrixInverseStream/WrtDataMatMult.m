

function WrtDataMatMult(~,hN,WrtDataMultInSigs,WrtDataMultOutSigs,...
    slRate,blockInfo)


    hWrtDataMultN=pirelab.createNewNetwork(...
    'Name','WrtDataMatMult',...
    'InportNames',{'prodValid','prodData'},...
    'InportTypes',[WrtDataMultInSigs(1).Type,WrtDataMultInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtDataMatMult'},...
    'OutportTypes',WrtDataMultOutSigs(1).Type);

    hWrtDataMultN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtDataMultN.PirOutputSignals)
        hWrtDataMultN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtDataMultNinSigs=hWrtDataMultN.PirInputSignals;
    hWrtDataMultNoutSigs=hWrtDataMultN.PirOutputSignals;


    hInputDataT=pir_single_t;


    prodValid=hWrtDataMultNinSigs(1);
    prodData=hWrtDataMultNinSigs(2);
    wrtDataMatMult=hWrtDataMultNoutSigs(1);

    Constant12_out1_s2=l_addSignal(hWrtDataMultN,'Constant12_out1',hInputDataT,slRate);
    Switch6_out1_s3=l_addSignal(hWrtDataMultN,'Switch6_out1',hInputDataT,slRate);


    pirelab.getConstComp(hWrtDataMultN,...
    Constant12_out1_s2,...
    single(0),...
    'Constant12','on',1,'','','');



    pirelab.getSwitchComp(hWrtDataMultN,...
    [prodData,Constant12_out1_s2],...
    Switch6_out1_s3,...
    prodValid,'Switch6',...
    '~=',0,'Floor','Wrap');

    SwitchOutArrayS=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize
        suffix=['_',int2str(itr)];

        SwitchOutArrayS(itr)=l_addSignal(hWrtDataMultN,['DelayOutArray',suffix],hInputDataT,slRate);
        pirelab.getWireComp(hWrtDataMultN,Switch6_out1_s3,SwitchOutArrayS(itr),['SwitchOutArrayS',suffix]);

    end

    pirelab.getMuxComp(hWrtDataMultN,...
    SwitchOutArrayS(1:end),...
    wrtDataMatMult,...
    'concatenate');

    pirelab.instantiateNetwork(hN,hWrtDataMultN,WrtDataMultInSigs,...
    WrtDataMultOutSigs,[hWrtDataMultN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


