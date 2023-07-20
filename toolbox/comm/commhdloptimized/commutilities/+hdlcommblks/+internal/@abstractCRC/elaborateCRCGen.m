function genNet=elaborateCRCGen(this,topNet,blockInfo,inRate,isDetector)









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


    if(nargin<5)
        isDetector=false;

    end


    if(isDetector)
        outportnames={'dataOut','startOut','endOut','validOut'};
        outporttypes=[dataType,ufix1Type,ufix1Type,ufix1Type];

        if(clen>dlen)
            outportnames=[outportnames,{'outputCRC'}];
            outporttypes=[outporttypes,ufix1Type];
        end

        genNet=pirelab.createNewNetwork(...
        'Network',topNet,...
        'Name','CRCGenerator',...
        'InportNames',{'dataIn','startIn','endIn','validIn'},...
        'InportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type],...
        'InportRates',[inRate,inRate,inRate,inRate],...
        'OutportNames',outportnames,...
        'OutportTypes',outporttypes...
        );
    else
        genNet=topNet;
        inRate=genNet.PirInputSignals(1).SimulinkRate;
    end



    datain=genNet.PirInputSignals(1);
    sofin=genNet.PirInputSignals(2);
    eofin=genNet.PirInputSignals(3);
    validin=genNet.PirInputSignals(4);

    dataout=genNet.PirOutputSignals(1);
    sofout=genNet.PirOutputSignals(2);
    eofout=genNet.PirOutputSignals(3);
    validout=genNet.PirOutputSignals(4);



    datainReg=genNet.addSignal(datain.Type,'datainReg');
    pirelab.getUnitDelayComp(genNet,datain,datainReg,'datainput_register',0);

    if tpinfo.isscalar&&dlen~=1
        datavinReg=genNet.addSignal(binvType,'datainBinVector');

        for i=1:dlen
            dv(i)=genNet.addSignal(ufix1Type,['datainBit',num2str(i)]);
            pirelab.getBitSliceComp(genNet,datainReg,dv(i),dlen-i,dlen-i);
        end
        pirelab.getMuxComp(genNet,dv,datavinReg);
    else
        datavinReg=datainReg;
    end

    ctype=sofin.Type;


    sof_vld=genNet.addSignal(ctype,'startIn_vld');
    eof_vld=genNet.addSignal(ctype,'endIn_vld');
    pirelab.getLogicComp(genNet,[sofin,validin],sof_vld,'and');
    pirelab.getLogicComp(genNet,[eofin,validin],eof_vld,'and');



    processMsg=genNet.addSignal(ctype,'processMsg');
    padZero=genNet.addSignal(ctype,'padZero');
    outputCRC=genNet.addSignal(ctype,'outputCRC');

    cntout=genNet.addSignal(cntType,'counter');
    tstartout=genNet.addSignal(ctype,'tstartout');
    lastfout=genNet.addSignal(ctype,'lastfout');
    validdata=genNet.addSignal(ctype,'validdata');

    ctlNet=this.elabCRCControl(genNet,blockInfo,inRate);
    ctlNet.addComment('CRC Generator Control Signals Generation');

    if(clen>dlen)

        cntout_opcrc=genNet.addSignal(cntType,'counter_opcrc');
        pirelab.instantiateNetwork(genNet,ctlNet,[sof_vld,eof_vld,validin],...
        [tstartout,processMsg,padZero,outputCRC,lastfout,validdata,cntout,cntout_opcrc],'Controlsignal_inst');
    else

        pirelab.instantiateNetwork(genNet,ctlNet,[sof_vld,eof_vld,validin],...
        [tstartout,processMsg,padZero,outputCRC,lastfout,validdata,cntout],'Controlsignal_inst');
    end





    crcType=pirelab.getPirVectorType(ctype,blockInfo.CRClen);
    crcchecksum=genNet.addSignal(crcType,'crcCheckSum');
    cptNet=this.elabCRCCompute(genNet,blockInfo,inRate);
    cptNet.addComment('Compute the CRC CheckSum');


    pirelab.instantiateNetwork(genNet,cptNet,[datavinReg,validin,processMsg,padZero,cntout],...
    crcchecksum,'ComputeCRC_inst');



    dataSreg=genNet.addSignal(binvType,'dataBuffer');


    delaynumber=round(clen/dlen);


    msgenb=genNet.addSignal(ctype,'msgenb');
    pirelab.getLogicComp(genNet,[processMsg,padZero],msgenb,'or');







    delayComp=pirelab.getIntDelayEnabledComp(genNet,datavinReg,dataSreg,msgenb,...
    delaynumber,'',0,0);
    delayComp.addComment(' Buffer Input Data');

    msgcrc=genNet.addSignal(binvType,'msgcrc');

    if(clen==dlen)
        pirelab.getSwitchComp(genNet,[crcchecksum,dataSreg],msgcrc,outputCRC,'','~=',0);
    else
        crcout=genNet.addSignal(binvType,'crcOut');
        for i=1:delaynumber
            sidx=1+dlen*(i-1);
            eidx=dlen*i;
            idxarray={sidx:eidx};
            crcpkg(i)=genNet.addSignal(binvType,['crcp',num2str(i)]);%#ok<AGROW>
            scomp=pirelab.getSelectorComp(genNet,crcchecksum,crcpkg(i),'One-based',...
            {'Index vector (dialog)'},idxarray,{'1'},'1');
            scomp.addComment('Select CRC output bits');

        end

        pirelab.getMultiPortSwitchComp(genNet,[cntout_opcrc,crcpkg],crcout,1,1,'Floor','Wrap');
        pirelab.getSwitchComp(genNet,[crcout,dataSreg],msgcrc,outputCRC,'','~=',0);
    end

    const0=genNet.addSignal(binvType,'const0');
    ccomp=pirelab.getConstComp(genNet,const0,0);
    ccomp.addComment('Constant Zero');

    tdataout=genNet.addSignal(binvType,'tdataout');

    scomp=pirelab.getSwitchComp(genNet,[msgcrc,const0],tdataout,validdata,'','~=',0);
    scomp.addComment(' Output data and CRC CheckSum');



    if tpinfo.isscalar&&dlen~=1
        tdataout2=genNet.addSignal(dataType,'tdataoutInt');
        tdataoutSplit=tdataout.split;
        doutbits=[];
        for i=1:dlen
            doutbits=[doutbits,tdataoutSplit.PirOutputSignals(i)];
        end
        pirelab.getBitConcatComp(genNet,doutbits,tdataout2);
    else
        tdataout2=tdataout;
    end




    delayComp=pirelab.getIntDelayComp(genNet,tdataout2,dataout,1,'dataOut_register',0,0);
    delayComp.addComment('Data output register');

    delayComp=pirelab.getIntDelayComp(genNet,tstartout,sofout,1,'startOut_register',0,0);
    delayComp.addComment('startOut output register');
    delayComp=pirelab.getIntDelayComp(genNet,lastfout,eofout,1,'endout_register',0,0);
    delayComp.addComment('endOut output register');
    delayComp=pirelab.getIntDelayComp(genNet,validdata,validout,1,'validout_register',0,0);
    delayComp.addComment('validOut output register');

    if isDetector&&(clen>dlen)
        pirelab.getDTCComp(genNet,outputCRC,genNet.PirOutputSignals(5),'floor','Wrap');
    end
