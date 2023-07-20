function acsunitNet=elabACSUnit(~,topNet,stmetType,dataRate)







    ufix1Type=pir_ufixpt_t(1,0);



    acsunitNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ACSUnit',...
    'InportNames',{'bmet0','bmet1','smet0','smet1'},...
    'InportTypes',[stmetType,stmetType,stmetType,stmetType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',{'branchdec','nextsmet'},...
    'OutportTypes',[ufix1Type,stmetType]);


    bm0=acsunitNet.PirInputSignals(1);
    bm1=acsunitNet.PirInputSignals(2);
    sm0=acsunitNet.PirInputSignals(3);
    sm1=acsunitNet.PirInputSignals(4);

    branchdec=acsunitNet.PirOutputSignals(1);
    nextsm=acsunitNet.PirOutputSignals(2);


    sum0=acsunitNet.addSignal(stmetType,'sum0');
    sum1=acsunitNet.addSignal(stmetType,'sum1');
    a1=pirelab.getAddComp(acsunitNet,[bm0,sm0],sum0,'Floor','Wrap');
    a1.addComment('Add branch metric and state metric');
    a2=pirelab.getAddComp(acsunitNet,[bm1,sm1],sum1,'Floor','Wrap');
    a2.addComment('Add branch metric and state metric');



    rlop=pirelab.getRelOpComp(acsunitNet,[sum0,sum1],branchdec,'>');
    rlop.addComment('Compare');

    scomp=pirelab.getSwitchComp(acsunitNet,[sum0,sum1],nextsm,branchdec,'acsbswitch','<',1);
    scomp.addComment('Select');


end
