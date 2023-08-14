function cascadeStageCgirComp_ValueAndIndex(this,hN,hC,opName,decomposeStage,ipf,bmp,...
    hSignalsIn,hSignalsOut,decompose_vector,isStartStage,indexType)




    netName=sprintf('cascade_%s_%d',opName,decomposeStage);
    netComment=sprintf('---- Stage_%d Input %s implementation ----',decomposeStage,opName);


    if this.getInstantiateStages
        hNewNet=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name',netName,...
        'InportSignals',hSignalsIn,...
        'OutportSignals',hSignalsOut);
        pirelab.instantiateNetwork(hN,hNewNet,hSignalsIn,hSignalsOut,[netName,'_inst']);
        tSignalsIn=hNewNet.PirInputSignals';
        tSignalsOut=hNewNet.PirOutputSignals';
        hNewNet.setFlattenHierarchy(hN.getFlattenHierarchy);
        hN=hNewNet;
    else
        tSignalsIn=hSignalsIn;
        tSignalsOut=hSignalsOut;
    end


    if isStartStage
        dataSignalsIn=tSignalsIn;
        indxSignalsIn=tSignalsIn(end);
    else
        dataSignalsIn=tSignalsIn(1:end-1);
        indxSignalsIn=tSignalsIn(end);
    end


    up=decompose_vector(1);


    hInType=dataSignalsIn(1).Type;
    ufix1Type=pir_ufixpt_t(1,0);
    addrType=pir_ufixpt_t(ceil(log2(decomposeStage)),0);



    regInSignal=hN.addSignal(hInType,sprintf('%s_%d',opName,decomposeStage));
    regOutSignal=hN.addSignal(hInType,sprintf('%s_reg_%d',opName,decomposeStage));

    regInIndxSignal=hN.addSignal(indexType,sprintf('%s_idx_%d',opName,decomposeStage));
    regOutIndxSignal=hN.addSignal(indexType,sprintf('%s_reg_idx_%d',opName,decomposeStage));
    idxclkenbSignal=hN.addSignal(ufix1Type,sprintf('%s_idx_clkenb_%d',opName,decomposeStage));

    cmptrueSignal=hN.addSignal(ufix1Type,sprintf('compare_true_%d',decomposeStage));
    nxtIdxSignal=hN.addSignal(indexType,sprintf('%s_nxt_idx_%d',opName,decomposeStage));


    if decomposeStage==2

        [constIndex1,constIndex2,constComp1,constComp2]=this.getIndexConstantCompTwo(hN,indexType);
        constComp1.addComment(netComment);


        opInSignals=[dataSignalsIn,constIndex1,constIndex2];
        opOutSignals=[regInSignal,regInIndxSignal,cmptrueSignal];
        compName=sprintf('%scomp_%d',opName,decomposeStage);
        opComp=this.getCgirCompForEml(hN,opInSignals,opOutSignals,compName,ipf,bmp);
        opComp.addComment(sprintf('%s: Compute ''%s'' of two inputs',netName,opName));


        compName=sprintf('comp_reg_%d',decomposeStage);
        outRegComp=pireml.getUnitDelayComp(hN,regInSignal,regOutSignal,compName);
        outRegComp.addComment(sprintf('%s: Output register',netName));
        outRegComp.getClockBundle(tSignalsOut(1),up,1,1);


        compName=sprintf('idx_reg_%d',decomposeStage);
        outRegIndxComp=pireml.getUnitDelayComp(hN,regInIndxSignal,regOutIndxSignal,compName);
        outRegIndxComp.addComment(sprintf('%s: Index output register',netName));
        outRegIndxComp.getClockBundle(tSignalsOut(1),up,1,1);


    else

        hS=hN.PirInputSignals(1);
        [clk,enable]=hN.getClockBundle(hS,1,1,1);
        inputValidSignal=hN.addSignal(ufix1Type,sprintf('in_vld_%d',decomposeStage));
        startComp=pirelab.getWireComp(hN,enable,inputValidSignal);
        startComp.addComment(netComment);


        hS=dataSignalsIn(1);
        [clk,stageValidSignal]=hN.getClockBundle(hS,up,1,1);


        cntSignal=hN.addSignal(addrType,sprintf('cnt_%d',decomposeStage));
        inSelSignal=hN.addSignal(hInType,sprintf('cur_value_%d',decomposeStage));

        inSelName=sprintf('inswitch_%d',decomposeStage);
        inSelComp=pirelab.getSwitchComp(hN,dataSignalsIn(2:end),inSelSignal,cntSignal,inSelName);
        inSelComp.addComment(sprintf('%s: Input selector',netName));


        invld_and_not_cntenbSignal=hN.addSignal(ufix1Type,sprintf('invld_and_not_cntenb_%d',decomposeStage));
        compSelSignal=hN.addSignal(hInType,sprintf('pre_%s_%d',opName,decomposeStage));

        hInSignals=[dataSignalsIn(1),regOutSignal];
        compSelName=sprintf('compswitch_%d',decomposeStage);
        compSelComp=pirelab.getSwitchComp(hN,hInSignals,compSelSignal,invld_and_not_cntenbSignal,compSelName,'==',1);
        compSelComp.addComment(sprintf('%s: Choose between new input value or saved value',netName));


        cnt_enbSignal=hN.addSignal(ufix1Type,sprintf('cnt_enb_%d',decomposeStage));
        cnt_clkenbSignal=hN.addSignal(ufix1Type,sprintf('cnt_clkenb_%d',decomposeStage));
        cntenb_tmpSignal=hN.addSignal(ufix1Type,sprintf('cntenb_tmp_%d',decomposeStage));

        hInSignals=[inputValidSignal,stageValidSignal,cnt_enbSignal,cntSignal];
        hOutSignals=[cnt_clkenbSignal,cntenb_tmpSignal,invld_and_not_cntenbSignal];
        compName=sprintf('cc_%d',decomposeStage);
        ccComp=this.getCascadeController(hN,hInSignals,hOutSignals,decomposeStage,compName);
        ccComp.addComment(sprintf('%s: Cascade controller',netName));
        [clock,~,reset]=hN.getClockBundle(tSignalsOut(1),up,1,1);


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
        cntComp.addComment(sprintf('%s: Counter',netName));


        compName=sprintf('cnt_enb_reg_%d',decomposeStage);
        cntenbComp=pireml.getUnitDelayComp(hN,cntenb_tmpSignal,cnt_enbSignal,compName);
        cntenbComp.addComment(sprintf('%s: Counter enable',netName));
        cntenbComp.connectClockBundle(clock,cnt_clkenbSignal,reset);


        inIdxSignal=hN.addSignal(indexType,sprintf('cur_idx_%d',decomposeStage));
        compIdxSignal=hN.addSignal(indexType,sprintf('pre_idx_%d',decomposeStage));

        opInSignals=[compSelSignal,inSelSignal,compIdxSignal,inIdxSignal];
        opOutSignals=[regInSignal,nxtIdxSignal,cmptrueSignal];
        compName=sprintf('%scomp_%d',opName,decomposeStage);
        opComp=this.getCgirCompForEml(hN,opInSignals,opOutSignals,compName,ipf,bmp);
        opComp.addComment(sprintf('%s: Compute ''%s'' of current and previous value',netName,opName));


        compName=sprintf('stage_%d_reg',decomposeStage);
        outRegComp=pireml.getUnitDelayComp(hN,regInSignal,regOutSignal,compName);
        outRegComp.addComment(sprintf('%s: Output register',netName));
        outRegComp.getClockBundle(tSignalsOut(1),up,1,1);


        hInSignals=[cntSignal,indxSignalsIn,invld_and_not_cntenbSignal,regOutIndxSignal,stageValidSignal,cmptrueSignal,nxtIdxSignal];
        hOutSignals=[inIdxSignal,compIdxSignal,idxclkenbSignal,regInIndxSignal];
        compName=sprintf('id_%d',decomposeStage);
        idComp=this.getCascadeControllerIndex(hN,hInSignals,hOutSignals,decomposeStage,isStartStage,compName);
        idComp.addComment(sprintf('%s: Determine the index of the %s',netName,opName));
        [clock,~,reset]=idComp.getClockBundle(tSignalsOut(1),up,1,1);


        compName=sprintf('idx_%d_reg',decomposeStage);
        outRegIndxComp=pireml.getUnitDelayComp(hN,regInIndxSignal,regOutIndxSignal,compName);
        outRegIndxComp.addComment(sprintf('%s: Index output register',netName));
        outRegIndxComp.connectClockBundle(clock,idxclkenbSignal,reset);

    end


    endComp=pirelab.getWireComp(hN,regOutSignal,tSignalsOut(1));
    endComp2=pirelab.getWireComp(hN,regOutIndxSignal,tSignalsOut(2));

end


