function elaborateCRCDetNetwork(this,topNet,blockInfo)









    insignals=topNet.PirInputSignals;
    datain=insignals(1);
    startin=insignals(2);
    endin=insignals(3);
    validin=insignals(4);
    inRate=datain.SimulinkRate;


    outsignals=topNet.PirOutputSignals;

    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    ratio=round(clen/dlen);
    if hdlissignalvector(datain)
        invecsize=dlen;
    else
        invecsize=1;
    end
    dataType=datain.Type;
    ctlType=startin.Type;
    if invecsize==1
        baseDataType=dataType;
    else
        baseDataType=dataType.BaseType;
    end
    vecDataType=pirelab.getPirVectorType(baseDataType,ratio);


    startinreg=topNet.addSignal(ctlType,'startinreg');
    validinreg=topNet.addSignal(ctlType,'validinreg');

    dataoutgen=topNet.addSignal(dataType,'dataoutgen');
    startoutgen=topNet.addSignal(ctlType,'startoutgen');
    endoutgen=topNet.addSignal(ctlType,'endoutgen');
    validoutgen=topNet.addSignal(ctlType,'validoutgen');


    startvalid=topNet.addSignal(ctlType,'start_valid');
    endvalid=topNet.addSignal(ctlType,'end_valid');
    pirelab.getLogicComp(topNet,[startin,validin],startvalid,'and');
    pirelab.getLogicComp(topNet,[endin,validin],endvalid,'and');











    if invecsize==1
        datain_sigs=datain;
    else
        datain_sigs=datain.split.PirOutputSignals;
    end


    for ii=1:invecsize
        datain_tapreg(ii)=topNet.addSignal(vecDataType,['datain_tapreg_',num2str(ii)]);%#ok<AGROW>
        pirelab.getTapDelayEnabledResettableComp(topNet,datain_sigs(ii),datain_tapreg(ii),validin,endvalid,ratio,['datain_tapregister',num2str(ii)],0);
        if ratio==1
            datain_tapreg_sigs(ii,:)=datain_tapreg(ii);%#ok<AGROW>
        else
            datain_tapreg_sigs(ii,:)=datain_tapreg(ii).split.PirOutputSignals;%#ok<AGROW>
        end
        datainreg_sigs(ii)=datain_tapreg_sigs(ii,1);%#ok<AGROW> % oldest value
    end
    if invecsize==1
        datainreg=datainreg_sigs;
    else
        datainreg=topNet.addSignal(dataType,'datainreg');
        pirelab.getMuxComp(topNet,datainreg_sigs,datainreg);
    end


    pirelab.getIntDelayEnabledResettableComp(topNet,startvalid,startinreg,validin,endvalid,ratio,'startin_register',0);


    pirelab.getIntDelayEnabledResettableComp(topNet,validin,validinreg,validin,endvalid,ratio,'validin_register',0);



    bufferenb=topNet.addSignal(ctlType,'csumbufferenb');
    csumenb=topNet.addSignal(ctlType,'csumenb');

    pirelab.getLogicComp(topNet,[bufferenb,validin],csumenb,'or');










    for ii=1:invecsize
        csum_tapreg(ii)=topNet.addSignal(vecDataType,['csum_tapreg_',num2str(ii)]);%#ok<AGROW>
        if ratio==1
            csum_tapreg_sigs(ii,:)=csum_tapreg(ii);%#ok<AGROW>
        else
            csum_tapreg_sigs(ii,:)=csum_tapreg(ii).split.PirOutputSignals;%#ok<AGROW>
        end
        csumreg_datain(ii)=topNet.addSignal(vecDataType,'csum_datain');%#ok<AGROW>
        pirelab.getMuxComp(topNet,[csum_tapreg_sigs(ii,2:end),datain_sigs(ii)],csumreg_datain(ii));
        csumreg_sigs(ii)=csum_tapreg_sigs(ii,1);%#ok<AGROW>
    end


    if invecsize==1
        csumreg=csumreg_sigs;
    else
        csumreg=topNet.addSignal(dataType,'csumreg');
        pirelab.getMuxComp(topNet,csumreg_sigs,csumreg);
    end




    for ii=1:invecsize
        msg_datain(ii)=topNet.addSignal(vecDataType,['msg_datain_',num2str(ii)]);%#ok<AGROW>
        pirelab.getMuxComp(topNet,[datain_tapreg_sigs(ii,2:end),datain_sigs(ii)],msg_datain(ii));
    end



    csumreg_enb=topNet.addSignal(ctlType,'csumreg_enb');
    pirelab.getLogicComp(topNet,[csumenb,endvalid],csumreg_enb,'or');









    for ii=1:invecsize
        csumreg_in(ii)=topNet.addSignal(vecDataType,['csumreg_in_',num2str(ii)]);%#ok<AGROW>

        pirelab.getSwitchComp(topNet,[csumreg_datain(ii),msg_datain(ii)],csumreg_in(ii),endvalid);

        pirelab.getIntDelayEnabledComp(topNet,csumreg_in(ii),csum_tapreg(ii),csumreg_enb,1);
    end



    startin_gen=topNet.addSignal(ctlType,'startin_gen');
    validin_gen=topNet.addSignal(ctlType,'validin_gen');
    pirelab.getLogicComp(topNet,[startinreg,validin],startin_gen,'and');
    pirelab.getLogicComp(topNet,[validinreg,validin],validin_gen,'and');


    geninports=[datainreg,startin_gen,endvalid,validin_gen];
    genoutports=[dataoutgen,startoutgen,endoutgen,validoutgen];

    cmpinports=[csumreg,endvalid,dataoutgen,startoutgen,endoutgen,validoutgen];
    cmpoutports=[outsignals.',bufferenb];

    if ratio>1
        outputcrc=topNet.addSignal(ctlType,'outputcrc');
        genoutports=[genoutports,outputcrc];
        cmpinports=[cmpinports,outputcrc];
    end

    genNet=this.elaborateCRCGen(topNet,blockInfo,inRate,true);


    ncomp=pirelab.instantiateNetwork(topNet,genNet,geninports,...
    genoutports,'HDLCRCGen_inst');
    ncomp.addComment(' HDL CRC Generator');




    cmpNet=this.elabCRCCompare(topNet,blockInfo,inRate);

    ncomp=pirelab.instantiateNetwork(topNet,cmpNet,cmpinports,cmpoutports,'ChecksumCompare_inst');
    ncomp.addComment(' Checksum Comparison');

end
