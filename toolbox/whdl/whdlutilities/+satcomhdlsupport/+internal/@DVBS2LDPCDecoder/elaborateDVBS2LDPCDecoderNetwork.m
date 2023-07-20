function elaborateDVBS2LDPCDecoderNetwork(this,topNet,blockInfo,insignals,...
    outsignals,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix8Type=pir_ufixpt_t(8,0);
    ufix16Type=pir_ufixpt_t(16,0);
    oType=pir_ufixpt_t(blockInfo.maxOutWL,0);
    layType=pir_ufixpt_t(blockInfo.layWL,0);

    cntType=ufix16Type;

    iType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);



    datai=insignals(1);
    starti=insignals(2);
    endi=insignals(3);
    validi=insignals(4);
    inputPortInd=5;

    if(strcmpi(blockInfo.FECFrameSource,'Property'))
        if(strcmpi(blockInfo.CodeRateSource,'Input port'))
            ratei=insignals(inputPortInd);
            inputPortInd=inputPortInd+1;
        else
            ratei=topNet.addSignal(ufix4Type,'rateidx');
            pirelab.getConstComp(topNet,ratei,0);
        end
        bleni=topNet.addSignal(ufix1Type,'blockLen');
        pirelab.getConstComp(topNet,bleni,0);

    else
        bleni=insignals(inputPortInd);
        ratei=insignals(inputPortInd+1);
        inputPortInd=inputPortInd+2;
    end

    if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
        niteri=insignals(inputPortInd);
    else
        niteri=topNet.addSignal(ufix8Type,'numIter');
        pirelab.getConstComp(topNet,niteri,blockInfo.NumIterations);
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

    dataout=topNet.addSignal(iType,'dataOut');
    valid=topNet.addSignal(ufix1Type,'valid');
    framevalid=topNet.addSignal(ufix1Type,'frameValid');
    reset=topNet.addSignal(ufix1Type,'reset');
    softreset=topNet.addSignal(ufix1Type,'softReset');
    numiter=topNet.addSignal(ufix8Type,'numIter');
    parind=topNet.addSignal(ufix1Type,'parInd');
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

    niter=topNet.addSignal(niteri.Type,'nIter');
    pirelab.getUnitDelayEnabledComp(topNet,niteri,niter,sof_vld,'',8);

    blen=topNet.addSignal(bleni.Type,'bLen');
    pirelab.getUnitDelayEnabledComp(topNet,bleni,blen,sof_vld,'',0);

    rate=topNet.addSignal(ratei.Type,'codeRate');
    pirelab.getUnitDelayEnabledComp(topNet,ratei,rate,sof_vld,'',0);

    outlen=topNet.addSignal(oType,'outLen');
    nlayers=topNet.addSignal(layType,'nLayers');
    if strcmpi(blockInfo.FECFrameSource,'Input port')
        index=topNet.addSignal(ufix5Type,'idxCon');
        index_reg=topNet.addSignal(ufix5Type,'idxConReg');
        pirelab.getBitConcatComp(topNet,[blen,rate],index,'indexConcat');
        pirelab.getUnitDelayComp(topNet,index,index_reg,0,'');
        pirelab.getDirectLookupComp(topNet,index_reg,outlen,blockInfo.outLenLUT,'outLenLUT','','','','',oType);
        pirelab.getDirectLookupComp(topNet,index_reg,nlayers,blockInfo.nLayersLUT,'nLayersLUT','','','','',layType);
    elseif strcmpi(blockInfo.CodeRateSource,'Input port')
        pirelab.getDirectLookupComp(topNet,rate,outlen,blockInfo.outLenLUT,'outLenLUT','','','','',oType);
        pirelab.getDirectLookupComp(topNet,rate,nlayers,blockInfo.nLayersLUT,'nLayersLUT','','','','',layType);
    else
        pirelab.getConstComp(topNet,outlen,blockInfo.outLenLUT);
        pirelab.getConstComp(topNet,nlayers,blockInfo.nLayersLUT);
    end



    aNet=this.elabCodeParametersNetwork(topNet,blockInfo,dataRate);
    aNet.addComment('Code Parameters');
    pirelab.instantiateNetwork(topNet,aNet,[datain,startin,endin,validin,niter,outlen],...
    [dataout,valid,framevalid,reset,softreset,numiter,parind],'Code Parameters');

    data_dtc=topNet.addSignal(aType,'dataDTC');
    pirelab.getDTCComp(topNet,dataout,data_dtc,'Floor','Wrap','RWV','Data Type Conversion');

    datao=topNet.addSignal(decbits.Type,'dataO');
    starto=topNet.addSignal(startout.Type,'startO');
    endo=topNet.addSignal(endout.Type,'endO');
    valido=topNet.addSignal(validout.Type,'validO');
    itero=topNet.addSignal(ufix8Type,'iterO');
    pchecko=topNet.addSignal(validout.Type,'pCheckO');
    nframe=topNet.addSignal(ufix1Type,'nFrame');

    core_reset=topNet.addSignal(ufix1Type,'resetCore');
    pirelab.getLogicComp(topNet,[reset,nframe],core_reset,'or');



    mNet=this.elabDecoderCoreNetwork(topNet,blockInfo,dataRate);
    mNet.addComment('Decoder Core');
    pirelab.instantiateNetwork(topNet,mNet,[data_dtc,valid,framevalid,core_reset,softreset,numiter,parind,nlayers,outlen,rate,blen],...
    [datao,starto,endo,valido,itero,pchecko],'Decoder Core');


    maxcount=topNet.addSignal(cntType,'maxCount');
    invld_ratetmp=topNet.addSignal(ufix1Type,'invCodeRateTmp');

    if strcmpi(blockInfo.FECFrameSource,'Input port')
        const0=topNet.addSignal(ufix16Type,'const0');
        pirelab.getConstComp(topNet,const0,64800-1);
        const1=topNet.addSignal(ufix16Type,'const1');
        pirelab.getConstComp(topNet,const1,16200-1);
        pirelab.getSwitchComp(topNet,[const0,const1],maxcount,blen,'count sel','==',0,'Floor','Wrap');

        invld_ratetmp1=topNet.addSignal(ufix1Type,'invCodeRateTmp1');
        invld_ratetmp2=topNet.addSignal(ufix1Type,'invCodeRateTmp2');
        pirelab.getCompareToValueComp(topNet,rate,invld_ratetmp1,'>',10,'nornal rate range');
        pirelab.getCompareToValueComp(topNet,rate,invld_ratetmp2,'>',9,'short rate range');
        pirelab.getSwitchComp(topNet,[invld_ratetmp1,invld_ratetmp2],invld_ratetmp,blen,'rate sel','==',0,'Floor','Wrap');
    else
        if strcmpi(blockInfo.FECFrame,'Normal')
            mVal=64800;
            pirelab.getConstComp(topNet,maxcount,mVal-1);
            pirelab.getCompareToValueComp(topNet,rate,invld_ratetmp,'>',10,'rate range');
        else
            mVal=16200;
            pirelab.getConstComp(topNet,maxcount,mVal-1);
            pirelab.getCompareToValueComp(topNet,rate,invld_ratetmp,'>',9,'rate range');
        end
    end


    eof_vld=topNet.addSignal(validi.Type,'eofVld');
    pirelab.getLogicComp(topNet,[validi,endi],eof_vld,'and');

    sof_vld_neg=topNet.addSignal(ufix1Type,'sofVldNeg');
    pirelab.getLogicComp(topNet,sof_vld,sof_vld_neg,'not');

    endvld=topNet.addSignal(validi.Type,'endVld');
    pirelab.getLogicComp(topNet,[validin,endin],endvld,'and');

    const=topNet.addSignal(ufix1Type,'const');
    pirelab.getConstComp(topNet,const,0);

    constreg=topNet.addSignal(ufix1Type,'constReg');
    pirelab.getUnitDelayEnabledComp(topNet,const,constreg,validi,'',0);

    framevld_tmp=topNet.addSignal(ufix1Type,'fValidTmp');
    pirelab.getUnitDelayEnabledResettableComp(topNet,constreg,framevld_tmp,eof_vld,sof_vld,'frame',1);

    fvalid_reg=topNet.addSignal(ufix1Type,'fValidReg');
    pirelab.getUnitDelayComp(topNet,framevld_tmp,fvalid_reg,'',0);

    framevld=topNet.addSignal(ufix1Type,'fValid');
    pirelab.getLogicComp(topNet,[fvalid_reg,endvld],framevld,'or');

    vframe=topNet.addSignal(ufix1Type,'vFrame');
    pirelab.getLogicComp(topNet,[validi,framevld],vframe,'and');

    cntdata=topNet.addSignal(cntType,'countVal');
    cntcomp=pirelab.getCounterComp(topNet,[sof_vld,vframe],cntdata,'Count limited',1,1,...
    64800,1,0,1,0,'Counting Data',1);
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

    invld_rate=topNet.addSignal(ufix1Type,'invalidCodeRate');
    pirelab.getUnitDelayEnabledResettableComp(topNet,invld_ratetmp,invld_rate,endtrig2,endtrig,'invalid code rate',0);

    endoutvld=topNet.addSignal(ufix1Type,'endOutVld');
    pirelab.getLogicComp(topNet,[endout,validout],endoutvld,'and');

    endoutvld_tmp=topNet.addSignal(ufix1Type,'endOutVldTmp');
    pirelab.getLogicComp(topNet,[endoutvld,sof_vld_neg],endoutvld_tmp,'and');

    endoutvldreg=topNet.addSignal(ufix1Type,'endOutVldReg');
    pirelab.getUnitDelayComp(topNet,endoutvld_tmp,endoutvldreg,'',0);

    iframe=topNet.addSignal(ufix1Type,'invFrame');
    pirelab.getLogicComp(topNet,[invld_len,invld_rate],iframe,'or');

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


    zero_data=topNet.addSignal(decbits.Type,'zData');
    pirelab.getConstComp(topNet,zero_data,0);

    decdatareg=topNet.addSignal(decbits.Type,'decData');
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

