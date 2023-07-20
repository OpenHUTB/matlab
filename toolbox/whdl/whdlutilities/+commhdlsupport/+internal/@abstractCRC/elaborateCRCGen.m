function elaborateCRCGen(this,topNet,blockInfo,insignals,outsignals,isDetector)





    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;


    ufix1Type=pir_ufixpt_t(1,0);
    binvType=pirelab.getPirVectorType(ufix1Type,dlen);
    tpinfo=blockInfo.tpinfo;

    if tpinfo.isscalar&&dlen~=1
        dataType=pir_ufixpt_t(dlen,0);
    else
        dataType=binvType;
    end

    if(clen==dlen)
        cntval=2*clen/dlen-1;
    else
        cntval=clen/dlen-1;
    end
    cntWL=floor(log2(double(cntval)))+1;
    cntType=pir_ufixpt_t(cntWL,0);

    if(nargin<6)
        isDetector=false;
    end

    datain=insignals(1);
    sofin=insignals(2);
    eofin=insignals(3);
    validin=insignals(4);
    inRate=datain.SimulinkRate;

    dataout=outsignals(1);
    sofout=outsignals(2);
    eofout=outsignals(3);
    validout=outsignals(4);


    datainReg=topNet.addSignal(datain.Type,'datainReg');
    pirelab.getUnitDelayComp(topNet,datain,datainReg,'datainput_register',0);

    if tpinfo.isscalar&&dlen~=1
        datavinReg=topNet.addSignal(binvType,'datainBinVector');

        for i=1:dlen
            dv(i)=topNet.addSignal(ufix1Type,['datainBit',num2str(i)]);
            pirelab.getBitSliceComp(topNet,datainReg,dv(i),dlen-i,dlen-i);
        end
        pirelab.getMuxComp(topNet,dv,datavinReg);
    else
        datavinReg=datainReg;
    end



    ctype=sofin.Type;
    processMsg=topNet.addSignal(ctype,'processMsg');
    padZero=topNet.addSignal(ctype,'padZero');
    outputCRC=topNet.addSignal(ctype,'outputCRC');

    cntout=topNet.addSignal(cntType,'counter');
    tstartout=topNet.addSignal(ctype,'tstartout');
    tstartoutGated=topNet.addSignal(ctype,'tstartoutGated');
    lastfout=topNet.addSignal(ctype,'lastfout');
    validdata=topNet.addSignal(ctype,'validdata');

    regClr=topNet.addSignal(ctype,'regClr');

    ctlNet=this.elabCRCControl(topNet,blockInfo,inRate);
    ctlNet.addComment('CRC Generator Control Signals Generation');

    if(clen>dlen)
        cntout_opcrc=topNet.addSignal(cntType,'counter_opcrc');
        pirelab.instantiateNetwork(topNet,ctlNet,[sofin,eofin,validin],...
        [tstartout,processMsg,padZero,outputCRC,lastfout,validdata,regClr,cntout,cntout_opcrc],'Controlsignal_inst');
    else
        pirelab.instantiateNetwork(topNet,ctlNet,[sofin,eofin,validin],...
        [tstartout,processMsg,padZero,outputCRC,lastfout,validdata,regClr,cntout],'Controlsignal_inst');
    end




    crcType=pirelab.getPirVectorType(ctype,blockInfo.CRClen);
    crcchecksum=topNet.addSignal(crcType,'crcCheckSum');
    cptNet=this.elabCRCCompute(topNet,blockInfo,inRate);
    cptNet.addComment('Compute the CRC CheckSum');


    pirelab.instantiateNetwork(topNet,cptNet,[datavinReg,validin,processMsg,padZero,cntout,regClr],...
    crcchecksum,'ComputeCRC_inst');



    dataSreg=topNet.addSignal(binvType,'dataBuffer');


    delaynumber=round(clen/dlen);

    msgenb=topNet.addSignal(ctype,'msgenb');
    pirelab.getLogicComp(topNet,[processMsg,padZero],msgenb,'or');

    [~,clkEnb,~]=topNet.getClockBundle(datainReg,1,1,0);



    delayComp=pirelab.getIntDelayEnabledComp(topNet,datavinReg,dataSreg,[clkEnb,msgenb],...
    delaynumber,'',0,0);

    delayComp.addComment(' Buffer Input Data');

    msgcrc=topNet.addSignal(binvType,'msgcrc');

    if(clen==dlen)
        pirelab.getSwitchComp(topNet,[crcchecksum,dataSreg],msgcrc,outputCRC,'','~=',0);
    else
        crcout=topNet.addSignal(binvType,'crcOut');
        for i=1:delaynumber
            sidx=1+dlen*(i-1);
            eidx=dlen*i;
            idxarray={sidx:eidx};
            crcpkg(i)=topNet.addSignal(binvType,['crcp',num2str(i)]);%#ok<AGROW>
            scomp=pirelab.getSelectorComp(topNet,crcchecksum,crcpkg(i),'One-based',...
            {'Index vector (dialog)'},idxarray,{'1'},'1');
            scomp.addComment('Select CRC output bits');

        end

        pirelab.getMultiPortSwitchComp(topNet,[cntout_opcrc,crcpkg],crcout,1,1,'Floor','Wrap');
        pirelab.getSwitchComp(topNet,[crcout,dataSreg],msgcrc,outputCRC,'','~=',0);
    end

    const0=topNet.addSignal(binvType,'const0');
    ccomp=pirelab.getConstComp(topNet,const0,0);
    ccomp.addComment('Constant Zero');

    tdataout=topNet.addSignal(binvType,'tdataout');

    scomp=pirelab.getSwitchComp(topNet,[msgcrc,const0],tdataout,validdata,'','~=',0);
    scomp.addComment(' Output data and CRC CheckSum');

    if tpinfo.isscalar&&dlen~=1
        tdataout2=topNet.addSignal(dataType,'tdataoutInt');
        tdataoutSplit=tdataout.split;
        doutbits=[];
        for i=1:dlen
            doutbits=[doutbits,tdataoutSplit.PirOutputSignals(i)];
        end
        pirelab.getBitConcatComp(topNet,doutbits,tdataout2);
    else
        tdataout2=tdataout;
    end




    delayComp=pirelab.getIntDelayComp(topNet,tdataout2,dataout,1,'dataOut_register',0,0);
    delayComp.addComment('Data output register');

    pirelab.getLogicComp(topNet,[tstartout,validdata],tstartoutGated,'and');

    delayComp=pirelab.getIntDelayComp(topNet,tstartoutGated,sofout,1,'startOut_register',0,0);
    delayComp.addComment('startOut output register');
    delayComp=pirelab.getIntDelayComp(topNet,lastfout,eofout,1,'endout_register',0,0);
    delayComp.addComment('endOut output register');
    delayComp=pirelab.getIntDelayComp(topNet,validdata,validout,1,'validout_register',0,0);
    delayComp.addComment('validOut output register');

    if isDetector&&(clen>dlen)
        pirelab.getDTCComp(topNet,outputCRC,outsignals(5),'floor','Wrap');
    end
