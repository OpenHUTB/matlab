function gcSection=elabGaincorrection(~,hTopN,blockInfo,slRate,integOut_re,...
    integOut_im,upsampleValInd,internalReset,gcOut_re,gcOut_im)




    in1=integOut_re;
    in2=integOut_im;
    in3=upsampleValInd;
    in4=internalReset;

    out1=gcOut_re;
    out2=gcOut_im;


    gcSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','gcSection',...
    'InportNames',{'integOut_re','integOut_im','upsampleValInd','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'gcOut_re','gcOut_im'},...
    'OutportTypes',[out1.Type,out2.Type]...
    );


    integOut_re=gcSection.PirInputSignals(1);
    integOut_im=gcSection.PirInputSignals(2);
    upsampleValInd=gcSection.PirInputSignals(3);
    internalReset=gcSection.PirInputSignals(4);

    gcOut_re=gcSection.PirOutputSignals(1);
    gcOut_im=gcSection.PirOutputSignals(2);

    gCorrection=blockInfo.GainCorrection;
    gainShift=blockInfo.gainShift;
    shiftLength=blockInfo.shiftLength;
    gDT=blockInfo.gDT;
    gainOuta1=blockInfo.gainOuta1;
    fineMult=blockInfo.fineMult;
    varR=blockInfo.inMode(2);

    if gCorrection
        coarseGtmp_re=gcSection.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'coarseGtmp_re');
        coarseGtmp_re.SimulinkRate=slRate;
        coarseGtmp_im=gcSection.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'coarseGtmp_im');
        coarseGtmp_im.SimulinkRate=slRate;
        coarseGtmpreg_re=gcSection.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'coarseGtmpreg_re');
        coarseGtmpreg_re.SimulinkRate=slRate;
        coarseGtmpreg_im=gcSection.addSignal(pir_sfixpt_t(gDT.WordLength,-gDT.FractionLength),'coarseGtmpreg_im');
        coarseGtmpreg_im.SimulinkRate=slRate;
        fineG=gcSection.addSignal(pir_sfixpt_t(23,-21),'fineG');
        fineG.SimulinkRate=slRate;
        fineGreg=gcSection.addSignal(pir_sfixpt_t(23,-21),'fineG');
        fineGreg.SimulinkRate=slRate;
        fineMultreg=gcSection.addSignal(pir_sfixpt_t(23,-21),'fineMultreg');
        fineMultreg.SimulinkRate=slRate;


        productFixType=pir_fixpt_t(...
        1,coarseGtmp_re.Type.WordLength+fineG.Type.WordLength,...
        coarseGtmp_re.Type.FractionLength+fineG.Type.FractionLength);
        mulOut_re=gcSection.addSignal(productFixType,'mulOut_re');
        mulOut_re.SimulinkRate=slRate;
        mulOut_im=gcSection.addSignal(productFixType,'mulOut_im');
        mulOut_im.SimulinkRate=slRate;
        mulOutreg_re=gcSection.addSignal(productFixType,'mulOutreg_re');
        mulOutreg_re.SimulinkRate=slRate;
        mulOutreg_im=gcSection.addSignal(productFixType,'mulOutreg_im');
        mulOutreg_im.SimulinkRate=slRate;
        gcOutreg_re=gcSection.addSignal(gcOut_re.Type,'gcOutreg_re');
        gcOutreg_im=gcSection.addSignal(gcOut_re.Type,'gcOutreg_im');


        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','initGainCorrection.m'),'r');
        initGainCorrection=fread(fid,Inf,'char=>char');
        fclose(fid);
        if varR
            gainShift=cell2mat(gainShift);
            fineMult=cell2mat(fineMult);
            initgc=gcSection.addComponent2(...
            'kind','cgireml',...
            'Name','initGainCorrection',...
            'InputSignals',[integOut_re,integOut_im,upsampleValInd],...
            'OutputSignals',[coarseGtmpreg_re,coarseGtmpreg_im,fineGreg],...
            'ExternalSynchronousResetSignal',internalReset,...
            'EMLFileName','initGainCorrection',...
            'EMLFileBody',initGainCorrection,...
            'EmlParams',{gainShift,gDT.WordLength,gDT.FractionLength,gainOuta1,fineMult},...
            'EMLFlag_TreatInputIntsAsFixpt',true);
            initgc.runConcurrencyMaximizer(0);
            initgc.resetNone(true);
        else
            if gDT.WordLength+shiftLength>=128
                bShiftWL=128;
            else
                bShiftWL=gDT.WordLength+shiftLength;
            end

            bShift_re=gcSection.addSignal(pir_sfixpt_t(gainOuta1.WordLength,gainOuta1.FractionLength),'bShift_re');
            bShift_re.SimulinkRate=slRate;
            bShift_im=gcSection.addSignal(pir_sfixpt_t(gainOuta1.WordLength,gainOuta1.FractionLength),'bShift_im');
            bShift_im.SimulinkRate=slRate;

            bShiftreg_re=gcSection.addSignal(pir_sfixpt_t(bShiftWL,-gDT.FractionLength),'bShiftreg_re');
            bShiftreg_re.SimulinkRate=slRate;
            bShiftreg_im=gcSection.addSignal(pir_sfixpt_t(bShiftWL,-gDT.FractionLength),'bShiftreg_im');
            bShiftreg_im.SimulinkRate=slRate;

            bRShift_re=gcSection.addSignal(pir_sfixpt_t(bShiftWL,-gDT.FractionLength),'bRShift_re');
            bRShift_re.SimulinkRate=slRate;
            bRShift_im=gcSection.addSignal(pir_sfixpt_t(bShiftWL,-gDT.FractionLength),'bRShift_im');
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

        end
        vecsize=blockInfo.vecsize;

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
end
