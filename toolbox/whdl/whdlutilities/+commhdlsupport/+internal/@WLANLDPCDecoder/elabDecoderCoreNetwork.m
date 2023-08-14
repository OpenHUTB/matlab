function dcNet=elabDecoderCoreNetwork(this,topNet,blockInfo,dataRate)






    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix8Type=pir_ufixpt_t(8,0);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    aVType=pirelab.getPirVectorType(aType,blockInfo.VectorSize);
    uVType=pirelab.getPirVectorType(ufix1Type,blockInfo.VectorSize);

    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    bc1Type=pir_ufixpt_t(blockInfo.betadecmpWL,0);
    bc2Type=pir_ufixpt_t(2*blockInfo.minWL,0);

    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);%#ok<*NASGU> 
    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    bcVType1=pirelab.getPirVectorType(bc1Type,blockInfo.memDepth);
    bcVType2=pirelab.getPirVectorType(bc2Type,blockInfo.memDepth);
    aV1Type=pirelab.getPirVectorType(aType,blockInfo.memDepth1);

    uV1Type=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    uV2Type=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth1);

    sType=pir_ufixpt_t(blockInfo.shiftWL,0);
    fType=pirelab.getPirVectorType(sType,blockInfo.finalVec);


    dcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DecoderCore',...
    'Inportnames',{'reset','data','valid','framevalid','blocklen','coderate','endind','smdone','numiter'},...
    'InportTypes',[ufix1Type,aVType,ufix1Type,ufix1Type,ufix2Type,ufix2Type,ufix1Type,ufix1Type,ufix8Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'data','start','end','valid','actIter','parCheck'},...
    'OutportTypes',[uVType,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix1Type]...
    );



    reset=dcNet.PirInputSignals(1);
    data=dcNet.PirInputSignals(2);
    valid=dcNet.PirInputSignals(3);
    framevalid=dcNet.PirInputSignals(4);
    blocklen=dcNet.PirInputSignals(5);
    coderate=dcNet.PirInputSignals(6);
    endind=dcNet.PirInputSignals(7);
    smdone=dcNet.PirInputSignals(8);
    numiter=dcNet.PirInputSignals(9);

    dataout=dcNet.PirOutputSignals(1);
    startout=dcNet.PirOutputSignals(2);
    endout=dcNet.PirOutputSignals(3);
    validout=dcNet.PirOutputSignals(4);
    actiter=dcNet.PirOutputSignals(5);
    parcheck=dcNet.PirOutputSignals(6);


    sFlag=strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax');
    earlyFlag=strcmpi(blockInfo.Termination,'Early');
    mem=blockInfo.memDepth1;

    datasel=dcNet.addSignal(ufix1Type,'dataSel');
    pirelab.getLogicComp(dcNet,framevalid,datasel,'not');

    gamma=dcNet.addSignal(alphaVType,'gamma');
    gamma_array=this.demuxSignal(dcNet,gamma,'gamma_array');
    for idx=1:blockInfo.memDepth1
        garray(idx)=dcNet.addSignal(aType,['garray',num2str(idx)]);%#ok<*AGROW>
        if idx>blockInfo.memDepth
            pirelab.getConstComp(dcNet,garray(idx),0);
        else
            pirelab.getWireComp(dcNet,gamma_array(idx),garray(idx),'');
        end
    end
    gamma_mem=dcNet.addSignal(aV1Type,'gammaMem');
    this.muxSignal(dcNet,garray,gamma_mem);

    gammavalid=dcNet.addSignal(ufix1Type,'gammaValid');
    gvalid_neg=dcNet.addSignal(ufix1Type,'gammaValidNeg');
    gammavalid_reg=dcNet.addSignal(ufix1Type,'gammaValidReg');

    pirelab.getLogicComp(dcNet,gammavalid,gvalid_neg,'not');
    pirelab.getUnitDelayComp(dcNet,gammavalid,gammavalid_reg,'',0);

    layerdone=dcNet.addSignal(ufix1Type,'layerDone');
    pirelab.getLogicComp(dcNet,[gvalid_neg,gammavalid_reg],layerdone,'and');

    endind_reg=dcNet.addSignal(ufix1Type,'endIndReg');
    endind_neg=dcNet.addSignal(ufix1Type,'endIndNeg');
    pirelab.getUnitDelayComp(dcNet,endind,endind_reg,'',0);
    pirelab.getLogicComp(dcNet,endind_reg,endind_neg,'not');

    softreset=dcNet.addSignal(ufix1Type,'softReset');
    pirelab.getLogicComp(dcNet,[endind_neg,endind],softreset,'and');

    termpass=dcNet.addSignal(ufix1Type,'termPass');
    termpass_reg=dcNet.addSignal(ufix1Type,'termPassReg');
    if earlyFlag
        pirelab.getUnitDelayComp(dcNet,termpass,termpass_reg,'',0);
    else
        pirelab.getConstComp(dcNet,termpass_reg,0);
    end

    wr_data=dcNet.addSignal(aV1Type,'wrData');
    wr_en=dcNet.addSignal(uV2Type,'wrEnb');
    wr_addr=dcNet.addSignal(ufix5Type,'wrAddr');
    rd_addr=dcNet.addSignal(ufix5Type,'rdAddr');
    rd_valid=dcNet.addSignal(ufix1Type,'rdValid');
    iterdone=dcNet.addSignal(ufix1Type,'iterDone');
    iterind=dcNet.addSignal(ufix1Type,'iterInd');
    betaread=dcNet.addSignal(ufix1Type,'betaRead');
    countidx=dcNet.addSignal(ufix5Type,'countIdx');
    countlayer=dcNet.addSignal(ufix4Type,'countLayer');
    validcount=dcNet.addSignal(ufix5Type,'validCount');
    iterout=dcNet.addSignal(ufix8Type,'iterOut');
    smsize=dcNet.addSignal(sType,'smSize');

    if blockInfo.VectorSize==8
        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','iterationController.m'),'r');
        iterationController=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','iterationController',...
        'InputSignals',[data,valid,datasel,reset,blocklen,coderate,smdone,layerdone,softreset,numiter,termpass_reg,gamma_mem,gammavalid],...
        'OutputSignals',[wr_data,wr_addr,wr_en,rd_addr,rd_valid,countlayer,countidx,iterind,validcount,iterdone,betaread,iterout,smsize],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','iterationController',...
        'EMLFileBody',iterationController,...
        'EmlParams',{sFlag,earlyFlag,mem},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    else
        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','iterationControllerSerial.m'),'r');
        iterationControllerSerial=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','iterationControllerSerial',...
        'InputSignals',[data,valid,datasel,reset,blocklen,coderate,layerdone,softreset,numiter,termpass_reg,gamma_mem,gammavalid],...
        'OutputSignals',[wr_data,wr_addr,wr_en,rd_addr,rd_valid,countlayer,countidx,iterind,validcount,iterdone,betaread,iterout,smsize],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','iterationControllerSerial',...
        'EMLFileBody',iterationControllerSerial,...
        'EmlParams',{sFlag,earlyFlag,mem},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end

    wrdata_array=this.demuxSignal(dcNet,wr_data,'wrdata_array');
    wren_array=this.demuxSignal(dcNet,wr_en,'wren_array');
    coldata=dcNet.addSignal(aV1Type,'colData');

    for idx=1:blockInfo.memDepth1
        data_array(idx)=dcNet.addSignal(aType,['data_array_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getSimpleDualPortRamComp(dcNet,[wrdata_array(idx),wr_addr,wren_array(idx),rd_addr],data_array(idx),'Variable Node RAM',1,-1,[],'','',blockInfo.ramAttr_dist);
    end
    this.muxSignal(dcNet,data_array,coldata);


    validcnt_reg=dcNet.addSignal(ufix5Type,'validCountReg');
    pirelab.getUnitDelayComp(dcNet,validcount,validcnt_reg,'',0);

    shift=dcNet.addSignal(sType,'shiftVal');
    offset=dcNet.addSignal(ufix3Type,'offSet');
    fin_shift=dcNet.addSignal(fType,'finShift');


    aNet=this.elabCheckMatrixLUTNetwork(dcNet,blockInfo,dataRate);
    aNet.addComment('Check Matrix LUT');
    pirelab.instantiateNetwork(dcNet,aNet,[blocklen,coderate,countlayer,iterind,validcnt_reg],...
    [shift,offset,fin_shift],'Check Matrix LUT');


    rdvalid_reg=dcNet.addSignal(ufix1Type,'rdValidReg');
    pirelab.getUnitDelayComp(dcNet,rd_valid,rdvalid_reg,'',0);

    const0=dcNet.addSignal(ufix3Type,'const0');
    pirelab.getConstComp(dcNet,const0,0);

    valid_reg=dcNet.addSignal(ufix1Type,'validReg');
    fshift=dcNet.addSignal(sType,'fShift');
    fshift_reg=dcNet.addSignal(sType,'fShiftReg');

    datafd=dcNet.addSignal(uV1Type,'dataFD');
    fd_array=this.demuxSignal(dcNet,datafd,'fd_array');
    for idx=1:blockInfo.memDepth1
        farray(idx)=dcNet.addSignal(ufix1Type,['farray',num2str(idx)]);%#ok<*AGROW>
        if idx>blockInfo.memDepth
            pirelab.getConstComp(dcNet,farray(idx),0);
        else
            pirelab.getWireComp(dcNet,fd_array(idx),farray(idx),'');
        end
    end

    datafd_reg=dcNet.addSignal(uV2Type,'dataFDReg');
    this.muxSignal(dcNet,farray,datafd_reg);

    datafd_dtc=dcNet.addSignal(aV1Type,'dataFDDTC');
    pirelab.getDTCComp(dcNet,datafd_reg,datafd_dtc,'Floor','Wrap');

    data_tmp=dcNet.addSignal(aV1Type,'dataTmp');
    shift_tmp=dcNet.addSignal(sType,'shiftTmp');
    offset_tmp=dcNet.addSignal(ufix3Type,'offsetTmp');
    rd_tmp=dcNet.addSignal(ufix1Type,'readTmp');

    sdata=dcNet.addSignal(aV1Type,'sData');
    svalid=dcNet.addSignal(ufix1Type,'sValid');

    pirelab.getSwitchComp(dcNet,[coldata,datafd_dtc],data_tmp,iterdone,'shift input sel','==',0,'Floor','Wrap');
    if blockInfo.VectorSize==1 %#ok<*IFBDUP> 
        pirelab.getSwitchComp(dcNet,[shift,fshift_reg],shift_tmp,iterdone,'shift value sel','==',0,'Floor','Wrap');
    else
        pirelab.getSwitchComp(dcNet,[shift,fshift_reg],shift_tmp,iterdone,'shift value sel','==',0,'Floor','Wrap');
    end
    pirelab.getSwitchComp(dcNet,[offset,const0],offset_tmp,iterdone,'offset value sel','==',0,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[rdvalid_reg,valid_reg],rd_tmp,iterdone,'valid sel','==',0,'Floor','Wrap');


    cNet=this.elabCircularShifterNetwork(dcNet,blockInfo,dataRate);
    cNet.addComment('Circular_Shifter_Unit');
    pirelab.instantiateNetwork(dcNet,cNet,[data_tmp,smsize,shift_tmp,offset_tmp,rd_tmp],...
    [sdata,svalid],'Circular_Shifter_Unit');

    sdata_array=this.demuxSignal(dcNet,sdata,'sdata_array');
    for idx=1:blockInfo.memDepth
        sarray(idx)=dcNet.addSignal(aType,['sarray',num2str(idx)]);%#ok<*AGROW>
        pirelab.getWireComp(dcNet,sdata_array(idx),sarray(idx),'');
    end

    sdata_mem=dcNet.addSignal(alphaVType,'sDataMem');
    this.muxSignal(dcNet,sarray,sdata_mem);


    intreset=dcNet.addSignal(ufix1Type,'intReset');
    pirelab.getLogicComp(dcNet,[softreset,reset],intreset,'or');

    bdecomp1=dcNet.addSignal(bcVType1,'bDecomp1');
    bdecomp2=dcNet.addSignal(bcVType2,'bDecomp2');
    bvalid=dcNet.addSignal(ufix1Type,'bValid');

    betacomp1=dcNet.addSignal(bcVType1,'betaDecomp1');
    betacomp2=dcNet.addSignal(bcVType2,'betaDecomp2');
    bvalid_reg=dcNet.addSignal(ufix1Type,'betaValid');
    cdecomp1=dcNet.addSignal(bcVType1,'cDecomp1');
    cdecomp2=dcNet.addSignal(bcVType2,'cDecomp2');
    cvalid=dcNet.addSignal(ufix1Type,'cValid');

    fvalid=dcNet.addSignal(ufix1Type,'fValid');
    iter_neg=dcNet.addSignal(ufix1Type,'iterDoneNeg');
    pirelab.getLogicComp(dcNet,iterdone,iter_neg,'not');
    pirelab.getLogicComp(dcNet,[svalid,iter_neg],fvalid,'and');


    fNet=this.elabFunctionalUnitNetwork(dcNet,blockInfo,dataRate);
    fNet.addComment('Functional_Unit');
    pirelab.instantiateNetwork(dcNet,fNet,[sdata_mem,fvalid,countidx,...
    cdecomp1,cdecomp2,cvalid,intreset],[gamma,gammavalid,bdecomp1,...
    bdecomp2,bvalid],'Functional_Unit');

    pirelab.getIntDelayComp(dcNet,bdecomp1,betacomp1,1,'',0);
    pirelab.getIntDelayComp(dcNet,bdecomp2,betacomp2,1,'',0);
    pirelab.getIntDelayComp(dcNet,bvalid,bvalid_reg,1,'',0);


    rdvalid_reg1=dcNet.addSignal(ufix1Type,'rdValidReg1');
    rdvalid_reg2=dcNet.addSignal(ufix1Type,'rdValidReg2');
    rd_neg=dcNet.addSignal(ufix1Type,'rdNeg');
    betaread_tmp=dcNet.addSignal(ufix1Type,'betaTmp');

    pirelab.getUnitDelayComp(dcNet,rdvalid_reg,rdvalid_reg1,'',0);
    pirelab.getUnitDelayComp(dcNet,rdvalid_reg1,rdvalid_reg2,'',0);
    pirelab.getLogicComp(dcNet,rdvalid_reg2,rd_neg,'not');
    pirelab.getLogicComp(dcNet,[rdvalid_reg1,rd_neg],betaread_tmp,'and');

    rdenb=dcNet.addSignal(ufix1Type,'betaReadReg');
    pirelab.getLogicComp(dcNet,[betaread_tmp,betaread],rdenb,'and');


    bmNet=this.elabBetaMemoryNetwork(dcNet,blockInfo,dataRate);
    bmNet.addComment('BetaMemory');
    pirelab.instantiateNetwork(dcNet,bmNet,[betacomp1,betacomp2,countlayer,rdenb,bvalid_reg],...
    [cdecomp1,cdecomp2,cvalid],'BetaMemory');


    col_array=this.demuxSignal(dcNet,coldata,'col_array');
    for idx=1:blockInfo.memDepth
        ctmp_array(idx)=dcNet.addSignal(aType,['ctmp_array',num2str(idx)]);%#ok<*AGROW>
        pirelab.getWireComp(dcNet,col_array(idx),ctmp_array(idx),'');
    end
    coldata_mem=dcNet.addSignal(alphaVType,'colDataMem');
    this.muxSignal(dcNet,ctmp_array,coldata_mem);

    start_reg=dcNet.addSignal(ufix1Type,'startReg');
    start_reg1=dcNet.addSignal(ufix1Type,'startReg1');
    valid_reg1=dcNet.addSignal(ufix1Type,'startReg1');


    fdNet=this.elabFinalDecisionNetwork(dcNet,blockInfo,dataRate);
    fdNet.addComment('Final Decision');
    pirelab.instantiateNetwork(dcNet,fdNet,[coldata_mem,iterdone,smsize,coderate,fin_shift,intreset],...
    [datafd,start_reg,valid_reg,fshift],'Final Decision');

    pirelab.getIntDelayComp(dcNet,fshift,fshift_reg,1,'',0);
    pirelab.getIntDelayComp(dcNet,start_reg,start_reg1,2,'',0);
    pirelab.getIntDelayComp(dcNet,valid_reg,valid_reg1,2,'',0);

    mem1=blockInfo.memDepth;
    if earlyFlag||blockInfo.ParityCheckStatus


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','finalParityChecks.m'),'r');
        finalParityChecks=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','finalParityChecks',...
        'InputSignals',[intreset,gamma,gammavalid,smsize,countidx,coderate],...
        'OutputSignals',termpass,...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','finalParityChecks',...
        'EMLFileBody',finalParityChecks,...
        'EmlParams',{sFlag,mem1},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    else
        pirelab.getConstComp(dcNet,termpass,0);
    end


    datao=dcNet.addSignal(dataout.Type,'dataO');
    starto=dcNet.addSignal(startout.Type,'startO');
    endo=dcNet.addSignal(endout.Type,'endO');
    valido=dcNet.addSignal(validout.Type,'validO');

    scalarFlag=(blockInfo.VectorSize==1);
    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','outputGeneration.m'),'r');
    outputGeneration=fread(fid,Inf,'char=>char');
    fclose(fid);

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','outputGeneration',...
    'InputSignals',[sdata_mem,start_reg1,valid_reg1,blocklen,coderate,intreset],...
    'OutputSignals',[datao,starto,endo,valido],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','outputGeneration',...
    'EMLFileBody',outputGeneration,...
    'EmlParams',{sFlag,scalarFlag,mem1},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    constData=dcNet.addSignal(dataout.Type,'zeroData');
    pirelab.getConstComp(dcNet,constData,0);

    const1=dcNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(dcNet,const1,0);

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
    pirelab.getSwitchComp(dcNet,[iterout,const1],iterout_tmp,valido,'iter sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[termpass,const1],termpass_tmp,valido,'parcheck sel','==',1,'Floor','Wrap');

    pirelab.getUnitDelayComp(dcNet,datao_tmp,dataout,'dataOut',0);
    pirelab.getUnitDelayComp(dcNet,starto_tmp,startout,'startOut',0);
    pirelab.getUnitDelayComp(dcNet,endo_tmp,endout,'endOut',0);
    pirelab.getUnitDelayComp(dcNet,valido_tmp,validout,'validOut',0);
    pirelab.getUnitDelayComp(dcNet,termpass_tmp,parcheck,'parCheck',0);
    pirelab.getUnitDelayComp(dcNet,iterout_tmp,actiter,'actIter',0);

end
