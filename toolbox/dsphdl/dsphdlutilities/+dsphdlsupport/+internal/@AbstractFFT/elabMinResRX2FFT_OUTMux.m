function OUTMUX=elabMinResRX2FFT_OUTMux(this,topNet,dataRate,blockInfo,...
    rdEnb1,rdEnb2,rdEnb3,...
    dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,vldOut,syncReset,...
    dout_re,dout_im,dout_vld)





    InportNames={rdEnb1.Name,rdEnb2.Name,rdEnb3.Name,...
    dMemOut1_re.Name,dMemOut1_im.Name,dMemOut2_re.Name,dMemOut2_im.Name,...
    vldOut.Name,syncReset.Name};
    InportTypes=[rdEnb1.Type,rdEnb2.Type,rdEnb3.Type,...
    dMemOut1_re.Type,dMemOut1_im.Type,dMemOut2_re.Type,dMemOut2_im.Type,...
    vldOut.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout_re.Name,dout_im.Name,dout_vld.Name};

    OutportTypes=[dout_re.Type,dout_im.Type,dout_vld.Type];

    OUTMUX=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MINRESRX2FFT_OUTMux',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=OUTMUX.PirInputSignals;
    outputPort=OUTMUX.PirOutputSignals;

    rdEnb1=inputPort(1);
    rdEnb2=inputPort(2);
    rdEnb3=inputPort(3);
    dMemOut1_re=inputPort(4);
    dMemOut1_im=inputPort(5);
    dMemOut2_re=inputPort(6);
    dMemOut2_im=inputPort(7);
    vldOut=inputPort(8);
    syncReset=inputPort(9);

    HASRESETPORT=blockInfo.inMode(2);
    if~HASRESETPORT
        syncReset='';
    end

    dout_re=outputPort(1);
    dout_im=outputPort(2);
    dout_vld=outputPort(3);

    dType=dMemOut1_re.Type;
    WORDLENGTH=dType.WordLength;
    FRACTIONLENGTH=-dType.FractionLength;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','minResRX2FFTOutMux.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='minResRX2FFTOutMux';
    ctrl_inst=OUTMUX.addComponent2(...
    'kind','cgireml',...
    'Name','minResRX2FFTOutMux',...
    'InputSignals',[rdEnb1,rdEnb2,rdEnb3,dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,vldOut],...
    'OutputSignals',[dout_re,dout_im,dout_vld],...
    'EMLFileName','minResRX2FFTOutMux',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{WORDLENGTH,FRACTIONLENGTH},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    ctrl_inst.runConcurrencyMaximizer(0);


