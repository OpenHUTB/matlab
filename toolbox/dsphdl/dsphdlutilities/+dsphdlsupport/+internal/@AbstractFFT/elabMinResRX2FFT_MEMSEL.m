function MEMSEL=elabMinResRX2FFT_MEMSEL(this,topNet,dataRate,blockInfo,...
    btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld,...
    stage,initIC,syncReset,...
    stgOut1_re,stgOut1_im,stgOut2_re,stgOut2_im,stgOut_vld)





    FFTLENGTH=blockInfo.FFTLength;
    BITREVIN=blockInfo.BitReversedInput;
    IC=FFTLENGTH/4-1;

    InportNames={btfOut1_re.Name,btfOut1_im.Name,btfOut2_re.Name,btfOut2_im.Name,btfOut_vld.Name,...
    stage.Name,initIC.Name,syncReset.Name};
    InportTypes=[btfOut1_re.Type,btfOut1_im.Type,btfOut2_re.Type,btfOut2_im.Type,btfOut_vld.Type,...
    stage.Type,initIC.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={stgOut1_re.Name,stgOut1_im.Name,stgOut2_re.Name,stgOut2_im.Name,stgOut_vld.Name};
    OutportTypes=[stgOut1_re.Type,stgOut1_im.Type,stgOut2_re.Type,stgOut2_im.Type,stgOut_vld.Type];

    MEMSEL=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MINRESRX2FFT_MEMSEL',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=MEMSEL.PirInputSignals;
    outputPort=MEMSEL.PirOutputSignals;

    btfOut1_re=inputPort(1);
    btfOut1_im=inputPort(2);
    btfOut2_re=inputPort(3);
    btfOut2_im=inputPort(4);
    btfOut_vld=inputPort(5);
    stage=inputPort(6);
    initIC=inputPort(7);
    syncReset=inputPort(8);

    HASRESETPORT=blockInfo.inMode(2);
    if~HASRESETPORT
        syncReset='';
    end

    stgOut1_re=outputPort(1);
    stgOut1_im=outputPort(2);
    stgOut2_re=outputPort(3);
    stgOut2_im=outputPort(4);
    stgOut_vld=outputPort(5);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','minResRX2FFTMEMSEL.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='MINRESRX2FFTMEMSEL';
    memsel_inst=MEMSEL.addComponent2(...
    'kind','cgireml',...
    'Name','MINRESRX2FFTMEMSEL',...
    'InputSignals',[btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld,stage,initIC],...
    'OutputSignals',[stgOut1_re,stgOut1_im,stgOut2_re,stgOut2_im,stgOut_vld],...
    'EMLFileName','minResRX2FFTMEMSEL',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,BITREVIN,IC},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    memsel_inst.runConcurrencyMaximizer(0);

end
