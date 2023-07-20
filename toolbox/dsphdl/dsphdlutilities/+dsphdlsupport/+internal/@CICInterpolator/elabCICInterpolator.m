function elabCICInterpolator(this,hTopN,blockInfo,slRate)





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
    readyOut=hTopNoutSigs(3);




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


    maxInterpFact=blockInfo.InterpolationFactor;
    if blockInfo.inMode(2)
        vReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','vReset');
        vReset1=hTopN.addSignal2('Type',pir_boolean_t,'Name','vReset1');
        softResetreg=hTopN.addSignal2('Type',pir_boolean_t,'Name','softResetreg');
        upsampleIn=hTopN.addSignal(R.Type,'upsampleIn');
        upsampleVal=hTopN.addSignal(R.Type,'upsampleVal');
        upsampleVal1=hTopN.addSignal(R.Type,'upsampleVal1');
        pirelab.getWireComp(hTopN,R,upsampleIn);

        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','calcUpSampleFactor.m'),'r');
        calcUpSampleFactor=fread(fid,Inf,'char=>char');
        fclose(fid);
        hTopN.addComponent2(...
        'kind','cgireml',...
        'Name','calcUpSampleFactor',...
        'InputSignals',[upsampleIn,validIn],...
        'OutputSignals',[upsampleVal,upsampleVal1,vReset,vReset1],...
        'EMLFileName','calcUpSampleFactor',...
        'EMLFileBody',calcUpSampleFactor,...
        'EmlParams',{maxInterpFact},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
        internalReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','internalReset');
        pirelab.getWireComp(hTopN,softReset,softResetreg);
        pirelab.getLogicComp(hTopN,[softResetreg,vReset],internalReset,'or');
        if blockInfo.InterpolationFactor==1&&blockInfo.inMode(2)

            pirelab.getWireComp(hTopN,dataIn,dataInreg);
            pirelab.getWireComp(hTopN,validIn,validInreg);
        else
            pirelab.getIntDelayEnabledResettableComp(hTopN,dataIn,dataInreg,1,softResetreg,1);
            pirelab.getIntDelayEnabledResettableComp(hTopN,validIn,validInreg,1,softResetreg,1);
        end
    else
        upsampleVal=hTopN.addSignal(pir_ufixpt_t(12,0),'upsampleVal');
        softResetreg=hTopN.addSignal2('Type',pir_boolean_t,'Name','softResetreg');
        pirelab.getConstComp(hTopN,upsampleVal,blockInfo.InterpolationFactor);
        internalReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','internalReset');
        pirelab.getWireComp(hTopN,softReset,softResetreg);
        pirelab.getWireComp(hTopN,softResetreg,internalReset);
        pirelab.getIntDelayEnabledResettableComp(hTopN,dataIn,dataInreg,1,softResetreg,1);
        pirelab.getIntDelayEnabledResettableComp(hTopN,validIn,validInreg,1,softResetreg,1);
    end

    coutWL=blockInfo.stageDT{blockInfo.NumSections}.WordLength;
    coutFL=blockInfo.stageDT{blockInfo.NumSections}.FractionLength;
    ioutWL=blockInfo.stageDT{2*blockInfo.NumSections}.WordLength;
    ioutFL=blockInfo.stageDT{2*blockInfo.NumSections}.FractionLength;
    if blockInfo.MinCycles<blockInfo.InterpolationFactor&&blockInfo.MinCycles~=1
        outSize=blockInfo.R2;
    else
        outSize=blockInfo.R1;
    end
    rateFalg=(blockInfo.MinCycles==blockInfo.InterpolationFactor)&&blockInfo.InterpolationFactor==1;
    vecFlag=(blockInfo.MinCycles<blockInfo.InterpolationFactor||rateFalg)&&~blockInfo.inMode(2)&&...
    ((blockInfo.InterpolationFactor<blockInfo.vecsize)||~(blockInfo.InterpolationFactor==1));
    if vecFlag

        pVType1=pirelab.getPirVectorType(pir_sfixpt_t(coutWL,coutFL),blockInfo.vecsize);
        combOut_re=hTopN.addSignal(pVType1,'combOut_re');
        combOut_re.SimulinkRate=slRate;
        combOut_im=hTopN.addSignal(pVType1,'combOut_im');
        combOut_im.SimulinkRate=slRate;

        pVType2=pirelab.getPirVectorType(pir_sfixpt_t(coutWL,coutFL),blockInfo.R1);
        usOut_re=hTopN.addSignal(pVType2,'usOut_re');
        usOut_re.SimulinkRate=slRate;
        usOut_im=hTopN.addSignal(pVType2,'usOut_im');
        usOut_im.SimulinkRate=slRate;

        pVType3=pirelab.getPirVectorType(pir_sfixpt_t(ioutWL,ioutFL),outSize);
        integOut_re=hTopN.addSignal(pVType3,'integOut_re');
        integOut_re.SimulinkRate=slRate;
        integOut_im=hTopN.addSignal(pVType3,'integOut_im');
        integOut_im.SimulinkRate=slRate;
        pVType8=pirelab.getPirVectorType(pir_sfixpt_t(ioutWL,ioutFL),blockInfo.R1);
        integOutreg_re=hTopN.addSignal(pVType8,'integOutreg_re');
        integOutreg_re.SimulinkRate=slRate;
        integOutreg_im=hTopN.addSignal(pVType8,'integOutreg_im');
        integOutreg_im.SimulinkRate=slRate;
    else

        combOut_re=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'combOut_re');
        combOut_re.SimulinkRate=slRate;
        combOut_im=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'combOut_im');
        combOut_im.SimulinkRate=slRate;

        usOut_re=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'usOut_re');
        usOut_re.SimulinkRate=slRate;
        usOut_im=hTopN.addSignal(pir_sfixpt_t(coutWL,coutFL),'usOut_im');
        usOut_im.SimulinkRate=slRate;

        integOut_re=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'integOut_re');
        integOut_re.SimulinkRate=slRate;
        integOut_im=hTopN.addSignal(pir_sfixpt_t(ioutWL,ioutFL),'integOut_im');
        integOut_im.SimulinkRate=slRate;
    end


    rdyout_re=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyout_re');
    rdyout_re.SimulinkRate=slRate;
    rdyout_im=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyout_im');
    rdyout_im.SimulinkRate=slRate;

    rdy_valid=hTopN.addSignal(hTopNoutSigs(2).Type,'rdy_valid');
    c_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'c_vout');
    c_vout.SimulinkRate=slRate;
    c_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'c_rstout');
    c_rstout.SimulinkRate=slRate;
    us_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'us_vout');
    us_vout.SimulinkRate=slRate;
    us_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'us_rstout');
    us_rstout.SimulinkRate=slRate;
    i_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'i_vout');
    i_vout.SimulinkRate=slRate;
    i_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'i_rstout');
    i_rstout.SimulinkRate=slRate;
    ireg_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'ireg_vout');
    ireg_vout.SimulinkRate=slRate;
    ireg_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'ireg_rstout');
    ireg_rstout.SimulinkRate=slRate;



    gC=blockInfo.GainCorrection;
    gDT=blockInfo.gDT;
    if vecFlag
        if gC
            pVType4=pirelab.getPirVectorType(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),outSize);
            gcOut_re=hTopN.addSignal(pVType4,'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pVType4,'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        else
            pVType5=pirelab.getPirVectorType(pir_sfixpt_t(integOut_re.Type.BaseType.WordLength,integOut_re.Type.BaseType.FractionLength),outSize);
            gcOut_re=hTopN.addSignal(pVType5,'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pVType5,'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        end
    else
        if gC
            gcOut_re=hTopN.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        else
            gcOut_re=hTopN.addSignal(pir_sfixpt_t(integOut_re.Type.WordLength,...
            integOut_re.Type.FractionLength),'gcOut_re');
            gcOut_re.SimulinkRate=slRate;
            gcOut_im=hTopN.addSignal(pir_sfixpt_t(integOut_im.Type.WordLength,...
            integOut_im.Type.FractionLength),'gcOut_im');
            gcOut_im.SimulinkRate=slRate;
        end
    end
    gc_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'gc_rstout');
    gc_rstout.SimulinkRate=slRate;


    varFlag=blockInfo.inMode(2);
    cyclesFlag=blockInfo.MinCycles;
    if varFlag
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','cicReadyLogicV.m'),'r');
        cicReadyLogicV=fread(fid,Inf,'char=>char');
        fclose(fid);
        hTopN.addComponent2(...
        'kind','cgireml',...
        'Name','cicReadyLogicV',...
        'InputSignals',[validIn,upsampleVal,softReset,vReset],...
        'OutputSignals',readyOut,...
        'EMLFileName','cicReadyLogicV',...
        'EMLFileBody',cicReadyLogicV,...
        'EmlParams',{maxInterpFact,varFlag,cyclesFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    else
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','cicReadyLogic.m'),'r');
        cicReadyLogic=fread(fid,Inf,'char=>char');
        fclose(fid);
        hTopN.addComponent2(...
        'kind','cgireml',...
        'Name','cicReadyLogic',...
        'InputSignals',[validIn,upsampleVal,softReset],...
        'OutputSignals',readyOut,...
        'EMLFileName','cicReadyLogic',...
        'EMLFileBody',cicReadyLogic,...
        'EmlParams',{maxInterpFact,varFlag,cyclesFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end
    if vecFlag
        if~(blockInfo.vecsize==1)
            for i=1:blockInfo.vecsize
                dtypeinfo=pirgetdatatypeinfo(dataInreg.Type.BaseType);
                dataInreg_cast(i)=hTopN.addSignal2('Type',pir_complex_t(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint)),'Name','dataInreg_cast');%#ok<*AGROW>
                dataInreg_cast(i).SimulinkRate=slRate;
                din_re(i)=hTopN.addSignal(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint),'din_re');
                din_re(i).SimulinkRate=slRate;
                din_im(i)=hTopN.addSignal(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint),'din_im');
                din_im(i).SimulinkRate=slRate;
                rdyInreg_re(i)=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyInreg_re');
                rdyInreg_re(i).SimulinkRate=slRate;
                rdyInreg_im(i)=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyInreg_im');
                rdyInreg_im(i).SimulinkRate=slRate;
                if blockInfo.InterpolationFactor==1
                    pirelab.getDTCComp(hTopN,dataIn.split.PirOutputSignals(i),dataInreg_cast(i));
                else
                    pirelab.getDTCComp(hTopN,dataInreg.split.PirOutputSignals(i),dataInreg_cast(i));
                end
                pirelab.getComplex2RealImag(hTopN,dataInreg_cast(i),[din_re(i),din_im(i)],'real and img');
                pirelab.getDTCComp(hTopN,din_re(i),rdyInreg_re(i),'Floor','Wrap');
                pirelab.getDTCComp(hTopN,din_im(i),rdyInreg_im(i),'Floor','Wrap');
            end
            pVType6=pirelab.getPirVectorType(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),blockInfo.vecsize);
            rdyIn_re=hTopN.addSignal(pVType6,'rdyIn_re');
            rdyIn_re.SimulinkRate=slRate;
            rdyIn_im=hTopN.addSignal(pVType6,'rdyIn_im');
            rdyIn_im.SimulinkRate=slRate;
            pirelab.getMuxComp(hTopN,rdyInreg_re,rdyIn_re);
            pirelab.getMuxComp(hTopN,rdyInreg_im,rdyIn_im);
            if blockInfo.InterpolationFactor==1

                cSection=this.elabVectComb(hTopN,blockInfo,slRate,rdyIn_re,rdyIn_im,validIn,...
                internalReset,combOut_re,combOut_im,c_vout);
                pirelab.instantiateNetwork(hTopN,cSection,[rdyIn_re,rdyIn_im,validIn,...
                internalReset],[combOut_re,combOut_im,c_vout],'cSection');
            else

                cSection=this.elabVectComb(hTopN,blockInfo,slRate,rdyIn_re,rdyIn_im,validInreg,...
                internalReset,combOut_re,combOut_im,c_vout);
                pirelab.instantiateNetwork(hTopN,cSection,[rdyIn_re,rdyIn_im,validInreg,...
                internalReset],[combOut_re,combOut_im,c_vout],'cSection');
            end
        else
            dtypeinfo=pirgetdatatypeinfo(dataInreg.Type.BaseType);
            dataInreg_cast=hTopN.addSignal2('Type',pir_complex_t(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint)),'Name','dataInreg_cast');%#ok<*AGROW>
            dataInreg_cast.SimulinkRate=slRate;
            din_re=hTopN.addSignal(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint),'din_re');
            din_re.SimulinkRate=slRate;
            din_im=hTopN.addSignal(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint),'din_im');
            din_im.SimulinkRate=slRate;
            rdyIn_re=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyIn_re');
            rdyIn_re.SimulinkRate=slRate;
            rdyIn_im=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyIn_im');
            rdyIn_im.SimulinkRate=slRate;
            pirelab.getDTCComp(hTopN,dataInreg,dataInreg_cast);
            pirelab.getComplex2RealImag(hTopN,dataInreg_cast,[din_re,din_im],'real and img');
            pirelab.getDTCComp(hTopN,din_re,rdyIn_re,'Floor','Wrap');
            pirelab.getDTCComp(hTopN,din_im,rdyIn_im,'Floor','Wrap');


            cSection=this.elabComb(hTopN,blockInfo,slRate,rdyIn_re,rdyIn_im,validInreg,...
            internalReset,combOut_re,combOut_im,c_vout);
            pirelab.instantiateNetwork(hTopN,cSection,[rdyIn_re,rdyIn_im,validInreg,...
            internalReset],[combOut_re,combOut_im,c_vout],'cSection');
        end

        usSection=this.elabVectUpsampler(hTopN,blockInfo,slRate,combOut_re,combOut_im,c_vout,...
        internalReset,usOut_re,usOut_im,us_vout);
        pirelab.instantiateNetwork(hTopN,usSection,[combOut_re,combOut_im,c_vout,...
        internalReset],[usOut_re,usOut_im,us_vout],'usSection');


        iSection=this.elabVectIntegrator(hTopN,blockInfo,slRate,usOut_re,usOut_im,us_vout,...
        internalReset,integOutreg_re,integOutreg_im,ireg_vout,ireg_rstout);
        pirelab.instantiateNetwork(hTopN,iSection,[usOut_re,usOut_im,us_vout,...
        internalReset],[integOutreg_re,integOutreg_im,ireg_vout,ireg_rstout],'iSection');


        if blockInfo.vecsize>1

            pSection=this.elabZeropadder(hTopN,blockInfo,slRate,integOutreg_re,integOutreg_im,ireg_vout,...
            ireg_rstout,integOut_re,integOut_im,i_vout);
            pirelab.instantiateNetwork(hTopN,pSection,[integOutreg_re,integOutreg_im,ireg_vout,ireg_rstout],...
            [integOut_re,integOut_im,i_vout],'pSection');
        else
            if(blockInfo.MinCycles>=blockInfo.InterpolationFactor)||(blockInfo.MinCycles==1)
                pirelab.getWireComp(hTopN,integOutreg_re,integOut_re);
                pirelab.getWireComp(hTopN,integOutreg_im,integOut_im);
                pirelab.getWireComp(hTopN,ireg_vout,i_vout);
            else

                bSection=this.elabBuffer(hTopN,blockInfo,slRate,integOutreg_re,integOutreg_im,ireg_vout,...
                ireg_rstout,integOut_re,integOut_im,i_vout);
                pirelab.instantiateNetwork(hTopN,bSection,[integOutreg_re,integOutreg_im,ireg_vout,ireg_rstout],...
                [integOut_re,integOut_im,i_vout],'bSection');
            end
        end

        gcSection=this.elabVectGaincorrection(hTopN,blockInfo,slRate,integOut_re,integOut_im,...
        internalReset,gcOut_re,gcOut_im);
        pirelab.instantiateNetwork(hTopN,gcSection,[integOut_re,integOut_im,...
        internalReset],[gcOut_re,gcOut_im],'gcSection');
        pirelab.getIntDelayComp(hTopN,i_rstout,gc_rstout,1,'',0);
    else

        dtypeinfo=pirgetdatatypeinfo(dataInreg.Type.BaseType);
        dataInreg_cast=hTopN.addSignal2('Type',pir_complex_t(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint)),'Name','dataInreg_cast');%#ok<*AGROW>
        dataInreg_cast.SimulinkRate=slRate;
        din_re=hTopN.addSignal(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint),'din_re');
        din_re.SimulinkRate=slRate;
        din_im=hTopN.addSignal(pir_sfixpt_t(dtypeinfo.wordsize,dtypeinfo.binarypoint),'din_im');
        din_im.SimulinkRate=slRate;
        rdyIn_re=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyIn_re');
        rdyIn_re.SimulinkRate=slRate;
        rdyIn_im=hTopN.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyIn_im');
        rdyIn_im.SimulinkRate=slRate;
        pirelab.getDTCComp(hTopN,dataIn,dataInreg_cast);
        pirelab.getComplex2RealImag(hTopN,dataInreg_cast,[din_re,din_im],'real and img');
        pirelab.getDTCComp(hTopN,din_re,rdyIn_re,'Floor','Wrap');
        pirelab.getDTCComp(hTopN,din_im,rdyIn_im,'Floor','Wrap');

        if blockInfo.InterpolationFactor==1&&~blockInfo.inMode(2)

            cSection=this.elabComb(hTopN,blockInfo,slRate,rdyIn_re,rdyIn_im,validIn,...
            internalReset,combOut_re,combOut_im,c_vout);
            pirelab.instantiateNetwork(hTopN,cSection,[rdyIn_re,rdyIn_im,validIn,...
            internalReset],[combOut_re,combOut_im,c_vout],'cSection');
        else

            rdySection=this.elabReadyLogic(hTopN,blockInfo,slRate,dataInreg,validInreg,...
            internalReset,upsampleVal,rdyout_re,rdyout_im,rdy_valid);
            pirelab.instantiateNetwork(hTopN,rdySection,[dataInreg,validInreg,...
            internalReset,upsampleVal],[rdyout_re,rdyout_im,rdy_valid],'rdySection');

            cSection=this.elabComb(hTopN,blockInfo,slRate,rdyout_re,rdyout_im,rdy_valid,...
            internalReset,combOut_re,combOut_im,c_vout);
            pirelab.instantiateNetwork(hTopN,cSection,[rdyout_re,rdyout_im,rdy_valid,...
            internalReset],[combOut_re,combOut_im,c_vout],'cSection');
        end

        usSection=this.elabUpsampler(hTopN,blockInfo,slRate,combOut_re,combOut_im,c_vout,...
        upsampleVal,internalReset,usOut_re,usOut_im,us_vout);
        pirelab.instantiateNetwork(hTopN,usSection,[combOut_re,combOut_im,c_vout,...
        upsampleVal,internalReset],[usOut_re,usOut_im,us_vout],'usSection');


        iSection=this.elabIntegrator(hTopN,blockInfo,slRate,usOut_re,usOut_im,us_vout,...
        internalReset,integOut_re,integOut_im);
        pirelab.instantiateNetwork(hTopN,iSection,[usOut_re,usOut_im,us_vout,...
        internalReset],[integOut_re,integOut_im],'iSection');


        gcSection=this.elabGaincorrection(hTopN,blockInfo,slRate,integOut_re,integOut_im,...
        upsampleVal,internalReset,gcOut_re,gcOut_im);
        pirelab.instantiateNetwork(hTopN,gcSection,[integOut_re,integOut_im,...
        upsampleVal,internalReset],[gcOut_re,gcOut_im],'gcSection');
    end



    if vecFlag
        outWL=pirgetdatatypeinfo(hTopNoutSigs(1).Type).wordsize;
        outFL=pirgetdatatypeinfo(hTopNoutSigs(1).Type).binarypoint;
        pVType7=pirelab.getPirVectorType(pir_sfixpt_t(outWL,outFL),outSize);
        dataOut_re=hTopN.addSignal(pVType7,'dataOut_re');
        dataOut_re.SimulinkRate=slRate;
        dataOut_im=hTopN.addSignal(pVType7,'dataOut_im');
        dataOut_im.SimulinkRate=slRate;
    else
        outWL=hTopNoutSigs(1).Type.BaseType.WordLength;
        outFL=hTopNoutSigs(1).Type.BaseType.FractionLength;
        dataOut_re=hTopN.addSignal(pir_sfixpt_t(outWL,outFL),'dataOut_re');
        dataOut_re.SimulinkRate=slRate;
        dataOut_im=hTopN.addSignal(pir_sfixpt_t(outWL,outFL),'dataOut_im');
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

    if vecFlag
        validOutF=hTopN.addSignal(hTopNoutSigs(2).Type,'validOutF');
        validOutF1=hTopN.addSignal(hTopNoutSigs(2).Type,'validOutF1');
        blkLatency=blockInfo.blkLatency;
        pirelab.getIntDelayEnabledResettableComp(hTopN,i_vout,validOutF1,1,...
        gc_rstout,9*blockInfo.GainCorrection);

        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','rstCond.m'),'r');
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
    else
        pirelab.getIntDelayEnabledResettableComp(hTopN,us_vout,validOut,1,...
        internalReset,9*blockInfo.GainCorrection);
        pirelab.getSwitchComp(hTopN,[dataOutTmp,invalidOut],dataOut,validOut,'','==',1);
    end

end