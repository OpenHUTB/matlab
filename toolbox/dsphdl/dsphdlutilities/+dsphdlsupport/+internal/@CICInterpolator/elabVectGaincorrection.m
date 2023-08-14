function gcSection=elabVectGaincorrection(~,hTopN,blockInfo,slRate,integOut_re,integOut_im,internalReset,...
    gcOut_re,gcOut_im)




    in1=integOut_re;
    in2=integOut_im;
    in3=internalReset;

    out1=gcOut_re;
    out2=gcOut_im;


    gcSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','gcSection',...
    'InportNames',{'integOut_re','integOut_im','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type],...
    'Inportrates',[slRate,slRate,slRate],...
    'OutportNames',{'gcOut_re','gcOut_im'},...
    'OutportTypes',[out1.Type,out2.Type]...
    );


    integOut_re=gcSection.PirInputSignals(1);
    integOut_im=gcSection.PirInputSignals(2);
    internalReset=gcSection.PirInputSignals(3);

    gcOut_re=gcSection.PirOutputSignals(1);
    gcOut_im=gcSection.PirOutputSignals(2);

    gainCorrection=blockInfo.GainCorrection;
    shiftLength=blockInfo.shiftLength;
    gDT=blockInfo.gDT;
    gainOuta1=blockInfo.gainOuta1;
    fineMult=blockInfo.fineMult;

    if blockInfo.MinCycles<blockInfo.InterpolationFactor&&blockInfo.MinCycles~=1
        vecsize=blockInfo.R2;
    else
        vecsize=blockInfo.R1;
    end

    if gainCorrection
        dType=pirelab.getPirVectorType(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),vecsize);
        coarseGtmp_re=gcSection.addSignal(dType,'coarseGtmp_re');
        coarseGtmp_re.SimulinkRate=slRate;
        coarseGtmp_im=gcSection.addSignal(dType,'coarseGtmp_im');
        coarseGtmp_im.SimulinkRate=slRate;
        coarseGtmpreg_re=gcSection.addSignal(dType,'coarseGtmpreg_re');
        coarseGtmpreg_re.SimulinkRate=slRate;
        coarseGtmpreg_im=gcSection.addSignal(dType,'coarseGtmpreg_im');
        coarseGtmpreg_im.SimulinkRate=slRate;

        fineG=gcSection.addSignal(pir_sfixpt_t(23,-21),'fineG');
        fineG.SimulinkRate=slRate;
        fineGreg=gcSection.addSignal(pir_sfixpt_t(23,-21),'fineG');
        fineGreg.SimulinkRate=slRate;
        fineMultreg=gcSection.addSignal(pir_sfixpt_t(23,-21),'fineMultreg');
        fineMultreg.SimulinkRate=slRate;


        productFixType=pir_sfixpt_t(coarseGtmp_re.Type.BaseType.WordLength+fineG.Type.WordLength,...
        (coarseGtmp_re.Type.BaseType.FractionLength+fineG.Type.FractionLength));
        dType1=pirelab.getPirVectorType(productFixType,vecsize);
        mulOut_re=gcSection.addSignal(dType1,'mulOut_re');
        mulOut_re.SimulinkRate=slRate;
        mulOut_im=gcSection.addSignal(dType1,'mulOut_im');
        mulOut_im.SimulinkRate=slRate;
        mulOutreg_re=gcSection.addSignal(dType1,'mulOutreg_re');
        mulOutreg_re.SimulinkRate=slRate;
        mulOutreg_im=gcSection.addSignal(dType1,'mulOutreg_im');
        mulOutreg_im.SimulinkRate=slRate;

        dType2=pirelab.getPirVectorType(pir_sfixpt_t(pirgetdatatypeinfo(gcOut_re.Type).wordsize,pirgetdatatypeinfo(gcOut_re.Type).binarypoint),vecsize);
        gcOutreg_re=gcSection.addSignal(dType2,'gcOutreg_re');
        gcOutreg_re.SimulinkRate=slRate;
        gcOutreg_im=gcSection.addSignal(dType2,'gcOutreg_im');
        gcOutreg_im.SimulinkRate=slRate;
        gcOutreg1_re=gcSection.addSignal(dType2,'gcOutreg1_re');
        gcOutreg1_re.SimulinkRate=slRate;
        gcOutreg1_im=gcSection.addSignal(dType2,'gcOutreg1_im');
        gcOutreg1_im.SimulinkRate=slRate;

        if gDT.WordLength+shiftLength>=128
            bShiftWL=128;
        else
            bShiftWL=gDT.WordLength+shiftLength;
        end
        dType3=pirelab.getPirVectorType(pir_sfixpt_t(gainOuta1.WordLength,gainOuta1.FractionLength),vecsize);
        bShift_re=gcSection.addSignal(dType3,'bShift_re');
        bShift_re.SimulinkRate=slRate;
        bShift_im=gcSection.addSignal(dType3,'bShift_im');
        bShift_im.SimulinkRate=slRate;

        dType4=pirelab.getPirVectorType(pir_sfixpt_t(bShiftWL,-gDT.FractionLength),vecsize);
        bShiftreg_re=gcSection.addSignal(dType4,'bShiftreg_re');
        bShiftreg_re.SimulinkRate=slRate;
        bShiftreg_im=gcSection.addSignal(dType4,'bShiftreg_im');
        bShiftreg_im.SimulinkRate=slRate;
        bRShift_re=gcSection.addSignal(dType4,'bRShift_re');
        bRShift_re.SimulinkRate=slRate;
        bRShift_im=gcSection.addSignal(dType4,'bRShift_im');
        bRShift_im.SimulinkRate=slRate;

        pirelab.getDTCComp(gcSection,integOut_re,bShift_re,'Nearest','Saturate');
        pirelab.getDTCComp(gcSection,integOut_im,bShift_im,'Nearest','Saturate');
        pirelab.getDTCComp(gcSection,bShift_re,bShiftreg_re,'Nearest','Saturate');
        pirelab.getDTCComp(gcSection,bShift_im,bShiftreg_im,'Nearest','Saturate');

        pirelab.getBitShiftComp(gcSection,bShiftreg_re,bRShift_re,'sra',shiftLength);
        pirelab.getBitShiftComp(gcSection,bShiftreg_im,bRShift_im,'sra',shiftLength);

        pirelab.getDTCComp(gcSection,bRShift_re,coarseGtmpreg_re,'Nearest','Saturate');
        pirelab.getDTCComp(gcSection,bRShift_im,coarseGtmpreg_im,'Nearest','Saturate');

        pirelab.getConstComp(gcSection,fineMultreg,fineMult);
        pirelab.getDTCComp(gcSection,fineMultreg,fineGreg,'Nearest','Saturate');

        varR=blockInfo.inMode(2);


        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','gainCorrection.m'),'r');
        gainCorrection=fread(fid,Inf,'char=>char');
        fclose(fid);

        gc=gcSection.addComponent2(...
        'kind','cgireml',...
        'Name','gainCorrection',...
        'InputSignals',[coarseGtmpreg_re,coarseGtmpreg_im,fineGreg],...
        'OutputSignals',[mulOut_re,mulOut_im],...
        'ExternalSynchronousResetSignal',internalReset,...
        'EMLFileName','gainCorrection',...
        'EMLFileBody',gainCorrection,...
        'EmlParams',{gDT.WordLength,gDT.FractionLength,fineMult,varR,productFixType.WordLength,productFixType.FractionLength,vecsize},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
        gc.runConcurrencyMaximizer(0);
        if blockInfo.HDLGlobalReset
            gc.resetNone(false);
        else
            gc.resetNone(true);
        end


        pirelab.getIntDelayEnabledResettableComp(gcSection,mulOut_re,mulOutreg_re,'','',3);
        pirelab.getIntDelayEnabledResettableComp(gcSection,mulOut_im,mulOutreg_im,'','',3);
        pirelab.getDTCComp(gcSection,mulOutreg_re,gcOutreg_re,'Nearest','Saturate');
        pirelab.getDTCComp(gcSection,mulOutreg_im,gcOutreg_im,'Nearest','Saturate');


        pirelab.getIntDelayEnabledResettableComp(gcSection,gcOutreg_re,gcOut_re,'','',2);
        pirelab.getIntDelayEnabledResettableComp(gcSection,gcOutreg_im,gcOut_im,'','',2);

    else
        pirelab.getWireComp(gcSection,integOut_re,gcOut_re);
        pirelab.getWireComp(gcSection,integOut_im,gcOut_im);
    end
