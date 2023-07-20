function acsunitNet=elabACSUnit(~,topNet,blockInfo,smtype,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    if blockInfo.issigned
        uType=pir_sfixpt_t(blockInfo.bmWL,0);
    else
        uType=pir_ufixpt_t(blockInfo.bmWL,0);
    end


    acsunitNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ACSUnit',...
    'Inportnames',{'bmet0','bmet1','smet0','smte1'},...
    'InportTypes',[uType,uType,smtype,smtype],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'branchDec','nextSM'},...
    'OutportTypes',[ufix1Type,smtype]...
    );


    bmet0=acsunitNet.PirInputSignals(1);
    bmet1=acsunitNet.PirInputSignals(2);
    smet0=acsunitNet.PirInputSignals(3);
    smet1=acsunitNet.PirInputSignals(4);

    branchdec=acsunitNet.PirOutputSignals(1);
    nextsmet=acsunitNet.PirOutputSignals(2);

    sub=acsunitNet.addSignal(smet0.type,'sub');

    sum0=acsunitNet.addSignal(smtype,'sum0');
    sum1=acsunitNet.addSignal(smtype,'sum1');

    scomp1=pirelab.getAddComp(acsunitNet,[bmet0,smet0],sum0,'Floor','Wrap');
    scomp1.addComment('Add Branch Metric and State Metric');

    scomp2=pirelab.getAddComp(acsunitNet,[bmet1,smet1],sum1,'Floor','Wrap');
    scomp2.addComment('Add Branch Metric and State Metric');

    relcomp=pirelab.getSubComp(acsunitNet,[sum1,sum0],sub,'Floor','Wrap');
    relcomp.addComment('Compare state metrics');

    ul=blockInfo.stateMetWL-1;
    ll=blockInfo.stateMetWL-1;
    pirelab.getBitSliceComp(acsunitNet,sub,branchdec,ul,ll,'bit_extract');

    selcomp=pirelab.getSwitchComp(acsunitNet,[sum0,sum1],nextsmet,branchdec,'selswitch','==',0);
    selcomp.addComment('Select the state metric');
end