function gmNet=elabGamma(~,topNet,blockInfo,dataRate)




    extrinType=blockInfo.extrinType;
    smetType=blockInfo.smetType;
    smetVType=pirelab.getPirVectorType(smetType,4);





    inportNames={'prc','llr_sys','llr_apriori'};
    inTypes=[extrinType,extrinType,extrinType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'gamma'};

    outTypes=smetVType;

    gmNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','GammaCaculator',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );
    gmNet.addComment('Gamma Caculation');

    prc=gmNet.PirInputSignals(1);
    llr_sys=gmNet.PirInputSignals(2);
    llr_apriori=gmNet.PirInputSignals(3);

    gamma=gmNet.PirOutputSignals(1);

    prc_delay=gmNet.addSignal(extrinType,'prc_delay');
    addout1=gmNet.addSignal(smetType,'addout1');
    addout1_delay=gmNet.addSignal(smetType,'addout1_delay');
    addout2=gmNet.addSignal(smetType,'addout2');
    addout3=gmNet.addSignal(smetType,'addout3');
    addout4=gmNet.addSignal(smetType,'addout4');
    addout5=gmNet.addSignal(smetType,'addout5');

    addoutvec=gmNet.addSignal(smetVType,'addoutVec');

    shiftout=gmNet.addSignal(smetVType,'shiftout');



    comp=pirelab.getAddComp(gmNet,[llr_sys,llr_apriori],...
    addout1,...
    'Floor','Wrap','a1',smetType,'++');
    comp.addComment('llr_sys+llr_apriori');

    pirelab.getUnitDelayComp(gmNet,addout1,addout1_delay);

    pirelab.getUnitDelayComp(gmNet,prc,prc_delay);


    pirelab.getAddComp(gmNet,[prc_delay,addout1_delay],addout2,...
    'Floor','Wrap','a2',smetType,'--');

    pirelab.getAddComp(gmNet,[prc_delay,addout1_delay],addout3,...
    'Floor','Wrap','a3',smetType,'-+');

    pirelab.getAddComp(gmNet,[prc_delay,addout1_delay],addout4,...
    'Floor','Wrap','a4',smetType,'+-');

    pirelab.getAddComp(gmNet,[prc_delay,addout1_delay],addout5,...
    'Floor','Wrap','a5',smetType,'++');

    pirelab.getMuxComp(gmNet,[addout2,addout3,addout4,addout5],addoutvec);

    pirelab.getBitShiftComp(gmNet,addoutvec,shiftout,'sra',1);

    pirelab.getUnitDelayComp(gmNet,shiftout,gamma);
