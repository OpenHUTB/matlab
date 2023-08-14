function dcoreNet=elabDecoderCore(this,topNet,blockInfo,dataRate)




    boolType=pir_boolean_t();
    extrinaddrType=pir_ufixpt_t(log2(2*blockInfo.winSize),0);
    extrinType=blockInfo.extrinType;
    extrinVType=pirelab.getPirVectorType(extrinType,3);
    smetType=blockInfo.smetType;
    smetVType=pirelab.getPirVectorType(smetType,4);
    smetVType8=pirelab.getPirVectorType(smetType,8);




    inportNames={'prc','llr_sys','llr_apriori','BB_Dr','BB_Sc','BB_En','Buffer_id',...
    'betaA_En','betaB_En','alpha_En','extrinsic_En',...
    'alpha_raddr','alpha_waddr'};


    inTypes=[extrinType,extrinType,extrinType,boolType,boolType,boolType,boolType,boolType,...
    boolType,boolType,boolType,extrinaddrType,extrinaddrType];

    indataRates=dataRate*ones(1,length(inportNames));
    outportNames={'extrinsic','decision'};
    outTypes=[extrinType,boolType];

    dcoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DecoderCore',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );



    prc=dcoreNet.PirInputSignals(1);
    llr_sys=dcoreNet.PirInputSignals(2);
    llr_apriori=dcoreNet.PirInputSignals(3);
    BB_Dr=dcoreNet.PirInputSignals(4);
    BB_Sc=dcoreNet.PirInputSignals(5);
    BB_En=dcoreNet.PirInputSignals(6);
    Buffer_id=dcoreNet.PirInputSignals(7);
    betaA_En=dcoreNet.PirInputSignals(8);
    betaB_En=dcoreNet.PirInputSignals(9);
    alpha_En=dcoreNet.PirInputSignals(10);
    extrinsic_En=dcoreNet.PirInputSignals(11);
    alpha_raddr=dcoreNet.PirInputSignals(12);
    alpha_waddr=dcoreNet.PirInputSignals(13);

    extrinsic=dcoreNet.PirOutputSignals(1);
    decision=dcoreNet.PirOutputSignals(2);


    extrinWL=extrinType.WordLength;
    concatType=pir_ufixpt_t(extrinWL*3,0);
    sliceType=pir_ufixpt_t(extrinWL,0);

    concatdataIn=dcoreNet.addSignal(concatType,'concatdataIn');
    concatdataOut1=dcoreNet.addSignal(concatType,'concatdataOut1');
    concatdataOut2=dcoreNet.addSignal(concatType,'concatdataOut2');

    comp=pirelab.getBitConcatComp(dcoreNet,[prc,llr_sys,llr_apriori],concatdataIn);
    comp.addComment('BitConcat for buffer input');


    desc='BiDirection Buffer';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+ltehdlsupport','+internal','@TurboDecoder','cgireml','BiBuffer.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');

    fclose(fid);

    inports=[concatdataIn,BB_Dr,BB_Sc,BB_En];

    outports=concatdataOut1;

    bbuffer1=dcoreNet.addComponent2(...
    'kind','cgireml',...
    'Name','BiBuffer1',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','BiBuffer',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.winSize,extrinWL*3},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    bbuffer1.runConcurrencyMaximizer(0);

    BB_Dr2=dcoreNet.addSignal(boolType,'BB_Dr2');
    BB_Sc2=dcoreNet.addSignal(boolType,'BB_Sc2');

    pirelab.getLogicComp(dcoreNet,BB_Dr,BB_Dr2,'not');
    pirelab.getLogicComp(dcoreNet,BB_Sc,BB_Sc2,'not');

    inports=[concatdataIn,BB_Dr2,BB_Sc2,BB_En];

    outports=concatdataOut2;


    bbuffer2=dcoreNet.addComponent2(...
    'kind','cgireml',...
    'Name','BiBuffer2',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','BiBuffer',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.winSize,extrinWL*3},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);
    bbuffer2.runConcurrencyMaximizer(0);


    prc_sliced1=dcoreNet.addSignal(sliceType,'prc_sliced1');
    llr_sys_sliced1=dcoreNet.addSignal(sliceType,'llr_sys_sliced1');
    llr_apriori_sliced1=dcoreNet.addSignal(sliceType,'llr_apriori_sliced1');

    prc_sliced2=dcoreNet.addSignal(sliceType,'prc_sliced2');
    llr_sys_sliced2=dcoreNet.addSignal(sliceType,'llr_sys_sliced2');
    llr_apriori_sliced2=dcoreNet.addSignal(sliceType,'llr_apriori_sliced2');

    prc1=dcoreNet.addSignal(extrinType,'prc1');
    llr_sys1=dcoreNet.addSignal(extrinType,'llr_sys1');
    llr_apriori1=dcoreNet.addSignal(extrinType,'llr_apriori1');

    prc2=dcoreNet.addSignal(extrinType,'prc2');
    llr_sys2=dcoreNet.addSignal(extrinType,'llr_sys2');
    llr_apriori2=dcoreNet.addSignal(extrinType,'llr_apriori2');

    comp=pirelab.getBitSliceComp(dcoreNet,concatdataOut1,llr_apriori_sliced1,extrinWL-1,0);
    comp.addComment('BitSlice buffer outputs');

    pirelab.getBitSliceComp(dcoreNet,concatdataOut1,llr_sys_sliced1,2*extrinWL-1,extrinWL);
    pirelab.getBitSliceComp(dcoreNet,concatdataOut1,prc_sliced1,3*extrinWL-1,2*extrinWL);

    pirelab.getBitSliceComp(dcoreNet,concatdataOut2,llr_apriori_sliced2,extrinWL-1,0);
    pirelab.getBitSliceComp(dcoreNet,concatdataOut2,llr_sys_sliced2,2*extrinWL-1,extrinWL);
    pirelab.getBitSliceComp(dcoreNet,concatdataOut2,prc_sliced2,3*extrinWL-1,2*extrinWL);


    pirelab.getDTCComp(dcoreNet,prc_sliced1,prc1,'Floor','Wrap','SI');
    pirelab.getDTCComp(dcoreNet,llr_sys_sliced1,llr_sys1,'Floor','Wrap','SI');
    pirelab.getDTCComp(dcoreNet,llr_apriori_sliced1,llr_apriori1,'Floor','Wrap','SI');

    pirelab.getDTCComp(dcoreNet,prc_sliced2,prc2,'Floor','Wrap','SI');
    pirelab.getDTCComp(dcoreNet,llr_sys_sliced2,llr_sys2,'Floor','Wrap','SI');
    pirelab.getDTCComp(dcoreNet,llr_apriori_sliced2,llr_apriori2,'Floor','Wrap','SI');




    gmNet=this.elabGamma(dcoreNet,blockInfo,dataRate);
    gamma=dcoreNet.addSignal(smetVType,'gamma');
    gammaA=dcoreNet.addSignal(smetVType,'gammaA');
    gammaB=dcoreNet.addSignal(smetVType,'gammaB');
    pirelab.instantiateNetwork(dcoreNet,gmNet,[prc,llr_sys,llr_apriori],gamma,'gammaInst');
    pirelab.instantiateNetwork(dcoreNet,gmNet,[prc1,llr_sys1,llr_apriori1],gammaA,'gammaAInst');
    pirelab.instantiateNetwork(dcoreNet,gmNet,[prc2,llr_sys2,llr_apriori2],gammaB,'gammaBInst');



    gdelay=2;
    buffer_id_gdelay=dcoreNet.addSignal(boolType,'buffer_id_gdelay');

    comp=pirelab.getIntDelayComp(dcoreNet,Buffer_id,buffer_id_gdelay,gdelay);
    comp.addComment('Buffer pipeline registers');

    gamma_alpha=dcoreNet.addSignal(smetVType,'gamma_alpha');
    gamma_betaA=dcoreNet.addSignal(smetVType,'gamma_betaA');
    gamma_betaB=dcoreNet.addSignal(smetVType,'gamma_betaB');

    alphaIn=dcoreNet.addSignal(smetVType,'alphaIn');
    betaAIn=dcoreNet.addSignal(smetVType,'betaAIn');
    betaBIn=dcoreNet.addSignal(smetVType,'betaBIn');

    comp=pirelab.getSwitchComp(dcoreNet,[gammaA,gammaB],gamma_alpha,buffer_id_gdelay,'','==',1);
    comp.addComment('Select alpha and beta computation inputs');
    pirelab.getSwitchComp(dcoreNet,[gamma,gammaA],gamma_betaA,buffer_id_gdelay,'','==',1);
    pirelab.getSwitchComp(dcoreNet,[gammaB,gamma],gamma_betaB,buffer_id_gdelay,'','==',1);
    pirelab.getUnitDelayComp(dcoreNet,gamma_alpha,alphaIn);
    pirelab.getUnitDelayComp(dcoreNet,gamma_betaA,betaAIn);
    pirelab.getUnitDelayComp(dcoreNet,gamma_betaB,betaBIn);


    alpha_En_pdelay=dcoreNet.addSignal(boolType,'alpha_En_pdelay');
    betaA_En_pdelay=dcoreNet.addSignal(boolType,'betaA_En_pdelay');
    betaB_En_pdelay=dcoreNet.addSignal(boolType,'betaB_En_pdelay');

    pirelab.getIntDelayComp(dcoreNet,alpha_En,alpha_En_pdelay,gdelay+1);
    pirelab.getIntDelayComp(dcoreNet,betaA_En,betaA_En_pdelay,gdelay+1);
    pirelab.getIntDelayComp(dcoreNet,betaB_En,betaB_En_pdelay,gdelay+1);

    alphaOut=dcoreNet.addSignal(smetVType8,'alphaOut');
    betaAOut=dcoreNet.addSignal(smetVType8,'betaAOut');
    betaBOut=dcoreNet.addSignal(smetVType8,'betaBOut');

    alphaNet=this.elabAlphaBeta(dcoreNet,blockInfo,dataRate,1);
    betaANet=this.elabAlphaBeta(dcoreNet,blockInfo,dataRate,2);
    betaBNet=this.elabAlphaBeta(dcoreNet,blockInfo,dataRate,3);
    pirelab.instantiateNetwork(dcoreNet,alphaNet,[alphaIn,alpha_En_pdelay],alphaOut,'alphaInst');
    pirelab.instantiateNetwork(dcoreNet,betaANet,[betaAIn,betaA_En_pdelay],betaAOut,'betaAInst');
    pirelab.instantiateNetwork(dcoreNet,betaBNet,[betaBIn,betaB_En_pdelay],betaBOut,'betaBInst');



    aramNet=this.elabAlphaRAM(dcoreNet,blockInfo,dataRate);

    alphaRAMOut=dcoreNet.addSignal(smetVType8,'alphaRAMOut');
    alpha_raddr_pdelay=dcoreNet.addSignal(extrinaddrType,'alpha_raddr_pdelay');
    alpha_waddr_pdelay=dcoreNet.addSignal(extrinaddrType,'alpha_waddr_pdelay');
    abdelay=4;
    comp=pirelab.getIntDelayComp(dcoreNet,alpha_raddr,alpha_raddr_pdelay,gdelay+abdelay+2+2);
    comp.addComment('alpha and beta pipeline registers');
    pirelab.getIntDelayComp(dcoreNet,alpha_waddr,alpha_waddr_pdelay,gdelay+abdelay+2+2);
    pirelab.instantiateNetwork(dcoreNet,aramNet,[alphaOut,alpha_waddr_pdelay,alpha_En_pdelay,alpha_raddr_pdelay],...
    alphaRAMOut,'alphaRAMInst');



    buffer_id_gabdelay=dcoreNet.addSignal(boolType,'buffer_id_gabdelay');
    pirelab.getIntDelayComp(dcoreNet,buffer_id_gdelay,buffer_id_gabdelay,abdelay);

    beta_selected=dcoreNet.addSignal(smetVType8,'beta_selected');
    beta_extrinIn=dcoreNet.addSignal(smetVType8,'beta_extrinIn');
    pirelab.getSwitchComp(dcoreNet,[betaBOut,betaAOut],beta_selected,buffer_id_gabdelay,'','==',1);
    alphaRAM_delay=2;
    pirelab.getIntDelayComp(dcoreNet,beta_selected,beta_extrinIn,alphaRAM_delay);


    extrinsic_En_pdelay=dcoreNet.addSignal(boolType,'extrinsic_En_pdelay');
    pirelab.getIntDelayComp(dcoreNet,extrinsic_En,extrinsic_En_pdelay,gdelay+abdelay+alphaRAM_delay);



    bufferA_vec=dcoreNet.addSignal(extrinVType,'bufferA_vec');
    bufferB_vec=dcoreNet.addSignal(extrinVType,'bufferB_vec');
    buffer_vec=dcoreNet.addSignal(extrinVType,'buffer_vec');
    buffer_vec_pdelay=dcoreNet.addSignal(extrinVType,'buffer_vec_pdelay');

    pirelab.getMuxComp(dcoreNet,[prc1,llr_sys1,llr_apriori1],bufferA_vec);
    pirelab.getMuxComp(dcoreNet,[prc2,llr_sys2,llr_apriori2],bufferB_vec);

    pirelab.getSwitchComp(dcoreNet,[bufferB_vec,bufferA_vec],buffer_vec,Buffer_id,'','==',1);
    comp=pirelab.getIntDelayComp(dcoreNet,buffer_vec,buffer_vec_pdelay,gdelay+abdelay+alphaRAM_delay);
    comp.addComment('Extrinsic pipeline registers');


    extrinNet=this.elabExtrinsic(dcoreNet,blockInfo,dataRate);
    pirelab.instantiateNetwork(dcoreNet,extrinNet,[alphaRAMOut,beta_extrinIn,extrinsic_En_pdelay,buffer_vec_pdelay],...
    [extrinsic,decision],'extrinInst');
