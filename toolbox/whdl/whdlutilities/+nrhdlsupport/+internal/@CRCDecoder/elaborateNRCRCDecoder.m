function elaborateNRCRCDecoder(this,topNet,blockInfo,insignals,outsignals)







    ufix1Type=pir_ufixpt_t(1,0);
    y=24/blockInfo.dlen;
    if blockInfo.Parallel&&blockInfo.Scalar
        ufixNType=pir_ufixpt_t(blockInfo.dlen,0);
        mType=pirelab.getPirVectorType(ufixNType,y);
    else
        mType=pirelab.getPirVectorType(ufix1Type,24);
    end


    datain=insignals(1);
    startin=insignals(2);
    endin=insignals(3);
    validin=insignals(4);
    inRate=datain.SimulinkRate;

    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    ratio=round(clen/dlen);

    dataType=datain.Type;
    ctrlType=startin.Type;
    ufixCRCType=pir_ufixpt_t(24,0);

    crcmask=topNet.addSignal(mType,'maskBits');

    if strcmpi(blockInfo.CRCType,'CRC24C')

        if blockInfo.EnableCRCMaskPort

            finxorval=insignals(5);
            maskType=finxorval.Type;


            sof_vld=topNet.addSignal(ctrlType,'startVld');
            pirelab.getLogicComp(topNet,[startin,validin],sof_vld,'and');
            mask=topNet.addSignal(maskType,'crcMask');
            pirelab.getUnitDelayEnabledComp(topNet,finxorval,mask,sof_vld,'Sampling of mask',0);


            i=0;
            for idx=24:-1:1
                i=i+1;
                maskbit(i)=topNet.addSignal(ufix1Type,['maskBit_',num2str(i)]);%#ok<*AGROW>
                pirelab.getBitSliceComp(topNet,mask,maskbit(i),idx-1,idx-1,'extract maskbits');
            end

            if blockInfo.Parallel&&blockInfo.Scalar
                for i=1:blockInfo.dlen:24
                    x=[];
                    for p=1:blockInfo.dlen
                        x=[x,maskbit(i+p-1)];
                    end
                    cmaskarr((i-1)/blockInfo.dlen+1)=topNet.addSignal(ufixNType,['cMaskArr_',num2str(idx)]);%#ok<*AGROW>
                    pirelab.getBitConcatComp(topNet,x,cmaskarr((i-1)/blockInfo.dlen+1),'bitConcat');
                end
                this.muxSignal(topNet,cmaskarr,crcmask);
            else
                this.muxSignal(topNet,maskbit,crcmask);
            end
        else
            pirelab.getConstComp(topNet,crcmask,0);
        end
    else
        pirelab.getConstComp(topNet,crcmask,0);
    end


    dataout=outsignals(1);
    startout=outsignals(2);
    endout=outsignals(3);
    validout=outsignals(4);
    errout=outsignals(5);

    booleanType=pir_boolean_t();
    if blockInfo.RNTIPort
        err=topNet.addSignal(ufixCRCType,'errOutWord');
    else
        err=topNet.addSignal(booleanType,'errOutBool');
    end

    datainff=topNet.addSignal(dataType,'dataInFF');
    startinff=topNet.addSignal(ctrlType,'startInFF');
    endinff=topNet.addSignal(ctrlType,'endInFF');
    validinff=topNet.addSignal(ctrlType,'validInFF');
    endinff_del=topNet.addSignal(ctrlType,'endInFFD');

    endoutff1=topNet.addSignal(ctrlType,'endoutff1');

    enable_crcbuffer=topNet.addSignal(ctrlType,'enCRCBuf');

    datainreg=topNet.addSignal(dataType,'dataInReg');
    startinreg=topNet.addSignal(ctrlType,'startInReg');
    startin_crcgen=topNet.addSignal(ctrlType,'startiInGen');
    zero_const=topNet.addSignal(dataType,'const0');
    datain_crcgen=topNet.addSignal(dataType,'dataInGen');
    crcreg=topNet.addSignal(dataType,'crcReg');
    crcreg_gated=topNet.addSignal(dataType,'crc_RegGated');
    crc_to_mask=topNet.addSignal(dataType,'crcToMask');


    dataoutgen=topNet.addSignal(dataType,'dataOutGen');
    startoutgen=topNet.addSignal(ctrlType,'startOutGen');
    endoutgen=topNet.addSignal(ctrlType,'endOutGen');
    validoutgen=topNet.addSignal(ctrlType,'validoutGen');

    dataoutgen_del=topNet.addSignal(dataType,'dataOutGenD');
    startoutgen_del=topNet.addSignal(ctrlType,'startOutGenD');
    startoutgen_gated=topNet.addSignal(ctrlType,'startOutGenGated');
    sel_muxdataout=topNet.addSignal(ctrlType,'muxDataOut');
    dataout_gated=topNet.addSignal(dataType,'dataOutGenGated');
    endoutt=topNet.addSignal(ctrlType,'endOutT');
    endoutdelay=topNet.addSignal(ctrlType,'endOutD');
    endout_n=topNet.addSignal(ctrlType,'endOutN');
    endout_state=topNet.addSignal(ctrlType,'endOutState');
    end_gateSR=topNet.addSignal(ctrlType,'endGateSR');
    end_nxt_state=topNet.addSignal(ctrlType,'endOutNxtState');
    rst_sr_n=topNet.addSignal(ctrlType,'local_rst_srcell_n');

    validouttmp=topNet.addSignal(ctrlType,'validoutTemp');
    endout_large=topNet.addSignal(ctrlType,'endOutLarge');
    endout_or1=topNet.addSignal(ctrlType,'endOutORLarge');
    enb_maskgen=topNet.addSignal(ctrlType,'enableMaskGen');


    pirelab.getIntDelayComp(topNet,datain,datainff,1,'datain ff',0);
    pirelab.getIntDelayComp(topNet,startin,startinff,1,'startin ff',0);
    pirelab.getIntDelayComp(topNet,endin,endinff,1,'endin ff',0);
    pirelab.getIntDelayComp(topNet,validin,validinff,1,'validin ff',0);


    pirelab.getIntDelayEnabledComp(topNet,datainff,datainreg,validinff,ratio,'dataInReg',0);
    pirelab.getIntDelayEnabledComp(topNet,startinff,startinreg,validinff,ratio,'startInReg',0);


    pirelab.getLogicComp(topNet,[validinff,startinreg],startin_crcgen,'and');
    pirelab.getConstComp(topNet,zero_const,0,'const','on',true);
    pirelab.getSwitchComp(topNet,[datainreg,zero_const],datain_crcgen,validinff,'mux_datain','>',0,'Floor','Wrap');


    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@CRCDecoder','cgireml','endinDelay.m'),'r');
    endinDelay=fread(fid,Inf,'char=>char');
    fclose(fid);

    endInDelayerComp=topNet.addComponent2(...
    'kind','cgireml',...
    'Name','endinDelay',...
    'InputSignals',endinff,...
    'OutputSignals',endinff_del,...
    'EMLFileName','endinDelay',...
    'EMLFileBody',endinDelay,...
    'EMLParams',{ratio},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false);
    endInDelayerComp.runConcurrencyMaximizer(0);

    pirelab.getLogicComp(topNet,[endinff_del,validinff],enable_crcbuffer,'or');

    pirelab.getIntDelayEnabledComp(topNet,datainff,crcreg,enable_crcbuffer,ratio,'crcReg',0);
    pirelab.getSwitchComp(topNet,[crcreg,zero_const],crcreg_gated,enable_crcbuffer,'mux_datain','>',0,'Floor','Wrap');


    pirelab.getIntDelayComp(topNet,crcreg_gated,crc_to_mask,ratio+2,'crcRegDEPTH2',0);


    genNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCGenerator',...
    'InportNames',{'dataIn','startIn','endIn','validIn'},...
    'InportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[inRate,inRate,inRate,inRate],...
    'OutportNames',{'dataOut','startOut','endOut','validout'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type]...
    );


    datain_gen=genNet.PirInputSignals(1);
    sofin_gen=genNet.PirInputSignals(2);
    eofin_gen=genNet.PirInputSignals(3);
    validin_gen=genNet.PirInputSignals(4);

    dataout_gen=genNet.PirOutputSignals(1);
    sofout_gen=genNet.PirOutputSignals(2);
    eofout_gen=genNet.PirOutputSignals(3);
    validout_gen=genNet.PirOutputSignals(4);

    insig=[datain_gen,sofin_gen,eofin_gen,validin_gen];
    outsig=[dataout_gen,sofout_gen,eofout_gen,validout_gen];


    this.elaborateCRCGen(genNet,blockInfo,insig,outsig,false);
    genoutports=[dataoutgen,startoutgen,endoutgen,validoutgen];
    ncomp=pirelab.instantiateNetwork(topNet,genNet,[datain_crcgen,startin_crcgen,endinff,validinff],...
    genoutports,'HDLCRCGen_inst');
    ncomp.addComment(' HDL CRC Generator');


    pirelab.getIntDelayEnabledComp(topNet,dataoutgen,dataoutgen_del,validoutgen,ratio,'dataOutReg',0);
    pirelab.getIntDelayEnabledComp(topNet,startoutgen,startoutgen_del,validoutgen,ratio,'startOutReg',0);
    pirelab.getLogicComp(topNet,[startoutgen_del,validoutgen],startoutgen_gated,'and');

    pirelab.getLogicComp(topNet,[validouttmp,validoutgen],sel_muxdataout,'and');
    pirelab.getSwitchComp(topNet,[dataoutgen_del,zero_const],dataout_gated,sel_muxdataout,'mux_dataout','>',0,'Floor','Wrap');


    pirelab.getLogicComp(topNet,[validouttmp,endoutgen],endoutt,'and');


    pirelab.getIntDelayComp(topNet,endoutgen,endoutdelay,1,'endRegSR',0);
    pirelab.getLogicComp(topNet,endoutdelay,endout_n,'not');
    pirelab.getLogicComp(topNet,[endout_n,endout_state],end_gateSR,'and');
    pirelab.getLogicComp(topNet,[startoutgen_gated,end_gateSR],end_nxt_state,'or');
    pirelab.getIntDelayEnabledResettableComp(topNet,end_nxt_state,endout_state,true,startoutgen,1,'SRcell',0,'');
    pirelab.getLogicComp(topNet,startoutgen,rst_sr_n,'not');
    pirelab.getLogicComp(topNet,[end_nxt_state,validoutgen,rst_sr_n],validouttmp,'and');


    pirelab.getIntDelayComp(topNet,endoutt,endout_large,1,'endout_largeFF',0);
    pirelab.getLogicComp(topNet,[endout_large,endoutt],endout_or1,'or');
    pirelab.getLogicComp(topNet,[endout_or1,validoutgen],enb_maskgen,'or');

    pirelab.getUnitDelayComp(topNet,endoutt,endoutff1,'endOu',0);

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@CRCDecoder','cgireml','crcCompare.m'),'r');
    crcCompare=fread(fid,Inf,'char=>char');
    fclose(fid);

    CRCComp=topNet.addComponent2(...
    'kind','cgireml',...
    'Name','crcCompare',...
    'InputSignals',[dataoutgen,crc_to_mask,enb_maskgen,startinff,endoutff1,crcmask],...
    'OutputSignals',err,...
    'EMLFileName','crcCompare',...
    'EMLFileBody',crcCompare,...
    'EMLParams',{blockInfo.CRClen,blockInfo.dlen,ratio,blockInfo.RNTIPort,blockInfo.CRCType,blockInfo.EnableCRCMaskPort},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false);
    CRCComp.runConcurrencyMaximizer(0);

    dataouttmp=topNet.addSignal(dataType,'dataOutTmp');

    pirelab.getIntDelayComp(topNet,startoutgen_gated,startout,2,'startOut',0);
    pirelab.getUnitDelayComp(topNet,endoutff1,endout,'endOut',0);
    pirelab.getIntDelayComp(topNet,validouttmp,validout,2,'validOut',0);
    pirelab.getIntDelayComp(topNet,dataout_gated,dataouttmp,2,'dataOut',0);
    pirelab.getUnitDelayComp(topNet,err,errout,'errOut',0);

    pirelab.getSwitchComp(topNet,[dataouttmp,zero_const],dataout,validout,'sel','~=',0,'Floor','Wrap');
end