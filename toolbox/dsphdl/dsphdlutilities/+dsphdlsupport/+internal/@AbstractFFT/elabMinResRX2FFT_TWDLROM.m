function twdlROM=elabMinResRX2FFT_TWDLROM(this,topNet,dataRate,blockInfo,...
    din_vld,stage,initIC,syncReset,twdl_re,twdl_im,twdl_vld)





    InportNames={din_vld.Name,stage.Name,initIC.Name,syncReset.Name};
    InportTypes=[din_vld.Type;stage.Type;initIC.Type;syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate];

    OutportNames={twdl_re.Name,twdl_im.Name,twdl_vld.Name};
    OutportTypes=[twdl_re.Type;twdl_im.Type;twdl_vld.Type];

    twdlROM=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','TWDLROM',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=twdlROM.PirInputSignals;
    outputPort=twdlROM.PirOutputSignals;

    din_vld=inputPort(1);
    stage=inputPort(2);
    initIC=inputPort(3);
    synReset=inputPort(4);
    twdl_re=outputPort(1);
    twdl_im=outputPort(2);
    twdl_vld=outputPort(3);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=synReset;
    else
        syncReset='';
    end
    BITREVERSEDINPUT=blockInfo.BitReversedInput;
    fimath_int=fimath('OverflowAction','Wrap','RoundingMethod','Floor');
    TWDL_WORDLENGTH=twdl_re.Type.WordLength;
    TWDL_FRACTIONLENGTH=twdl_re.Type.FractionLength;
    reqNumberOfTwdls=(0:blockInfo.FFTLength)/(blockInfo.FFTLength);
    reqNumberOfTwdls=reqNumberOfTwdls(reqNumberOfTwdls<1/8);
    twiddleTable=fi(exp(-1i*2*pi*reqNumberOfTwdls).',1,TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH,'RoundingMethod','Convergent','OverflowAction','Wrap');
    twiddle_data=fi(twiddleTable,1,TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH,fimath_int);

    twdlAddr=twdlROM.addSignal2('Type',pir_ufixpt_t(max(log2(blockInfo.FFTLength/8),1),0),'Name','twdlAddr');
    twdlAddr.SimulinkRate=dataRate;
    twdlAddrVld=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdlAddrVld');
    twdlAddrVld.SimulinkRate=dataRate;

    twdlVldReg=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdlVldReg');
    twdlVldReg.SimulinkRate=dataRate;
    twdlOctant=twdlROM.addSignal2('Type',pir_ufixpt_t(3,0),'Name','twdlOctant');
    twdlOctant.SimulinkRate=dataRate;
    twdlOctantReg=twdlROM.addSignal2('Type',pir_ufixpt_t(3,0),'Name','twdlOctantReg');
    twdlOctantReg.SimulinkRate=dataRate;
    twdl45=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdl45');
    twdl45.SimulinkRate=dataRate;
    twdl45Reg=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdl45Reg');
    twdl45Reg.SimulinkRate=dataRate;

    twiddleS_re=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleS_re');
    twiddleS_re.SimulinkRate=dataRate;
    twiddleS_im=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleS_im');
    twiddleS_im.SimulinkRate=dataRate;

    twiddleReg_re=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleReg_re');
    twiddleReg_re.SimulinkRate=dataRate;
    twiddleReg_im=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleReg_im');
    twiddleReg_im.SimulinkRate=dataRate;

    twiddleROM1=pirelab.getDirectLookupComp(twdlROM,twdlAddr,twiddleS_re,twiddle_data.real,'Twiddle_re');
    twiddleROM1.addComment('Twiddle ROM1');
    twiddleROM2=pirelab.getDirectLookupComp(twdlROM,twdlAddr,twiddleS_im,twiddle_data.imag,'Twiddle_im');
    twiddleROM2.addComment('Twiddle ROM2');

    pirelab.getUnitDelayComp(twdlROM,twiddleS_re,twiddleReg_re,'TWIDDLEROM_RE',0,blockInfo.resetnone);
    pirelab.getUnitDelayComp(twdlROM,twiddleS_im,twiddleReg_im,'TWIDDLEROM_IM',0,blockInfo.resetnone);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@AbstractFFT','cgireml','minResRX2FFTTwdlMapping.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='minResRX2FFTTwdlMapping';

    twdlMapping=twdlROM.addComponent2(...
    'kind','cgireml',...
    'Name','minResRX2FFTTwdlMapping',...
    'InputSignals',[din_vld,stage,initIC],...
    'OutputSignals',[twdlAddr,twdlAddrVld,twdlOctant,twdl45],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','minResRX2FFTTwdlMapping',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.FFTLength,BITREVERSEDINPUT},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    twdlMapping.runConcurrencyMaximizer(0);

    pirelab.getIntDelayEnabledResettableComp(twdlROM,twdlAddrVld,twdl_vld,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(twdlROM,twdlOctant,twdlOctantReg,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(twdlROM,twdl45,twdl45Reg,'',syncReset,1);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22TwdlOctCorr.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22TwdlOctCorr';

    twdlCorr=twdlROM.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22TwdlOctCorr',...
    'InputSignals',[twiddleReg_re,twiddleReg_im,twdlOctantReg,twdl45Reg],...
    'OutputSignals',[twdl_re,twdl_im],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22TwdlOctCorr',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    twdlCorr.runConcurrencyMaximizer(0);
