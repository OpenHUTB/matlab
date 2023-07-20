function elabHDLCICDecimation(this,hTopN,blockInfo,slRate)





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
    if blockInfo.inMode(2)
        R=hTopNinSigs(3);
        R.SimulinkRate=slRate;
    end


    dataOut=hTopNoutSigs(1);
    validOut=hTopNoutSigs(2);



    if blockInfo.inMode(2)&&~blockInfo.inResetSS&&blockInfo.inMode(3)
        softReset=hTopNinSigs(4);
        softReset.SimulinkRate=slRate;
    elseif~blockInfo.inMode(2)&&~blockInfo.inResetSS&&blockInfo.inMode(3)
        softReset=hTopNinSigs(3);
        softReset.SimulinkRate=slRate;
    else
        softReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','softReset');
        softReset.SimulinkRate=slRate;
        if blockInfo.inResetSS

            softReset.setSynthResetInsideResetSS;

            blockInfo.inMode(3)=true;
        else


            pirelab.getConstComp(hTopN,softReset,false);
        end
    end


    dataInreg=hTopN.addSignal(dataIn.Type,'dataInreg');
    dataInreg.SimulinkRate=slRate;
    validInreg=hTopN.addSignal(hTopNoutSigs(2).Type,'validInreg');


    maxDecimFact=blockInfo.DecimationFactor;
    if blockInfo.inMode(2)
        vReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','vReset');
        softResetreg=hTopN.addSignal2('Type',pir_boolean_t,'Name','softResetreg');
        downsampleIn=hTopN.addSignal(R.Type,'downsampleIn');
        downsampleVal=hTopN.addSignal(R.Type,'downsampleVal');
        pirelab.getWireComp(hTopN,R,downsampleIn);

        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICDecimator','cgireml','calcDownSampleFactor.m'),'r');
        calcDownSampleFactor=fread(fid,Inf,'char=>char');
        fclose(fid);
        hTopN.addComponent2(...
        'kind','cgireml',...
        'Name','calcDownSampleFactor',...
        'InputSignals',[downsampleIn,validIn],...
        'OutputSignals',[downsampleVal,vReset],...
        'ExternalSynchronousResetSignal',softReset,...
        'EMLFileName','calcDownSampleFactor',...
        'EMLFileBody',calcDownSampleFactor,...
        'EmlParams',{maxDecimFact},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
        internalReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','internalReset');
        pirelab.getWireComp(hTopN,softReset,softResetreg);
        pirelab.getLogicComp(hTopN,[softResetreg,vReset],internalReset,'or');

        pirelab.getIntDelayEnabledResettableComp(hTopN,dataIn,dataInreg,1,softResetreg,2);
        pirelab.getIntDelayEnabledResettableComp(hTopN,validIn,validInreg,1,softResetreg,2);
    else
        downsampleVal=hTopN.addSignal(pir_ufixpt_t(12,0),'downsampleVal');
        softResetreg=hTopN.addSignal2('Type',pir_boolean_t,'Name','softResetreg');
        pirelab.getConstComp(hTopN,downsampleVal,blockInfo.DecimationFactor);
        internalReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','internalReset');
        pirelab.getWireComp(hTopN,softReset,softResetreg);
        pirelab.getWireComp(hTopN,softResetreg,internalReset);
        pirelab.getIntDelayEnabledResettableComp(hTopN,dataIn,dataInreg,1,softResetreg,1);
        pirelab.getIntDelayEnabledResettableComp(hTopN,validIn,validInreg,1,softResetreg,1);
    end

    ioutWL=blockInfo.stageDT{blockInfo.NumSections}.WordLength;
    ioutFL=blockInfo.stageDT{blockInfo.NumSections}.FractionLength;
    coutWL=blockInfo.stageDT{2*blockInfo.NumSections}.WordLength;
    coutFL=blockInfo.stageDT{2*blockInfo.NumSections}.FractionLength;

    if blockInfo.vecsize==1


        integOut_re=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'integOut_re');
        integOut_re.SimulinkRate=slRate;
        integOut_im=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'integOut_im');
        integOut_im.SimulinkRate=slRate;



        dsOut_re=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'dsOut_re');
        dsOut_re.SimulinkRate=slRate;
        dsOut_im=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'dsOut_im');
        dsOut_im.SimulinkRate=slRate;



        combOut_re=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'combOut_re');
        combOut_re.SimulinkRate=slRate;
        combOut_im=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'combOut_im');
        combOut_im.SimulinkRate=slRate;

    else


        pVType=pirelab.getPirVectorType(pir_sfixpt_t(ioutWL,ioutFL),blockInfo.vecsize);
        integOut_re=hTopN.addSignal(pVType,'integOut_re');
        integOut_re.SimulinkRate=slRate;
        integOut_im=hTopN.addSignal(pVType,'integOut_im');
        integOut_im.SimulinkRate=slRate;

        if blockInfo.vecsize<=blockInfo.DecimationFactor


            dsOut_re=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'dsOut_re');
            dsOut_re.SimulinkRate=slRate;
            dsOut_im=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'dsOut_im');
            dsOut_im.SimulinkRate=slRate;



            combOut_re=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'combOut_re');
            combOut_re.SimulinkRate=slRate;
            combOut_im=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'combOut_im');
            combOut_im.SimulinkRate=slRate;

        else



            pVType1=pirelab.getPirVectorType(pir_sfixpt_t(ioutWL,ioutFL),blockInfo.numcombinputs);
            dsOut_re=hTopN.addSignal(pVType1,'dsOut_re');
            dsOut_re.SimulinkRate=slRate;
            dsOut_im=hTopN.addSignal(pVType1,'dsOut_im');
            dsOut_im.SimulinkRate=slRate;



            pVType2=pirelab.getPirVectorType(pir_sfixpt_t(coutWL,coutFL),blockInfo.numcombinputs);
            combOut_re=hTopN.addSignal(pVType2,'combOut_re');
            combOut_re.SimulinkRate=slRate;
            combOut_im=hTopN.addSignal(pVType2,'combOut_im');
            combOut_im.SimulinkRate=slRate;
        end
    end


    i_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'i_vout');
    i_vout.SimulinkRate=slRate;
    i_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'i_rstout');
    i_rstout.SimulinkRate=slRate;
    ds_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'ds_vout');
    ds_vout.SimulinkRate=slRate;
    ds_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'ds_rstout');
    ds_rstout.SimulinkRate=slRate;
    c_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'c_vout');
    c_vout.SimulinkRate=slRate;
    c_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'c_rstout');
    c_rstout.SimulinkRate=slRate;
    gc_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'gc_rstout');
    gc_rstout.SimulinkRate=slRate;




    gC=blockInfo.GainCorrection;
    gDT=blockInfo.gDT;
    if blockInfo.vecsize==1||blockInfo.vecsize<=blockInfo.DecimationFactor
        if gC
            gcOut_re=hTopN.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        else
            gcOut_re=hTopN.addSignal(pir_sfixpt_t(combOut_re.Type.WordLength,...
            combOut_re.Type.FractionLength),'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pir_sfixpt_t(combOut_im.Type.WordLength,...
            combOut_re.Type.FractionLength),'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        end
    else
        if gC
            pVType3=pirelab.getPirVectorType(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),blockInfo.numcombinputs);
            gcOut_re=hTopN.addSignal(pVType3,'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pVType3,'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        else
            pVType4=pirelab.getPirVectorType(pir_sfixpt_t(combOut_re.Type.BaseType.WordLength,combOut_re.Type.BaseType.FractionLength),blockInfo.numcombinputs);
            gcOut_re=hTopN.addSignal(pVType4,'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pVType4,'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        end
    end
    if blockInfo.vecsize==1

        iSection=this.elabIntegrator(hTopN,blockInfo,slRate,dataInreg,validInreg,...
        internalReset,integOut_re,integOut_im);
        pirelab.instantiateNetwork(hTopN,iSection,[dataInreg,validInreg,...
        internalReset],[integOut_re,integOut_im],'iSection');


        dsSection=this.elabDownsampler(hTopN,blockInfo,slRate,integOut_re,integOut_im,...
        validInreg,downsampleVal,internalReset,dsOut_re,dsOut_im,ds_vout);
        pirelab.instantiateNetwork(hTopN,dsSection,[integOut_re,integOut_im,validInreg,...
        downsampleVal,internalReset],[dsOut_re,dsOut_im,ds_vout],'dsSection');


        cSection=this.elabComb(hTopN,blockInfo,slRate,dsOut_re,dsOut_im,...
        ds_vout,internalReset,combOut_re,combOut_im,c_vout);
        pirelab.instantiateNetwork(hTopN,cSection,[dsOut_re,dsOut_im,ds_vout,...
        internalReset],[combOut_re,combOut_im,c_vout],'cSection');


        gcSection=this.elabGaincorrection(hTopN,blockInfo,slRate,combOut_re,...
        combOut_im,downsampleVal,internalReset,gcOut_re,gcOut_im);
        pirelab.instantiateNetwork(hTopN,gcSection,[combOut_re,combOut_im,...
        downsampleVal,internalReset],[gcOut_re,gcOut_im],'gcSection');

    else

        iSection=this.elabVectIntegrator(hTopN,blockInfo,slRate,dataInreg,validInreg,...
        internalReset,integOut_re,integOut_im,i_vout,i_rstout);
        pirelab.instantiateNetwork(hTopN,iSection,[dataInreg,validInreg,...
        internalReset],[integOut_re,integOut_im,i_vout,i_rstout],'iSection');


        dsSection=this.elabVectDownsampler(hTopN,blockInfo,slRate,integOut_re,integOut_im,...
        i_vout,i_rstout,dsOut_re,dsOut_im,ds_vout);
        pirelab.instantiateNetwork(hTopN,dsSection,[integOut_re,integOut_im,i_vout,...
        i_rstout],[dsOut_re,dsOut_im,ds_vout],'dsSection');
        if~blockInfo.vecFlag

            cSection=this.elabComb(hTopN,blockInfo,slRate,dsOut_re,dsOut_im,...
            ds_vout,i_rstout,combOut_re,combOut_im,c_vout);
            pirelab.instantiateNetwork(hTopN,cSection,[dsOut_re,dsOut_im,ds_vout,...
            i_rstout],[combOut_re,combOut_im,c_vout],'cSection');
            pirelab.getIntDelayComp(hTopN,i_rstout,c_rstout,1,'',0);

            gcSection=this.elabGaincorrection(hTopN,blockInfo,slRate,combOut_re,...
            combOut_im,downsampleVal,c_rstout,gcOut_re,gcOut_im);
            pirelab.instantiateNetwork(hTopN,gcSection,[combOut_re,combOut_im,...
            downsampleVal,c_rstout],[gcOut_re,gcOut_im],'gcSection');
            pirelab.getIntDelayComp(hTopN,c_rstout,gc_rstout,1,'',0);
        else

            cSection=this.elabVectComb(hTopN,blockInfo,slRate,dsOut_re,dsOut_im,...
            ds_vout,i_rstout,combOut_re,combOut_im,c_vout);
            pirelab.instantiateNetwork(hTopN,cSection,[dsOut_re,dsOut_im,ds_vout,...
            i_rstout],[combOut_re,combOut_im,c_vout],'cSection');
            pirelab.getIntDelayEnabledResettableComp(hTopN,i_rstout,c_rstout,1,1,blockInfo.NumSections);


            gcSection=this.elabVectGaincorrection(hTopN,blockInfo,slRate,combOut_re,...
            combOut_im,internalReset,gcOut_re,gcOut_im);
            pirelab.instantiateNetwork(hTopN,gcSection,[combOut_re,combOut_im,internalReset],...
            [gcOut_re,gcOut_im],'gcSection');
            pirelab.getIntDelayComp(hTopN,c_rstout,gc_rstout,1,'',0);
        end
    end



    if blockInfo.vecsize==1||blockInfo.vecsize<=blockInfo.DecimationFactor
        outWL=hTopNoutSigs(1).Type.BaseType.WordLength;
        outFL=hTopNoutSigs(1).Type.BaseType.FractionLength;
        dataOut_re=hTopN.addSignal(pir_sfixpt_t(outWL,outFL),'dataOut_re');
        dataOut_re.SimulinkRate=slRate;
        dataOut_im=hTopN.addSignal(pir_sfixpt_t(outWL,outFL),'dataOut_im');
        dataOut_im.SimulinkRate=slRate;
    else
        outWL=pirgetdatatypeinfo(hTopNoutSigs(1).Type).wordsize;
        outFL=pirgetdatatypeinfo(hTopNoutSigs(1).Type).binarypoint;
        pVType5=pirelab.getPirVectorType(pir_sfixpt_t(outWL,outFL),blockInfo.numcombinputs);
        dataOut_re=hTopN.addSignal(pVType5,'dataOut_re');
        dataOut_re.SimulinkRate=slRate;
        dataOut_im=hTopN.addSignal(pVType5,'dataOut_im');
        dataOut_im.SimulinkRate=slRate;
    end

    castSection=this.elabcastout(hTopN,blockInfo,slRate,gcOut_re,...
    gcOut_im,dataOut_re,dataOut_im);
    pirelab.instantiateNetwork(hTopN,castSection,[gcOut_re,gcOut_im],...
    [dataOut_re,dataOut_im],'castSection');


    dataOutTmp=hTopN.addSignal(dataOut.Type,'dataOutTmp');
    dataOutTmp.SimulinkRate=slRate;

    if blockInfo.InputDataIsReal
        pirelab.getWireComp(hTopN,dataOut_re,dataOutTmp);
    else
        pirelab.getRealImag2Complex(hTopN,[dataOut_re,dataOut_im],dataOutTmp);
    end


    invalidOut=hTopN.addSignal(dataOut.Type,'invalidOut');
    invalidOut.SimulinkRate=slRate;
    pirelab.getConstComp(hTopN,invalidOut,0,'invalidOut');
    if blockInfo.vecsize==1
        pirelab.getIntDelayEnabledResettableComp(hTopN,c_vout,validOut,1,...
        internalReset,9*blockInfo.GainCorrection);
        pirelab.getSwitchComp(hTopN,[dataOutTmp,invalidOut],dataOut,validOut,'','==',1);
    else
        validOutF=hTopN.addSignal(hTopNoutSigs(2).Type,'validOutF');
        validOutF1=hTopN.addSignal(hTopNoutSigs(2).Type,'validOutF1');
        blkLatency=blockInfo.blkLatency;
        pirelab.getIntDelayEnabledResettableComp(hTopN,c_vout,validOutF1,1,...
        gc_rstout,9*blockInfo.GainCorrection);

        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICDecimator','cgireml','rstCond.m'),'r');
        rstCond=fread(fid,Inf,'char=>char');
        fclose(fid);
        hTopN.addComponent2(...
        'kind','cgireml',...
        'Name','rstCond',...
        'InputSignals',[validOutF1,internalReset],...
        'OutputSignals',validOutF,...
        'EMLFileName','rstCond',...
        'EMLFileBody',rstCond,...
        'EmlParams',{blkLatency},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
        pirelab.getSwitchComp(hTopN,[dataOutTmp,invalidOut],dataOut,validOutF,'','==',1);
        pirelab.getWireComp(hTopN,validOutF,validOut);
    end
end
