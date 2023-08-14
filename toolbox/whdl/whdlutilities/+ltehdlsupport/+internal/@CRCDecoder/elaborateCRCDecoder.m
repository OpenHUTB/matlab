function elaborateCRCDecoder(this,topNet,blockInfo,insignals,outsignals)







    ufix1Type=pir_ufixpt_t(1,0);



    datain=insignals(1);
    startin=insignals(2);
    endin=insignals(3);
    validin=insignals(4);
    inRate=datain.SimulinkRate;


    dataOutff=outsignals(1);
    startOutff=outsignals(2);
    endOutff2=outsignals(3);
    validOutff=outsignals(4);
    errOut=outsignals(5);

    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    ratio=round(clen/dlen);

    dataType=datain.Type;
    ctlType=startin.Type;
    sigInfo.dataType=dataType;

    ufixCRCType=pir_ufixpt_t(clen,0);
    booleanType=pir_boolean_t();
    err_word=topNet.addSignal(ufixCRCType,'errout_word');
    err_bool=topNet.addSignal(booleanType,'errout_bool');

    datainff=topNet.addSignal(dataType,'datain_ff');
    startinff=topNet.addSignal(ctlType,'startin_ff');
    endinff=topNet.addSignal(ctlType,'endin_ff');
    validinff=topNet.addSignal(ctlType,'validin_ff');
    endinff_del=topNet.addSignal(ctlType,'endin_ffdel');

    endOutff1=topNet.addSignal(ctlType,'endout_ff1');

    enable_crcbuffer=topNet.addSignal(ctlType,'enCRCBuf');

    datainreg=topNet.addSignal(dataType,'datain_reg');
    startinreg=topNet.addSignal(ctlType,'startin_reg');
    startin_crcgen=topNet.addSignal(ctlType,'startin_crcgen');
    zero_const=topNet.addSignal(dataType,'constant');
    datain_crcgen=topNet.addSignal(dataType,'datain_crcgen');
    crcreg=topNet.addSignal(dataType,'crc_reg');
    crcreg_gated=topNet.addSignal(dataType,'crc_reg_gated');
    crc_to_mask=topNet.addSignal(dataType,'crc_to_mask');


    dataoutgen=topNet.addSignal(dataType,'dataoutgen');
    startoutgen=topNet.addSignal(ctlType,'startoutgen');
    endoutgen=topNet.addSignal(ctlType,'endoutgen');
    validoutgen=topNet.addSignal(ctlType,'validoutgen');

    dataoutgen_del=topNet.addSignal(dataType,'dataoutgen_del');
    startoutgen_del=topNet.addSignal(ctlType,'startout_del');
    startoutgen_gated=topNet.addSignal(ctlType,'startoutgen_gated');

    sel_muxdataout=topNet.addSignal(ctlType,'sel_dataoutmux');
    dataout_gated=topNet.addSignal(dataType,'dataoutgen_gated');
    endOut=topNet.addSignal(ctlType,'endOut');
    endoutdelay=topNet.addSignal(ctlType,'endOutdelay');
    endout_n=topNet.addSignal(ctlType,'endOut_n');
    endout_state=topNet.addSignal(ctlType,'endOut_state');
    end_gateSR=topNet.addSignal(ctlType,'endgate_sr');
    end_nxt_state=topNet.addSignal(ctlType,'endOut_nxt_state');
    rst_sr_n=topNet.addSignal(ctlType,'local_rst_srcell_n');

    validOut=topNet.addSignal(ctlType,'validOutTemp');
    endout_large=topNet.addSignal(ctlType,'endout_large');
    endOut_or1=topNet.addSignal(ctlType,'endout_orlarge');
    en_maskgen=topNet.addSignal(ctlType,'enable_maskgen');









    pirelab.getIntDelayComp(topNet,datain,datainff,1,'datain_ff',0);
    pirelab.getIntDelayComp(topNet,startin,startinff,1,'startin_ff',0);
    pirelab.getIntDelayComp(topNet,endin,endinff,1,'endin_ff',0);
    pirelab.getIntDelayComp(topNet,validin,validinff,1,'validin_ff',0);



    pirelab.getIntDelayEnabledComp(topNet,datainff,datainreg,validinff,ratio,'dataInReg',0);


    pirelab.getIntDelayEnabledComp(topNet,startinff,startinreg,validinff,ratio,'startInReg',0);


    pirelab.getLogicComp(topNet,[validinff,startinreg],startin_crcgen,'and');
    pirelab.getConstComp(topNet,zero_const,0,'const','on',true);
    pirelab.getSwitchComp(topNet,[datainreg,zero_const],datain_crcgen,validinff,'mux_datain','>',0,'Floor','Wrap');


    endInNet=this.elaborateEndIn(topNet,blockInfo,inRate);
    pirelab.instantiateNetwork(topNet,endInNet,endinff,endinff_del,'endInEntity');


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
    'OutportNames',{'dataOut','startOut','endOut','validOut'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type]...
    );


    datain=genNet.PirInputSignals(1);
    sofin=genNet.PirInputSignals(2);
    eofin=genNet.PirInputSignals(3);
    validin=genNet.PirInputSignals(4);

    dataout=genNet.PirOutputSignals(1);
    sofout=genNet.PirOutputSignals(2);
    eofout=genNet.PirOutputSignals(3);
    validout=genNet.PirOutputSignals(4);

    insig=[datain,sofin,eofin,validin];
    outsig=[dataout,sofout,eofout,validout];






    this.elaborateCRCGen(genNet,blockInfo,insig,outsig,false);
    genoutports=[dataoutgen,startoutgen,endoutgen,validoutgen];
    ncomp=pirelab.instantiateNetwork(topNet,genNet,[datain_crcgen,startin_crcgen,endinff,validinff],...
    genoutports,'HDLCRCGen_inst');
    ncomp.addComment(' HDL CRC Generator');



    pirelab.getIntDelayEnabledComp(topNet,dataoutgen,dataoutgen_del,validoutgen,ratio,'dataOutReg',0);


    pirelab.getIntDelayEnabledComp(topNet,startoutgen,startoutgen_del,validoutgen,ratio,'startOutReg',0);
    pirelab.getLogicComp(topNet,[startoutgen_del,validoutgen],startoutgen_gated,'and');

    pirelab.getLogicComp(topNet,[validOut,validoutgen],sel_muxdataout,'and');
    pirelab.getSwitchComp(topNet,[dataoutgen_del,zero_const],dataout_gated,sel_muxdataout,'mux_dataout','>',0,'Floor','Wrap');


    pirelab.getLogicComp(topNet,[validOut,endoutgen],endOut,'and');



    pirelab.getIntDelayComp(topNet,endoutgen,endoutdelay,1,'endRegSR',0);
    pirelab.getLogicComp(topNet,endoutdelay,endout_n,'not');
    pirelab.getLogicComp(topNet,[endout_n,endout_state],end_gateSR,'and');
    pirelab.getLogicComp(topNet,[startoutgen_gated,end_gateSR],end_nxt_state,'or');
    pirelab.getIntDelayEnabledResettableComp(topNet,end_nxt_state,endout_state,true,startoutgen,1,'SRcell',0,'');
    pirelab.getLogicComp(topNet,startoutgen,rst_sr_n,'not');
    pirelab.getLogicComp(topNet,[end_nxt_state,validoutgen,rst_sr_n],validOut,'and');



    pirelab.getIntDelayComp(topNet,endOut,endout_large,1,'endout_largeFF',0);
    pirelab.getLogicComp(topNet,[endout_large,endOut],endOut_or1,'or');
    pirelab.getLogicComp(topNet,[endOut_or1,validoutgen],en_maskgen,'or');



    inputMAT=[dataoutgen,crc_to_mask,en_maskgen,startinff,endOutff1];


    crcCompNet=this.elaborateErr(topNet,blockInfo,sigInfo,inRate);

    if blockInfo.RNTIPort
        pirelab.instantiateNetwork(topNet,crcCompNet,inputMAT,err_word,'ErrPortEntity');
    else
        pirelab.instantiateNetwork(topNet,crcCompNet,inputMAT,err_bool,'ErrPortEntity');
    end


    pirelab.getIntDelayComp(topNet,startoutgen_gated,startOutff,2,'startOut_2del',0);
    pirelab.getUnitDelayComp(topNet,endOut,endOutff1,'endOut_1del1',0);
    pirelab.getUnitDelayComp(topNet,endOutff1,endOutff2,'endOut_1del2',0);
    pirelab.getIntDelayComp(topNet,validOut,validOutff,2,'validOut_2del',0);
    pirelab.getIntDelayComp(topNet,dataout_gated,dataOutff,2,'dataOut_2del',0);

    if blockInfo.RNTIPort
        pirelab.getUnitDelayComp(topNet,err_word,errOut,'errOut_1del',0);
    else
        pirelab.getUnitDelayComp(topNet,err_bool,errOut,'errOut_1del',0);
    end













end