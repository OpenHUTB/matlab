function elaborateWLANLDPCDecoderNetwork(this,topNet,blockInfo,insignals,...
    outsignals,dataRate)






    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    ufix8Type=pir_ufixpt_t(8,0);

    if blockInfo.VectorSize==8
        cntType=pir_ufixpt_t(8,0);
    else
        cntType=pir_ufixpt_t(11,0);
    end

    iType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    iVType=pirelab.getPirVectorType(iType,blockInfo.VectorSize);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    aVType=pirelab.getPirVectorType(aType,blockInfo.VectorSize);



    datai=insignals(1);
    starti=insignals(2);
    endi=insignals(3);
    validi=insignals(4);

    sof_vld=topNet.addSignal(ufix1Type,'startValid');
    pirelab.getLogicComp(topNet,[starti,validi],sof_vld,'and');

    if strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax')
        bleni=insignals(5);
        ratei=insignals(6);
        if~strcmpi(blockInfo.SpecifyInputs,'Property')&&(strcmpi(blockInfo.Termination,'Max'))
            niteri=insignals(7);
        else
            niteri=topNet.addSignal(ufix8Type,'numIter');
            pirelab.getConstComp(topNet,niteri,blockInfo.NumIterations);
        end
    else
        bleni=topNet.addSignal(ufix2Type,'blockLen');
        pirelab.getConstComp(topNet,bleni,0);
        ratei=insignals(5);
        if~strcmpi(blockInfo.SpecifyInputs,'Property')&&(strcmpi(blockInfo.Termination,'Max'))
            niteri=insignals(6);
        else
            niteri=topNet.addSignal(ufix8Type,'numIter');
            pirelab.getConstComp(topNet,niteri,blockInfo.NumIterations);
        end
    end

    decbits=outsignals(1);
    startout=outsignals(2);
    endout=outsignals(3);
    validout=outsignals(4);

    if(strcmpi(blockInfo.Termination,'Early'))
        actiter=outsignals(5);
        if blockInfo.ParityCheckStatus
            parcheck=outsignals(6);
            nextframe=outsignals(7);
        else
            nextframe=outsignals(6);
        end
    else
        if blockInfo.ParityCheckStatus
            parcheck=outsignals(5);
            nextframe=outsignals(6);
        else
            nextframe=outsignals(5);
        end
    end

    dataout=topNet.addSignal(iVType,'dataOut');
    valid=topNet.addSignal(ufix1Type,'valid');
    framevalid=topNet.addSignal(ufix1Type,'frameValid');
    dataout_reg=topNet.addSignal(iVType,'dataOutReg');
    valid_reg=topNet.addSignal(ufix1Type,'validReg');
    framevalid_reg=topNet.addSignal(ufix1Type,'frameValidReg');
    reset=topNet.addSignal(ufix1Type,'reset');
    endind=topNet.addSignal(ufix1Type,'endInd');
    smdone=topNet.addSignal(ufix1Type,'smDone');
    niter_out=topNet.addSignal(ufix8Type,'niterOut');

    datain=topNet.addSignal(datai.Type,'dataIn');
    pirelab.getIntDelayComp(topNet,datai,datain,1,'',0);

    startin=topNet.addSignal(starti.Type,'startIn');
    pirelab.getIntDelayComp(topNet,starti,startin,1,'',0);

    endin=topNet.addSignal(endi.Type,'endIn');
    pirelab.getIntDelayComp(topNet,endi,endin,1,'',0);

    validin=topNet.addSignal(validi.Type,'validIn');
    pirelab.getIntDelayComp(topNet,validi,validin,1,'',0);

    sof_vld=topNet.addSignal(validi.Type,'sofVld');
    pirelab.getLogicComp(topNet,[validi,starti],sof_vld,'and');

    blen=topNet.addSignal(bleni.Type,'bLen');
    pirelab.getUnitDelayEnabledComp(topNet,bleni,blen,sof_vld,'',0);

    rate=topNet.addSignal(ratei.Type,'codeRate');
    pirelab.getUnitDelayEnabledComp(topNet,ratei,rate,sof_vld,'',0);

    niter=topNet.addSignal(niteri.Type,'nIter');
    pirelab.getUnitDelayEnabledComp(topNet,niteri,niter,sof_vld,'',8);



    aNet=this.elabCodeParametersNetwork(topNet,blockInfo,dataRate);
    aNet.addComment('Code Parameters');
    pirelab.instantiateNetwork(topNet,aNet,[datain,startin,endin,validin,blen,rate,niter],...
    [dataout,valid,framevalid,reset,endind,smdone,niter_out],'Code Parameters');

    if blockInfo.VectorSize==8
        pirelab.getWireComp(topNet,dataout,dataout_reg,'');
        pirelab.getWireComp(topNet,valid,valid_reg,'');
        pirelab.getWireComp(topNet,framevalid,framevalid_reg,'');
    else
        pirelab.getUnitDelayComp(topNet,dataout,dataout_reg,'',0);
        pirelab.getUnitDelayComp(topNet,valid,valid_reg,'',0);
        pirelab.getUnitDelayComp(topNet,framevalid,framevalid_reg,'',0);
    end

    data_dtc=topNet.addSignal(aVType,'dataDTC');
    pirelab.getDTCComp(topNet,dataout_reg,data_dtc,'Floor','Wrap','RWV','Data Type Conversion');

    datao=topNet.addSignal(decbits.Type,'dataO');
    starto=topNet.addSignal(startout.Type,'startO');
    endo=topNet.addSignal(endout.Type,'endO');
    valido=topNet.addSignal(validout.Type,'validO');
    itero=topNet.addSignal(ufix8Type,'iterO');
    pchecko=topNet.addSignal(validout.Type,'pCheckO');



    mNet=this.elabDecoderCoreNetwork(topNet,blockInfo,dataRate);
    mNet.addComment('Decoder Core');
    pirelab.instantiateNetwork(topNet,mNet,[reset,data_dtc,valid_reg,framevalid_reg,blen,rate,endind,smdone,niter_out],...
    [datao,starto,endo,valido,itero,pchecko],'Decoder Core');


    maxcount=topNet.addSignal(cntType,'maxCount');
    if strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax')
        if blockInfo.VectorSize==1
            maxCountLUT=[648,1296,1944,648]-1;mVal=1944;
        else
            maxCountLUT=[81,162,243,81]-1;mVal=243;
        end
        pirelab.getDirectLookupComp(topNet,blen,maxcount,maxCountLUT,'Max Count','','','','',cntType);
    else
        if blockInfo.VectorSize==1
            maxCountVal=671;mVal=672;
        else
            maxCountVal=83;mVal=84;
        end
        pirelab.getConstComp(topNet,maxcount,maxCountVal);
    end

    invld_blentmp=topNet.addSignal(ufix1Type,'invBlockLengthTmp');
    pirelab.getCompareToValueComp(topNet,blen,invld_blentmp,'==',3,'blen range');


    eof_vld=topNet.addSignal(validi.Type,'eofVld');
    pirelab.getLogicComp(topNet,[validi,endi],eof_vld,'and');

    sof_vld_neg=topNet.addSignal(ufix1Type,'sofVldNeg');
    pirelab.getLogicComp(topNet,sof_vld,sof_vld_neg,'not');

    endvld=topNet.addSignal(validi.Type,'endVld');
    pirelab.getLogicComp(topNet,[validin,endin],endvld,'and');

    const0=topNet.addSignal(ufix1Type,'const0');
    pirelab.getConstComp(topNet,const0,0);

    const0reg=topNet.addSignal(ufix1Type,'const0Reg');
    pirelab.getUnitDelayEnabledComp(topNet,const0,const0reg,validi,'',0);

    framevld_tmp=topNet.addSignal(ufix1Type,'fValidTmp');
    pirelab.getUnitDelayEnabledResettableComp(topNet,const0reg,framevld_tmp,eof_vld,sof_vld,'frame',1);

    fvalid_reg=topNet.addSignal(ufix1Type,'fValidReg');
    pirelab.getUnitDelayComp(topNet,framevld_tmp,fvalid_reg,'',0);

    framevld=topNet.addSignal(ufix1Type,'fValid');
    pirelab.getLogicComp(topNet,[fvalid_reg,endvld],framevld,'or');

    vframe=topNet.addSignal(ufix1Type,'vFrame');
    pirelab.getLogicComp(topNet,[validi,framevld],vframe,'and');

    cntdata=topNet.addSignal(cntType,'countVal');
    cntcomp=pirelab.getCounterComp(topNet,[sof_vld,vframe],cntdata,'Count limited',1,1,...
    mVal,1,0,1,0,'Counting Data',1);
    cntcomp.addComment('Counter for input data length');

    countrel=topNet.addSignal(ufix1Type,'rel_count');
    rcomp=pirelab.getRelOpComp(topNet,[cntdata,maxcount],countrel,'~=',1);
    rcomp.addComment('Comparison of counter to max count');

    endtrig1=topNet.addSignal(ufix1Type,'endTrigger');
    pirelab.getLogicComp(topNet,[eof_vld,framevld],endtrig1,'and');

    endtrig2=topNet.addSignal(ufix1Type,'endTrigger2');
    pirelab.getLogicComp(topNet,[endtrig1,sof_vld_neg],endtrig2,'and');

    endtrig=topNet.addSignal(ufix1Type,'endTriggerReg');
    pirelab.getIntDelayComp(topNet,endtrig2,endtrig,2,'end trigger',0);

    invld_len=topNet.addSignal(ufix1Type,'invalidLength');
    pirelab.getUnitDelayEnabledResettableComp(topNet,countrel,invld_len,endtrig2,endtrig,'invalid length',0);

    invld_blen=topNet.addSignal(ufix1Type,'invalidBlockLength');
    pirelab.getUnitDelayEnabledResettableComp(topNet,invld_blentmp,invld_blen,endtrig2,endtrig,'invalid block length',0);

    endoutvld=topNet.addSignal(ufix1Type,'endOutVld');
    pirelab.getLogicComp(topNet,[endout,validout],endoutvld,'and');

    endoutvld_tmp=topNet.addSignal(ufix1Type,'endOutVldTmp');
    pirelab.getLogicComp(topNet,[endoutvld,sof_vld_neg],endoutvld_tmp,'and');

    endoutvldreg=topNet.addSignal(ufix1Type,'endOutVldReg');
    pirelab.getUnitDelayComp(topNet,endoutvld_tmp,endoutvldreg,'',0);

    iframe=topNet.addSignal(ufix1Type,'invFrame');
    pirelab.getLogicComp(topNet,[invld_len,invld_blen],iframe,'or');

    iframe_tmp=topNet.addSignal(ufix1Type,'invFrameTmp');
    pirelab.getLogicComp(topNet,[endoutvldreg,iframe],iframe_tmp,'or');

    nfenb=topNet.addSignal(ufix1Type,'nFrameEnb');
    pirelab.getLogicComp(topNet,[iframe_tmp,sof_vld_neg],nfenb,'and');

    nframe_tmp=topNet.addSignal(ufix1Type,'nFrameTmp');
    pirelab.getUnitDelayEnabledResettableComp(topNet,const0reg,nframe_tmp,sof_vld,nfenb,'nextFrame',1);

    nframe=topNet.addSignal(ufix1Type,'nFrame');
    pirelab.getLogicComp(topNet,[nframe_tmp,iframe_tmp],nframe,'or');

    rframe=topNet.addSignal(ufix1Type,'resetFrame');
    pirelab.getLogicComp(topNet,[nframe,framevld],rframe,'or');


    zero_data=topNet.addSignal(decbits.Type,'zData');
    pirelab.getConstComp(topNet,zero_data,0);

    decdatareg=topNet.addSignal(decbits.Type,'decData');
    starto_reg=topNet.addSignal(startout.Type,'startOReg');
    endo_reg=topNet.addSignal(startout.Type,'endOReg');
    valido_reg=topNet.addSignal(startout.Type,'validOReg');
    itero_reg=topNet.addSignal(ufix8Type,'iterOReg');
    pchecko_reg=topNet.addSignal(startout.Type,'pCheckOReg');

    pirelab.getSwitchComp(topNet,[datao,zero_data],decdatareg,rframe,'data sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[starto,const0],starto_reg,rframe,'start sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[endo,const0],endo_reg,rframe,'end sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[valido,const0],valido_reg,rframe,'valid sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[itero,const0],itero_reg,rframe,'iter sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[pchecko,const0],pchecko_reg,rframe,'pcheck sel','==',0,'Floor','Wrap');

    pirelab.getUnitDelayComp(topNet,decdatareg,decbits,'data',0);
    pirelab.getUnitDelayComp(topNet,starto_reg,startout,'start',0);
    pirelab.getUnitDelayComp(topNet,endo_reg,endout,'end',0);
    pirelab.getUnitDelayComp(topNet,valido_reg,validout,'valid',0);
    pirelab.getWireComp(topNet,nframe,nextframe,'next frame');

    if(strcmpi(blockInfo.Termination,'Early'))
        pirelab.getUnitDelayComp(topNet,itero_reg,actiter,'iter',0);
    end
    if blockInfo.ParityCheckStatus
        pirelab.getUnitDelayComp(topNet,pchecko_reg,parcheck,'parity check',0);
    end

