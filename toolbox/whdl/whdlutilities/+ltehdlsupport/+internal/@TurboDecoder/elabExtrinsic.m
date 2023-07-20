function extrinNet=elabExtrinsic(~,topNet,blockInfo,dataRate)




    extrinType=blockInfo.extrinType;
    extrinExtType=blockInfo.extrinExtType;
    extrinExtVType=pirelab.getPirVectorType(extrinExtType,8);
    extrinVType=pirelab.getPirVectorType(extrinType,3);
    boolType=pir_boolean_t();
    smetType=blockInfo.smetType;
    smetVType8=pirelab.getPirVectorType(smetType,8);
    adderType=pir_sfixpt_t(smetType.WordLength+2,smetType.FractionLength);
    adderVType8=pirelab.getPirVectorType(adderType,8);





    inportNames={'alpha','beta','extrin_en','llrdata'};
    inTypes=[smetVType8,smetVType8,boolType,extrinVType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'extrinsic','decision'}';

    outTypes=[extrinType,boolType];

    extrinNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Extrinsic',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );
    extrinNet.addComment('Extrinsic Computation');

    alpha=extrinNet.PirInputSignals(1);
    beta=extrinNet.PirInputSignals(2);
    extrin_en=extrinNet.PirInputSignals(3);
    llr_data=extrinNet.PirInputSignals(4);

    extrinsic=extrinNet.PirOutputSignals(1);
    decision=extrinNet.PirOutputSignals(2);


    beta1=extrinNet.addSignal(smetVType8,'beta1');
    beta2=extrinNet.addSignal(smetVType8,'beta2');

    pirelab.getSelectorComp(extrinNet,beta,beta1,...
    'One-based',{'Index vector (dialog)'},{[2,4,5,7,1,3,6,8]},{'1'},'1');

    pirelab.getSelectorComp(extrinNet,beta,beta2,...
    'One-based',{'Index vector (dialog)'},{[1,3,6,8,2,4,5,7]},{'1'},'1');


    llr_datasplit=llr_data.split;

    prc=llr_datasplit.PirOutputSignals(1);
    llr_sys=llr_datasplit.PirOutputSignals(2);
    llr_apriori=llr_datasplit.PirOutputSignals(3);

    prc_dtc=extrinNet.addSignal(extrinExtType,'prc_dtc');
    halfprc=extrinNet.addSignal(extrinExtType,'prc_half');
    neghalfprc=extrinNet.addSignal(extrinExtType,'neg_prc_half');
    halfprcvec1=extrinNet.addSignal(extrinExtVType,'prc_halfvec1');
    halfprcvec2=extrinNet.addSignal(extrinExtVType,'prc_halfvec2');


    pirelab.getDTCComp(extrinNet,prc,prc_dtc);
    pirelab.getBitShiftComp(extrinNet,prc_dtc,halfprc,'sra',1);
    pirelab.getUnaryMinusComp(extrinNet,halfprc,neghalfprc,'saturate');
    inarray1=[halfprc,neghalfprc,neghalfprc,halfprc,halfprc,neghalfprc,neghalfprc,halfprc];
    inarray2=[neghalfprc,halfprc,halfprc,neghalfprc,neghalfprc,halfprc,halfprc,neghalfprc];

    pirelab.getMuxComp(extrinNet,inarray1,halfprcvec1);
    pirelab.getMuxComp(extrinNet,inarray2,halfprcvec2);

    brunch1=extrinNet.addSignal(adderVType8,'brunch1');
    brunch2=extrinNet.addSignal(adderVType8,'brunch2');
    brunch1_delay=extrinNet.addSignal(adderVType8,'brunch1_delay');
    brunch2_delay=extrinNet.addSignal(adderVType8,'brunch2_delay');
    brunch1_max=extrinNet.addSignal(adderType,'brunch1_max');
    brunch2_max=extrinNet.addSignal(adderType,'brunch2_max');
    diff_max=extrinNet.addSignal(adderType,'diff_max');
    diff_max_dtc=extrinNet.addSignal(extrinType,'diff_max_dtc');
    constzero=extrinNet.addSignal(extrinType,'constZero');
    sys_bit=extrinNet.addSignal(extrinType,'sys_bit');
    extrin_en_pdelay=extrinNet.addSignal(boolType,'extrin_en_pdelay');
    llr_sys_pdelay=extrinNet.addSignal(extrinType,'llr_sys_pdelay');
    llr_apriori_pdelay=extrinNet.addSignal(extrinType,'llr_apriori_pdelay');
    decSel=extrinNet.addSignal(adderType,'decSel');
    cmpzero=extrinNet.addSignal(boolType,'cmpZero');


    comp=pirelab.getAddComp(extrinNet,[alpha,beta1,halfprcvec1],brunch1,'Floor',...
    'wrap','state metric adder1',adderType,'+++');
    comp.addComment('Brunch1');

    comp=pirelab.getAddComp(extrinNet,[alpha,beta2,halfprcvec2],brunch2,'Floor',...
    'wrap','state metric adder2',adderType,'+++');
    comp.addComment('Brunch2');

    pirelab.getUnitDelayComp(extrinNet,brunch1,brunch1_delay);
    pirelab.getUnitDelayComp(extrinNet,brunch2,brunch2_delay);


    pipeTree=true;
    pirelab.getTreeArch(extrinNet,brunch1_delay,brunch1_max,'max','Floor',...
    'Wrap','MaximumTree','',pipeTree);


    pirelab.getTreeArch(extrinNet,brunch2_delay,brunch2_max,'max','Floor',...
    'Wrap','MaximumTree','',pipeTree);


    pirelab.getAddComp(extrinNet,[brunch1_max,brunch2_max],diff_max,...
    'Floor','Wrap','diff_max',adderType,'+-');
    pirelab.getDTCComp(extrinNet,diff_max,diff_max_dtc,'Floor','Saturate');

    pirelab.getConstComp(extrinNet,constzero,0);

    pdelay=4;
    pirelab.getIntDelayComp(extrinNet,extrin_en,extrin_en_pdelay,pdelay);
    pirelab.getSwitchComp(extrinNet,[diff_max_dtc,constzero],sys_bit,extrin_en_pdelay,'','==',1);
    pirelab.getUnitDelayComp(extrinNet,sys_bit,extrinsic);

    pirelab.getIntDelayComp(extrinNet,llr_sys,llr_sys_pdelay,pdelay);
    pirelab.getIntDelayComp(extrinNet,llr_apriori,llr_apriori_pdelay,pdelay);

    pirelab.getAddComp(extrinNet,[diff_max_dtc,llr_sys_pdelay,llr_apriori_pdelay],decSel,'Floor',...
    'wrap','',smetType,'+++');

    comp=pirelab.getCompareToValueComp(extrinNet,decSel,cmpzero,'>=',0);
    comp.addComment(' Decision');
    pirelab.getUnitDelayComp(extrinNet,cmpzero,decision);


