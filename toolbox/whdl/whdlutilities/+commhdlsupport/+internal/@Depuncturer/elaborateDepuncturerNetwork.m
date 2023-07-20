function elaborateDepuncturerNetwork(this,topNet,blockInfo,insignals,...
    outsignals,dataRate)




    wordlen=blockInfo.dlen;
    fractlen=blockInfo.flen;
    punclen=blockInfo.PuncturingLength;

    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    cntType=pir_ufixpt_t(5,0);
    puncType=pirelab.getPirVectorType(ufix1Type,punclen);



    datain=insignals(1);
    dataout=outsignals(1);

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            puncvector=insignals(2);
            syncstart=insignals(3);
            validin=insignals(4);
        else
            syncstart=insignals(2);
            validin=insignals(3);
        end

        validout=outsignals(2);
        erasureout=outsignals(3);
    else
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            puncvector=insignals(2);
            startin=insignals(3);
            endin=insignals(4);
            validin=insignals(5);
        else
            startin=insignals(2);
            endin=insignals(3);
            validin=insignals(4);
        end

        startout=outsignals(2);
        endout=outsignals(3);
        validout=outsignals(4);
        erasureout=outsignals(5);
    end

    if(datain.type.signed||(wordlen==1))
        null=0;
    else
        NsDec=wordlen;
        fNsDec=(2^(-1*fractlen));
        null=2^(NsDec-1)/fNsDec;
    end

    maxval=blockInfo.PuncturingLength/2;



    if(strcmpi(blockInfo.OperationMode,'Continuous'))%#ok<*ALIGN>
        if(strcmpi(blockInfo.SpecifyInputs,'Property'))
            delaynum=2;
        else
            delaynum=5;
        end
    else
        delaynum=4;
    end

    datainreg=topNet.addSignal(datain.Type,'datainReg');
    pirelab.getIntDelayComp(topNet,datain,datainreg,delaynum,'datainput_register',0);


    const1=topNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(topNet,const1,1);
    const0=topNet.addSignal(ufix1Type,'const0');
    pirelab.getConstComp(topNet,const0,0);


    const1_dtc=topNet.addSignal(datain.Type,'const1_dtc');
    pirelab.getConstComp(topNet,const1_dtc,1);
    const0_dtc=topNet.addSignal(datain.Type,'const0_dtc');
    pirelab.getConstComp(topNet,const0_dtc,0);


    validinreg=topNet.addSignal(ufix1Type,'validinReg');
    if(strcmpi(blockInfo.OperationMode,'Frame'))
        pirelab.getIntDelayComp(topNet,validin,validinreg,delaynum,'validinput_register',0);
    else
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            pirelab.getIntDelayComp(topNet,validin,validinreg,delaynum-1,'validinput_register',0);
            vldinreg=topNet.addSignal(ufix1Type,'vldin_Reg');
            pirelab.getIntDelayComp(topNet,validin,vldinreg,delaynum-3,'validinput_register',0);
        else
            pirelab.getIntDelayComp(topNet,validin,validinreg,delaynum+1,'validinput_register',0);
        end
    end

    if(strcmpi(blockInfo.OperationMode,'Continuous'))

        sync_vld=topNet.addSignal(ufix1Type,'syncPunc_vld');
        synccomp=pirelab.getLogicComp(topNet,[syncstart,validin],sync_vld,'and');
        synccomp.addComment('Indicates the valid syncPunc signal');

        sync_vldreg=topNet.addSignal(ufix1Type,'startPunc_vldReg');
        sregcomp=pirelab.getIntDelayComp(topNet,sync_vld,sync_vldreg,1,'syncPunc_register',0);
        sregcomp.addComment('Delaying the syncPunc_vld');

        sync_vldreg1=topNet.addSignal(ufix1Type,'syncPunc_vldReg1');
        sregcomp=pirelab.getIntDelayComp(topNet,sync_vldreg,sync_vldreg1,1,'syncPunc_register',0);
        sregcomp.addComment('Delaying the syncPunc_vldReg')

        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))



            initvld=topNet.addSignal(ufix1Type,'initvld');
            ivcomp=pirelab.getUnitDelayEnabledComp(topNet,validin,initvld,validin,'initialvalidInd',0);
            initvldn=topNet.addSignal(ufix1Type,'initvldNeg');
            pirelab.getLogicComp(topNet,initvld,initvldn,'not');
            ivcomp.addComment('Indicates the initial validin signal for sampling of puncvector');

            samp=topNet.addSignal(ufix1Type,'samp_int1');
            pirelab.getLogicComp(topNet,[initvldn,validin],samp,'and');

            sampint=topNet.addSignal(ufix1Type,'samp_int2');
            pirelab.getLogicComp(topNet,vldinreg,sampint,'not');

            samp_vld=topNet.addSignal(ufix1Type,'samp_vld');
            svcomp=pirelab.getLogicComp(topNet,[samp,sampint],samp_vld,'and');
            svcomp.addComment('Valid signal for sampling of puncVector at initial validin');

            enbsamp=topNet.addSignal(ufix1Type,'enbSampling');
            escomp=pirelab.getLogicComp(topNet,[samp_vld,sync_vld],enbsamp,'or');
            escomp.addComment('Enable signal for Sampling of puncVector at either initial validin or valid syncPunc');

            enbsampreg=topNet.addSignal(ufix1Type,'enbSamplingReg');
            esrcomp=pirelab.getUnitDelayComp(topNet,enbsamp,enbsampreg,'enbSampling_register',0);
            esrcomp.addComment('Delaying the enbSampling');

        else

            enbdepunc=topNet.addSignal(ufix1Type,'enbDepunc');
            ecomp=pirelab.getIntDelayComp(topNet,validin,enbdepunc,2,'enable_depunc_register',0);
            ecomp.addComment('Update the enbDepunc wrt to input valid');
        end
    else


        sof_vld=topNet.addSignal(ufix1Type,'startIn_vld');
        pirelab.getLogicComp(topNet,[startin,validin],sof_vld,'and');
        eof_vld=topNet.addSignal(ufix1Type,'endIn_vld');
        pirelab.getLogicComp(topNet,[endin,validin],eof_vld,'and');

        sof_vldreg=topNet.addSignal(ufix1Type,'startIn_vldReg');
        eof_vldreg=topNet.addSignal(ufix1Type,'endIn_vldReg');

        int_strtvld=topNet.addSignal(ufix1Type,'startvld_int');
        pirelab.getUnitDelayComp(topNet,sof_vldreg,int_strtvld,'',0);

        int_strtvldneg=topNet.addSignal(ufix1Type,'startvldNeg_int');
        pirelab.getLogicComp(topNet,sof_vld,int_strtvldneg,'not');

        frm_vldrst=topNet.addSignal(ufix1Type,'frame_vldRst');
        pirelab.getLogicComp(topNet,[int_strtvldneg,eof_vld],frm_vldrst,'and');

        frm_vld=topNet.addSignal(ufix1Type,'frame_vld');
        fvcomp=pirelab.getUnitDelayEnabledResettableComp(topNet,sof_vld,frm_vld,sof_vld,frm_vldrst,'Frame_valid',0,'',1);
        fvcomp.addComment('Frame Valid between start and end control signals');

        frm_vldreg=topNet.addSignal(ufix1Type,'frame_vldReg');
        pirelab.getIntDelayComp(topNet,frm_vld,frm_vldreg,3,'Frame_valid',0);

        frm_vldregd=topNet.addSignal(ufix1Type,'frame_vldRegD');
        pirelab.getIntDelayComp(topNet,frm_vldreg,frm_vldregd,1,'Frame_valid',0);

        enbdepunc=topNet.addSignal(ufix1Type,'enbDepunc');



        frm=topNet.addSignal(ufix1Type,'frm_enable');
        pirelab.getLogicComp(topNet,[frm_vldregd,frm_vldreg],frm,'or');
        pirelab.getLogicComp(topNet,[frm,validinreg],enbdepunc,'and');

        pirelab.getIntDelayComp(topNet,sof_vld,sof_vldreg,3,'startin_valid_register',0);
        pirelab.getIntDelayComp(topNet,eof_vld,eof_vldreg,4,'endin_valid_register',0);

        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            enbsamp=topNet.addSignal(ufix1Type,'enbSampling');
            escomp=pirelab.getWireComp(topNet,sof_vld,enbsamp);
            escomp.addComment('Enable signal for Sampling of puncvector at valid start of frame');

            enbsampreg=topNet.addSignal(ufix1Type,'enbSamplingReg');
            esrcomp=pirelab.getUnitDelayComp(topNet,enbsamp,enbsampreg,'enbSampling',0);
            esrcomp.addComment('Delaying the enbSampling');
        end
    end



    nullsym=topNet.addSignal(datain.Type,'nullSym');
    ncomp=pirelab.getConstComp(topNet,nullsym,null);
    ncomp.addComment('Null Symbol based on Input data type');


    maxcount=topNet.addSignal(cntType,'maxCount');
    mcomp=pirelab.getConstComp(topNet,maxcount,maxval);
    mcomp.addComment('Maximum Counter value of Counter for positioning of Puncturing vector');


    if(strcmpi(blockInfo.SpecifyInputs,'Property'))

        pattern=topNet.addSignal(puncType,'Pattern');
        pcomp=pirelab.getConstComp(topNet,pattern,blockInfo.PuncturingVector);
        pcomp.addComment('Punturing Vector from Property');

        dmuxout=[];
        for i=1:punclen
            dins(i)=topNet.addSignal(ufix1Type,['pV',num2str(i)]);%#ok<*AGROW>
            dmuxout=[dmuxout,dins(i)];
        end

        dcomp=pirelab.getDemuxComp(topNet,pattern,dmuxout);
        dcomp.addComment('Extracts the sub-vector from Puncturing Vector');
        for i=1:punclen/2
            pv(i)=topNet.addSignal(ufix2Type,['pV_',num2str(i)]);
            pirelab.getBitConcatComp(topNet,[dmuxout(2*i-1),dmuxout(2*i)],pv(i));
        end


        initalval=1;
        initcount=topNet.addSignal(cntType,'initCountVal');
        icomp=pirelab.getConstComp(topNet,initcount,initalval);
        icomp.addComment('Initial value for Counting the positioning of Puncturing Vector');
    else

        pattern=topNet.addSignal(puncType,'Pattern');
        pcomp=pirelab.getUnitDelayEnabledComp(topNet,puncvector,pattern,enbsamp,'puncvector_sampling',0);
        pcomp.addComment('Sampling of Puncturing Vector');



        initcount=topNet.addSignal(cntType,'initCount');
        initcount_vld=topNet.addSignal(ufix1Type,'initCount_vld');

        initcountreg=topNet.addSignal(cntType,'initCountReg');
        initcount_vldreg=topNet.addSignal(ufix1Type,'initCount_vldReg');

        ecomp=pirelab.getIntDelayComp(topNet,initcount_vld,initcount_vldreg,1,'initcount_vld_register',0);
        ecomp.addComment('Update the initcount_vld Register');
        ecomp=pirelab.getIntDelayComp(topNet,initcount,initcountreg,1,'initcount_reg',0);
        ecomp.addComment('Update the initcount Register')

        puncvec=topNet.addSignal(puncType,'puncVector');
        if(strcmpi(blockInfo.OperationMode,'Frame'))
            pirelab.getIntDelayEnabledComp(topNet,pattern,puncvec,initcount_vld,1,'puncvector_register',0);
        else
            pirelab.getIntDelayComp(topNet,pattern,puncvec,4,'puncvector_register',0);
        end

        dmuxout=[];
        for i=1:punclen
            dins(i)=topNet.addSignal(ufix1Type,['pV',num2str(i)]);
            dmuxout=[dmuxout,dins(i)];
        end

        dcomp=pirelab.getDemuxComp(topNet,puncvec,dmuxout);
        dcomp.addComment('Extracts the sub-vector from Puncturing Vector');
        for i=1:punclen/2
            pv(i)=topNet.addSignal(ufix2Type,['pV_',num2str(i)]);
            pirelab.getBitConcatComp(topNet,[dmuxout(2*i-1),dmuxout(2*i)],pv(i));
        end

        extPncVecNet=this.elabExtractPuncVect(topNet,blockInfo,dataRate);


        rcomp=pirelab.instantiateNetwork(topNet,extPncVecNet,[pattern,enbsampreg],[initcount,initcount_vld],'extractPuncVector_inst');
        rcomp.addComment('Instantiation for Extracting Puncturing Vector');
        if(strcmpi(blockInfo.OperationMode,'Continuous'))
            enbdepunc=topNet.addSignal(ufix1Type,'enbDepunc');
            ecomp=pirelab.getIntDelayComp(topNet,validinreg,enbdepunc,1,'enable_depunc_register',0);
            ecomp.addComment('Update the enbDepunc')
        end
    end









    statesubvec=topNet.addSignal(ufix2Type,'state_subvec');

    dataVType=pirelab.getPirVectorType(datain.Type,2);
    dstream=topNet.addSignal(dataVType,'dataStream');

    eraVType=pirelab.getPirVectorType(ufix1Type,2);
    estream=topNet.addSignal(eraVType,'eraStream');

    enbcount=topNet.addSignal(ufix1Type,'enbCount');
    enbcountreg=topNet.addSignal(ufix1Type,'enbCountReg');

    ctrlind=topNet.addSignal(ufix1Type,'ctrlInd');
    ctrlindreg=topNet.addSignal(ufix1Type,'ctrlIndReg');

    countval=topNet.addSignal(cntType,'countVal');
    countvalreg=topNet.addSignal(cntType,'countValReg');

    buffer=topNet.addSignal(datain.Type,'buffer');
    bufferreg=topNet.addSignal(datain.Type,'bufferReg');


    x=[];
    for i=punclen/2:-1:1
        x=[pv(i),x];
    end
    x=[pv(1),x];

    pirelab.getWireComp(topNet,countval,countvalreg);

    decomp=pirelab.getMultiPortSwitchComp(topNet,[countvalreg,x],statesubvec,1,1,'Floor','Wrap');
    decomp.addComment('MultiPortSwitch for State-subVector');


    togglevld=topNet.addSignal(ufix1Type,'togglevld');
    cntcomp=pirelab.getCompareToValueComp(topNet,statesubvec,togglevld,'==',3);
    cntcomp.addComment('Toggeling counter for Puncturing Sub-Vector "11"');

    toggle=topNet.addSignal(ufix1Type,'toggle');
    enbtoggle=topNet.addSignal(ufix1Type,'enbToggle');
    pirelab.getLogicComp(topNet,[togglevld,enbdepunc],enbtoggle,'and');

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(strcmpi(blockInfo.SpecifyInputs,'Property'))
            cntcomp=pirelab.getCounterComp(topNet,[sync_vldreg,enbtoggle],toggle,...
            'Count limited',0,1,1,1,0,1,0);
        else
            cntcomp=pirelab.getCounterComp(topNet,[initcount_vldreg,enbtoggle],toggle,...
            'Count limited',0,1,1,1,0,1,0);
        end
    else
        if(strcmpi(blockInfo.SpecifyInputs,'Property'))
            togg=topNet.addSignal(ufix1Type,'togg');
            eof_vldreg2=topNet.addSignal(ufix1Type,'eof_vld');
            pirelab.getIntDelayComp(topNet,eof_vld,eof_vldreg2,3,'eofvld_register',0);
            pirelab.getLogicComp(topNet,[eof_vldreg2,sof_vldreg],togg,'or');
            cntcomp=pirelab.getCounterComp(topNet,[sof_vldreg,const0,enbtoggle],toggle,...
            'Count limited',0,1,1,0,1,1,0);
        else
            cntcomp=pirelab.getCounterComp(topNet,[initcount_vld,const0,enbtoggle],toggle,...
            'Count limited',0,1,1,0,1,1,0);
        end
    end
    cntcomp.addComment('Counter for Puncturing Sub-Vector "11"');


    if(strcmpi(blockInfo.OperationMode,'Frame'))
        intdata0=topNet.addSignal(datain.Type,'data0_int');
        intdata1=topNet.addSignal(datain.Type,'data1_int');
        int_frmmis=topNet.addSignal(ufix1Type,'frameMismatch');
        toggneg=topNet.addSignal(ufix1Type,'toggNeg');
        endindrst=topNet.addSignal(ufix1Type,'endIndRst');
        endindrstneg=topNet.addSignal(ufix1Type,'endIndRstNeg');
        pirelab.getLogicComp(topNet,endindrst,endindrstneg,'not');
        pirelab.getLogicComp(topNet,toggle,toggneg,'not');

        int_frm1=topNet.addSignal(ufix1Type,'frame_int1');
        int_frm2=topNet.addSignal(ufix1Type,'frame_int2');

        pirelab.getLogicComp(topNet,[eof_vldreg,enbtoggle],int_frm1,'and');
        pirelab.getLogicComp(topNet,[int_frm1,toggneg],int_frm2,'and');
        ccomp=pirelab.getLogicComp(topNet,[int_frm2,endindrstneg],int_frmmis,'and');
        ccomp.addComment('Indicates the Frame length mismatch condition');
    end


    ctrlind11=topNet.addSignal(ufix1Type,'ctrlsubvec11');
    int_ctrlind=topNet.addSignal(ufix1Type,'ctrlind_int');
    if(strcmpi(blockInfo.OperationMode,'Frame'))
        pirelab.getSwitchComp(topNet,[const1,const0],int_ctrlind,int_frmmis,'CtrlInd_Sel_Comp1','==',1);
        pirelab.getSwitchComp(topNet,[const1,int_ctrlind],ctrlind11,toggle,'CtrlInd_Sel_Comp2','==',1);
    else
        pirelab.getSwitchComp(topNet,[const1,const0],ctrlind11,toggle,'CtrlInd_Sel_Comp','==',1);
    end

    eracomp=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0,const1,const1,ctrlind11],ctrlindreg,1,1,'Floor','Wrap');
    eracomp.addComment('MultiPortSwitch for ctrlInd');

    ctrlindrst=topNet.addSignal(ufix1Type,'ctrlIndRst');
    pirelab.getLogicComp(topNet,enbdepunc,ctrlindrst,'not');

    dcomp=pirelab.getUnitDelayEnabledResettableComp(topNet,ctrlindreg,ctrlind,enbdepunc,ctrlindrst,'cltrInd',0,'',1);
    dcomp.addComment('ctrlInd Register Process');


    enbcnt11=topNet.addSignal(ufix1Type,'enbcntsbvect11');
    pirelab.getSwitchComp(topNet,[const1,const0],enbcnt11,toggle,'enbCount_Sel_Comp','==',1);

    eracomp=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const1,const1,const1,enbcnt11],enbcountreg,1,1,'Floor','Wrap');
    eracomp.addComment('MultiPortSwitch for enbCount');


    buffer11=topNet.addSignal(datain.Type,'buffsbvect11');
    pirelab.getSwitchComp(topNet,[const0_dtc,datainreg],buffer11,toggle,'buffer_Sel_Comp','==',1);

    eracomp=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0_dtc,const0_dtc,const0_dtc,buffer11],bufferreg,1,1,'Floor','Wrap');
    eracomp.addComment('MultiPortSwitch for buffer');

    dcomp=pirelab.getUnitDelayEnabledResettableComp(topNet,bufferreg,buffer,enbdepunc,'buffer',0);
    dcomp.addComment('buffer Register Process');


    dstream0=topNet.addSignal(datain.Type,'dstream0');
    dstream1=topNet.addSignal(datain.Type,'dstream1');
    estream0=topNet.addSignal(ufix1Type,'estream0');
    estream1=topNet.addSignal(ufix1Type,'estream1');

    ds1_11=topNet.addSignal(datain.Type,'ds1sbvect11');
    ds2_11=topNet.addSignal(datain.Type,'ds2sbvect11');

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        syncbuff=topNet.addSignal(datain.Type,'syncbuff');
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            syncbuffcomp=pirelab.getSwitchComp(topNet,[const0_dtc,buffer],syncbuff,initcount_vld,'Buffer clear Comp','==',1);
        else
            syncbuffcomp=pirelab.getSwitchComp(topNet,[const0_dtc,buffer],syncbuff,sync_vldreg1,'Buffer clear Comp','==',1);
        end
        syncbuffcomp.addComment('Clearing the buffer when startpunc_vld high');
        if(strcmpi(blockInfo.SpecifyInputs,'Input port'))
            pirelab.getSwitchComp(topNet,[buffer,const0_dtc],ds1_11,toggle,'dataStream1_Sel_Comp','==',1);
        else
            pirelab.getSwitchComp(topNet,[syncbuff,const0_dtc],ds1_11,toggle,'dataStream1_Sel_Comp','==',1);
        end

        pirelab.getSwitchComp(topNet,[datainreg,const0_dtc],ds2_11,toggle,'dataStream2_Sel_Comp','==',1);
    else
        pirelab.getSwitchComp(topNet,[datainreg,const0_dtc],intdata0,int_frmmis,'dataStream1_SelComp1','==',1);
        pirelab.getSwitchComp(topNet,[buffer,intdata0],ds1_11,toggle,'dataStream1_Sel_Comp2','==',1);
        ncomp=pirelab.getSwitchComp(topNet,[nullsym,const0_dtc],intdata1,int_frmmis,'dataStream2_SelComp1','==',1);
        ncomp.addComment('Inserts null symbol - When Frame length mismatch occurs');
        pirelab.getSwitchComp(topNet,[datainreg,intdata1],ds2_11,toggle,'dataStream2_Sel_Comp2','==',1);
    end

    dcomp1=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0_dtc,nullsym,datainreg,ds1_11],dstream0,1,1,'Floor','Wrap');
    dcomp1.addComment('Data Stream1');

    dcomp2=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0_dtc,datainreg,nullsym,ds2_11],dstream1,1,1,'Floor','Wrap');
    dcomp2.addComment('Data Stream2');

    const0reg=topNet.addSignal(ufix1Type,'const0Reg');
    const1reg=topNet.addSignal(ufix1Type,'const1Reg');

    enb=topNet.addSignal(ufix1Type,'enbConst');
    pirelab.getIntDelayComp(topNet,validin,enb,1,'',0);

    pirelab.getUnitDelayEnabledComp(topNet,const0,const0reg,enb,'',0);
    pirelab.getUnitDelayEnabledComp(topNet,const1,const1reg,enb,'',0);

    ecomp1=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0reg,const1reg,const0reg,const0reg],estream0,1,1,'Floor','Wrap');
    ecomp1.addComment('Erasure Stream1');

    if(strcmpi(blockInfo.OperationMode,'Frame'))
        intera1=topNet.addSignal(ufix1Type,'era1_int');
        ecomp=pirelab.getSwitchComp(topNet,[const1reg,const0reg],intera1,int_frmmis,'eraStream2_Sel_Comp1','==',1);
        ecomp.addComment('Makes ErasureOut high - When Frame length mismatch occurs');
        ecomp2=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0reg,const0reg,const1reg,intera1],estream1,1,1,'Floor','Wrap');
        ecomp2.addComment('Erasure Stream2');
    else
        ecomp2=pirelab.getMultiPortSwitchComp(topNet,[statesubvec,const0reg,const0reg,const1reg,const0reg],estream1,1,1,'Floor','Wrap');
        ecomp2.addComment('Erasure Stream2');
    end

    dArray=[dstream0,dstream1];
    eArray=[estream0,estream1];

    dim=2;
    dmuxin=[];
    for i=1:dim
        dmuxin=[dmuxin,dArray(i)];
    end
    muxcomp=pirelab.getMuxComp(topNet,dmuxin,dstream);
    muxcomp.addComment('dataStream Muxing');

    emuxin=[];
    for i=1:dim
        emuxin=[emuxin,eArray(i)];
    end
    muxecomp=pirelab.getMuxComp(topNet,emuxin,estream);
    muxecomp.addComment('erasureStream Muxing');


    outregrst=topNet.addSignal(ufix1Type,'outRegRst');
    pirelab.getLogicComp(topNet,enbdepunc,outregrst,'not');
    if((strcmpi(blockInfo.OperationMode,'Continuous'))&&(strcmpi(blockInfo.SpecifyInputs,'Property')))
        datareg=topNet.addSignal(dataout.type,'dataOutReg');
        erasurereg=topNet.addSignal(erasureout.type,'erasureOutReg');
        pirelab.getUnitDelayEnabledResettableComp(topNet,dstream,datareg,enbdepunc,outregrst,'dataOut_register',0,'',1);
        pirelab.getUnitDelayEnabledResettableComp(topNet,estream,erasurereg,enbdepunc,outregrst,'erasureOut_register',0,'',1);

        dcomp=pirelab.getIntDelayComp(topNet,datareg,dataout,3,'dataOut',0);
        dcomp.addComment('Output Data Register Process');
        ecomp=pirelab.getIntDelayComp(topNet,erasurereg,erasureout,3,'erasureOut',0);
        ecomp.addComment('Output Erasure Register Process');

    else
        dcomp=pirelab.getUnitDelayEnabledResettableComp(topNet,dstream,dataout,enbdepunc,outregrst,'dataOut_register',0,'',1);
        dcomp.addComment('Output Data Register Process');
        ecomp=pirelab.getUnitDelayEnabledResettableComp(topNet,estream,erasureout,enbdepunc,outregrst,'erasureOut_register',0,'',1);
        ecomp.addComment('Output Erasure Register Process');
    end



    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        ccomp=pirelab.getLogicComp(topNet,[enbcountreg,enbdepunc],enbcount,'and');
        ccomp.addComment('enbCount Process');
        if(strcmpi(blockInfo.SpecifyInputs,'Property'))
            cntcomp=pirelab.getCounterComp(topNet,[sync_vldreg,enbcount],countval,...
            'Count limited',1,1,maxval,1,0,1,0);
        else
            cntr1=topNet.addSignal(ufix1Type,'cntr1');
            cntr2=topNet.addSignal(ufix1Type,'cntr2');
            pirelab.getCompareToValueComp(topNet,countval,cntr1,'==',maxval);
            cntr=topNet.addSignal(ufix1Type,'cntr');

            cntrenb11=topNet.addSignal(ufix1Type,'cntrenb11');
            togglevldneg=topNet.addSignal(ufix1Type,'togglevldNeg');
            cntrenb=topNet.addSignal(ufix1Type,'cntrenb');
            pirelab.getLogicComp(topNet,togglevld,togglevldneg,'not');
            pirelab.getLogicComp(topNet,[togglevldneg,cntr1],cntrenb,'and');
            pirelab.getLogicComp(topNet,[togglevld,toggle],cntrenb11,'and');
            cntload=topNet.addSignal(ufix1Type,'cntrload');
            pirelab.getLogicComp(topNet,[cntr1,cntrenb11],cntload,'and');
            pirelab.getLogicComp(topNet,[cntrenb,cntload],cntr2,'or');
            pirelab.getLogicComp(topNet,[cntr2,enbdepunc],cntr,'and');
            loadcount=topNet.addSignal(ufix1Type,'loadCount');
            lcomp=pirelab.getLogicComp(topNet,[cntr,initcount_vldreg],loadcount,'or');
            lcomp.addComment('Indicates the Counter to load initial Count value');

            cntcomp=pirelab.getCounterComp(topNet,[loadcount,initcountreg,enbcount],countval,...
            'Count limited',1,1,maxval,0,1,1,0);
        end
    else
        enbcnt_int=topNet.addSignal(ufix1Type,'enbcount_int');
        sofvld_int=topNet.addSignal(ufix1Type,'sofvld_int');
        pirelab.getLogicComp(topNet,sof_vldreg,sofvld_int,'not');
        pirelab.getLogicComp(topNet,[enbcountreg,enbdepunc],enbcnt_int,'and');

        ccomp=pirelab.getLogicComp(topNet,[enbcnt_int,sofvld_int],enbcount,'and');
        ccomp.addComment('enbCount Process');

        if(strcmpi(blockInfo.SpecifyInputs,'Property'))
            cntcomp=pirelab.getCounterComp(topNet,[sof_vldreg,enbcount],countval,...
            'Count limited',1,1,maxval,1,0,1,0);
        else
            cntr1=topNet.addSignal(ufix1Type,'cntr1');
            cntr2=topNet.addSignal(ufix1Type,'cntr2');
            pirelab.getCompareToValueComp(topNet,countval,cntr1,'==',maxval);
            cntr=topNet.addSignal(ufix1Type,'cntr');

            togglevldneg=topNet.addSignal(ufix1Type,'togglevldn');
            pirelab.getLogicComp(topNet,togglevld,togglevldneg,'not');
            pirelab.getLogicComp(topNet,[cntr1,togglevldneg],cntr2,'and');
            pirelab.getLogicComp(topNet,[cntr2,enbdepunc],cntr,'and');
            loadcount=topNet.addSignal(ufix1Type,'loadCount');
            lcomp=pirelab.getLogicComp(topNet,[cntr,initcount_vld],loadcount,'or');
            lcomp.addComment('Indicates the Counter to load initial Count value');

            cntcomp=pirelab.getCounterComp(topNet,[loadcount,initcount,enbcount],countval,...
            'Count limited',1,1,maxval,0,1,1,0);
        end
    end
    cntcomp.addComment('Counter for Positioning of Puncturing Vector');


    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(strcmpi(blockInfo.SpecifyInputs,'Property'))
            validreg=topNet.addSignal(ufix1Type,'validOutReg');
            pirelab.getWireComp(topNet,ctrlind,validreg,'');

            vcomp=pirelab.getIntDelayComp(topNet,validreg,validout,3,'validOut',0);
            vcomp.addComment('Output Valid Register Process');
        else
            vcomp=pirelab.getWireComp(topNet,ctrlind,validout,'');
            vcomp.addComment('Output Valid Register Process');
        end
    else


        ctrlstart=topNet.addSignal(ufix1Type,'ctrlStart');
        ctrlend=topNet.addSignal(ufix1Type,'ctrlEnd');
        strtind_int=topNet.addSignal(ufix1Type,'strtind_int');
        strtind_rst=topNet.addSignal(ufix1Type,'startIndRst');

        startind=topNet.addSignal(ufix1Type,'startInd');
        pirelab.getLogicComp(topNet,int_strtvld,strtind_int,'not');
        pirelab.getLogicComp(topNet,[strtind_int,ctrlstart],strtind_rst,'and');
        scomp=pirelab.getUnitDelayEnabledResettableComp(topNet,const1reg,startind,endindrst,strtind_rst,'startInd_register',0,'',1);
        scomp.addComment('Indicates Start of Frame occurred');

        endind=topNet.addSignal(ufix1Type,'endInd');
        pirelab.getUnitDelayComp(topNet,sof_vldreg,endindrst,'',0);

        ecomp=pirelab.getUnitDelayEnabledResettableComp(topNet,eof_vldreg,endind,'',endindrst,'endInd_register',0,'',1);
        ecomp.addComment('Indicates End of Frame occurred');


        pirelab.getLogicComp(topNet,[ctrlind,endind],ctrlend,'and');

        pirelab.getLogicComp(topNet,[ctrlind,startind],ctrlstart,'and');

        scomp=pirelab.getWireComp(topNet,ctrlstart,startout,'StartOut');
        scomp.addComment('StartOut Register');
        ecomp=pirelab.getWireComp(topNet,ctrlend,endout,'EndOut');
        ecomp.addComment('EndOut Register');
        vcomp=pirelab.getWireComp(topNet,ctrlind,validout,'ctrlInd');
        vcomp.addComment('ValidOut Register');
    end
end