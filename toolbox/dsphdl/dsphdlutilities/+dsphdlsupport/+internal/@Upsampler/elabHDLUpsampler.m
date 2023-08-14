function elabHDLUpsampler(this,hTopN,blockInfo,slRate)




    for loop=1:numel(hTopN.PirOutputSignals)
        hTopN.PirOutputSignals(loop).SimulinkRate=slRate;
    end
    for loop=1:numel(hTopN.PirInputSignals)
        hTopN.PirInputSignals(loop).SimulinkRate=slRate;
    end

    hTopNinSigs=hTopN.PirInputSignals;
    hTopNoutSigs=hTopN.PirOutputSignals;


    dataIn=hTopNinSigs(1);
    validIn=hTopNinSigs(2);
    validIn.SimulinkRate=slRate;


    dataOut=hTopNoutSigs(1);
    validOut=hTopNoutSigs(2);



    if blockInfo.inMode(2)&&~blockInfo.inResetSS
        softReset=hTopNinSigs(3);
        softReset.SimulinkRate=slRate;
    else
        softReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','softReset');
        softReset.SimulinkRate=slRate;
        if blockInfo.inResetSS

            softReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(hTopN,softReset,false);
        end
    end

    upsampleFact=blockInfo.UpsampleFactor;


    dataInreg=hTopN.addSignal(dataIn.Type,'dataInreg');
    dataInreg.SimulinkRate=slRate;
    validInreg=hTopN.addSignal(hTopNoutSigs(2).Type,'validInreg');
    pirelab.getIntDelayEnabledResettableComp(hTopN,dataIn,dataInreg,1,softReset,1);
    pirelab.getIntDelayEnabledResettableComp(hTopN,validIn,validInreg,1,softReset,1);

    internalReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','internalReset');
    pirelab.getWireComp(hTopN,softReset,internalReset);

    inS=blockInfo.issigned;
    inWL=blockInfo.dlen;
    inFL=blockInfo.flen;
    pVType=pir_fixpt_t(inS,inWL,inFL);

    if(blockInfo.NumCycles<blockInfo.UpsampleFactor&&...
        blockInfo.NumCycles~=1)&&blockInfo.vecsize==1
        outSize=blockInfo.R2;
    else
        outSize=blockInfo.R1;
    end

    vecFlag=(blockInfo.NumCycles<blockInfo.UpsampleFactor||blockInfo.vecsize>1);
    if vecFlag

        pVType1=pirelab.getPirVectorType(pVType,outSize);
        usOut_re=hTopN.addSignal(pVType1,'usOut_re');
        usOut_re.SimulinkRate=slRate;
        usOut_im=hTopN.addSignal(pVType1,'usOut_im');
        usOut_im.SimulinkRate=slRate;
        usOut1_re=hTopN.addSignal(pVType1,'usOut1_re');
        usOut1_re.SimulinkRate=slRate;
        usOut1_im=hTopN.addSignal(pVType1,'usOut1_im');
        usOut1_im.SimulinkRate=slRate;
    else

        usOut_re=hTopN.addSignal(pVType,'usOut_re');
        usOut_re.SimulinkRate=slRate;
        usOut_im=hTopN.addSignal(pVType,'usOut_im');
        usOut_im.SimulinkRate=slRate;
        usOut1_re=hTopN.addSignal(pVType,'usOut1_re');
        usOut1_re.SimulinkRate=slRate;
        usOut1_im=hTopN.addSignal(pVType,'usOut1_im');
        usOut1_im.SimulinkRate=slRate;
    end


    rdyout_re=hTopN.addSignal(pVType,'rdyout_re');
    rdyout_re.SimulinkRate=slRate;
    rdyout_im=hTopN.addSignal(pVType,'rdyout_im');
    rdyout_im.SimulinkRate=slRate;

    rdy_valid=hTopN.addSignal(hTopNoutSigs(2).Type,'rdy_valid');
    us_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'us_vout');
    us_vout.SimulinkRate=slRate;
    us_vout1=hTopN.addSignal(hTopNoutSigs(2).Type,'us_vout1');
    us_vout1.SimulinkRate=slRate;
    us_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'us_rstout');
    us_rstout.SimulinkRate=slRate;

    dataOutTmp=hTopN.addSignal(dataOut.Type,'dataOutTmp');
    dataOutTmp.SimulinkRate=slRate;

    if blockInfo.inMode(3)
        if blockInfo.inMode(2)
            softReset=hTopNinSigs(3);
        else
            softReset=hTopN.addSignal(pir_boolean_t,'softReset');
            pirelab.getConstComp(hTopN,softReset,false);
        end
        readyOut=hTopNoutSigs(3);

        cyclesFlag=blockInfo.NumCycles;
        vecSize=blockInfo.vecsize;
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
        '+dsphdlsupport','+internal','@Upsampler','cgireml','readyLogic.m'),'r');
        readyLogic=fread(fid,Inf,'char=>char');
        fclose(fid);
        hTopN.addComponent2(...
        'kind','cgireml',...
        'Name','readyLogic',...
        'InputSignals',[validIn,softReset],...
        'OutputSignals',readyOut,...
        'EMLFileName','readyLogic',...
        'EMLFileBody',readyLogic,...
        'EmlParams',{upsampleFact,cyclesFlag,vecSize},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end

    if blockInfo.UpsampleFactor==1
        pirelab.getWireComp(hTopN,dataInreg,dataOutTmp);
        pirelab.getWireComp(hTopN,validInreg,us_vout);
    elseif(blockInfo.NumCycles==1||blockInfo.vecsize>1)
        if~(blockInfo.vecsize==1)
            for i=1:blockInfo.vecsize
                dataInreg_cast(i)=hTopN.addSignal2('Type',...
                pir_complex_t(pVType),'Name','dataInreg_cast');%#ok<*AGROW>
                dataInreg_cast(i).SimulinkRate=slRate;
                din_re(i)=hTopN.addSignal(pVType,'din_re');
                din_re(i).SimulinkRate=slRate;
                din_im(i)=hTopN.addSignal(pVType,'din_im');
                din_im(i).SimulinkRate=slRate;
                rdyInreg_re(i)=hTopN.addSignal(pVType,'rdyInreg_re');
                rdyInreg_re(i).SimulinkRate=slRate;
                rdyInreg_im(i)=hTopN.addSignal(pVType,'rdyInreg_im');
                rdyInreg_im(i).SimulinkRate=slRate;
                pirelab.getDTCComp(hTopN,dataInreg.split.PirOutputSignals(i),...
                dataInreg_cast(i));
                pirelab.getComplex2RealImag(hTopN,dataInreg_cast(i),[din_re(i),...
                din_im(i)],'real and img');
                pirelab.getDTCComp(hTopN,din_re(i),rdyInreg_re(i),'Floor','Wrap');
                pirelab.getDTCComp(hTopN,din_im(i),rdyInreg_im(i),'Floor','Wrap');
            end
            pVType2=pirelab.getPirVectorType(pVType,blockInfo.vecsize);
            rdyIn_re=hTopN.addSignal(pVType2,'rdyIn_re');
            rdyIn_re.SimulinkRate=slRate;
            rdyIn_im=hTopN.addSignal(pVType2,'rdyIn_im');
            rdyIn_im.SimulinkRate=slRate;
            pirelab.getMuxComp(hTopN,rdyInreg_re,rdyIn_re);
            pirelab.getMuxComp(hTopN,rdyInreg_im,rdyIn_im);
        else
            dataInreg_cast=hTopN.addSignal2('Type',pir_complex_t(pVType),...
            'Name','dataInreg_cast');%#ok<*AGROW>
            dataInreg_cast.SimulinkRate=slRate;
            din_re=hTopN.addSignal(pVType,'din_re');
            din_re.SimulinkRate=slRate;
            din_im=hTopN.addSignal(pVType,'din_im');
            din_im.SimulinkRate=slRate;
            rdyIn_re=hTopN.addSignal(pVType,'rdyIn_re');
            rdyIn_re.SimulinkRate=slRate;
            rdyIn_im=hTopN.addSignal(pVType,'rdyIn_im');
            rdyIn_im.SimulinkRate=slRate;
            pirelab.getDTCComp(hTopN,dataInreg,dataInreg_cast);
            pirelab.getComplex2RealImag(hTopN,dataInreg_cast,[din_re,din_im],...
            'real and img');
            pirelab.getDTCComp(hTopN,din_re,rdyIn_re,'Floor','Wrap');
            pirelab.getDTCComp(hTopN,din_im,rdyIn_im,'Floor','Wrap');
        end

        usSection=this.elabVectUpsampler(hTopN,blockInfo,slRate,rdyIn_re,...
        rdyIn_im,validInreg,...
        internalReset,usOut1_re,usOut1_im,us_vout1);
        pirelab.instantiateNetwork(hTopN,usSection,[rdyIn_re,rdyIn_im,validInreg,...
        internalReset],[usOut1_re,usOut1_im,us_vout1],'usSection');
    else

        rdySection=this.elabReadyLogic(hTopN,blockInfo,slRate,dataInreg,...
        validInreg,internalReset,rdyout_re,rdyout_im,rdy_valid);
        pirelab.instantiateNetwork(hTopN,rdySection,[dataInreg,validInreg,...
        internalReset],[rdyout_re,rdyout_im,rdy_valid],'rdySection');
        if blockInfo.NumCycles<blockInfo.UpsampleFactor

            usSection=this.elabVectUpsampler(hTopN,blockInfo,slRate,rdyout_re,...
            rdyout_im,rdy_valid,internalReset,usOut1_re,usOut1_im,us_vout1);
            pirelab.instantiateNetwork(hTopN,usSection,[rdyout_re,rdyout_im,rdy_valid,...
            internalReset],[usOut1_re,usOut1_im,us_vout1],'usSection');
        else

            usSection=this.elabUpsampler(hTopN,blockInfo,slRate,rdyout_re,...
            rdyout_im,rdy_valid,internalReset,usOut1_re,usOut1_im,us_vout1);
            pirelab.instantiateNetwork(hTopN,usSection,[rdyout_re,rdyout_im,...
            rdy_valid,internalReset],[usOut1_re,usOut1_im,us_vout1],'usSection');
        end
    end


    if blockInfo.vecsize==1

        bSection=this.elabBuffer(hTopN,blockInfo,slRate,usOut1_re,...
        usOut1_im,us_vout1,internalReset,usOut_re,usOut_im,us_vout);
        pirelab.instantiateNetwork(hTopN,bSection,[usOut1_re,usOut1_im,...
        us_vout1,internalReset],[usOut_re,usOut_im,us_vout],'bSection');
    else
        pirelab.getWireComp(hTopN,usOut1_re,usOut_re);
        pirelab.getWireComp(hTopN,usOut1_im,usOut_im);
        pirelab.getWireComp(hTopN,us_vout1,us_vout);
    end


    if blockInfo.InputDataIsReal
        pirelab.getWireComp(hTopN,usOut_re,dataOutTmp);
    else
        pirelab.getRealImag2Complex(hTopN,[usOut_re,usOut_im],dataOutTmp);
    end


    invalidOut=hTopN.addSignal(dataOut.Type,'invalidOut');
    invalidOut.SimulinkRate=slRate;

    pirelab.getConstComp(hTopN,invalidOut,0,'invalidOut');
    pirelab.getWireComp(hTopN,us_vout,validOut);
    pirelab.getSwitchComp(hTopN,[dataOutTmp,invalidOut],dataOut,validOut,...
    '','==',1);
end