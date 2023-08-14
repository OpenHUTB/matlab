function abNet=elabAlphaBeta(~,topNet,blockInfo,dataRate,mode)




    boolType=pir_boolean_t();
    boolVType=pirelab.getPirVectorType(boolType,8);

    smetType=blockInfo.smetType;
    smetVType=pirelab.getPirVectorType(smetType,4);
    smetVType8=pirelab.getPirVectorType(smetType,8);


    inportNames={'gamma','ab_enb'};
    inTypes=[smetVType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    smetiniValue=zeros(1,8);
    switch mode
    case 1
        outportNames={'alpha'};
        netName='AlphaCalculator';
        smetiniValue(2:end)=blockInfo.inistmet;
        gammaIdx1=[1,1,3,3,3,3,1,1];
        gammaIdx2=[4,4,2,2,2,2,4,4];
        alphaIdx1=[1,5,2,6,7,3,8,4];
        alphaIdx2=[5,1,6,2,3,7,4,8];
    case 2
        outportNames={'betaA'};
        netName='BetaACalculator';
        gammaIdx1=[1,3,3,1,1,3,3,1];
        gammaIdx2=[4,2,2,4,4,2,2,4];
        alphaIdx1=[1,3,6,8,2,4,5,7];
        alphaIdx2=[2,4,5,7,1,3,6,8];

    otherwise
        outportNames={'betaB'};
        netName='BetaBCalculator';
        gammaIdx1=[1,3,3,1,1,3,3,1];
        gammaIdx2=[4,2,2,4,4,2,2,4];
        alphaIdx1=[1,3,6,8,2,4,5,7];
        alphaIdx2=[2,4,5,7,1,3,6,8];
    end


    outTypes=smetVType8;

    abNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',netName,...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );
    abNet.addComment(netName);

    gamma=abNet.PirInputSignals(1);
    ab_en=abNet.PirInputSignals(2);
    alphabeta=abNet.PirOutputSignals(1);


    gammaoffset=abNet.addSignal(smetVType,'gammaOffset');
    offsetValue=abNet.addSignal(smetVType,'offsetValue');
    gammaoffset_delay=abNet.addSignal(smetVType,'gammaOffset_delay');
    smet=abNet.addSignal(smetVType8,'stmet');
    smet.SimulinkRate=dataRate;
    smet_delay=abNet.addSignal(smetVType8,'stmet_delay');
    cmp=abNet.addSignal(boolVType,'cmp');
    cmp_delay=abNet.addSignal(boolVType,'cmp_delay');
    cmp_delay_or=abNet.addSignal(boolType,'cmp_delay_or');
    offsetSel=abNet.addSignal(boolType,'offsetSel');
    gamma_delay=abNet.addSignal(smetVType,'gamma_delay');
    gamma_next=abNet.addSignal(smetVType,'gamma_next');
    gamma_next_delay=abNet.addSignal(smetVType,'gamma_next_delay');


    pirelab.getConstComp(abNet,offsetValue,blockInfo.offset);
    comp=pirelab.getAddComp(abNet,[gamma,offsetValue],gammaoffset,...
    'Floor','Wrap','',smetType,'+-');

    comp.addComment('Normalization');

    pirelab.getIntDelayComp(abNet,gammaoffset,gammaoffset_delay,2,'gammaoffset_register',0);
    pirelab.getUnitDelayComp(abNet,smet,smet_delay);




    comp=pirelab.getCompareToValueComp(abNet,smet_delay,cmp,'>',blockInfo.threshold);
    comp.addComment('compare to threshold');
    pirelab.getUnitDelayComp(abNet,cmp,cmp_delay);
    comp=pirelab.getLogicComp(abNet,cmp_delay,cmp_delay_or,'or');
    pirelab.getUnitDelayComp(abNet,cmp_delay_or,offsetSel);

    pirelab.getIntDelayComp(abNet,gamma,gamma_delay,2,'gamma_register',0);
    pirelab.getSwitchComp(abNet,[gammaoffset_delay,gamma_delay],gamma_next,offsetSel,'','==',1);
    pirelab.getUnitDelayComp(abNet,gamma_next,gamma_next_delay);

    ab_en_delay=abNet.addSignal(boolType,'ab_en_delay');
    pirelab.getIntDelayComp(abNet,ab_en,ab_en_delay,3,'ab_en_register',0);

    smetini=abNet.addSignal(smetVType8,'smetini');
    pirelab.getConstComp(abNet,smetini,smetiniValue);

    alphabeta_next=abNet.addSignal(smetVType8,'alphabeta_next');
    smet_next=abNet.addSignal(smetVType8,'smet_next');

    comp=pirelab.getSwitchComp(abNet,[smet,smetini],smet_next,ab_en_delay,'','==',1);
    comp.addComment('Compare and select');
    pirelab.getUnitDelayComp(abNet,smet_next,alphabeta_next);



    gamma_expand1=abNet.addSignal(smetVType8,'gamma_expand1');
    gamma_expand2=abNet.addSignal(smetVType8,'gamma_expand2');
    ab_shuffle1=abNet.addSignal(smetVType8,'ab_shuffle1');
    ab_shuffle2=abNet.addSignal(smetVType8,'ab_shuffle2');
    brunch1=abNet.addSignal(smetVType8,'brunch1');
    brunch2=abNet.addSignal(smetVType8,'brunch2');


    comp=pirelab.getSelectorComp(abNet,gamma_next_delay,gamma_expand1,...
    'One-based',{'Index vector (dialog)'},{gammaIdx1},{'1'},'1');

    pirelab.getSelectorComp(abNet,gamma_next_delay,gamma_expand2,...
    'One-based',{'Index vector (dialog)'},{gammaIdx2},{'1'},'1');

    pirelab.getSelectorComp(abNet,alphabeta_next,ab_shuffle1,...
    'One-based',{'Index vector (dialog)'},{alphaIdx1},{'1'},'1');

    pirelab.getSelectorComp(abNet,alphabeta_next,ab_shuffle2,...
    'One-based',{'Index vector (dialog)'},{alphaIdx2},{'1'},'1');


    pirelab.getAddComp(abNet,[gamma_expand1,ab_shuffle1],brunch1,...
    'Floor','Wrap','badd1',smetType,'++');

    pirelab.getAddComp(abNet,[gamma_expand2,ab_shuffle2],brunch2,...
    'Floor','Wrap','badd2',smetType,'++');


    b1split=brunch1.split;
    b2split=brunch2.split;

    for i=1:8
        maxout(i)=abNet.addSignal(smetType,['maxout',num2str(i)]);
        pirelab.getMinMaxComp(abNet,[b1split.PirOutputSignal(i),b2split.PirOutputSignal(i)],...
        maxout(i),'','max');
    end

    pirelab.getMuxComp(abNet,maxout,smet);
    pirelab.getDTCComp(abNet,alphabeta_next,alphabeta);



