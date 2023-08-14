function bcNet=elabBetaDecompressNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_ufixpt_t(1,0);
    ufix5Type=pir_ufixpt_t(5,0);
    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    mindtcType=pir_ufixpt_t(blockInfo.minWL,0);
    bc1Type=pir_ufixpt_t(blockInfo.betadecmpWL,0);
    bc2Type=pir_ufixpt_t(2*blockInfo.minWL,0);
    sminType=pir_ufixpt_t(blockInfo.betaWL,blockInfo.alphaFL);

    sminVType=pirelab.getPirVectorType(sminType,blockInfo.memDepth);
    sType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    vType=pirelab.getPirVectorType(ufix5Type,blockInfo.memDepth);
    bcVType1=pirelab.getPirVectorType(bc1Type,blockInfo.memDepth);
    bcVType2=pirelab.getPirVectorType(bc2Type,blockInfo.memDepth);
    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);
    dtcVType=pirelab.getPirVectorType(mindtcType,blockInfo.memDepth);


    bcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BetaDecompress',...
    'Inportnames',{'betacomp1','betacomp2','validin','count','reset'},...
    'InportTypes',[bcVType1,bcVType2,ufix1Type,ufix5Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'beta','valid'},...
    'OutportTypes',[betaVType,ufix1Type]...
    );



    betacomp1=bcNet.PirInputSignals(1);
    betacomp2=bcNet.PirInputSignals(2);
    validin=bcNet.PirInputSignals(3);
    count=bcNet.PirInputSignals(4);
    reset=bcNet.PirInputSignals(5);

    betaout=bcNet.PirOutputSignals(1);
    validout=bcNet.PirOutputSignals(2);
    x=2*(blockInfo.minWL);
    y=blockInfo.minWL-1;



    sign1=bcNet.addSignal(sType,'sign1');%#ok<*AGROW>
    pirelab.getBitSliceComp(bcNet,betacomp1,sign1,29,29,'ext_sign1');

    sign2=bcNet.addSignal(sType,'sign2');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign2,28,28,'ext_sign2');

    sign3=bcNet.addSignal(sType,'sign3');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign3,27,27,'ext_sign3');

    sign4=bcNet.addSignal(sType,'sign4');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign4,26,26,'ext_sign4');

    sign5=bcNet.addSignal(sType,'sign5');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign5,25,25,'ext_sign5');

    sign6=bcNet.addSignal(sType,'sign6');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign6,24,24,'ext_sign6');

    sign7=bcNet.addSignal(sType,'sign7');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign7,23,23,'ext_sign7');

    sign8=bcNet.addSignal(sType,'sign8');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign8,22,22,'ext_sign8');

    sign9=bcNet.addSignal(sType,'sign9');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign9,21,21,'ext_sign9');

    sign10=bcNet.addSignal(sType,'sign10');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign10,20,20,'ext_sign10');

    sign11=bcNet.addSignal(sType,'sign11');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign11,19,19,'ext_sign11');

    sign12=bcNet.addSignal(sType,'sign12');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign12,18,18,'ext_sign12');

    sign13=bcNet.addSignal(sType,'sign13');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign13,17,17,'ext_sign13');

    sign14=bcNet.addSignal(sType,'sign14');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign14,16,16,'ext_sign14');

    sign15=bcNet.addSignal(sType,'sign15');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign15,15,15,'ext_sign15');

    sign16=bcNet.addSignal(sType,'sign16');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign16,14,14,'ext_sign16');

    sign17=bcNet.addSignal(sType,'sign17');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign17,13,13,'ext_sign17');

    sign18=bcNet.addSignal(sType,'sign18');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign18,12,12,'ext_sign18');

    sign19=bcNet.addSignal(sType,'sign19');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign19,11,11,'ext_sign19');

    sign20=bcNet.addSignal(sType,'sign20');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign20,10,10,'ext_sign20');

    sign21=bcNet.addSignal(sType,'sign21');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign21,9,9,'ext_sign21');

    sign22=bcNet.addSignal(sType,'sign22');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign22,8,8,'ext_sign22');

    sign23=bcNet.addSignal(sType,'sign23');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign23,7,7,'ext_sign23');

    sign24=bcNet.addSignal(sType,'sign24');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign24,6,6,'ext_sign24');

    sign25=bcNet.addSignal(sType,'sign25');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign25,5,5,'ext_sign25');

    sign26=bcNet.addSignal(sType,'sign26');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign26,4,4,'ext_sign26');

    sign27=bcNet.addSignal(sType,'sign27');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign27,3,3,'ext_sign27');

    sign28=bcNet.addSignal(sType,'sign28');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign28,2,2,'ext_sign28');

    sign29=bcNet.addSignal(sType,'sign29');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign29,1,1,'ext_sign29');

    sign30=bcNet.addSignal(sType,'sign30');
    pirelab.getBitSliceComp(bcNet,betacomp1,sign30,0,0,'ext_sign30');

    prodsign=bcNet.addSignal(sType,'prodsign');
    pirelab.getBitSliceComp(bcNet,betacomp1,prodsign,35,35,'ext_prodsign');

    min_index=bcNet.addSignal(vType,'min_index');
    pirelab.getBitSliceComp(bcNet,betacomp1,min_index,34,30,'ext_minindex');

    min1_dtc=bcNet.addSignal(dtcVType,'min1_dtc');
    min2_dtc=bcNet.addSignal(dtcVType,'min2_dtc');
    smin1=bcNet.addSignal(sminVType,'sMin1');
    smin2=bcNet.addSignal(sminVType,'sMin2');

    pirelab.getBitSliceComp(bcNet,betacomp2,min2_dtc,y,0,'ext_min2');
    pirelab.getDTCComp(bcNet,min2_dtc,smin2,'Floor','Wrap','SI');

    pirelab.getBitSliceComp(bcNet,betacomp2,min1_dtc,x-1,y+1,'ext_min1');
    pirelab.getDTCComp(bcNet,min1_dtc,smin1,'Floor','Wrap','SI');



    rstcount=bcNet.addSignal(ufix1Type,'resetCount');
    countmax=bcNet.addSignal(ufix1Type,'countMax');
    count1=bcNet.addSignal(count.Type,'countVal');

    const1=bcNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(bcNet,const1,1);

    countadd=bcNet.addSignal(count.Type,'countIdx');
    pirelab.getAddComp(bcNet,[count,const1],countadd,'Floor','Wrap','AddComp');

    count1_reg=bcNet.addSignal(count.Type,'countValReg');

    pirelab.getRelOpComp(bcNet,[countadd,count1_reg],countmax,'==');
    pirelab.getLogicComp(bcNet,[countmax,reset],rstcount,'or');


    enbcount=bcNet.addSignal(ufix1Type,'enbCount');
    pirelab.getUnitDelayEnabledResettableComp(bcNet,validin,enbcount,validin,rstcount,'',0);

    enbcnt=bcNet.addSignal(ufix1Type,'enbCountReg');
    pirelab.getLogicComp(bcNet,[validin,enbcount],enbcnt,'or');



    pirelab.getWireComp(bcNet,enbcount,validout,'');
    pirelab.getCounterComp(bcNet,[rstcount,enbcnt],count1,'Count limited',0,1,31,1,0,1,0,'counter',0);

    pirelab.getUnitDelayComp(bcNet,count1,count1_reg,'',0);



    x=[sign1,sign2,sign3,sign4,sign5,sign6,sign7,sign8,sign9,sign10,sign11,sign12,sign13,sign14,sign15,sign16,sign17,sign18,sign19,sign20...
    ,sign21,sign22,sign23,sign24,sign25,sign26,sign27,sign28,sign29,sign30,sign1];
    sign=bcNet.addSignal(sType,'signs');
    pirelab.getMultiPortSwitchComp(bcNet,[count1,x],sign,1,1,'Floor','Wrap');

    beta=bcNet.addSignal(betaout.Type,'beta');
    betaoutd=bcNet.addSignal(betaout.Type,'betaD');

    beta_reg=bcNet.addSignal(beta.Type,'betaReg');

    bcalNet=this.elabBetaCalculationNetwork(bcNet,blockInfo,dataRate);
    bcalNet.addComment('Beta Calculation Unit');
    pirelab.instantiateNetwork(bcNet,bcalNet,[sign,prodsign,min_index,smin1,smin2,count1],...
    beta_reg,'BetaCalUnit');

    pirelab.getUnitDelayComp(bcNet,beta_reg,beta,'beta',0);


    beta_tmp1=bcNet.addSignal(beta.Type,'beta_tmp1');
    pirelab.getBitShiftComp(bcNet,beta,beta_tmp1,'sra',1,0,'shifter_beta');

    beta_tmp2=bcNet.addSignal(beta.Type,'beta_tmp2');
    pirelab.getBitShiftComp(bcNet,beta,beta_tmp2,'sra',2,0,'shifter_beta');

    beta_tmp3=bcNet.addSignal(beta.Type,'beta_tmp3');
    pirelab.getBitShiftComp(bcNet,beta,beta_tmp3,'sra',3,0,'shifter_beta');

    beta_tmp4=bcNet.addSignal(beta.Type,'beta_tmp4');
    pirelab.getBitShiftComp(bcNet,beta,beta_tmp4,'sra',4,0,'shifter_beta');

    beta_add1=bcNet.addSignal(beta.Type,'beta_add1');

    if blockInfo.ScalingFactor==1
        pirelab.getWireComp(bcNet,beta,betaoutd);

    elseif blockInfo.ScalingFactor==0.5
        pirelab.getWireComp(bcNet,beta_tmp1,betaoutd);

    elseif blockInfo.ScalingFactor==0.5625
        pirelab.getAddComp(bcNet,[beta_tmp1,beta_tmp4],betaoutd,'Floor','Wrap','AddComp');

    elseif blockInfo.ScalingFactor==0.625
        pirelab.getAddComp(bcNet,[beta_tmp1,beta_tmp3],betaoutd,'Floor','Wrap','AddComp');

    elseif blockInfo.ScalingFactor==0.75
        pirelab.getAddComp(bcNet,[beta_tmp1,beta_tmp2],betaoutd,'Floor','Wrap','AddComp');

    elseif(blockInfo.ScalingFactor==0.6875||blockInfo.ScalingFactor==0.8125)
        if(blockInfo.ScalingFactor==0.6875)
            pirelab.getAddComp(bcNet,[beta_tmp4,beta_tmp3],beta_add1,'Floor','Wrap','AddComp');

        else
            pirelab.getAddComp(bcNet,[beta_tmp2,beta_tmp4],beta_add1,'Floor','Wrap','AddComp');
        end
        pirelab.getAddComp(bcNet,[beta_tmp1,beta_add1],betaoutd,'Floor','Wrap','AddComp');

    elseif blockInfo.ScalingFactor==0.875
        pirelab.getSubComp(bcNet,[beta,beta_tmp3],betaoutd,'Floor','Wrap','SubComp');

    elseif blockInfo.ScalingFactor==0.9375
        pirelab.getSubComp(bcNet,[beta,beta_tmp4],betaoutd,'Floor','Wrap','SubComp');
    end

    pirelab.getWireComp(bcNet,betaoutd,betaout);
