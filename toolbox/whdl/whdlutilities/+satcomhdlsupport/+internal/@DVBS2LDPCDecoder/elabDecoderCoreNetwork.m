function dcNet=elabDecoderCoreNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix6Type=pir_ufixpt_t(6,0);
    ufix8Type=pir_ufixpt_t(8,0);
    ufix11Type=pir_ufixpt_t(11,0);
    oType=pir_ufixpt_t(blockInfo.maxOutWL,0);
    layType=pir_ufixpt_t(blockInfo.layWL,0);
    ivnType=pir_ufixpt_t(blockInfo.ivnWL,0);
    parType=pir_ufixpt_t(blockInfo.parWL,0);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    wType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);


    dcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DecoderCore',...
    'Inportnames',{'data','valid','framevalid','reset','softReset','numiter','parind','nlayers','outlen','rateidx','lenidx'},...
    'InportTypes',[aType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix1Type,layType,oType,ufix4Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'data','start','end','valid','actIter','parCheck'},...
    'OutportTypes',[ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix1Type]...
    );



    data=dcNet.PirInputSignals(1);
    valid=dcNet.PirInputSignals(2);
    framevalid=dcNet.PirInputSignals(3);
    reset=dcNet.PirInputSignals(4);
    softreset=dcNet.PirInputSignals(5);
    numiter=dcNet.PirInputSignals(6);
    parind=dcNet.PirInputSignals(7);
    nlayers=dcNet.PirInputSignals(8);
    outlen=dcNet.PirInputSignals(9);
    rateidx=dcNet.PirInputSignals(10);
    lenidx=dcNet.PirInputSignals(11);

    dataout=dcNet.PirOutputSignals(1);
    startout=dcNet.PirOutputSignals(2);
    endout=dcNet.PirOutputSignals(3);
    validout=dcNet.PirOutputSignals(4);
    actiter=dcNet.PirOutputSignals(5);
    parcheck=dcNet.PirOutputSignals(6);


    data_reg=dcNet.addSignal(data.Type,'dataReg');
    pirelab.getUnitDelayComp(dcNet,data,data_reg,'',0);
    valid_reg=dcNet.addSignal(ufix1Type,'validReg');
    pirelab.getUnitDelayComp(dcNet,valid,valid_reg,'',0);

    frame_neg=dcNet.addSignal(ufix1Type,'fValidNeg');
    pirelab.getLogicComp(dcNet,framevalid,frame_neg,'not');
    frame_reg=dcNet.addSignal(ufix1Type,'frameReg');
    pirelab.getUnitDelayComp(dcNet,frame_neg,frame_reg,'',0);

    sreset_reg=dcNet.addSignal(ufix1Type,'sResetReg');
    pirelab.getUnitDelayComp(dcNet,softreset,sreset_reg,'',0);
    parind_reg=dcNet.addSignal(ufix1Type,'parityReg');
    pirelab.getUnitDelayComp(dcNet,parind,parind_reg,'',0);

    int_reset=dcNet.addSignal(ufix1Type,'intReset');
    pirelab.getLogicComp(dcNet,[reset,sreset_reg],int_reset,'or');



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','parityVNWriting.m'),'r');
    parityVNWriting=fread(fid,Inf,'char=>char');
    fclose(fid);

    gamma=dcNet.addSignal(alphaVType,'gamma');
    gvalid=dcNet.addSignal(valid.Type,'gValid');
    gpvalid=dcNet.addSignal(valid.Type,'gParValid');
    count_layer=dcNet.addSignal(layType,'countLayer');

    layeridx=dcNet.addSignal(layType,'layerIdx');
    pirelab.getUnitDelayComp(dcNet,count_layer,layeridx,'',0);

    gamma_out=dcNet.addSignal(alphaVType,'gammaReg');
    gvalid_out=dcNet.addSignal(valid.Type,'gValidReg');
    gwr_enb=dcNet.addSignal(wType,'gWrEnb');
    layerdone=dcNet.addSignal(valid.Type,'layerDone');

    valid_neg=dcNet.addSignal(valid.Type,'validNeg');
    gvalid_reg=dcNet.addSignal(valid.Type,'validReg');
    pirelab.getLogicComp(dcNet,gvalid,valid_neg,'not');
    pirelab.getUnitDelayComp(dcNet,gvalid,gvalid_reg,'',0);
    pirelab.getLogicComp(dcNet,[valid_neg,gvalid_reg],layerdone,'and');

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','parityVNWriting',...
    'InputSignals',[gamma,gvalid,gpvalid,layeridx,int_reset],...
    'OutputSignals',[gamma_out,gvalid_out,gwr_enb],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','parityVNWriting',...
    'EMLFileBody',parityVNWriting,...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    parind_tmp=dcNet.addSignal(valid.Type,'parIndTmp');
    gpvalid_reg=dcNet.addSignal(valid.Type,'gParValidReg');
    pirelab.getUnitDelayComp(dcNet,gpvalid,gpvalid_reg,'',0);
    pirelab.getLogicComp(dcNet,[gpvalid_reg,parind_reg],parind_tmp,'or');

    termpass=dcNet.addSignal(ufix1Type,'termPass');
    termpass_reg=dcNet.addSignal(ufix1Type,'termPassReg');
    if strcmpi(blockInfo.Termination,'Early')
        pirelab.getWireComp(dcNet,termpass,termpass_reg,'');
    else
        pirelab.getConstComp(dcNet,termpass_reg,0);
    end



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','iterationController.m'),'r');
    iterationController=fread(fid,Inf,'char=>char');
    fclose(fid);

    iterdone=dcNet.addSignal(ufix1Type,'iterDone');
    datasel=dcNet.addSignal(ufix1Type,'dataSel');
    iwr_data=dcNet.addSignal(alphaVType,'iWrData');
    iwr_addr=dcNet.addSignal(ivnType,'iWrAddr');
    iwr_enb=dcNet.addSignal(wType,'iWrEnb');
    ivalid_count=dcNet.addSignal(ufix5Type,'ivCount');
    pwr_data=dcNet.addSignal(alphaVType,'iWrData');
    pwr_addr=dcNet.addSignal(parType,'pWrAddr');
    pwr_enb=dcNet.addSignal(wType,'pWrEnb');
    pvalid_count=dcNet.addSignal(ufix2Type,'pvCount');
    parity=dcNet.addSignal(ufix1Type,'parity');
    rd_valid=dcNet.addSignal(ufix1Type,'rdValid');
    rd_addr=dcNet.addSignal(ivnType,'rdAddr');
    rd_count=dcNet.addSignal(oType,'rdCount');
    betaenb=dcNet.addSignal(ufix1Type,'betaEnb');
    degree=dcNet.addSignal(ufix5Type,'degree');
    iterout=dcNet.addSignal(actiter.Type,'iterOut');
    iterout_tmp=dcNet.addSignal(actiter.Type,'iterOutTmp');
    iterout_reg=dcNet.addSignal(actiter.Type,'iterOutReg');

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','iterationController',...
    'InputSignals',[data_reg,valid_reg,frame_reg,reset,sreset_reg,numiter,parind_tmp,...
    gamma_out,gvalid_out,gwr_enb,layerdone,nlayers,outlen,rateidx,lenidx,...
    termpass_reg],...
    'OutputSignals',[iterdone,datasel,iwr_data,iwr_addr,iwr_enb,pwr_data,pwr_addr,...
    pwr_enb,count_layer,ivalid_count,pvalid_count,parity,rd_valid,...
    rd_addr,betaenb,degree,iterout,rd_count],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','iterationController',...
    'EMLFileBody',iterationController,...
    'EmlParams',{blockInfo},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    rd_valid_reg=dcNet.addSignal(ufix1Type,'rdValidReg');
    pirelab.getIntDelayComp(dcNet,rd_valid,rd_valid_reg,2,'',0);

    parity_ind=dcNet.addSignal(ufix1Type,'parityReg');
    pirelab.getIntDelayComp(dcNet,parity,parity_ind,1,'',0);

    parity_neg=dcNet.addSignal(ufix1Type,'parityNeg');
    pirelab.getLogicComp(dcNet,parity,parity_neg,'not');

    valid_lut=dcNet.addSignal(ufix1Type,'validLUT');
    pirelab.getLogicComp(dcNet,[parity_neg,rd_valid],valid_lut,'and');


    cval=dcNet.addSignal(ufix11Type,'columnVal');
    shift=dcNet.addSignal(ufix6Type,'shiftVal');
    pval=dcNet.addSignal(ufix11Type,'parityVal');
    ddsm=dcNet.addSignal(ufix1Type,'ddsm');


    clNet=this.elabCheckMatrixLUTNetwork(dcNet,blockInfo,dataRate);
    clNet.addComment('Check Matrix LUT');
    pirelab.instantiateNetwork(dcNet,clNet,[count_layer,ivalid_count,pvalid_count,rateidx,lenidx,valid_lut],...
    [cval,shift,pval,ddsm],'Check Matrix LUT');

    cval_dtc=dcNet.addSignal(ivnType,'cVal_dtc');
    pirelab.getDTCComp(dcNet,cval,cval_dtc,'Floor','Wrap');
    pval_dtc=dcNet.addSignal(parType,'pVal_dtc');
    pirelab.getDTCComp(dcNet,pval,pval_dtc,'Floor','Wrap');



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','variableDelayColumns.m'),'r');
    variableDelayColumns=fread(fid,Inf,'char=>char');
    fclose(fid);

    iwraddr_v=dcNet.addSignal(ufix5Type,'iwrAddrV');
    iwrenb_v=dcNet.addSignal(ufix1Type,'iwrEnbV');
    irdaddr_v=dcNet.addSignal(ufix5Type,'irdAddrV');
    pwraddr_v=dcNet.addSignal(ufix3Type,'pwrAddrV');
    pwrenb_v=dcNet.addSignal(ufix1Type,'pwrEnbV');
    prdaddr_v=dcNet.addSignal(ufix3Type,'prdAddrV');

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','variableDelayColumns',...
    'InputSignals',[rd_valid_reg,gvalid,parity_ind,gpvalid,int_reset],...
    'OutputSignals',[iwraddr_v,iwrenb_v,irdaddr_v,pwraddr_v,pwrenb_v,prdaddr_v],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','variableDelayColumns',...
    'EMLFileBody',variableDelayColumns,...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    pval_reg=dcNet.addSignal(parType,'pValReg');
    pirelab.getIntDelayComp(dcNet,pval_dtc,pval_reg,2,'',0);

    cval_reg=dcNet.addSignal(ivnType,'cValReg');
    pirelab.getIntDelayComp(dcNet,cval_dtc,cval_reg,2,'',0);

    ivnval=dcNet.addSignal(ivnType,'ivnVal');
    parval=dcNet.addSignal(parType,'parVal');
    pirelab.getSimpleDualPortRamComp(dcNet,[cval_reg,iwraddr_v,iwrenb_v,irdaddr_v],ivnval,'VariableDelayInfo',1,-1,[],'','',blockInfo.ramAttr_dist);
    pirelab.getSimpleDualPortRamComp(dcNet,[pval_reg,pwraddr_v,pwrenb_v,prdaddr_v],parval,'VariableDelayPar',1,-1,[],'','',blockInfo.ramAttr_dist);


    iwraddr_reg=dcNet.addSignal(ivnType,'iwrAddrReg');
    rdaddr_reg=dcNet.addSignal(ivnType,'rdAddrReg');
    pwraddr_reg=dcNet.addSignal(parType,'pwrAddrReg');

    pirelab.getSwitchComp(dcNet,[ivnval,iwr_addr],iwraddr_reg,datasel,'switchComp1','==',1);
    pirelab.getSwitchComp(dcNet,[parval,pwr_addr],pwraddr_reg,datasel,'switchComp2','==',1);

    irdaddr_reg=dcNet.addSignal(ivnType,'irdAddrReg');
    pirelab.getIntDelayComp(dcNet,rd_addr,rdaddr_reg,1,'',0);
    pirelab.getSwitchComp(dcNet,[rd_addr,cval_dtc],irdaddr_reg,iterdone,'switchComp3','==',1);


    idata_array=this.demuxSignal(dcNet,iwr_data,'i_array');
    pdata_array=this.demuxSignal(dcNet,pwr_data,'p_array');

    iwren_array=this.demuxSignal(dcNet,iwr_enb,'iwren_array');
    pwren_array=this.demuxSignal(dcNet,pwr_enb,'pwren_array');

    ird_data=dcNet.addSignal(alphaVType,'irdData');
    prd_data=dcNet.addSignal(alphaVType,'prdData');

    for idx=1:blockInfo.memDepth
        iarray(idx)=dcNet.addSignal(aType,['info_array_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getSimpleDualPortRamComp(dcNet,[idata_array(idx),iwraddr_reg,iwren_array(idx),irdaddr_reg],iarray(idx),'Info Variable Node RAM',1,-1,[],'','',blockInfo.ramAttr_block);

        parray(idx)=dcNet.addSignal(aType,['parity_array_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getSimpleDualPortRamComp(dcNet,[pdata_array(idx),pwraddr_reg,pwren_array(idx),pval_dtc],parray(idx),'Parity Variable Node RAM',1,-1,[],'','',blockInfo.ramAttr_block);
    end

    this.muxSignal(dcNet,iarray,ird_data);
    this.muxSignal(dcNet,parray,prd_data);



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','parityVNReading.m'),'r');
    parityVNReading=fread(fid,Inf,'char=>char');
    fclose(fid);
    prd_data_tmp=dcNet.addSignal(alphaVType,'prdDataTmp');
    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','parityVNReading',...
    'InputSignals',[prd_data,parity_ind,count_layer,int_reset],...
    'OutputSignals',prd_data_tmp,...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','parityVNReading',...
    'EMLFileBody',parityVNReading,...
    'EmlParams',{blockInfo},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    parity_ind_reg=dcNet.addSignal(ufix1Type,'parIndReg');
    pirelab.getUnitDelayComp(dcNet,parity_ind,parity_ind_reg,'',0);

    rd_data=dcNet.addSignal(alphaVType,'rdData');
    pirelab.getSwitchComp(dcNet,[prd_data_tmp,ird_data],rd_data,parity_ind_reg,'switchComp4','==',1);

    const0=dcNet.addSignal(ufix6Type,'const0');
    pirelab.getConstComp(dcNet,const0,0);

    shiftval=dcNet.addSignal(ufix6Type,'shiftVal');
    pirelab.getSwitchComp(dcNet,[const0,shift],shiftval,parity_ind_reg,'switchComp4','==',1);

    ddsm_reg=dcNet.addSignal(ufix1Type,'ddsmReg');
    pirelab.getIntDelayComp(dcNet,ddsm,ddsm_reg,2,'',0);

    fdata=dcNet.addSignal(alphaVType,'fData');



    mNet=this.elabMetricCalculatorNetwork(dcNet,blockInfo,dataRate);
    mNet.addComment('Metric Calculator');
    pirelab.instantiateNetwork(dcNet,mNet,[rd_data,rd_valid_reg,shiftval,int_reset,ddsm_reg,parity_ind_reg...
    ,count_layer,betaenb,degree],[gamma,gvalid,gpvalid,fdata],'Metric Calculator');

    const1=dcNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(dcNet,const1,0);

    consth=dcNet.addSignal(ufix1Type,'constH');
    pirelab.getConstComp(dcNet,consth,1);


    if strcmpi(blockInfo.Termination,'Early')||blockInfo.ParityCheckStatus


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','finalParityChecks.m'),'r');
        finalParityChecks=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','finalParityChecks',...
        'InputSignals',[int_reset,fdata,gvalid,degree,nlayers],...
        'OutputSignals',termpass,...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','finalParityChecks',...
        'EMLFileBody',finalParityChecks,...
        'EmlParams',{blockInfo.layWL},...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        pirelab.getAddComp(dcNet,[iterout,consth],iterout_tmp,'floor','wrap','add_Comp');
        pirelab.getSwitchComp(dcNet,[iterout_tmp,iterout],iterout_reg,termpass,'iter sel','==',1,'Floor','Wrap');
    else
        pirelab.getWireComp(dcNet,iterout,iterout_reg,'');
        pirelab.getConstComp(dcNet,termpass,0);
    end



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','finalDecision.m'),'r');
    finalDecision=fread(fid,Inf,'char=>char');
    fclose(fid);

    datao=dcNet.addSignal(ufix1Type,'dataO');
    starto=dcNet.addSignal(ufix1Type,'startO');
    endo=dcNet.addSignal(ufix1Type,'endO');
    valido=dcNet.addSignal(ufix1Type,'validO');

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','finalDecision',...
    'InputSignals',[iterdone,rd_count,ird_data,int_reset,outlen],...
    'OutputSignals',[datao,starto,endo,valido],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','finalDecision',...
    'EMLFileBody',finalDecision,...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    constData=dcNet.addSignal(dataout.Type,'zeroData');
    pirelab.getConstComp(dcNet,constData,0);

    datao_tmp=dcNet.addSignal(dataout.Type,'dataTmp');
    starto_tmp=dcNet.addSignal(startout.Type,'startTmp');
    endo_tmp=dcNet.addSignal(endout.Type,'endTmp');
    valido_tmp=dcNet.addSignal(validout.Type,'validTmp');
    iterout_tmp=dcNet.addSignal(iterout.Type,'iterTmp');
    termpass_tmp=dcNet.addSignal(termpass.Type,'parCheckTmp');

    pirelab.getSwitchComp(dcNet,[datao,constData],datao_tmp,valido,'data sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[starto,const1],starto_tmp,valido,'start sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[endo,const1],endo_tmp,valido,'end sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[valido,const1],valido_tmp,valido,'valid sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[iterout_reg,const1],iterout_tmp,valido,'iter sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[termpass,const1],termpass_tmp,valido,'parcheck sel','==',1,'Floor','Wrap');

    pirelab.getUnitDelayComp(dcNet,datao_tmp,dataout,'dataOut',0);
    pirelab.getUnitDelayComp(dcNet,starto_tmp,startout,'startOut',0);
    pirelab.getUnitDelayComp(dcNet,endo_tmp,endout,'endOut',0);
    pirelab.getUnitDelayComp(dcNet,valido_tmp,validout,'validOut',0);
    pirelab.getUnitDelayComp(dcNet,termpass_tmp,parcheck,'parCheck',0);
    pirelab.getUnitDelayComp(dcNet,iterout_tmp,actiter,'actIter',0);
