function elaborateCCSDSLDPCDecoderNetwork(this,topNet,blockInfo,insignals,outsignals,dataRate)





    ufix1Type=pir_boolean_t;
    ufix2Type=pir_ufixpt_t(2,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufix8Type=pir_ufixpt_t(8,0);
    cntType=pir_ufixpt_t(16,0);
    dType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    dVType=pirelab.getPirVectorType(dType,blockInfo.vectorSize);
    aVType=pirelab.getPirVectorType(aType,blockInfo.vectorSize);



    datai=insignals(1);
    starti=insignals(2);
    endi=insignals(3);
    validi=insignals(4);
    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        if strcmpi(blockInfo.SpecifyInputs,'Input port')
            niteri=insignals(5);
        end
    else
        blocklen=insignals(5);
        coderate=insignals(6);
        if strcmpi(blockInfo.SpecifyInputs,'Input port')
            niteri=insignals(7);
        end
    end

    dataout=outsignals(1);
    startout=outsignals(2);
    endout=outsignals(3);
    validout=outsignals(4);
    if strcmpi(blockInfo.Termination,'Early')
        iterout=outsignals(5);
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

    sof_vld=topNet.addSignal(ufix1Type,'startValid');
    pirelab.getLogicComp(topNet,[starti,validi],sof_vld,'and');

    lenidx=topNet.addSignal(ufix2Type,'lenIdx');
    rateidx=topNet.addSignal(ufix2Type,'rateIdx');

    if strcmpi(blockInfo.LDPCConfiguration,'AR4JA LDPC')
        pirelab.getUnitDelayEnabledComp(topNet,blocklen,lenidx,sof_vld,'',0);
        pirelab.getUnitDelayEnabledComp(topNet,coderate,rateidx,sof_vld,'',0);
    else
        pirelab.getConstComp(topNet,lenidx,0);
        pirelab.getConstComp(topNet,rateidx,0);
    end

    numiter=topNet.addSignal(ufix8Type,'numIter');

    if strcmpi(blockInfo.SpecifyInputs,'Input port')
        range_iter=topNet.addSignal(ufix1Type,'rangeIter');
        const8=topNet.addSignal(ufix8Type,'const8');
        iteract=topNet.addSignal(ufix8Type,'iterAct');

        pirelab.getCompareToValueComp(topNet,niteri,range_iter,'>',63,'iter range');
        pirelab.getConstComp(topNet,const8,8);
        pirelab.getSwitchComp(topNet,[niteri,const8],iteract,range_iter,'sel','==',0,'Floor','Wrap');
        pirelab.getUnitDelayEnabledComp(topNet,iteract,numiter,sof_vld,'',8);
    else
        pirelab.getConstComp(topNet,numiter,blockInfo.NumIterations);
    end



    datacp=topNet.addSignal(dVType,'dataCP');
    validcp=topNet.addSignal(ufix1Type,'validCP');
    fvalidcp=topNet.addSignal(ufix1Type,'fValidCP');
    reset=topNet.addSignal(ufix1Type,'reset');
    endind=topNet.addSignal(ufix1Type,'endInd');

    cpNet=this.elabCodeParametersNetwork(topNet,blockInfo,dataRate);
    cpNet.addComment('Code Parameters');
    pirelab.instantiateNetwork(topNet,cpNet,[datai,starti,endi,validi,nextframe],...
    [datacp,validcp,fvalidcp,reset,endind],'Code Parameters');

    data_dtc=topNet.addSignal(aVType,'dataDTC');
    pirelab.getDTCComp(topNet,datacp,data_dtc,'Floor','Wrap','RWV','Data Type Conversion');



    datao=topNet.addSignal(dataout.Type,'dataOutReg');
    starto=topNet.addSignal(startout.Type,'startOutReg');
    endo=topNet.addSignal(endout.Type,'endOutReg');
    valido=topNet.addSignal(validout.Type,'validOutReg');
    itero=topNet.addSignal(ufix8Type,'iterOutReg');
    pchecko=topNet.addSignal(validout.Type,'pCheckOutReg');

    datasel=topNet.addSignal(validout.Type,'dataSel');
    pirelab.getLogicComp(topNet,fvalidcp,datasel,'not');

    endind_reg=topNet.addSignal(validout.Type,'endIndReg');
    endind_neg=topNet.addSignal(validout.Type,'endIndNeg');

    pirelab.getUnitDelayComp(topNet,endind,endind_reg,'',0);
    pirelab.getLogicComp(topNet,endind_reg,endind_neg,'not');

    softreset=topNet.addSignal(validout.Type,'softReset');
    pirelab.getLogicComp(topNet,[endind,endind_neg],softreset,'and');

    mNet=this.elabDecoderCoreNetwork(topNet,blockInfo,dataRate);
    mNet.addComment('Decoder Core');
    pirelab.instantiateNetwork(topNet,mNet,[data_dtc,validcp,datasel,reset,softreset,numiter,lenidx,rateidx],...
    [datao,starto,endo,valido,itero,pchecko],'Decoder Core');


    maxcount=topNet.addSignal(cntType,'maxCount');
    if strcmpi(blockInfo.LDPCConfiguration,'AR4JA LDPC')
        invld_lentmp=topNet.addSignal(ufix1Type,'invBlkLenTmp');
        invld_ratetmp=topNet.addSignal(ufix1Type,'invCodeRateTmp');
        pirelab.getCompareToValueComp(topNet,lenidx,invld_lentmp,'>',2,'block length range');
        pirelab.getCompareToValueComp(topNet,rateidx,invld_ratetmp,'>',2,'Code rate range');

        idx_con=topNet.addSignal(ufix4Type,'indexConcat');
        pirelab.getBitConcatComp(topNet,[lenidx,rateidx],idx_con,'');
        pirelab.getDirectLookupComp(topNet,idx_con,maxcount,blockInfo.InputLength-1,'InputLUT','','','','',cntType);
    else
        pirelab.getConstComp(topNet,maxcount,blockInfo.InputLength-1);
    end


    eof_vld=topNet.addSignal(validi.Type,'eofVld');
    pirelab.getLogicComp(topNet,[validi,endi],eof_vld,'and');

    sof_vld_neg=topNet.addSignal(ufix1Type,'sofVldNeg');
    pirelab.getLogicComp(topNet,sof_vld,sof_vld_neg,'not');

    const=topNet.addSignal(ufix1Type,'const');
    pirelab.getConstComp(topNet,const,0);

    constreg=topNet.addSignal(ufix1Type,'constReg');
    pirelab.getUnitDelayEnabledComp(topNet,const,constreg,validi,'',0);

    framevld_tmp=topNet.addSignal(ufix1Type,'fValidTmp');
    pirelab.getUnitDelayEnabledResettableComp(topNet,constreg,framevld_tmp,eof_vld,sof_vld,'frame',1);

    fvalid_reg=topNet.addSignal(ufix1Type,'fValidReg');
    pirelab.getUnitDelayComp(topNet,framevld_tmp,fvalid_reg,'',0);

    framevld=topNet.addSignal(ufix1Type,'fValid');
    pirelab.getLogicComp(topNet,[fvalid_reg,eof_vld],framevld,'or');

    vframe=topNet.addSignal(ufix1Type,'vFrame');
    pirelab.getLogicComp(topNet,[validi,framevld],vframe,'and');

    cntdata=topNet.addSignal(cntType,'countVal');
    cntcomp=pirelab.getCounterComp(topNet,[sof_vld,vframe],cntdata,'Count limited',1,1,...
    32768,1,0,1,0,'Counting Data',1);
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

    iframe=topNet.addSignal(ufix1Type,'invFrame');
    nframe=topNet.addSignal(ufix1Type,'nFrame');
    if strcmpi(blockInfo.LDPCConfiguration,'AR4JA LDPC')
        invld_rate=topNet.addSignal(ufix1Type,'invalidCodeRate');
        pirelab.getUnitDelayEnabledResettableComp(topNet,invld_ratetmp,invld_rate,endtrig2,endtrig,'invalid code rate',0);

        invld_blen=topNet.addSignal(ufix1Type,'invalidBlockLen');
        pirelab.getUnitDelayEnabledResettableComp(topNet,invld_lentmp,invld_blen,endtrig2,endtrig,'invalid block length',0);

        invalid_tmp=topNet.addSignal(ufix1Type,'invTmp');
        pirelab.getLogicComp(topNet,[invld_rate,invld_blen],invalid_tmp,'or');

        pirelab.getLogicComp(topNet,[invalid_tmp,invld_len],iframe,'or');

    else
        pirelab.getWireComp(topNet,invld_len,iframe,'');
    end

    endoutvld=topNet.addSignal(ufix1Type,'endOutVld');
    pirelab.getLogicComp(topNet,[endout,validout],endoutvld,'and');

    endoutvld_tmp=topNet.addSignal(ufix1Type,'endOutVldTmp');
    pirelab.getLogicComp(topNet,[endoutvld,sof_vld_neg],endoutvld_tmp,'and');

    endoutvldreg=topNet.addSignal(ufix1Type,'endOutVldReg');
    pirelab.getUnitDelayComp(topNet,endoutvld_tmp,endoutvldreg,'',0);

    iframe_tmp=topNet.addSignal(ufix1Type,'invFrameTmp');
    pirelab.getLogicComp(topNet,[endoutvldreg,iframe],iframe_tmp,'or');

    nfenb=topNet.addSignal(ufix1Type,'nFrameEnb');
    pirelab.getLogicComp(topNet,[iframe_tmp,sof_vld_neg],nfenb,'and');

    nframe_tmp=topNet.addSignal(ufix1Type,'nFrameTmp');
    pirelab.getUnitDelayEnabledResettableComp(topNet,constreg,nframe_tmp,sof_vld,nfenb,'nextFrame',1);

    pirelab.getLogicComp(topNet,[nframe_tmp,iframe_tmp],nframe,'or');

    rframe=topNet.addSignal(ufix1Type,'resetFrame');
    pirelab.getLogicComp(topNet,[nframe,framevld],rframe,'or');

    rframe_reg=topNet.addSignal(ufix1Type,'rFrameReg');
    pirelab.getLogicComp(topNet,[rframe,sof_vld],rframe_reg,'or');


    zero_data=topNet.addSignal(dataout.Type,'zData');
    pirelab.getConstComp(topNet,zero_data,0);

    decdatareg=topNet.addSignal(dataout.Type,'decData');
    starto_reg=topNet.addSignal(startout.Type,'startOReg');
    endo_reg=topNet.addSignal(startout.Type,'endOReg');
    valido_reg=topNet.addSignal(startout.Type,'validOReg');
    itero_reg=topNet.addSignal(ufix8Type,'iterOReg');
    pchecko_reg=topNet.addSignal(startout.Type,'pCheckOReg');

    pirelab.getSwitchComp(topNet,[datao,zero_data],decdatareg,rframe_reg,'data sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[starto,const],starto_reg,rframe_reg,'start sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[endo,const],endo_reg,rframe_reg,'end sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[valido,const],valido_reg,rframe_reg,'valid sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[itero,const],itero_reg,rframe_reg,'iter sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[pchecko,const],pchecko_reg,rframe_reg,'pcheck sel','==',0,'Floor','Wrap');

    pirelab.getUnitDelayComp(topNet,decdatareg,dataout,'data',0);
    pirelab.getUnitDelayComp(topNet,starto_reg,startout,'start',0);
    pirelab.getUnitDelayComp(topNet,endo_reg,endout,'end',0);
    pirelab.getUnitDelayComp(topNet,valido_reg,validout,'valid',0);
    pirelab.getWireComp(topNet,nframe,nextframe,'next frame');

    if strcmpi(blockInfo.Termination,'Early')
        pirelab.getUnitDelayComp(topNet,itero_reg,iterout,'',0);
    end
    if blockInfo.ParityCheckStatus
        pirelab.getUnitDelayComp(topNet,pchecko_reg,parcheck,'',0);
    end

end


