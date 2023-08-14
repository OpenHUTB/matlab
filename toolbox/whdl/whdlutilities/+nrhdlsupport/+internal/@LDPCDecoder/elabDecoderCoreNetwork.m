function dcNet=elabDecoderCoreNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix6Type=pir_ufixpt_t(6,0);
    ufix7Type=pir_ufixpt_t(7,0);
    ufix8Type=pir_ufixpt_t(8,0);
    ufix9Type=pir_ufixpt_t(9,0);
    sType=pir_sfixpt_t(11,0);
    s1Type=pir_sfixpt_t(10,0);

    RAMAddr=384/blockInfo.RAMOptFactor;

    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    aVType=pirelab.getPirVectorType(aType,blockInfo.VectorSize);
    aV1Type=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    aV2Type=pirelab.getPirVectorType(aType,384);

    if blockInfo.RAMOptimize
        wrDataType=pir_ufixpt_t(blockInfo.RAMOptFactor*blockInfo.alphaWL,0);
        colDataType=pir_ufixpt_t(blockInfo.alphaWL,0);
    else
        wrDataType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
        colDataType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    end
    wrDataVType=pirelab.getPirVectorType(wrDataType,RAMAddr);
    colDataVType=pirelab.getPirVectorType(colDataType,384);

    uVType=pirelab.getPirVectorType(ufix1Type,blockInfo.VectorSize);
    uV1Type=pirelab.getPirVectorType(ufix1Type,RAMAddr);
    uV2Type=pirelab.getPirVectorType(ufix1Type,384);

    fVType=pirelab.getPirVectorType(ufix9Type,22);
    zVType=pirelab.getPirVectorType(ufix9Type,7);

    vecSize=blockInfo.VectorSize;


    dcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DecoderCore',...
    'Inportnames',{'dataIn','validIn','frameValid','reset','bgn','iLS','liftsize','endInd','niter','zAddr','endReg','nrow'},...
    'InportTypes',[aVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix3Type,ufix9Type,ufix1Type,ufix8Type,ufix3Type,ufix1Type,ufix6Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'dataOut','startOut','endOut','validOut','iterOut','pCheckOut'},...
    'OutportTypes',[uVType,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix1Type]...
    );



    data=dcNet.PirInputSignals(1);
    valid=dcNet.PirInputSignals(2);
    framevalid=dcNet.PirInputSignals(3);
    reset=dcNet.PirInputSignals(4);
    bgn=dcNet.PirInputSignals(5);
    iLS=dcNet.PirInputSignals(6);
    liftsize=dcNet.PirInputSignals(7);
    endind=dcNet.PirInputSignals(8);
    niter=dcNet.PirInputSignals(9);
    zaddr=dcNet.PirInputSignals(10);
    trigger=dcNet.PirInputSignals(11);
    nrow=dcNet.PirInputSignals(12);

    decbits=dcNet.PirOutputSignals(1);
    startout=dcNet.PirOutputSignals(2);
    endout=dcNet.PirOutputSignals(3);
    validout=dcNet.PirOutputSignals(4);
    iterout=dcNet.PirOutputSignals(5);
    pcheckout=dcNet.PirOutputSignals(6);

    data_mc=dcNet.addSignal(aV1Type,'dataMC');
    valid_mc=dcNet.addSignal(valid.Type,'validMC');
    wr_addr=dcNet.addSignal(ufix7Type,'wrAddr');
    rd_addr=dcNet.addSignal(ufix7Type,'rdAddr');
    rd_valid=dcNet.addSignal(valid.Type,'rdValid');
    iterdone=dcNet.addSignal(valid.Type,'iterDone');
    itercount=dcNet.addSignal(valid.Type,'iterCount');
    betaread=dcNet.addSignal(valid.Type,'betaRead');
    countidx=dcNet.addSignal(ufix5Type,'countIdx');
    layeridx=dcNet.addSignal(ufix6Type,'layerIdx');

    layerout=dcNet.addSignal(ufix6Type,'layer');
    validcount=dcNet.addSignal(ufix5Type,'validCount');

    valid_reg=dcNet.addSignal(ufix1Type,'validReg');
    pirelab.getUnitDelayComp(dcNet,valid_mc,valid_reg,'',0);

    valid_N=dcNet.addSignal(ufix1Type,'validRegN');
    pirelab.getLogicComp(dcNet,valid_mc,valid_N,'not');

    validN=dcNet.addSignal(ufix1Type,'validN');
    pirelab.getLogicComp(dcNet,[valid_N,valid_reg],validN,'and');


    wr_data=dcNet.addSignal(wrDataVType,'wrData');
    wr_en=dcNet.addSignal(uV1Type,'wrEnb');
    coldata=dcNet.addSignal(aV2Type,'colData');
    coldata_dtc=dcNet.addSignal(colDataVType,'colDataDTC');
    iter_out=dcNet.addSignal(ufix8Type,'iterVal');



    endind_reg=dcNet.addSignal(ufix1Type,'endIndReg');
    pirelab.getUnitDelayComp(dcNet,endind,endind_reg,'',0);

    endind_N=dcNet.addSignal(ufix1Type,'endIndN');
    pirelab.getLogicComp(dcNet,endind_reg,endind_N,'not');

    softreset=dcNet.addSignal(ufix1Type,'softReset');
    pirelab.getLogicComp(dcNet,[endind_N,endind],softreset,'and');

    datasel=dcNet.addSignal(ufix1Type,'dataSel');
    pirelab.getLogicComp(dcNet,framevalid,datasel,'not');

    funcenb=dcNet.addSignal(ufix1Type,'funcEnb');

    RAMOptimize=blockInfo.RAMOptimize;
    RAMOptFactor=blockInfo.RAMOptFactor;
    alphaWL=blockInfo.alphaWL;
    alphaFL=-blockInfo.alphaFL;
    earlyFlag=strcmpi(blockInfo.Termination,'early');

    termpass=dcNet.addSignal(ufix1Type,'termPass');
    termpass_reg=dcNet.addSignal(ufix1Type,'termPassReg');
    if earlyFlag
        pirelab.getWireComp(dcNet,termpass,termpass_reg);
    else
        pirelab.getConstComp(dcNet,termpass_reg,0);
    end

    if blockInfo.VectorSize==64
        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','iterationController.m'),'r');
        iterationController=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','iterationController',...
        'InputSignals',[data,valid,datasel,reset,data_mc,valid_mc,bgn,liftsize,softreset,niter,validN,nrow,termpass_reg],...
        'OutputSignals',[wr_data,wr_addr,wr_en,rd_addr,rd_valid,iterdone,betaread,countidx,layeridx,iter_out],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','iterationController',...
        'EMLFileBody',iterationController,...
        'EmlParams',{RAMOptimize,RAMOptFactor,alphaWL,alphaFL,earlyFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        pirelab.getConstComp(dcNet,funcenb,0);

    else
        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','iterationControllerScalar.m'),'r');
        iterationControllerScalar=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','iterationControllerScalar',...
        'InputSignals',[data,valid,datasel,reset,bgn,liftsize,softreset,data_mc,valid_mc,niter,validN,nrow,termpass_reg],...
        'OutputSignals',[wr_data,wr_addr,wr_en,rd_addr,rd_valid,iterdone,betaread,countidx,layeridx,funcenb,iter_out],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','iterationControllerScalar',...
        'EMLFileBody',iterationControllerScalar,...
        'EmlParams',{RAMOptimize,RAMOptFactor,alphaWL,alphaFL,earlyFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end

    wrdata_array=this.demuxSignal(dcNet,wr_data,'wrdata_array');
    wren_array=this.demuxSignal(dcNet,wr_en,'wren_array');


    for idx=1:RAMAddr
        if blockInfo.RAMOptimize
            coldata_array(idx)=dcNet.addSignal(wrDataType,['col_data_array_',num2str(idx)]);%#ok<*AGROW>
            pirelab.getSimpleDualPortRamComp(dcNet,[wrdata_array(idx),wr_addr,wren_array(idx),rd_addr],coldata_array(idx),'Variable Node RAM',1,-1,[],'','',blockInfo.ramAttr_block);

            if blockInfo.RAMOptFactor==4
                data_array((idx-1)*4+1)=dcNet.addSignal(colDataType,['data_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                data_array((idx-1)*4+2)=dcNet.addSignal(colDataType,['data_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                data_array((idx-1)*4+3)=dcNet.addSignal(colDataType,['data_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                data_array((idx-1)*4+4)=dcNet.addSignal(colDataType,['data_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(dcNet,coldata_array(idx),data_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(dcNet,coldata_array(idx),data_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(dcNet,coldata_array(idx),data_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(dcNet,coldata_array(idx),data_array((idx-1)*4+4),alphaWL-1,0,'ext4');

            else
                data_array((idx-1)*2+1)=dcNet.addSignal(colDataType,['data_array_',num2str((idx-1)*2+1)]);%#ok<*AGROW>
                data_array((idx-1)*2+2)=dcNet.addSignal(colDataType,['data_array_',num2str((idx-1)*2+2)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(dcNet,coldata_array(idx),data_array((idx-1)*2+1),2*alphaWL-1,alphaWL,'ext1');
                pirelab.getBitSliceComp(dcNet,coldata_array(idx),data_array((idx-1)*2+2),alphaWL-1,0,'ext2');
            end
        else
            data_array(idx)=dcNet.addSignal(aType,['data_array_',num2str(idx)]);%#ok<*AGROW>
            pirelab.getSimpleDualPortRamComp(dcNet,[wrdata_array(idx),wr_addr,wren_array(idx),rd_addr],data_array(idx),'Variable Node RAM',1,-1,[],'','',blockInfo.ramAttr_dist);

        end
    end

    if blockInfo.RAMOptimize
        this.muxSignal(dcNet,data_array,coldata_dtc);
        pirelab.getDTCComp(dcNet,coldata_dtc,coldata,'Floor','Wrap','SI');
    else
        this.muxSignal(dcNet,data_array,coldata);
    end

    rd_valid_reg=dcNet.addSignal(ufix1Type,'rdValidReg');
    pirelab.getUnitDelayComp(dcNet,rd_valid,rd_valid_reg,'',0);

    rd_valid_reg1=dcNet.addSignal(ufix1Type,'rdValidReg1');
    pirelab.getUnitDelayComp(dcNet,rd_valid_reg,rd_valid_reg1,'',0);

    rd_valid_neg=dcNet.addSignal(ufix1Type,'rdValidNeg');
    pirelab.getLogicComp(dcNet,rd_valid_reg,rd_valid_neg,'not');

    nextvalid=dcNet.addSignal(ufix1Type,'nextValid');
    pirelab.getLogicComp(dcNet,[rd_valid_neg,rd_valid],nextvalid,'and');

    zVec=dcNet.addSignal(zVType,'zVec');
    zMax=dcNet.addSignal(ufix9Type,'zMax');

    trigger_reg=dcNet.addSignal(ufix1Type,'trigReg');
    pirelab.getUnitDelayComp(dcNet,trigger,trigger_reg,'trigger',0);

    nrow_reg=dcNet.addSignal(nrow.Type,'nRowReg');
    pirelab.getUnitDelayComp(dcNet,nrow,nrow_reg,'numRows',4);



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','controlModCalculation.m'),'r');
    controlModCalculation=fread(fid,Inf,'char=>char');
    fclose(fid);

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','controlModCalculation',...
    'InputSignals',[trigger_reg,nextvalid,bgn,layeridx,iLS,liftsize,reset,nrow_reg],...
    'OutputSignals',[layerout,itercount,validcount,zVec,zMax],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','controlModCalculation',...
    'EMLFileBody',controlModCalculation,...
    'EmlParams',{vecSize},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    validcnt_reg=dcNet.addSignal(ufix5Type,'validCountReg');
    pirelab.getUnitDelayComp(dcNet,validcount,validcnt_reg,'',0);

    shift=dcNet.addSignal(sType,'shiftVal');
    fin_shift=dcNet.addSignal(fVType,'finalShifts');

    shift_new=dcNet.addSignal(sType,'shiftNew');
    shift_new_reg=dcNet.addSignal(sType,'shiftNewReg');

    const4=dcNet.addSignal(ufix6Type,'const4');
    pirelab.getConstComp(dcNet,const4,4);

    nrowidx=dcNet.addSignal(ufix6Type,'nrowIdx');
    pirelab.getSubComp(dcNet,[nrow_reg,const4],nrowidx,'Floor','Wrap');



    aNet=this.elabCheckMatrixLUTNetwork(dcNet,blockInfo,dataRate);
    aNet.addComment('Check Matrix LUT');
    pirelab.instantiateNetwork(dcNet,aNet,[bgn,iLS,layerout,itercount,validcnt_reg,zaddr,nrowidx],...
    [shift,fin_shift],'Check Matrix LUT');

    pirelab.getAddComp(dcNet,[shift,liftsize],shift_new,'Floor','Wrap');

    pirelab.getUnitDelayComp(dcNet,shift_new,shift_new_reg,'shiftabs',0);


    shift_abs=dcNet.addSignal(sType,'shiftAbs');
    shift_abs_reg=dcNet.addSignal(sType,'shiftAbsReg');
    pirelab.getAbsComp(dcNet,shift_new_reg,shift_abs_reg,'Floor','Wrap','abs shift');



    isshift_great=dcNet.addSignal(ufix1Type,'isShiftGreater');
    pirelab.getRelOpComp(dcNet,[shift_abs_reg,zMax],isshift_great,'>',0,'is great');

    shiftz=dcNet.addSignal(sType,'shiftZ');
    pirelab.getSubComp(dcNet,[shift_abs_reg,zMax],shiftz,'Floor','Wrap');

    shiftSel1=dcNet.addSignal(sType,'shiftSel1');
    pirelab.getSwitchComp(dcNet,[shiftz,shift_abs_reg],shiftSel1,isshift_great,'shift sel','>',0,'Floor','Wrap');

    zvec_array=this.demuxSignal(dcNet,zVec,'zVecArray');

    x=shiftSel1;


    for idx=1:7
        modval(idx)=dcNet.addSignal(sType,['modValStage_',num2str(idx)]);
        pirelab.getSubComp(dcNet,[x,zvec_array(idx)],modval(idx),'Floor','Wrap');

        signval(idx)=dcNet.addSignal(ufix1Type,['signValStage_',num2str(idx)]);
        pirelab.getBitSliceComp(dcNet,modval(idx),signval(idx),10,10,'ext_sign');

        stagereg(idx)=dcNet.addSignal(sType,['stageReg_',num2str(idx)]);
        pirelab.getSwitchComp(dcNet,[x,modval(idx)],stagereg(idx),signval(idx),['shift_sel_',num2str(idx)],'~=',0,'Floor','Wrap');

        stageout(idx)=dcNet.addSignal(sType,['stageOut_',num2str(idx)]);
        pirelab.getUnitDelayComp(dcNet,stagereg(idx),stageout(idx),['stage_delay_',num2str(idx)],0);

        x=stageout(idx);
    end

    stageoutz=dcNet.addSignal(sType,'stageOutZ');
    pirelab.getSubComp(dcNet,[liftsize,stageout(7)],stageoutz,'Floor','Wrap');

    isshift_neg=dcNet.addSignal(ufix1Type,'isShiftNeg');
    pirelab.getCompareToValueComp(dcNet,shift_new,isshift_neg,'<',0,'is negative',1);

    isneg_reg=dcNet.addSignal(ufix1Type,'isNegReg');
    pirelab.getIntDelayComp(dcNet,isshift_neg,isneg_reg,8,'is neg',0);

    shiftSel2=dcNet.addSignal(sType,'shiftSel2');
    pirelab.getSwitchComp(dcNet,[stageoutz,stageout(7)],shiftSel2,isneg_reg,'shift sel','>',0,'Floor','Wrap');


    const0=dcNet.addSignal(sType,'const0');
    pirelab.getConstComp(dcNet,const0,0);

    isequal1=dcNet.addSignal(ufix1Type,'isEqual1');
    pirelab.getCompareToValueComp(dcNet,stageout(7),isequal1,'==',0,'is equal1',1);

    isequal2=dcNet.addSignal(ufix1Type,'isEqual2');
    pirelab.getCompareToValueComp(dcNet,stageoutz,isequal2,'==',0,'is equal2',1);

    isequal=dcNet.addSignal(ufix1Type,'isEqual');
    pirelab.getLogicComp(dcNet,[isequal1,isequal2],isequal,'or');

    shift_del=dcNet.addSignal(ufix9Type,'shiftModReg');
    pirelab.getSwitchComp(dcNet,[const0,shiftSel2],shift_del,isequal,'shift sel','>',0,'Floor','Wrap');


    shift_val=dcNet.addSignal(ufix9Type,'shiftVal');
    pirelab.getWireComp(dcNet,shift_del,shift_val,'');
    shift_mod=dcNet.addSignal(ufix9Type,'shiftMod');
    pirelab.getSwitchComp(dcNet,[shift_val,const0],shift_mod,rd_valid_reg,'shift sel','~=',0,'Floor','Wrap');

    intreset=dcNet.addSignal(ufix1Type,'intReset');
    pirelab.getLogicComp(dcNet,[softreset,reset],intreset,'or');

    funcenb_reg=dcNet.addSignal(ufix1Type,'funcReg');
    pirelab.getUnitDelayComp(dcNet,funcenb,funcenb_reg,'',0);

    iterdone_reg=dcNet.addSignal(ufix1Type,'iterDoneReg');
    pirelab.getUnitDelayComp(dcNet,iterdone,iterdone_reg,'',0);

    data_fd=dcNet.addSignal(uV2Type,'dataFD');
    data_fdreg=dcNet.addSignal(uV2Type,'dataFDReg');
    data_fd_dtc=dcNet.addSignal(aV2Type,'dataFD_dtc');
    start_reg=dcNet.addSignal(ufix1Type,'startReg');
    end_reg=dcNet.addSignal(ufix1Type,'endReg');
    valid_reg=dcNet.addSignal(ufix1Type,'validReg');
    valid_reg1=dcNet.addSignal(ufix1Type,'validReg1');
    final_shift=dcNet.addSignal(ufix9Type,'finShiftVal');
    finsub=dcNet.addSignal(final_shift.Type,'finSub');
    finsub_reg=dcNet.addSignal(final_shift.Type,'finSubReg');
    finsub_reg1=dcNet.addSignal(final_shift.Type,'finSubReg1');
    coldata_tmp=dcNet.addSignal(aV2Type,'colDataTmp');
    sdata=dcNet.addSignal(aV2Type,'sData');
    shift_mod_tmp=dcNet.addSignal(ufix9Type,'shiftModTmp');
    rd_valid_reg_tmp=dcNet.addSignal(ufix1Type,'rdvalidRegTmp');
    validout_tmp=dcNet.addSignal(ufix1Type,'validOutTmp');
    datao=dcNet.addSignal(uV2Type,'shiftData');
    datao1=dcNet.addSignal(uV2Type,'dataDelay');
    dec_bits=dcNet.addSignal(uVType,'decBitsReg');

    valid_fp=dcNet.addSignal(ufix1Type,'validFP');
    iterdone_neg=dcNet.addSignal(ufix1Type,'iterdoneNeg');
    pirelab.getLogicComp(dcNet,iterdone_reg,iterdone_neg,'not');

    pirelab.getLogicComp(dcNet,[valid_mc,iterdone_neg],valid_fp,'and');

    if blockInfo.VectorSize==64
        pirelab.getDTCComp(dcNet,data_fdreg,data_fd_dtc,'Floor','Wrap');

        pirelab.getSwitchComp(dcNet,[coldata,data_fd_dtc],coldata_tmp,iterdone,'shift input sel','==',0,'Floor','Wrap');
        pirelab.getSwitchComp(dcNet,[shift_mod,finsub_reg],shift_mod_tmp,iterdone,'shift value sel','==',0,'Floor','Wrap');
        pirelab.getSwitchComp(dcNet,[rd_valid_reg,valid_reg1],rd_valid_reg_tmp,iterdone,'shift valid sel','==',0,'Floor','Wrap');


        cNet=this.elabCircularShifterNetwork(dcNet,blockInfo,dataRate);
        cNet.addComment('Circular_Shifter_Unit');
        pirelab.instantiateNetwork(dcNet,cNet,[coldata_tmp,liftsize,shift_mod_tmp,rd_valid_reg_tmp],...
        [sdata,validout_tmp],'Circular_Shifter_Unit');


        mNet=this.elabMetricCalculatorNetwork(dcNet,blockInfo,dataRate);
        mNet.addComment('Metric Calculator');
        pirelab.instantiateNetwork(dcNet,mNet,[sdata,validout_tmp,layeridx,betaread,countidx,intreset,rd_valid_reg],...
        [data_mc,valid_mc],'Metric Calculator');



        fdNet=this.elabFinalDecisionNetwork(dcNet,blockInfo,dataRate);
        fdNet.addComment('Final Decision');
        pirelab.instantiateNetwork(dcNet,fdNet,[coldata,iterdone_reg,liftsize,bgn,fin_shift,intreset],...
        [data_fd,start_reg,end_reg,valid_reg,final_shift],'Final Decision');

        if blockInfo.RateCompatible
            pirelab.getIntDelayComp(dcNet,data_fd,data_fdreg,8,'dataFD',0);

            finsub1=dcNet.addSignal(s1Type,'finSubDTC');
            pirelab.getDTCComp(dcNet,final_shift,finsub1,'Floor','Wrap','SI');
            x=finsub1;

            for idx=1:7
                modval1(idx)=dcNet.addSignal(s1Type,['modValStage_',num2str(idx)]);
                pirelab.getSubComp(dcNet,[x,zvec_array(idx)],modval1(idx),'Floor','Wrap');

                signval1(idx)=dcNet.addSignal(ufix1Type,['signValStage_',num2str(idx)]);
                pirelab.getBitSliceComp(dcNet,modval1(idx),signval1(idx),9,9,'ext_sign');

                stagereg1(idx)=dcNet.addSignal(s1Type,['stageReg_',num2str(idx)]);
                pirelab.getSwitchComp(dcNet,[x,modval1(idx)],stagereg1(idx),signval1(idx),['shift_sel_',num2str(idx)],'~=',0,'Floor','Wrap');

                stageout1(idx)=dcNet.addSignal(s1Type,['stageOut_',num2str(idx)]);
                pirelab.getUnitDelayComp(dcNet,stagereg1(idx),stageout1(idx),['stage_delay_',num2str(idx)],0);

                x=stageout1(idx);
            end
            pirelab.getDTCComp(dcNet,stageout1(7),finsub_reg1,'Floor','Wrap','SI');
            pirelab.getSubComp(dcNet,[liftsize,finsub_reg1],finsub,'Floor','Wrap');
            pirelab.getIntDelayComp(dcNet,finsub,finsub_reg,1,'finShift',0);
        else
            pirelab.getSubComp(dcNet,[liftsize,final_shift],finsub,'Floor','Wrap');
            pirelab.getWireComp(dcNet,data_fd,data_fdreg,'');
            pirelab.getWireComp(dcNet,finsub,finsub_reg,'');
        end

        if earlyFlag||blockInfo.ParityCheckStatus


            fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
            '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','finalParityChecks.m'),'r');
            finalParityChecks=fread(fid,Inf,'char=>char');
            fclose(fid);

            dcNet.addComponent2(...
            'kind','cgireml',...
            'Name','finalParityChecks',...
            'InputSignals',[intreset,data_mc,valid_fp,liftsize,countidx,nrow],...
            'OutputSignals',termpass,...
            'ExternalSynchronousResetSignal','',...
            'EMLFileName','finalParityChecks',...
            'EMLFileBody',finalParityChecks,...
            'EmlParams',{vecSize},...
            'EMLFlag_TreatInputIntsAsFixpt',true);
        else
            pirelab.getConstComp(dcNet,termpass,0);
        end

        pirelab.getDTCComp(dcNet,sdata,datao,'Floor','Wrap');
        pirelab.getUnitDelayComp(dcNet,datao,datao1,'',0);

        validout_reg=dcNet.addSignal(ufix1Type,'validOutReg');
        if blockInfo.RateCompatible
            delayNum=10;
            pirelab.getIntDelayComp(dcNet,valid_reg,valid_reg1,8,'valid',0);
        else
            delayNum=2;
            pirelab.getWireComp(dcNet,valid_reg,valid_reg1,'valid');
        end

        pirelab.getIntDelayComp(dcNet,valid_reg1,validout_reg,3,'',0);
        pirelab.getLogicComp(dcNet,[validout_reg,iterdone_reg],validout,'and');

        pirelab.getIntDelayComp(dcNet,start_reg,startout,delayNum,'start',0);
        pirelab.getIntDelayComp(dcNet,end_reg,endout,delayNum,'end',0);
        pirelab.getIntDelayComp(dcNet,iter_out,iterout,delayNum,'end',0);
        pirelab.getIntDelayComp(dcNet,termpass,pcheckout,delayNum,'end',0);


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','outputGeneration.m'),'r');
        outputGeneration=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','outputGeneration',...
        'InputSignals',[datao1,zaddr,iLS,liftsize,validout,intreset,finsub_reg],...
        'OutputSignals',dec_bits,...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','outputGeneration',...
        'EMLFileBody',outputGeneration,...
        'EmlParams',{vecSize},...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        pirelab.getWireComp(dcNet,dec_bits,decbits,'');
    else

        mNet=this.elabMetricCalculatorNetwork(dcNet,blockInfo,dataRate);
        mNet.addComment('Metric Calculator');
        pirelab.instantiateNetwork(dcNet,mNet,[coldata,liftsize,shift_mod,rd_valid_reg,layeridx,betaread,countidx,framevalid,funcenb_reg,iterdone,rd_valid_reg],...
        [data_mc,valid_mc],'Metric Calculator');



        fdNet=this.elabFinalDecisionNetwork(dcNet,blockInfo,dataRate);
        fdNet.addComment('Final Decision');
        pirelab.instantiateNetwork(dcNet,fdNet,[coldata,iterdone_reg,liftsize,bgn,fin_shift,intreset],...
        [data_fd,start_reg,end_reg,valid_reg,final_shift],'Final Decision');

        if blockInfo.RateCompatible
            pirelab.getIntDelayComp(dcNet,data_fd,data_fdreg,8,'dataFD',0);

            finsub1=dcNet.addSignal(s1Type,'finSubDTC');
            pirelab.getDTCComp(dcNet,final_shift,finsub1,'Floor','Wrap','SI');
            x=finsub1;

            for idx=1:7
                modval1(idx)=dcNet.addSignal(s1Type,['modValStage_',num2str(idx)]);
                pirelab.getSubComp(dcNet,[x,zvec_array(idx)],modval1(idx),'Floor','Wrap');

                signval1(idx)=dcNet.addSignal(ufix1Type,['signValStage_',num2str(idx)]);
                pirelab.getBitSliceComp(dcNet,modval1(idx),signval1(idx),9,9,'ext_sign');

                stagereg1(idx)=dcNet.addSignal(s1Type,['stageReg_',num2str(idx)]);
                pirelab.getSwitchComp(dcNet,[x,modval1(idx)],stagereg1(idx),signval1(idx),['shift_sel_',num2str(idx)],'~=',0,'Floor','Wrap');

                stageout1(idx)=dcNet.addSignal(s1Type,['stageOut_',num2str(idx)]);
                pirelab.getUnitDelayComp(dcNet,stagereg1(idx),stageout1(idx),['stage_delay_',num2str(idx)],0);

                x=stageout1(idx);
            end
            pirelab.getDTCComp(dcNet,stageout1(7),finsub_reg1,'Floor','Wrap','SI');
            pirelab.getSubComp(dcNet,[liftsize,finsub_reg1],finsub,'Floor','Wrap');
            pirelab.getIntDelayComp(dcNet,finsub,finsub_reg,1,'finShift',0);
        else
            pirelab.getSubComp(dcNet,[liftsize,final_shift],finsub,'Floor','Wrap');
            pirelab.getWireComp(dcNet,data_fd,data_fdreg,'');
            pirelab.getWireComp(dcNet,finsub,finsub_reg,'');
        end

        if earlyFlag||blockInfo.ParityCheckStatus


            fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
            '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','finalParityChecks.m'),'r');
            finalParityChecks=fread(fid,Inf,'char=>char');
            fclose(fid);

            dcNet.addComponent2(...
            'kind','cgireml',...
            'Name','finalParityChecks',...
            'InputSignals',[intreset,data_mc,valid_fp,liftsize,countidx,nrow],...
            'OutputSignals',termpass,...
            'ExternalSynchronousResetSignal','',...
            'EMLFileName','finalParityChecks',...
            'EMLFileBody',finalParityChecks,...
            'EmlParams',{vecSize},...
            'EMLFlag_TreatInputIntsAsFixpt',true);
        else
            pirelab.getConstComp(dcNet,termpass,0);
        end

        if blockInfo.RateCompatible
            delayNum=10;
            pirelab.getIntDelayComp(dcNet,valid_reg,valid_reg1,8,'valid',0);
        else
            delayNum=2;
            pirelab.getWireComp(dcNet,valid_reg,valid_reg1,'valid');
        end


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','outputGeneration.m'),'r');
        outputGeneration=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','outputGeneration',...
        'InputSignals',[data_fdreg,zaddr,iLS,liftsize,valid_reg1,intreset,finsub_reg],...
        'OutputSignals',dec_bits,...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','outputGeneration',...
        'EMLFileBody',outputGeneration,...
        'EmlParams',{vecSize},...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        pirelab.getIntDelayComp(dcNet,start_reg,startout,delayNum,'start',0);
        pirelab.getIntDelayComp(dcNet,end_reg,endout,delayNum,'end',0);
        pirelab.getIntDelayComp(dcNet,valid_reg1,validout,2,'valid',0);
        pirelab.getIntDelayComp(dcNet,iter_out,iterout,delayNum,'end',0);
        pirelab.getUnitDelayComp(dcNet,dec_bits,decbits,'data',0);
        pirelab.getIntDelayComp(dcNet,termpass,pcheckout,delayNum,'end',0);
    end
