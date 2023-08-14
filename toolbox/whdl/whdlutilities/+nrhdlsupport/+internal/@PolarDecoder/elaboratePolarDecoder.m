function elaboratePolarDecoder(this,topNet,blockInfo,insignals,outsignals)







    configFromPort=blockInfo.configFromPort;
    outputRnti=blockInfo.outputRnti;
    rntiFromPort=blockInfo.rntiFromPort;
    debugPortsEn=blockInfo.debugPortsEn;
    downlinkMode=blockInfo.downlinkMode;
    coreOrder=blockInfo.coreOrder;
    nMax=blockInfo.nMax;
    listLength=blockInfo.listLength;
    boolType=pir_boolean_t;
    boolVecType=pirelab.createPirArrayType(boolType,[1,listLength]);
    decType=blockInfo.decType;
    betaVecType=pirelab.createPirArrayType(decType,[1,coreOrder]);
    llrReinType=blockInfo.llrReinType;
    intLlrType=blockInfo.intLlrType;
    intLlrVecType=pirelab.createPirArrayType(intLlrType,[1,coreOrder]);
    intLlrDecType=pirelab.createPirArrayType(intLlrType,[1,listLength]);
    intLlrSatLim=blockInfo.intLlrSatLim;
    stageType=blockInfo.stageType;
    blockType=blockInfo.blockType;
    pathType=blockInfo.pathType;
    betaPathType=pirelab.createPirArrayType(pathType,[1,nMax]);
    pathVecType=pirelab.createPirArrayType(pathType,[1,listLength]);
    decVecType=pirelab.createPirArrayType(decType,[1,listLength]);
    metricType=blockInfo.metricType;
    metricVecType=pirelab.createPirArrayType(metricType,[1,listLength]);
    NType=blockInfo.NType;
    KType=blockInfo.KType;
    KInType=blockInfo.KInType;
    EType=blockInfo.EType;
    crcErrType=blockInfo.crcErrType;
    parityCrcErrType=blockInfo.parityCrcErrType;
    crcErrVecType=pirelab.createPirArrayType(crcErrType,[1,listLength]);
    errType=blockInfo.errType;
    errVecType=pirelab.createPirArrayType(errType,[1,listLength]);
    concatBetaType=blockInfo.concatBetaType;
    targetRntiType=blockInfo.targetRntiType;


    dataIn=insignals(1);
    dataRate=dataIn.SimulinkRate;

    startIn=insignals(2);
    endIn=insignals(3);
    validIn=insignals(4);

    if configFromPort
        KIn=insignals(5);
        EIn=insignals(6);
    end

    if rntiFromPort
        targetRntiIn=insignals(end);
    end


    dataOut=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    validOut=outsignals(4);
    errOut=outsignals(5);
    nextFrameOut=outsignals(6);

    if debugPortsEn
        decLlr=outsignals(7);
        decLlrValid=outsignals(8);
    end


    dataIn_reg=topNet.addSignal(dataIn.Type,'dataIn_reg');
    startIn_reg=topNet.addSignal(boolType,'startIn_reg');
    endIn_reg=topNet.addSignal(boolType,'endIn_reg');
    validIn_reg=topNet.addSignal(boolType,'validIn_reg');
    pirelab.getUnitDelayComp(topNet,dataIn,dataIn_reg);
    pirelab.getUnitDelayComp(topNet,startIn,startIn_reg);
    pirelab.getUnitDelayComp(topNet,endIn,endIn_reg);
    pirelab.getUnitDelayComp(topNet,validIn,validIn_reg);

    if rntiFromPort
        targetRnti_reg=topNet.addSignal(targetRntiType,'targetRnti_reg');
        pirelab.getUnitDelayComp(topNet,targetRntiIn,targetRnti_reg);

        targetRntiLatch=topNet.addSignal(targetRntiType,'targetRntiLatch');
        pirelab.getUnitDelayEnabledComp(topNet,targetRnti_reg,targetRntiLatch,startIn_reg,'RNTIreg','','',false,'',-1,true);
    end




    rxBuffer=topNet.addSignal(intLlrVecType,'rxBuffer');
    rxSel=topNet.addSignal(boolType,'rxSel');
    chnlBlock=topNet.addSignal(blockType,'chnlBlock');
    chnlLowerWrEn=topNet.addSignal(boolType,'chnlLowerWrEn');
    chnlUpperWrEn=topNet.addSignal(boolType,'chnlUpperWrEn');
    nextFrame=topNet.addSignal(boolType,'nextFrame');


    KLatch=topNet.addSignal(KType,'KLatch');
    nSub1=topNet.addSignal(stageType,'nSub1');
    NSub1=topNet.addSignal(NType,'NSub1');
    F=topNet.addSignal(boolType,'F');
    configured=topNet.addSignal(boolType,'configured');
    configValid=topNet.addSignal(boolType,'configValid');
    if downlinkMode
        ELatch=topNet.addSignal(EType,'ELatch');
        deitlvPathRdAddr=topNet.addSignal(KType,'deitlvPathRdAddr');
    else
        isParity=topNet.addSignal(boolType,'isParity');
        parityEn=topNet.addSignal(boolType,'parityEn');
    end


    decWrStage=topNet.addSignal(stageType,'decWrStage');
    decWrBlock=topNet.addSignal(blockType,'decWrBlock');
    decLowerWrEn=topNet.addSignal(boolType,'decLowerWrEn');
    decUpperWrEn=topNet.addSignal(boolType,'decUpperWrEn');
    rdStage=topNet.addSignal(stageType,'rdStage');
    rdBlock=topNet.addSignal(blockType,'rdBlock');
    makeDec=topNet.addSignal(boolType,'makeDec');
    alphaRdPath=topNet.addSignal(pathType,'alphaRdPath');
    betaRdPath=topNet.addSignal(betaPathType,'betaRdPath');
    wrPath=topNet.addSignal(pathType,'wrPath');
    activePathCnt=topNet.addSignal(pathType,'activePathCnt');
    mode=topNet.addSignal(boolType,'mode');
    betaSrc=topNet.addSignal(boolType,'betaSrc');
    startOutput=topNet.addSignal(boolType,'startOutput');
    leafIdx=topNet.addSignal(NType,'leafIdx');
    alphaUpdateWrEn=topNet.addSignal(boolType,'alphaUpdateWrEn');
    betaUpdateWrEn=topNet.addSignal(boolType,'betaUpdateWrEn');
    dupPtrWrEn=topNet.addSignal(boolType,'dupPtrWrEn');


    treeLowerOut=topNet.addSignal(intLlrVecType,'treeLowerOut');
    treeUpperOut=topNet.addSignal(intLlrVecType,'treeUpperOut');
    treeBetaOut=topNet.addSignal(betaVecType,'treeBetaOut');


    coreLowerOut=topNet.addSignal(intLlrVecType,'coreLowerOut');
    coreUpperOut=topNet.addSignal(intLlrVecType,'coreUpperOut');
    coreLeaf=topNet.addSignal(intLlrType,'coreLeaf');


    hardDecs=topNet.addSignal(decVecType,'hardDecs');
    pathWrEn=topNet.addSignal(boolType,'pathWrEn');
    contPaths=topNet.addSignal(pathVecType,'contPaths');
    pathOrder=topNet.addSignal(pathVecType,'metrics');
    newActvPathCnt=topNet.addSignal(pathType,'newActvPathCnt');


    pathRdAddr=topNet.addSignal(KType,'hardDecs');
    rdPath=topNet.addSignal(boolType,'rdPath');
    startInt=topNet.addSignal(boolType,'startInt');
    endInt=topNet.addSignal(boolType,'endInt');
    validInt=topNet.addSignal(boolType,'validInt');
    validCrc=topNet.addSignal(boolType,'validCrc');
    if downlinkMode
        prepad=topNet.addSignal(boolType,'prepad');
    end


    reconPaths=topNet.addSignal(decVecType,'reconPaths');
    copyEn=topNet.addSignal(boolType,'copyEn');


    configNet=this.elabConfig(topNet,blockInfo,dataRate);

    if configFromPort
        K_reg=topNet.addSignal(KInType,'K_reg');
        E_reg=topNet.addSignal(EType,'E_reg');
        pirelab.getUnitDelayComp(topNet,KIn,K_reg);
        pirelab.getUnitDelayComp(topNet,EIn,E_reg);

        inports=[leafIdx,K_reg,E_reg,startIn_reg];
    else
        inports=leafIdx;
    end

    outports=[KLatch,nSub1,NSub1,F,configured,configValid];

    if downlinkMode
        itlvPathRdAddr=topNet.addSignal(KType,'itlvPathRdAddr');
        inports=[inports,itlvPathRdAddr];

        outports=[outports,ELatch,deitlvPathRdAddr];
    else
        outports=[outports,isParity,parityEn];
    end

    pirelab.instantiateNetwork(topNet,configNet,inports,outports,'configNet_inst');


    dataInReinterp=topNet.addSignal(llrReinType,'dataInReinterp');
    pirelab.getDTCComp(topNet,dataIn_reg,dataInReinterp,'Floor','Wrap','SI');

    dataInDTC=topNet.addSignal(intLlrType,'dataInDTC');
    pirelab.getDTCComp(topNet,dataInReinterp,dataInDTC,'Floor','Wrap','RWV');

    channelLoaderNet=this.elabChannelLoader(topNet,blockInfo,dataRate);

    inports=[dataInDTC,startIn_reg,endIn_reg,validIn_reg,NSub1,startOutput,configValid];
    outports=[rxBuffer,rxSel,chnlBlock,chnlLowerWrEn,chnlUpperWrEn,nextFrame];

    pirelab.instantiateNetwork(topNet,channelLoaderNet,inports,outports,'channelLoaderNet_inst');


    startDecodePosEdge=topNet.addSignal(boolType,'startDecodePosEdge');

    coreControlNet=this.elabCoreController(topNet,blockInfo,dataRate);

    inports=[startIn_reg,startDecodePosEdge,nSub1,NSub1,F,newActvPathCnt];
    outports=[decWrStage,decWrBlock,decLowerWrEn,decUpperWrEn,rdStage,rdBlock,makeDec,...
    wrPath,activePathCnt,mode,betaSrc,startOutput,leafIdx,alphaUpdateWrEn,betaUpdateWrEn,dupPtrWrEn];

    pirelab.instantiateNetwork(topNet,coreControlNet,inports,outports,'coreControlNet_inst');



    ptrMemNet=this.elabPtrMem(topNet,blockInfo,dataRate);

    inports=[contPaths,dupPtrWrEn,decWrStage,rdStage,wrPath,alphaUpdateWrEn,betaUpdateWrEn];
    outports=[alphaRdPath,betaRdPath];

    pirelab.instantiateNetwork(topNet,ptrMemNet,inports,outports,'ptrMemNet_inst');

    rxBufferSat=topNet.addSignal(intLlrVecType,'rxBufferSat');
    pirelab.getSaturateComp(topNet,rxBuffer,rxBufferSat,-intLlrSatLim,intLlrSatLim);

    rxBufferSat_reg=topNet.addSignal(intLlrVecType,'rxBufferSat_reg');
    rxSel_reg=topNet.addSignal(boolType,'rxSel_reg');
    pirelab.getUnitDelayComp(topNet,rxBufferSat,rxBufferSat_reg);
    pirelab.getUnitDelayComp(topNet,rxSel,rxSel_reg);

    endValid_reg=topNet.addSignal(boolType,'endValid_reg');

    constTrue=topNet.addSignal(boolType,'constTrue');
    constTrue.SimulinkRate=dataRate;
    pirelab.getConstComp(topNet,constTrue,1);

    prevFrameNotDone=topNet.addSignal(boolType,'prevFrameNotDone');
    pirelab.getUnitDelayEnabledResettableComp(topNet,constTrue,prevFrameNotDone,startOutput,endValid_reg,'reg',0,'',true,'',-1,true);

    prevFrameDone=topNet.addSignal(boolType,'prevFrameDone');
    pirelab.getLogicComp(topNet,prevFrameNotDone,prevFrameDone,'not');

    startDecode=topNet.addSignal(boolType,'startDecode');
    pirelab.getLogicComp(topNet,[rxSel,configured,prevFrameDone],startDecode,'and');

    startDecode_reg=topNet.addSignal(boolType,'startDecode_reg');
    pirelab.getUnitDelayComp(topNet,startDecode,startDecode_reg);

    pirelab.getRelOpComp(topNet,[startDecode,startDecode_reg],startDecodePosEdge,'>');




    decWrStage_reg=topNet.addSignal(stageType,'decWrStage_reg');
    decWrBlock_reg=topNet.addSignal(blockType,'decWrBlock_reg');
    decLowerWrEn_reg=topNet.addSignal(boolType,'lowerWrEn_reg');
    decUpperWrEn_reg=topNet.addSignal(boolType,'upperWrEn_reg');
    pirelab.getIntDelayComp(topNet,decWrStage,decWrStage_reg,2);
    pirelab.getIntDelayComp(topNet,decWrBlock,decWrBlock_reg,2);
    pirelab.getIntDelayComp(topNet,decLowerWrEn,decLowerWrEn_reg,2);
    pirelab.getIntDelayComp(topNet,decUpperWrEn,decUpperWrEn_reg,2);


    wrStage=topNet.addSignal(stageType,'wrStage');
    wrBlock=topNet.addSignal(blockType,'wrBlock');
    lowerWrEn=topNet.addSignal(boolType,'lowerWrEn');
    upperWrEn=topNet.addSignal(boolType,'upperWrEn');
    pirelab.getMultiPortSwitchComp(topNet,[rxSel_reg,nSub1,decWrStage_reg],wrStage,1);
    pirelab.getMultiPortSwitchComp(topNet,[rxSel_reg,chnlBlock,decWrBlock_reg],wrBlock,1);
    pirelab.getMultiPortSwitchComp(topNet,[rxSel_reg,chnlLowerWrEn,decLowerWrEn_reg],lowerWrEn,1);
    pirelab.getMultiPortSwitchComp(topNet,[rxSel_reg,chnlUpperWrEn,decUpperWrEn_reg],upperWrEn,1);


    wrStage_reg=topNet.addSignal(stageType,'wrStage_reg');
    wrBlock_reg=topNet.addSignal(blockType,'wrBlock_reg');
    lowerWrEn_reg=topNet.addSignal(boolType,'lowerWrEn_reg');
    upperWrEn_reg=topNet.addSignal(boolType,'upperWrEn_reg');
    pirelab.getUnitDelayComp(topNet,wrStage,wrStage_reg);
    pirelab.getUnitDelayComp(topNet,wrBlock,wrBlock_reg);
    pirelab.getUnitDelayComp(topNet,lowerWrEn,lowerWrEn_reg);
    pirelab.getUnitDelayComp(topNet,upperWrEn,upperWrEn_reg);


    treeLowerIn=topNet.addSignal(intLlrVecType,'treeLowerIn');
    treeUpperIn=topNet.addSignal(intLlrVecType,'treeUpperIn');
    pirelab.getMultiPortSwitchComp(topNet,[rxSel_reg,rxBufferSat_reg,coreLowerOut],treeLowerIn,1);
    pirelab.getMultiPortSwitchComp(topNet,[rxSel_reg,rxBufferSat_reg,coreUpperOut],treeUpperIn,1);

    alphaWrPath=topNet.addSignal(pathType,'treeAlphaWrPath');
    betaWrPath=topNet.addSignal(pathType,'treeBetaWrPath');
    pirelab.getIntDelayComp(topNet,wrPath,alphaWrPath,3);
    pirelab.getWireComp(topNet,wrPath,betaWrPath);

    mode_reg=topNet.addSignal(boolType,'mode_reg');
    pirelab.getUnitDelayComp(topNet,mode,mode_reg);


    makeDec_reg=topNet.addSignal(boolType,'makeDec_reg');
    pirelab.getIntDelayComp(topNet,makeDec,makeDec_reg,2);


    makeDec_reg_reg=topNet.addSignal(boolType,'makeDec_reg_reg');
    if listLength==2
        makeDecDelay=1;
    elseif listLength==4
        makeDecDelay=3;
    else
        makeDecDelay=6;
    end
    pirelab.getIntDelayComp(topNet,makeDec_reg,makeDec_reg_reg,makeDecDelay);

    F_reg=topNet.addSignal(boolType,'F_reg');
    if listLength==2
        FDelay=1;
    elseif listLength==4
        FDelay=3;
    else
        FDelay=6;
    end
    pirelab.getIntDelayComp(topNet,F,F_reg,FDelay);

    infoBetaWr=topNet.addSignal(boolType,'infoBetaWr');
    pirelab.getLogicComp(topNet,[makeDec_reg_reg,F_reg],infoBetaWr,'and');

    notF=topNet.addSignal(boolType,'notF');
    pirelab.getLogicComp(topNet,F,notF,'not');

    frozenBetaWr=topNet.addSignal(boolType,'frozenBetaWr');
    pirelab.getLogicComp(topNet,[makeDec,notF],frozenBetaWr,'and');

    betaWr=topNet.addSignal(boolType,'betaWr');
    pirelab.getLogicComp(topNet,[infoBetaWr,frozenBetaWr],betaWr,'or');

    zeroDecs=topNet.addSignal(decVecType,'zeroDecs');
    zeroDecs.SimulinkRate=dataRate;
    pirelab.getConstComp(topNet,zeroDecs,0);

    hardDecsSel=topNet.addSignal(decVecType,'hardDecsSel');
    pirelab.getMultiPortSwitchComp(topNet,[frozenBetaWr,hardDecs,zeroDecs],hardDecsSel,1);

    treeNet=this.elabTree(topNet,blockInfo,dataRate);

    inports=[treeLowerIn,treeUpperIn,wrStage_reg,wrBlock_reg,lowerWrEn_reg,upperWrEn_reg,...
    rdStage,rdBlock,hardDecsSel,betaWr,...
    alphaRdPath,betaRdPath,alphaWrPath,betaWrPath,nSub1,mode_reg...
    ];
    outports=[treeLowerOut,treeUpperOut,treeBetaOut];
    pirelab.instantiateNetwork(topNet,treeNet,inports,outports,'treeNet_inst');

    llrSrc=topNet.addSignal(boolType,'llrSrc');
    pirelab.getCompareToValueComp(topNet,wrStage_reg,llrSrc,'<',log2(coreOrder));

    betaSrc_reg=topNet.addSignal(boolType,'betaSrc_reg');
    pirelab.getUnitDelayComp(topNet,betaSrc,betaSrc_reg);


    coreNet=this.elabCore(topNet,blockInfo,dataRate);

    inports=[treeLowerOut,treeUpperOut,llrSrc,treeBetaOut,betaSrc_reg,mode_reg];
    outports=[coreLowerOut,coreUpperOut,coreLeaf];

    pirelab.instantiateNetwork(topNet,coreNet,inports,outports,'coreNet_inst');

    if debugPortsEn
        coreLeaf_reg=topNet.addSignal(intLlrType,'coreLeaf_reg');
        pirelab.getUnitDelayComp(topNet,coreLeaf,coreLeaf_reg);

        decLlrs=topNet.addSignal(intLlrDecType,'decs');
        pirelab.getTapDelayComp(topNet,coreLeaf_reg,decLlrs,listLength-1,'tapdelay',0,false,true);

        activePathMask(1)=topNet.addSignal(boolType,'debugPortMask_0');
        activePathMask(1).SimulinkRate=dataRate;
        pirelab.getConstComp(topNet,activePathMask(1),1);

        for ii=2:listLength
            activePathMask(ii)=topNet.addSignal(boolType,['debugPortMask_',num2str(ii-1)]);%#ok
            pirelab.getCompareToValueComp(topNet,activePathCnt,activePathMask(ii),'>=',2^ceil(log2(ii))-1);
        end

        activePathMaskCat=topNet.addSignal(boolVecType,'activePathMaskCat');
        pirelab.getConcatenateComp(topNet,activePathMask,activePathMaskCat,'Multidimensional array',2);

        debugPortValid=topNet.addSignal(boolVecType,'debugPortValid');
        pirelab.getLogicComp(topNet,[activePathMaskCat,makeDec_reg],debugPortValid,'and');

        decZeros=topNet.addSignal(intLlrDecType,'decZeros');
        decZeros.SimulinkRate=dataRate;
        pirelab.getConstComp(topNet,decZeros,0);

        softDecsT=topNet.addSignal(intLlrDecType,'softDecT');
        pirelab.getMultiPortSwitchComp(topNet,[debugPortValid,decZeros,decLlrs],softDecsT,2);

        pirelab.getTransposeComp(topNet,softDecsT,decLlr);
        pirelab.getWireComp(topNet,makeDec_reg,decLlrValid);
    end


    decNet=this.elabDec(topNet,blockInfo,dataRate);

    inports=[coreLeaf,activePathCnt,F,makeDec_reg,copyEn,startDecodePosEdge];
    outports=[hardDecs,pathWrEn,contPaths,pathOrder,newActvPathCnt];

    pirelab.instantiateNetwork(topNet,decNet,inports,outports,'decNet_inst');

    hardDecs_reg=topNet.addSignal(decVecType,'hardDecs_reg');
    pathWrEn_reg=topNet.addSignal(boolType,'pathWrEn_reg');
    contPaths_reg=topNet.addSignal(pathVecType,'contPaths_reg');
    pirelab.getUnitDelayComp(topNet,hardDecs,hardDecs_reg);
    pirelab.getUnitDelayComp(topNet,pathWrEn,pathWrEn_reg);
    pirelab.getUnitDelayComp(topNet,contPaths,contPaths_reg);

    pathWrEnParity=topNet.addSignal(boolType,'pathWrEnParity');
    if downlinkMode
        pirelab.getWireComp(topNet,pathWrEn_reg,pathWrEnParity);
    else

        isParity_reg=topNet.addSignal(boolType,'isParity_reg');
        pirelab.getIntDelayComp(topNet,isParity,isParity_reg,3);

        notParity=topNet.addSignal(boolType,'notParity');
        pirelab.getLogicComp(topNet,isParity_reg,notParity,'not');

        pirelab.getLogicComp(topNet,[notParity,pathWrEn_reg],pathWrEnParity,'and');
    end


    rstRdCnt=topNet.addSignal(boolType,'rstRdCnt');
    rstWrCnt=topNet.addSignal(boolType,'rstWrCnt');
    pirelab.getIntDelayComp(topNet,startDecodePosEdge,rstWrCnt,3);

    pathMemNet=this.elabPathMem(topNet,blockInfo,dataRate);

    inports=[hardDecs_reg,pathWrEnParity,contPaths_reg,pathRdAddr,rdPath,rstRdCnt,rstWrCnt];
    outports=[reconPaths,copyEn];

    pirelab.instantiateNetwork(topNet,pathMemNet,inports,outports,'pathMemNet_inst');


    crcDone=topNet.addSignal(boolType,'crcDone');

    outputControlNet=this.elabOutputController(topNet,blockInfo,dataRate);

    inports=[startOutput,KLatch,crcDone];
    outports=[pathRdAddr,rdPath,startInt,endInt,validInt,validCrc];

    if downlinkMode
        inports=[inports,ELatch];
        outports=[outports,prepad];
    else


        parityEnLatch=topNet.addSignal(boolType,'parityEnLatch');
        pirelab.getUnitDelayEnabledComp(topNet,parityEn,parityEnLatch,startOutput,'parityEnReg','','',false,'',-1,true);

        inports=[inports,parityEnLatch];
    end

    if rntiFromPort


        targetRntiOutLatch=topNet.addSignal(targetRntiType,'targetRntiOutLatch');
        pirelab.getUnitDelayEnabledComp(topNet,targetRntiLatch,targetRntiOutLatch,startOutput,'RNTIreg','','',false,'',-1,true);
    end

    pirelab.instantiateNetwork(topNet,outputControlNet,inports,outports,'outputControlNet_inst');

    startInt_reg=topNet.addSignal(boolType,'startInt_reg');
    endInt_reg=topNet.addSignal(boolType,'endInt_reg');
    validInt_reg=topNet.addSignal(boolType,'validInt_reg');
    validCrc_reg=topNet.addSignal(boolType,'validCrc_reg');
    pirelab.getIntDelayComp(topNet,startInt,startInt_reg,3);
    pirelab.getIntDelayComp(topNet,endInt,endInt_reg,3);
    pirelab.getIntDelayComp(topNet,validInt,validInt_reg,3);
    pirelab.getIntDelayComp(topNet,validCrc,validCrc_reg,3);

    pirelab.getWireComp(topNet,endInt_reg,rstRdCnt);

    crcPaths=topNet.addSignal(decVecType,'crcPaths');
    canPaths=topNet.addSignal(decVecType,'canPaths');


    if downlinkMode
        deitlvRamWrEn=topNet.addSignal(boolType,'deitlvRamWrEn');
        pirelab.getIntDelayComp(topNet,rdPath,deitlvRamWrEn,3);

        reconPathsConcat=topNet.addSignal(concatBetaType,'reconPathsConcat');
        pirelab.getBitConcatComp(topNet,reconPaths,reconPathsConcat);

        pirelab.getUnitDelayComp(topNet,pathRdAddr,itlvPathRdAddr);

        deitlvRamRdAddr=topNet.addSignal(KType,'deitlvRamRdAddr');
        pirelab.getUnitDelayComp(topNet,itlvPathRdAddr,deitlvRamRdAddr);

        deitlvPathsConcat=topNet.addSignal(concatBetaType,'deitlvPathsConcat');
        pirelab.getSimpleDualPortRamComp(topNet,[reconPathsConcat,deitlvPathRdAddr,deitlvRamWrEn,deitlvRamRdAddr],deitlvPathsConcat);

        for ii=1:listLength
            deitlvPathsSlice(ii)=topNet.addSignal(decType,['deitlvPathsSlice_',num2str(ii-1)]);%#ok
            pirelab.getBitSliceComp(topNet,deitlvPathsConcat,deitlvPathsSlice(ii),listLength-ii,listLength-ii);
        end

        pirelab.getConcatenateComp(topNet,deitlvPathsSlice,canPaths,'Multidimensional array',2);

        prepad_reg=topNet.addSignal(boolType,'prepad_reg');
        pirelab.getIntDelayComp(topNet,prepad,prepad_reg,3);

        prepadConst=topNet.addSignal(decVecType,'prepadConst');
        prepadConst.SimulinkRate=dataRate;
        pirelab.getConstComp(topNet,prepadConst,ones(1,listLength));

        pirelab.getMultiPortSwitchComp(topNet,[prepad_reg,canPaths,prepadConst],crcPaths,1);
    else
        pirelab.getWireComp(topNet,reconPaths,crcPaths);
        pirelab.getWireComp(topNet,reconPaths,canPaths);
    end


    canPathDemux=pirelab.demuxSignal(topNet,crcPaths);
    for ii=1:listLength
        crcDataOut(ii)=topNet.addSignal(decType,['crcDataOut_',num2str(ii-1)]);%#ok
        crcStartOut(ii)=topNet.addSignal(decType,['crcStartOut_',num2str(ii-1)]);%#ok
        crcEndOut(ii)=topNet.addSignal(decType,['crcEndOut_',num2str(ii-1)]);%#ok
        crcValidOut(ii)=topNet.addSignal(decType,['crcValidOut_',num2str(ii-1)]);%#ok
        crcErrOut(ii)=topNet.addSignal(crcErrType,['crcErrOut_',num2str(ii-1)]);%#ok


        crcBlockInfo=blockInfo;
        crcBlockInfo.RNTIPort=blockInfo.outputRnti||blockInfo.rntiFromPort;

        parityCrcNet(ii)=this.addCRCDecoder(topNet,crcBlockInfo,dataRate);%#ok

        pirelab.instantiateNetwork(topNet,parityCrcNet(ii),[canPathDemux(ii),startInt_reg,endInt_reg,validCrc_reg],...
        [crcDataOut(ii),crcStartOut(ii),crcEndOut(ii),crcValidOut(ii),crcErrOut(ii)],['CRC Decoder_',num2str(ii-1)]);

        if~downlinkMode

            parityCrcDataOut(ii)=topNet.addSignal(decType,['parityCrcDataOut_',num2str(ii-1)]);%#ok
            parityCrcStartOut(ii)=topNet.addSignal(decType,['parityCrcStartOut_',num2str(ii-1)]);%#ok
            parityCrcEndOut(ii)=topNet.addSignal(decType,['parityCrcEndOut_',num2str(ii-1)]);%#ok
            parityCrcValidOut(ii)=topNet.addSignal(decType,['parityCrcValidOut_',num2str(ii-1)]);%#ok
            parityCrcErrOut(ii)=topNet.addSignal(parityCrcErrType,['parityCrcErrOut_',num2str(ii-1)]);%#ok
            parityCrcErrDTC(ii)=topNet.addSignal(crcErrType,['parityCrcErrDTC_',num2str(ii-1)]);%#ok

            crcBlockInfo.Polynomial=blockInfo.ParityPolynomial;
            crcBlockInfo.CRClen=blockInfo.ParityCRClen;
            crcBlockInfo.crcErrType=parityCrcErrType;
            parityCrcNet(ii)=this.addCRCDecoder(topNet,crcBlockInfo,dataRate);%#ok

            pirelab.instantiateNetwork(topNet,parityCrcNet(ii),[canPathDemux(ii),startInt_reg,endInt_reg,validCrc_reg],...
            [parityCrcDataOut(ii),parityCrcStartOut(ii),parityCrcEndOut(ii),parityCrcValidOut(ii),parityCrcErrOut(ii)],['Parity CRC Decoder_',num2str(ii-1)]);

            pirelab.getDTCComp(topNet,parityCrcErrOut(ii),parityCrcErrDTC(ii));
        end
    end

    crcErrs=topNet.addSignal(crcErrVecType,'crcErrs');
    if downlinkMode
        pirelab.getConcatenateComp(topNet,crcErrOut,crcErrs,'Multidimensional array',2);
        pirelab.getWireComp(topNet,crcEndOut(1),crcDone);
    else
        nonParityErrs=topNet.addSignal(crcErrVecType,'nonParityErrs');
        pirelab.getConcatenateComp(topNet,crcErrOut,nonParityErrs,'Multidimensional array',2);
        parityErrs=topNet.addSignal(crcErrVecType,'parityErrs');
        pirelab.getConcatenateComp(topNet,parityCrcErrDTC,parityErrs,'Multidimensional array',2);

        pirelab.getMultiPortSwitchComp(topNet,[parityEnLatch,nonParityErrs,parityErrs],crcErrs,1);
        pirelab.getMultiPortSwitchComp(topNet,[parityEnLatch,crcEndOut(1),parityCrcEndOut(1)],crcDone,1);

    end

    targetCrc=topNet.addSignal(crcErrType,'targetCrc');
    if rntiFromPort
        pirelab.getDTCComp(topNet,targetRntiOutLatch,targetCrc);
    else
        targetCrc.SimulinkRate=dataRate;
        pirelab.getConstComp(topNet,targetCrc,0);
    end

    crcRes=topNet.addSignal(crcErrVecType,'crcRes');
    pirelab.getUnitDelayEnabledComp(topNet,crcErrs,crcRes,crcDone);

    crcPasses=topNet.addSignal(boolVecType,'crcPasses');
    pirelab.getRelOpComp(topNet,[crcRes,targetCrc],crcPasses,'==');



    crcPassesDemux=pirelab.demuxSignal(topNet,crcPasses);


    for ii=1:log2(listLength)-1
        activePathCmp(ii)=topNet.addSignal(boolType,['activePathComp_',num2str(ii-1)]);%#ok
        pirelab.getCompareToValueComp(topNet,activePathCnt,activePathCmp(ii),'>=',2^(ii+1)-1);
    end


    for ii=1:listLength
        cmpIdx=ceil(log2(ii))-1;
        if cmpIdx<=0
            crcPassesMasked(ii)=crcPassesDemux(ii);%#ok
        else
            crcPassesMasked(ii)=topNet.addSignal(boolType,['crcPassesMasked_',num2str(ii-1)]);%#ok
            pirelab.getLogicComp(topNet,[crcPassesDemux(ii),activePathCmp(cmpIdx)],crcPassesMasked(ii),'and');
        end
    end


    crcPassesReord=topNet.addSignal(boolVecType,'crcPassesReord');
    pirelab.getMultiPortSwitchComp(topNet,[pathOrder,crcPassesMasked],crcPassesReord,2);

    pathOrderDemux=pirelab.demuxSignal(topNet,pathOrder);
    crcPassesReordDemux=pirelab.demuxSignal(topNet,crcPassesReord);

    for ii=1:listLength-1
        bestCrcPass(ii)=topNet.addSignal(pathType,['bestCrcPass_',num2str(ii-1)]);%#ok
        if ii==1
            prevBestCrcPass=pathOrderDemux(listLength);
        else
            prevBestCrcPass=bestCrcPass(ii-1);
        end
        pirelab.getMultiPortSwitchComp(topNet,[crcPassesReordDemux(listLength-ii),prevBestCrcPass,pathOrderDemux(listLength-ii)],bestCrcPass(ii),1);
    end


    anyCrcPass=topNet.addSignal(boolType,'anyCrcPass');
    pirelab.getBitwiseOpComp(topNet,crcPassesMasked,anyCrcPass,'or');



    pathId=topNet.addSignal(pathType,'pathId');
    pirelab.getMultiPortSwitchComp(topNet,[anyCrcPass,pathOrderDemux(1),bestCrcPass(listLength-1)],pathId,1);

    pathId_reg=topNet.addSignal(pathType,'pathId_reg');
    pirelab.getUnitDelayComp(topNet,pathId,pathId_reg);

    startValid=topNet.addSignal(boolType,'startValid');
    endValid=topNet.addSignal(boolType,'endValid');
    pirelab.getLogicComp(topNet,[startInt_reg,validInt_reg],startValid,'and');
    pirelab.getLogicComp(topNet,[endInt_reg,validInt_reg],endValid,'and');

    pirelab.getIntDelayComp(topNet,endValid,endValid_reg,4);

    corPath=topNet.addSignal(decType,'corPath');
    pirelab.getMultiPortSwitchComp(topNet,[pathId_reg,canPaths],corPath,0);

    corPathValid=topNet.addSignal(decType,'corPathValid');
    pirelab.getLogicComp(topNet,[corPath,validInt_reg],corPathValid,'and');

    crcErr=topNet.addSignal(errVecType,'crcErr');
    if outputRnti
        pirelab.getWireComp(topNet,crcRes,crcErr);
    else
        pirelab.getLogicComp(topNet,crcPasses,crcErr,'not');
    end

    crcSel=topNet.addSignal(errType,'crcSel');
    pirelab.getMultiPortSwitchComp(topNet,[pathId_reg,crcErr],crcSel,0);

    crcSelMask=topNet.addSignal(errType,'crcSelMask');
    if outputRnti&&rntiFromPort
        pirelab.getBitwiseOpComp(topNet,[crcSel,targetCrc],crcSelMask,'xor');
    else
        pirelab.getWireComp(topNet,crcSel,crcSelMask);
    end

    crcZero=topNet.addSignal(errType,'crcZero');
    crcZero.SimulinkRate=dataRate;
    pirelab.getConstComp(topNet,crcZero,0);

    crcErrValid=topNet.addSignal(errType,'errSel');
    pirelab.getMultiPortSwitchComp(topNet,[validInt_reg,crcZero,crcSelMask],crcErrValid,1);

    pirelab.getUnitDelayComp(topNet,corPathValid,dataOut);
    pirelab.getUnitDelayComp(topNet,startValid,startOut);
    pirelab.getUnitDelayComp(topNet,endValid,endOut);
    pirelab.getUnitDelayComp(topNet,validInt_reg,validOut);
    pirelab.getUnitDelayComp(topNet,crcErrValid,errOut);
    pirelab.getWireComp(topNet,nextFrame,nextFrameOut);
end
