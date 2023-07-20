function bcalNet=elabBetaCalculationUnit(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix5Type=pir_ufixpt_t(5,0);
    sfix5Type=pir_sfixpt_t(6,0);
    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);

    sminType=pir_ufixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    sminVType=pirelab.getPirVectorType(sminType,blockInfo.memDepth);

    sType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    vType=pirelab.getPirVectorType(ufix5Type,blockInfo.memDepth);
    v1Type=pirelab.getPirVectorType(sfix5Type,blockInfo.memDepth);
    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);


    bcalNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BetaCalculationUnit',...
    'Inportnames',{'signs','prodsign','minidx','min1','min2','count'},...
    'InportTypes',[sType,sType,vType,sminVType,sminVType,ufix5Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'beta'},...
    'OutportTypes',betaVType...
    );

    signs=bcalNet.PirInputSignals(1);
    prodsign=bcalNet.PirInputSignals(2);
    minidx=bcalNet.PirInputSignals(3);
    min1=bcalNet.PirInputSignals(4);
    min2=bcalNet.PirInputSignals(5);
    count=bcalNet.PirInputSignals(6);

    beta=bcalNet.PirOutputSignals(1);

    signmag=bcalNet.addSignal(betaVType,'signmag');
    signsel=bcalNet.addSignal(sType,'signsel');
    ind_min=bcalNet.addSignal(sType,'minind');%#ok<*AGROW>

    pirelab.getLogicComp(bcalNet,[prodsign,signs],signsel,'xnor');


    const1=bcalNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(bcalNet,const1,1);

    countadd=bcalNet.addSignal(count.Type,'countIdx');
    pirelab.getAddComp(bcalNet,[count,const1],countadd,'Floor','Wrap','AddComp');
    pirelab.getRelOpComp(bcalNet,[minidx,countadd],ind_min,'==');

    ind_minarray=this.demuxSignal(bcalNet,ind_min,'ind_min_array');
    min1array=this.demuxSignal(bcalNet,min1,'min1_array');
    min2array=this.demuxSignal(bcalNet,min2,'min2_array');

    for idx=1:blockInfo.memDepth
        magarray(idx)=bcalNet.addSignal(sminType,['mag_array_',num2str(idx)]);
        pirelab.getSwitchComp(bcalNet,[min2array(idx),min1array(idx)],magarray(idx),ind_minarray(idx),'Switch_min','==',1);
    end

    mag=bcalNet.addSignal(sminVType,'mag');
    mag_dtc=bcalNet.addSignal(betaVType,'mag_dtc');

    this.muxSignal(bcalNet,magarray,mag);
    pirelab.getDTCComp(bcalNet,mag,mag_dtc,'Floor','Wrap','SI');

    smarray=this.demuxSignal(bcalNet,mag_dtc,'magdtc_array');

    smag=bcalNet.addSignal(betaVType,'smag');
    pirelab.getUnaryMinusComp(bcalNet,mag_dtc,smag,'wrap','uminusComp');

    signmagarray=this.demuxSignal(bcalNet,smag,'smag_array');
    signselarray=this.demuxSignal(bcalNet,signsel,'signalsel_array');

    for idx1=1:blockInfo.memDepth
        betadarray(idx1)=bcalNet.addSignal(bType,['betad_array_',num2str(idx1)]);
        pirelab.getSwitchComp(bcalNet,[smarray(idx1),signmagarray(idx1)],betadarray(idx1),signselarray(idx1),'Switch_min','==',1);
    end

    betad=bcalNet.addSignal(betaVType,'betaD');
    this.muxSignal(bcalNet,betadarray,betad);
    pirelab.getWireComp(bcalNet,betad,beta);

