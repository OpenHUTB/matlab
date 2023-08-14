function elaborateLDPCDecoderNetwork(this,topNet,blockInfo,insignals,...
    outsignals,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix6Type=pir_ufixpt_t(6,0);
    ufix8Type=pir_ufixpt_t(8,0);
    ufix9Type=pir_ufixpt_t(9,0);

    if blockInfo.VectorSize==64
        cntType=pir_ufixpt_t(9,0);
    else
        cntType=pir_ufixpt_t(15,0);
    end

    sType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    dtcType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);

    sVType=pirelab.getPirVectorType(sType,blockInfo.VectorSize);
    sV1Type=pirelab.getPirVectorType(dtcType,blockInfo.VectorSize);



    datai=insignals(1);
    starti=insignals(2);
    endi=insignals(3);
    validi=insignals(4);
    bgni=insignals(5);
    liftsizei=insignals(6);

    niter=topNet.addSignal(ufix8Type,'numIter');
    numrow=topNet.addSignal(ufix6Type,'numRows');

    sof_vld=topNet.addSignal(ufix1Type,'startValid');
    pirelab.getLogicComp(topNet,[starti,validi],sof_vld,'and');

    if strcmpi(blockInfo.SpecifyInputs,'Input port')
        niteri=insignals(7);
        pirelab.getIntDelayComp(topNet,niteri,niter,1,'',0);
        if blockInfo.RateCompatible
            numrowsi=insignals(8);
            pirelab.getUnitDelayEnabledComp(topNet,numrowsi,numrow,sof_vld,'',0);
        else
            pirelab.getConstComp(topNet,numrow,46);
        end
    else
        pirelab.getConstComp(topNet,niter,blockInfo.NumIterations);
        if blockInfo.RateCompatible
            numrowsi=insignals(7);
            pirelab.getUnitDelayEnabledComp(topNet,numrowsi,numrow,sof_vld,'',0);
        else
            pirelab.getConstComp(topNet,numrow,46);
        end
    end

    decbits=outsignals(1);
    startout=outsignals(2);
    endout=outsignals(3);
    validout=outsignals(4);
    zOut=outsignals(5);

    if(strcmpi(blockInfo.Termination,'early'))
        actiter=outsignals(6);
        if blockInfo.ParityCheckStatus
            parcheck=outsignals(7);
            nextframe=outsignals(8);
        else
            nextframe=outsignals(7);
        end
    else
        if blockInfo.ParityCheckStatus
            parcheck=outsignals(6);
            nextframe=outsignals(7);
        else
            nextframe=outsignals(6);
        end
    end

    dataout=topNet.addSignal(sVType,'dataOut');
    valid=topNet.addSignal(ufix1Type,'valid');
    framevalid=topNet.addSignal(ufix1Type,'frameValid');
    reset=topNet.addSignal(ufix1Type,'reset');
    bgnout=topNet.addSignal(ufix1Type,'bgn');
    iLS=topNet.addSignal(ufix3Type,'iLS');
    liftsizeout=topNet.addSignal(ufix9Type,'liftSize');
    endind=topNet.addSignal(ufix1Type,'endInd');
    zaddr=topNet.addSignal(ufix3Type,'zAddr');
    niter_out=topNet.addSignal(ufix8Type,'niterOut');
    nrowreg=topNet.addSignal(ufix6Type,'nRowReg');

    datain=topNet.addSignal(datai.Type,'dataIn');
    pirelab.getIntDelayComp(topNet,datai,datain,1,'',0);

    startin=topNet.addSignal(starti.Type,'startIn');
    pirelab.getIntDelayComp(topNet,starti,startin,1,'',0);

    endin=topNet.addSignal(endi.Type,'endIn');
    pirelab.getIntDelayComp(topNet,endi,endin,1,'',0);

    validin=topNet.addSignal(validi.Type,'validIn');
    pirelab.getIntDelayComp(topNet,validi,validin,1,'',0);

    bgn=topNet.addSignal(bgni.Type,'bgnIn');
    pirelab.getIntDelayComp(topNet,bgni,bgn,1,'',0);

    liftsize=topNet.addSignal(liftsizei.Type,'ZIn');
    pirelab.getIntDelayComp(topNet,liftsizei,liftsize,1,'',0);

    liftsizei_dtc=topNet.addSignal(ufix9Type,'Z_dtc');
    pirelab.getDTCComp(topNet,liftsizei,liftsizei_dtc,'Floor','Wrap','SI');

    liftsize_dtc=topNet.addSignal(ufix9Type,'Z_dtc');
    pirelab.getDTCComp(topNet,liftsize,liftsize_dtc,'Floor','Wrap','SI');

    rstnextframe=topNet.addSignal(ufix1Type,'rstNextFrame');

    zout_tmp=topNet.addSignal(liftsizeout.Type,'shiftReg');



    aNet=this.elabCodeParametersNetwork(topNet,blockInfo,dataRate);
    aNet.addComment('Code Parameters');
    pirelab.instantiateNetwork(topNet,aNet,[datain,startin,endin,validin,bgn,liftsize_dtc,niter,numrow],...
    [dataout,valid,framevalid,reset,bgnout,iLS,zout_tmp,endind,niter_out,zaddr,rstnextframe,nrowreg],'Code Parameters');

    data_dtc=topNet.addSignal(sV1Type,'dataDTC');
    pirelab.getDTCComp(topNet,dataout,data_dtc,'Floor','Wrap','RWV','Data Type Conversion');

    datao=topNet.addSignal(decbits.Type,'dataOutReg');
    starto=topNet.addSignal(startout.Type,'startOutReg');
    endo=topNet.addSignal(endout.Type,'endOutReg');
    valido=topNet.addSignal(validout.Type,'validOutReg');
    itero=topNet.addSignal(ufix8Type,'iterOutReg');
    pchecko=topNet.addSignal(validout.Type,'pCheckOutReg');


    startvld=topNet.addSignal(ufix1Type,'startVld');
    pirelab.getLogicComp(topNet,[starti,validi],startvld,'and');

    svld_neg=topNet.addSignal(ufix1Type,'startVldNeg');
    pirelab.getLogicComp(topNet,startvld,svld_neg,'not');

    bgnout1=topNet.addSignal(ufix1Type,'bgnStart');
    pirelab.getUnitDelayEnabledComp(topNet,bgni,bgnout1,startvld,1);

    z1=topNet.addSignal(ufix9Type,'zStart');
    pirelab.getUnitDelayEnabledComp(topNet,liftsizei_dtc,z1,startvld,2);

    endvld=topNet.addSignal(ufix1Type,'endVld');
    pirelab.getLogicComp(topNet,[endi,validi],endvld,'and');

    const0=topNet.addSignal(ufix1Type,'const0');
    pirelab.getConstComp(topNet,const0,0);

    const1=topNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(topNet,const1,1);

    enb=topNet.addSignal(ufix1Type,'enbConst');
    pirelab.getIntDelayComp(topNet,validin,enb,1,'',0);

    const0reg=topNet.addSignal(ufix1Type,'const0Reg');
    pirelab.getUnitDelayEnabledComp(topNet,const0,const0reg,enb,'',0);

    framevld=topNet.addSignal(ufix1Type,'frameVld');
    pirelab.getUnitDelayEnabledResettableComp(topNet,const0reg,framevld,endvld,startvld,'frame',1);

    framevldreg=topNet.addSignal(ufix1Type,'frameVldReg');
    pirelab.getIntDelayComp(topNet,framevld,framevldreg,1,'',0);

    fvldneg=topNet.addSignal(ufix1Type,'fVldNeg');
    pirelab.getLogicComp(topNet,framevld,fvldneg,'not');

    cntenb=topNet.addSignal(ufix1Type,'cntEnb');
    pirelab.getLogicComp(topNet,[framevld,validi],cntenb,'and');

    cntdata=topNet.addSignal(cntType,'countData');

    maxcount=topNet.addSignal(cntType,'maxCount');
    maxcount1=topNet.addSignal(cntType,'maxcount1');
    maxcount2=topNet.addSignal(cntType,'maxcount2');
    maxcountreg=topNet.addSignal(cntType,'maxCountReg');

    shiftreg=topNet.addSignal(liftsizeout.Type,'shiftReg');
    pirelab.getSubComp(topNet,[z1,const1],shiftreg,'Floor','Wrap');

    if blockInfo.VectorSize==64
        cntcomp=pirelab.getCounterComp(topNet,[startvld,cntenb],cntdata,'Count limited',1,1,...
        396,1,0,1,0,'Counting Data',1);
        cntcomp.addComment('Counter for input data length');

        shifte=topNet.addSignal(ufix3Type,'shiftE');
        shift=topNet.addSignal(ufix3Type,'shiftCount');
        pirelab.getBitSliceComp(topNet,shiftreg,shifte,8,6,'bit slice');
        pirelab.getAddComp(topNet,[shifte,const1],shift,'Floor','Wrap');
    else
        cntcomp=pirelab.getCounterComp(topNet,[startvld,cntenb],cntdata,'Count limited',1,1,...
        25344,1,0,1,0,'Counting Data',1);
        cntcomp.addComment('Counter for input data length');

        shift=topNet.addSignal(ufix9Type,'shiftCount');
        pirelab.getAddComp(topNet,[shiftreg,const1],shift,'Floor','Wrap');
    end


    if blockInfo.RateCompatible
        const8=topNet.addSignal(cntType,'const8');
        pirelab.getConstComp(topNet,const8,8);

        const20=topNet.addSignal(cntType,'const20');
        pirelab.getConstComp(topNet,const20,20);

        pirelab.getAddComp(topNet,[const20,numrow],maxcount1,'Floor','Wrap');
        pirelab.getAddComp(topNet,[const8,numrow],maxcount2,'Floor','Wrap');

        maxcount_tmp=topNet.addSignal(cntType,'maxCountTmp');
        mcomp=pirelab.getMultiPortSwitchComp(topNet,[bgnout1,maxcount1,maxcount2],maxcount_tmp,1,1,'Floor','Wrap');
        mcomp.addComment('Input data count based on bgn and lifting size');

        pirelab.getMulComp(topNet,[maxcount_tmp,shift],maxcount);

    else
        const66=topNet.addSignal(cntType,'const66');
        pirelab.getConstComp(topNet,const66,66);

        const50=topNet.addSignal(cntType,'const50');
        pirelab.getConstComp(topNet,const50,50);

        pirelab.getMulComp(topNet,[const66,shift],maxcount1);
        pirelab.getMulComp(topNet,[const50,shift],maxcount2);

        mcomp=pirelab.getMultiPortSwitchComp(topNet,[bgnout1,maxcount1,maxcount2],maxcount,1,1,'Floor','Wrap');
        mcomp.addComment('Input data count based on bgn and lifting size');
    end

    pirelab.getSubComp(topNet,[maxcount,const1],maxcountreg,'Floor','Wrap');

    countrel=topNet.addSignal(ufix1Type,'rel_count');
    rcomp=pirelab.getRelOpComp(topNet,[cntdata,maxcountreg],countrel,'~=',1);
    rcomp.addComment('Comparison of counter to max count');

    evldreg=topNet.addSignal(ufix1Type,'endTrigger');
    pirelab.getLogicComp(topNet,[endvld,framevld],evldreg,'and');

    evldreg_neg=topNet.addSignal(ufix1Type,'endTrigger1');
    pirelab.getLogicComp(topNet,[evldreg,svld_neg],evldreg_neg,'and');

    evldregd=topNet.addSignal(ufix1Type,'endTriggerReg');
    pirelab.getIntDelayComp(topNet,evldreg_neg,evldregd,2,'end_in',0);

    invld_z=topNet.addSignal(ufix1Type,'invalidZ');
    pirelab.getUnitDelayEnabledResettableComp(topNet,rstnextframe,invld_z,evldreg_neg,evldregd,'invalid_z',0);

    invld_len=topNet.addSignal(ufix1Type,'invalidLength');
    pirelab.getUnitDelayEnabledResettableComp(topNet,countrel,invld_len,evldreg_neg,evldregd,'invalid_length',0);



    mNet=this.elabDecoderCoreNetwork(topNet,blockInfo,dataRate);
    mNet.addComment('Decoder Core');
    pirelab.instantiateNetwork(topNet,mNet,[data_dtc,valid,framevalid,reset,bgnout,iLS,zout_tmp,endind,niter_out,zaddr,evldregd,nrowreg],...
    [datao,starto,endo,valido,itero,pchecko],'Decoder Core');


    start_out=topNet.addSignal(startout.Type,'startReg');
    pirelab.getUnitDelayComp(topNet,starto,start_out,'',0);

    end_out=topNet.addSignal(startout.Type,'endReg');
    pirelab.getUnitDelayComp(topNet,endo,end_out,'',0);

    valid_out=topNet.addSignal(startout.Type,'validReg');
    pirelab.getUnitDelayComp(topNet,valido,valid_out,'',0);

    startoutvld=topNet.addSignal(ufix1Type,'startOutVld');
    pirelab.getLogicComp(topNet,[start_out,start_out],startoutvld,'and');

    enbZ=topNet.addSignal(ufix1Type,'enbZ');
    pirelab.getSwitchComp(topNet,[startoutvld,const0],enbZ,nextframe,'enb Z sel','==',0,'Floor','Wrap');

    endoutvld=topNet.addSignal(ufix1Type,'endOutVld');
    pirelab.getLogicComp(topNet,[endout,validout],endoutvld,'and');

    endoutvldreg=topNet.addSignal(ufix1Type,'endOutVldReg');
    pirelab.getUnitDelayComp(topNet,endoutvld,endoutvldreg,'',0);

    z_rst=topNet.addSignal(ufix1Type,'zReset');
    pirelab.getLogicComp(topNet,[endoutvldreg,framevldreg],z_rst,'or');

    z_dtc=topNet.addSignal(zOut.Type,'Z_dtc');
    pirelab.getDTCComp(topNet,zout_tmp,z_dtc,'Floor','Wrap','SI');

    pirelab.getUnitDelayEnabledResettableComp(topNet,z_dtc,zOut,enbZ,z_rst,'lifting Size',0);

    zero_data=topNet.addSignal(decbits.Type,'zData');
    pirelab.getConstComp(topNet,zero_data,0);

    decdata=topNet.addSignal(decbits.Type,'decData');
    pirelab.getUnitDelayEnabledComp(topNet,datao,decdata,valido,'dataOut',0);

    valid_outReg=topNet.addSignal(startout.Type,'validReg');

    decdatareg=topNet.addSignal(decbits.Type,'decData');
    pirelab.getSwitchComp(topNet,[decdata,zero_data],decdatareg,valid_outReg,'sel','~=',0,'Floor','Wrap');

    start_outReg=topNet.addSignal(startout.Type,'startReg');
    pirelab.getSwitchComp(topNet,[start_out,const0],start_outReg,nextframe,'start sel','==',0,'Floor','Wrap');

    end_outReg=topNet.addSignal(startout.Type,'endReg');
    pirelab.getSwitchComp(topNet,[end_out,const0],end_outReg,nextframe,'end sel','==',0,'Floor','Wrap');

    pirelab.getSwitchComp(topNet,[valid_out,const0],valid_outReg,nextframe,'valid sel','==',0,'Floor','Wrap');

    nenable=topNet.addSignal(ufix1Type,'newEnb');
    pirelab.getLogicComp(topNet,[invld_len,invld_z],nenable,'or');

    nfenb=topNet.addSignal(ufix1Type,'nFrameEnb_tmp');
    pirelab.getLogicComp(topNet,[endoutvldreg,nenable],nfenb,'or');

    nfenb1=topNet.addSignal(ufix1Type,'nFrameEnb');
    pirelab.getLogicComp(topNet,[nfenb,svld_neg],nfenb1,'and');

    nextframe_out=topNet.addSignal(ufix1Type,'nFrame');
    pirelab.getUnitDelayEnabledResettableComp(topNet,const0reg,nextframe_out,startvld,nfenb1,'nextFrame',1);

    pirelab.getSwitchComp(topNet,[const1,nextframe_out],nextframe,nfenb,'sel','~=',0,'Floor','Wrap');


    if blockInfo.VectorSize==64
        pirelab.getUnitDelayResettableComp(topNet,decdatareg,decbits,framevld,'dataOut',0,'',true);
        pirelab.getUnitDelayResettableComp(topNet,valid_outReg,validout,framevld,'validOut',0,'',true);
        pirelab.getUnitDelayResettableComp(topNet,start_outReg,startout,framevld,'startOut',0,'',true);
        pirelab.getUnitDelayResettableComp(topNet,end_outReg,endout,framevld,'endOut',0,'',true);
    else
        pirelab.getUnitDelayResettableComp(topNet,decdatareg,decbits,framevldreg,'dataOut',0,'',true);
        pirelab.getUnitDelayResettableComp(topNet,valid_outReg,validout,framevldreg,'validOut',0,'',true);
        pirelab.getUnitDelayResettableComp(topNet,start_outReg,startout,framevldreg,'startOut',0,'',true);
        pirelab.getUnitDelayResettableComp(topNet,end_outReg,endout,framevldreg,'endOut',0,'',true);
    end


    if(strcmpi(blockInfo.Termination,'early'))
        iter_out=topNet.addSignal(actiter.Type,'iterReg1');
        pirelab.getUnitDelayComp(topNet,itero,iter_out,'',0);

        iter_outReg=topNet.addSignal(actiter.Type,'iterReg2');
        const0_dtc=topNet.addSignal(actiter.Type,'const0_dtc');
        pirelab.getConstComp(topNet,const0_dtc,0);
        pirelab.getSwitchComp(topNet,[iter_out,const0_dtc],iter_outReg,valid_outReg,'iter sel','==',1,'Floor','Wrap');

        if blockInfo.VectorSize==64
            pirelab.getUnitDelayResettableComp(topNet,iter_outReg,actiter,framevld,'iterOut',0,'',true);
        else
            pirelab.getUnitDelayResettableComp(topNet,iter_outReg,actiter,framevldreg,'iterOut',0,'',true);
        end
    end

    if blockInfo.ParityCheckStatus
        pcheck_out=topNet.addSignal(parcheck.Type,'pCheckReg1');
        pirelab.getUnitDelayComp(topNet,pchecko,pcheck_out,'',0);

        pcheck_outReg=topNet.addSignal(parcheck.Type,'pCheckReg2');
        pirelab.getSwitchComp(topNet,[pcheck_out,const0],pcheck_outReg,valid_outReg,'parity sel','==',1,'Floor','Wrap');

        if blockInfo.VectorSize==64
            pirelab.getUnitDelayResettableComp(topNet,pcheck_outReg,parcheck,framevld,'pCheckOut',0,'',true);
        else
            pirelab.getUnitDelayResettableComp(topNet,pcheck_outReg,parcheck,framevldreg,'pCheckOut',0,'',true);
        end
    end

