function BTFSEL=elabMinResRX2FFT_BTFSEL(this,topNet,dataRate,blockInfo,...
    din_re,din_im,din_vld,rdy,...
    dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,dMemOut_vld,...
    stage,initIC,syncReset,...
    btfIn1_re,btfIn1_im,btfIn2_re,btfIn2_im,btfIn_vld)





    FFTLENGTH=blockInfo.FFTLength;
    BITREVIN=blockInfo.BitReversedInput;
    IC=FFTLENGTH/2-1;

    InportNames={din_re.Name,din_im.Name,din_vld.name,rdy.Name,...
    dMemOut1_re.Name,dMemOut1_im.Name,dMemOut2_re.Name,dMemOut2_im.Name,dMemOut_vld.Name,...
    stage.Name,initIC.Name,syncReset.Name};
    InportTypes=[din_re.Type,din_im.Type,din_vld.Type,rdy.Type,...
    dMemOut1_re.Type,dMemOut1_im.Type,dMemOut2_re.Type,dMemOut2_im.Type,dMemOut_vld.Type,...
    stage.Type,initIC.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={btfIn1_re.Name,btfIn1_im.Name,btfIn2_re.Name,btfIn2_im.Name,btfIn_vld.Name};
    OutportTypes=[btfIn1_re.Type,btfIn1_im.Type,btfIn2_re.Type,btfIn2_im.Type,btfIn_vld.Type];

    BTFSEL=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MINRESRX2FFT_BTFSEL',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=BTFSEL.PirInputSignals;
    outputPort=BTFSEL.PirOutputSignals;

    din_re=inputPort(1);
    din_im=inputPort(2);
    din_vld=inputPort(3);
    rdy=inputPort(4);
    dMemOut1_re=inputPort(5);
    dMemOut1_im=inputPort(6);
    dMemOut2_re=inputPort(7);
    dMemOut2_im=inputPort(8);
    dMemOut_vld=inputPort(9);
    stage=inputPort(10);
    initIC=inputPort(11);
    syncReset=inputPort(12);

    HASRESETPORT=blockInfo.inMode(2);
    if~HASRESETPORT
        syncReset='';
    end

    btfIn1_re=outputPort(1);
    btfIn1_im=outputPort(2);
    btfIn2_re=outputPort(3);
    btfIn2_im=outputPort(4);
    btfIn_vld=outputPort(5);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','minResRX2FFTBTFSEL.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='minResRX2FFTBTFSEL';
    btfsel_inst=BTFSEL.addComponent2(...
    'kind','cgireml',...
    'Name','minResRX2FFTBTFSEL',...
    'InputSignals',[din_re,din_im,din_vld,rdy...
    ,dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,dMemOut_vld,stage,initIC],...
    'OutputSignals',[btfIn1_re,btfIn1_im,btfIn2_re,btfIn2_im,btfIn_vld],...
    'EMLFileName','minResRX2FFTBTFSEL',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,BITREVIN,IC},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    btfsel_inst.runConcurrencyMaximizer(0);

end
