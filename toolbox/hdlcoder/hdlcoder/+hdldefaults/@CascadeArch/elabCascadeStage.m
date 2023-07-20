function elabCascadeStage(this,hN,opName,decomposeStage,ipf,bmp,...
    hSignalsIn,hSignalsOut,isStartStage,casName,cascadeNum,...
    inVldSignal,hSerialNet,cascadeEnbSignal)




    stageName=sprintf('cascade_%s_%d',opName,decomposeStage);
    stageComment=sprintf('---- Cascade %s stage %d ----',opName,decomposeStage);
    if cascadeNum~=0&&isStartStage
        stageComment=sprintf('%s\n%s',casName,stageComment);
    end


    [dimLen,hInType]=pirelab.getVectorTypeInfo(hSignalsIn(1));
    ufix1Type=pir_ufixpt_t(1,0);
    addrType=pir_ufixpt_t(ceil(log2(decomposeStage)),0);


    if decomposeStage==2

        regInSignal=hN.addSignal(hInType,sprintf('%s_%d',opName,decomposeStage));
        regOutSignal=hN.addSignal(hInType,sprintf('%s_reg_%d',opName,decomposeStage));
        compName=sprintf('%scomp_%d',opName,decomposeStage);
        opComp=this.getCgirCompForEml(hN,hSignalsIn,regInSignal,compName,ipf,bmp);
        opComp.paramsFollowInputs(false);
        opComp.addComment(sprintf('%s\n%s: Compute ''%s'' of two inputs',stageComment,stageName,opName));


        compName=sprintf('stage_%d_reg',decomposeStage);
        outRegComp=pireml.getUnitDelayComp(hN,regInSignal,regOutSignal,compName);
        outRegComp.addComment(sprintf('%s: Stage output register',stageName));
        outRegComp.setClockEnable(cascadeEnbSignal);


        endComp=pirelab.getWireComp(hN,regOutSignal,hSignalsOut);


    else

        if isStartStage
            vecInSignal=hSignalsIn(1);


            preInSignal=hN.addSignal(hInType,sprintf('pre_in_%d',decomposeStage));
            pirelab.getConstComp(hN,preInSignal,0);
        else
            vecInSignal=hSignalsIn(1);
            preInSignal=hSignalsIn(2);
        end


        serialInSignal=hN.addSignal(hInType,sprintf('serial_in_%d',decomposeStage));
        firstInSignal=hN.addSignal(hInType,sprintf('dinx_%d',decomposeStage));
        hInSignals=[inVldSignal,vecInSignal];
        hOutSignals=[firstInSignal,serialInSignal];
        compName=sprintf('se_%d',decomposeStage);
        serialComp=this.getCascadeSerializer(hN,hInSignals,hOutSignals,compName,cascadeEnbSignal);
        serialComp.addComment(sprintf('%s\n%s: Stage serializer',stageComment,stageName));


        outEnbSignal=hN.addSignal(ufix1Type,sprintf('%s_enb_%d',opName,decomposeStage));
        preEnbSignal=hN.addSignal(ufix1Type,sprintf('pre_enb_%d',decomposeStage));
        countLimit=pirelab.getTypeInfoAsFi(addrType,'Floor','Wrap',decomposeStage-1);
        hInSignals=inVldSignal;
        hOutSignals=[outEnbSignal,preEnbSignal];
        compName=sprintf('cc_%d',decomposeStage);
        ccComp=this.getCascadeController2(hN,hInSignals,hOutSignals,countLimit,~isStartStage,compName);
        ccComp.setClockEnable(cascadeEnbSignal);
        ccComp.addComment(sprintf('%s: Cascade controller',stageName));


        hNetworkComp=hN.addComponent('ntwk_instance_comp',hSerialNet);
        inPort=[inVldSignal,serialInSignal,firstInSignal,outEnbSignal,preInSignal,preEnbSignal];
        outPort=hSignalsOut;
        pirelab.connectNtwkInstComp(hNetworkComp,inPort,outPort);
        hNetworkComp.Name=sprintf('serial_%s_operation_%d',opName,decomposeStage);

    end


