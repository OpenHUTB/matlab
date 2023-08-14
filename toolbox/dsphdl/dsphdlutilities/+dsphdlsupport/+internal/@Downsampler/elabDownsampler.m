function dsSection=elabDownsampler(~,hTopN,blockInfo,slRate,dataInreg,...
    validInreg,internalReset,dsOut_re,dsOut_im,ds_vout)




    in1=dataInreg;
    in2=validInreg;
    in3=internalReset;

    out1=dsOut_re;
    out2=dsOut_im;
    out3=ds_vout;


    dsSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','dsSection',...
    'InportNames',{'dataInreg','validInreg','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type],...
    'Inportrates',[slRate,slRate,slRate],...
    'OutportNames',{'dsOut_re','dsOut_im','ds_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dataInreg=dsSection.PirInputSignals(1);
    validInreg=dsSection.PirInputSignals(2);


    if blockInfo.inMode(2)
        internalReset=dsSection.PirInputSignals(3);
    else
        internalReset='';
    end

    dsOut_re=dsSection.PirOutputSignals(1);
    dsOut_im=dsSection.PirOutputSignals(2);
    ds_vout=dsSection.PirOutputSignals(3);

    inS=blockInfo.issigned;
    inWL=blockInfo.dlen;
    inFL=blockInfo.flen;
    PVType=pir_fixpt_t(inS,inWL,inFL);

    dataInreg_cast=dsSection.addSignal2('Type',pir_complex_t(PVType),'Name','dataInreg_cast');%#ok<*AGROW>
    dataInreg_cast.SimulinkRate=slRate;
    din_re=dsSection.addSignal(PVType,'din_re');
    din_re.SimulinkRate=slRate;
    din_im=dsSection.addSignal(PVType,'din_im');
    din_im.SimulinkRate=slRate;
    dataIn_re=dsSection.addSignal(PVType,'dataIn_re');
    dataIn_re.SimulinkRate=slRate;
    dataIn_im=dsSection.addSignal(PVType,'dataIn_im');
    dataIn_im.SimulinkRate=slRate;
    pirelab.getDTCComp(dsSection,dataInreg,dataInreg_cast);
    pirelab.getComplex2RealImag(dsSection,dataInreg_cast,[din_re,din_im],'real and img');
    pirelab.getDTCComp(dsSection,din_re,dataIn_re,'Floor','Wrap');
    pirelab.getDTCComp(dsSection,din_im,dataIn_im,'Floor','Wrap');

    downsampleFact=blockInfo.DownsampleFactor;
    offSet=blockInfo.SampleOffset;


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@Downsampler','cgireml','downSampler.m'),'r');
    downSampler=fread(fid,Inf,'char=>char');
    fclose(fid);
    dsSection.addComponent2(...
    'kind','cgireml',...
    'Name','downSampler',...
    'InputSignals',[dataIn_re,dataIn_im,validInreg],...
    'OutputSignals',[dsOut_re,dsOut_im,ds_vout],...
    'EMLFileName','downSampler',...
    'EMLFileBody',downSampler,...
    'EmlParams',{downsampleFact,offSet},...
    'ExternalSynchronousResetSignal',internalReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true);
end
