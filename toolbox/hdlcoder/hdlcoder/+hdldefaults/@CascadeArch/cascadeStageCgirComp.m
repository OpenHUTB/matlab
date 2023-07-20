function cascadeStageCgirComp(this,hN,hC,opName,decomposeStage,ipf,bmp,...
    hSignalsIn,hSignalsOut,decompose_vector,isStartStage,casName,cascadeNum)




    ntwkName=sprintf('cascade_%s_%d',opName,decomposeStage);
    ntwkComment=sprintf('---- Cascade %s stage %d ----',opName,decomposeStage);
    if cascadeNum~=0&&isStartStage
        ntwkComment=sprintf('%s\n%s',casName,ntwkComment);
    end


    if this.getInstantiateStages
        hNewNet=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name',ntwkName,...
        'InportSignals',hSignalsIn,...
        'OutportSignals',hSignalsOut);
        pirelab.instantiateNetwork(hN,hNewNet,hSignalsIn,hSignalsOut,[ntwkName,'_inst']);
        tSignalsIn=hNewNet.PirInputSignals';
        tSignalsOut=hNewNet.PirOutputSignals';
        hNewNet.setFlattenHierarchy(hN.getFlattenHierarchy);
        hN=hNewNet;
    else
        tSignalsIn=hSignalsIn;
        tSignalsOut=hSignalsOut;
    end


    dataSignalsIn=tSignalsIn;


    up=decompose_vector(1);


    hInType=dataSignalsIn(1).Type;
    ufix1Type=pir_ufixpt_t(1,0);
    addrType=pir_ufixpt_t(ceil(log2(decomposeStage)),0);



    regInSignal=hN.addSignal(hInType,sprintf('%s_%d',opName,decomposeStage));
    regOutSignal=hN.addSignal(hInType,sprintf('%s_reg_%d',opName,decomposeStage));


    if decomposeStage==2

        opInSignals=dataSignalsIn;
        compName=sprintf('%scomp_%d',opName,decomposeStage);
        opComp=this.getCgirCompForEml(hN,opInSignals,regInSignal,compName,ipf,bmp);
        opComp.addComment(sprintf('%s\n%s: Compute ''%s'' of two inputs',ntwkComment,ntwkName,opName));


    else

        hS=hC.PirInputSignals(1);
        [~,enable]=hN.getClockBundle(hS,1,1,1);
        inputValidSignal=hN.addSignal(ufix1Type,sprintf('in_vld_%d',decomposeStage));
        startComp=pirelab.getWireComp(hN,enable,inputValidSignal);
        startComp.addComment(ntwkComment);


        hS=dataSignalsIn(1);
        [~,stageValidSignal]=hN.getClockBundle(hS,up,1,1);


        cntSignal=hN.addSignal(addrType,sprintf('cnt_%d',decomposeStage));
        inSelSignal=hN.addSignal(hInType,sprintf('cur_value_%d',decomposeStage));

        inSelName=sprintf('inswitch_%d',decomposeStage);
        inSelComp=pirelab.getSwitchComp(hN,dataSignalsIn(2:end),inSelSignal,cntSignal,inSelName);
        inSelComp.addComment(sprintf('%s: Input selector',ntwkName));


        invld_and_not_cntenbSignal=hN.addSignal(ufix1Type,sprintf('invld_and_not_cntenb_%d',decomposeStage));
        compSelSignal=hN.addSignal(hInType,sprintf('pre_%s_%d',opName,decomposeStage));

        hInSignals=[dataSignalsIn(1),regOutSignal];
        compSelName=sprintf('compswitch_%d',decomposeStage);
        compSelComp=pirelab.getSwitchComp(hN,hInSignals,compSelSignal,invld_and_not_cntenbSignal,compSelName,'==',1);
        compSelComp.addComment(sprintf('%s: Choose between new input value or saved value',ntwkName));


        cnt_enbSignal=hN.addSignal(ufix1Type,sprintf('cnt_enb_%d',decomposeStage));
        cnt_clkenbSignal=hN.addSignal(ufix1Type,sprintf('cnt_clkenb_%d',decomposeStage));
        cntenb_tmpSignal=hN.addSignal(ufix1Type,sprintf('cntenb_tmp_%d',decomposeStage));

        hInSignals=[inputValidSignal,stageValidSignal,cnt_enbSignal,cntSignal];
        hOutSignals=[cnt_clkenbSignal,cntenb_tmpSignal,invld_and_not_cntenbSignal];
        compName=sprintf('cc_%d',decomposeStage);
        ccComp=this.getCascadeController(hN,hInSignals,hOutSignals,decomposeStage,compName);
        ccComp.addComment(sprintf('%s: Cascade controller',ntwkName));
        [clock,~,reset]=ccComp.getClockBundle(tSignalsOut(1),up,1,1);


        count_limit=decomposeStage-1;
        compName=sprintf('count_%d',decomposeStage);
        cntComp=pireml.getCounterComp(...
        'Network',hN,...
        'OutputSignal',cntSignal,...
        'OutputSimulinkRate',0,...
        'Name',compName,...
        'CountToValue',count_limit,...
        'ClockEnableSignal',cnt_clkenbSignal,...
        'LimitedCounterOptimize',false);
        cntComp.addComment(sprintf('%s: Counter',ntwkName));


        compName=sprintf('cnt_enb_reg_%d',decomposeStage);
        cntenbComp=pireml.getUnitDelayComp(hN,cntenb_tmpSignal,cnt_enbSignal,compName);
        cntenbComp.addComment(sprintf('%s: Counter enable',ntwkName));
        cntenbComp.connectClockBundle(clock,cnt_clkenbSignal,reset);


        opInSignals=[compSelSignal,inSelSignal];
        compName=sprintf('%scomp_%d',opName,decomposeStage);
        opComp=this.getCgirCompForEml(hN,opInSignals,regInSignal,compName,ipf,bmp);
        opComp.addComment(sprintf('%s: Compute ''%s'' of current and previous value',ntwkName,opName));

    end


    compName=sprintf('stage_%d_reg',decomposeStage);
    outRegComp=pireml.getUnitDelayComp(hN,regInSignal,regOutSignal,compName);
    outRegComp.addComment(sprintf('%s: Stage output register',ntwkName));
    [clock,enb,reset]=outRegComp.getClockBundle(tSignalsOut(1),up,1,1);
    outRegComp.connectClockBundle(clock,enb,reset);


    endComp=pirelab.getWireComp(hN,regOutSignal,tSignalsOut(1));

end


