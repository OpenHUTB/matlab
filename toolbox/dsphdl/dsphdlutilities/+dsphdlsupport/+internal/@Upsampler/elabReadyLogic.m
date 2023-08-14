function rdySection=elabReadyLogic(~,hTopN,blockInfo,slRate,dataInreg,validInreg,internalReset,rdyout_re,rdyout_im,rdy_valid)




    in1=dataInreg;
    in2=validInreg;
    in3=internalReset;

    out1=rdyout_re;
    out2=rdyout_im;
    out3=rdy_valid;


    rdySection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','rdySection',...
    'InportNames',{'dataInreg','validInreg','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type],...
    'Inportrates',[slRate,slRate,slRate],...
    'OutportNames',{'rdyout_re','rdyout_im','rdy_valid'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dataInreg=rdySection.PirInputSignals(1);
    validInreg=rdySection.PirInputSignals(2);

    if blockInfo.inMode(2)
        internalReset=rdySection.PirInputSignals(3);
    else
        internalReset=rdySection.addSignal(pir_boolean_t,'syncReset');
        pirelab.getConstComp(rdySection,internalReset,false);
    end
    rdyout_re=rdySection.PirOutputSignals(1);
    rdyout_im=rdySection.PirOutputSignals(2);
    rdy_valid=rdySection.PirOutputSignals(3);

    inS=blockInfo.issigned;
    inWL=blockInfo.dlen;
    inFL=blockInfo.flen;
    PVType=pir_fixpt_t(inS,inWL,inFL);

    rdyIn_re=rdySection.addSignal(PVType,'rdyIn_re');
    rdyIn_re.SimulinkRate=slRate;
    rdyIn_im=rdySection.addSignal(PVType,'rdyIn_im');
    rdyIn_im.SimulinkRate=slRate;

    dataInreg_cast=rdySection.addSignal2('Type',pir_complex_t(PVType),'Name','dataInreg_cast');%#ok<*AGROW>
    dataInreg_cast.SimulinkRate=slRate;
    din_re=rdySection.addSignal(PVType,'din_re');
    din_re.SimulinkRate=slRate;
    din_im=rdySection.addSignal(PVType,'din_im');
    din_im.SimulinkRate=slRate;

    pirelab.getDTCComp(rdySection,dataInreg,dataInreg_cast);
    pirelab.getComplex2RealImag(rdySection,dataInreg_cast,[din_re,din_im],'real and img');
    pirelab.getDTCComp(rdySection,din_re,rdyIn_re,'Floor','Wrap');
    pirelab.getDTCComp(rdySection,din_im,rdyIn_im,'Floor','Wrap');

    if(blockInfo.NumCycles==1)
        pirelab.getWireComp(rdySection,rdyIn_re,rdyout_re);
        pirelab.getWireComp(rdySection,rdyIn_im,rdyout_im);
        pirelab.getWireComp(rdySection,validInreg,rdy_valid);
    else

        upsampleFact=blockInfo.UpsampleFactor;
        cyclesFlag=blockInfo.NumCycles;
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@Upsampler','cgireml','readyData.m'),'r');
        readyData=fread(fid,Inf,'char=>char');
        fclose(fid);
        rdySection.addComponent2(...
        'kind','cgireml',...
        'Name','readyData',...
        'InputSignals',[rdyIn_re,rdyIn_im,validInreg,internalReset],...
        'OutputSignals',[rdyout_re,rdyout_im,rdy_valid],...
        'EMLFileName','readyData',...
        'EMLFileBody',readyData,...
        'EmlParams',{upsampleFact,cyclesFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end
end