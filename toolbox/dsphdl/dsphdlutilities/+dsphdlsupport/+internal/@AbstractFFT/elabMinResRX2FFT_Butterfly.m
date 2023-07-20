function butterfly=elabMinResRX2FFT_Butterfly(this,topNet,dataRate,blockInfo,...
    din1_re,din1_im,din2_re,din2_im,din_vld,...
    twdl_re,twdl_im,syncReset,...
    btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld)








    InportNames={din1_re.Name,din1_im.Name,din2_re.Name,din2_im.Name,din_vld.Name,twdl_re.Name,twdl_im.Name,syncReset.Name};
    InportTypes=[din1_re.Type,din1_im.Type,din2_re.Type,din2_im.Type,din_vld.Type,twdl_re.Type,twdl_im.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={btfOut1_re.Name,btfOut1_im.Name,btfOut2_re.Name,btfOut2_im.Name,btfOut_vld.Name};
    OutportTypes=[btfOut1_re.Type,btfOut1_im.Type,btfOut2_re.Type,btfOut2_im.Type,btfOut_vld.Type];



    butterfly=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MINRESRX2_BUTTERFLY',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=butterfly.PirInputSignals;
    outputPort=butterfly.PirOutputSignals;

    din1_re=inputPort(1);
    din1_im=inputPort(2);
    din2_re=inputPort(3);
    din2_im=inputPort(4);
    din_vld=inputPort(5);
    twdl_re=inputPort(6);
    twdl_im=inputPort(7);
    softReset=inputPort(8);

    ROUNDINGMETHOD=blockInfo.RoundingMethod;
    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=softReset;
    else
        syncReset='';
    end

    btfOut1_re=outputPort(1);
    btfOut1_im=outputPort(2);
    btfOut2_re=outputPort(3);
    btfOut2_im=outputPort(4);
    btfOut_vld=outputPort(5);











    dType=din1_re.Type;
    DATA_WORDLENGTH=dType.WordLength;
    DATA_FRACTIONLENGTH=dType.FractionLength;
    TWDL_WORDLENGTH=DATA_WORDLENGTH;
    TWDL_FRACTIONLENGTH=-(DATA_WORDLENGTH-2);
    NORMALIZE=blockInfo.Normalize;
    dinXTwdlType=pir_sfixpt_t(DATA_WORDLENGTH+TWDL_WORDLENGTH+1,DATA_FRACTIONLENGTH+TWDL_FRACTIONLENGTH);
    btfFPType=pir_sfixpt_t(DATA_WORDLENGTH+TWDL_WORDLENGTH+2,DATA_FRACTIONLENGTH+TWDL_FRACTIONLENGTH);

    dinXTwdl_re=butterfly.addSignal2('Type',dinXTwdlType,'Name','dinXTwdl_re');
    dinXTwdl_re.SimulinkRate=dataRate;
    dinXTwdl_im=butterfly.addSignal2('Type',dinXTwdlType,'Name','dinXTwdl_im');
    dinXTwdl_im.SimulinkRate=dataRate;
    dinXTwdl_vld=butterfly.addSignal2('Type',pir_boolean_t(),'Name','dinXTwdl_vld');
    dinXTwdl_vld.SimulinkRate=dataRate;

    din1Dly_re=butterfly.addSignal2('Type',dType,'Name','din1Dly_re');
    din1Dly_re.SimulinkRate=dataRate;
    din1Dly_im=butterfly.addSignal2('Type',dType,'Name','din1Dly_im');
    din1Dly_im.SimulinkRate=dataRate;
    din2Dly_re=butterfly.addSignal2('Type',dType,'Name','din2Dly_re');
    din2Dly_re.SimulinkRate=dataRate;
    din2Dly_im=butterfly.addSignal2('Type',dType,'Name','din2Dly_im');
    din2Dly_im.SimulinkRate=dataRate;
    din1Dly_vld=butterfly.addSignal2('Type',pir_boolean_t(),'Name','din1Dly_vld');
    din1Dly_vld.SimulinkRate=dataRate;
    din2Dly_vld=butterfly.addSignal2('Type',pir_boolean_t(),'Name','din2Dly_vld');
    din2Dly_vld.SimulinkRate=dataRate;

    btfOut1FP_re=butterfly.addSignal2('Type',btfFPType,'Name','btfOut1FP_re');
    btfOut1FP_re.SimulinkRate=dataRate;
    btfOut1FP_im=butterfly.addSignal2('Type',btfFPType,'Name','btfOut1FP_im');
    btfOut1FP_im.SimulinkRate=dataRate;
    btfOut2FP_re=butterfly.addSignal2('Type',btfFPType,'Name','btfOut2FP_re');
    btfOut2FP_re.SimulinkRate=dataRate;
    btfOut2FP_im=butterfly.addSignal2('Type',btfFPType,'Name','btfOut2FP_im');
    btfOut2FP_im.SimulinkRate=dataRate;


    if strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
        MUL3=this.elabComplex3Multiply(butterfly,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
        din2Dly_re,din2Dly_im,din2Dly_vld,twdl_re,twdl_im,softReset,dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld);
        pirelab.instantiateNetwork(butterfly,MUL3,[din2Dly_re,din2Dly_im,din2Dly_vld,twdl_re,twdl_im,softReset],[dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld],...
        'MUL3');
    else
        MUL4=this.elabComplex4Multiply(butterfly,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
        din2_re,din2_im,din2Dly_vld,twdl_re,twdl_im,softReset,dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld);
        pirelab.instantiateNetwork(butterfly,MUL4,[din2Dly_re,din2Dly_im,din_vld,twdl_re,twdl_im,softReset],[dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld],...
        'MUL4');
    end

    pirelab.getIntDelayEnabledResettableComp(butterfly,din1_re,din1Dly_re,'',syncReset,8);
    pirelab.getIntDelayEnabledResettableComp(butterfly,din1_im,din1Dly_im,'',syncReset,8);
    pirelab.getIntDelayEnabledResettableComp(butterfly,din_vld,din1Dly_vld,'',syncReset,8);
    pirelab.getIntDelayEnabledResettableComp(butterfly,din2_re,din2Dly_re,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(butterfly,din2_im,din2Dly_im,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(butterfly,din_vld,din2Dly_vld,'',syncReset,2);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','minResRX2FFTButterfly.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='minResRX2FFTButterfly';
    minResRX2FFTButterfly=butterfly.addComponent2(...
    'kind','cgireml',...
    'Name','minResRX2FFTButterfly',...
    'InputSignals',[dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld,din1Dly_re,din1Dly_im,din1Dly_vld],...
    'OutputSignals',[btfOut1FP_re,btfOut1FP_im,btfOut2FP_re,btfOut2FP_im,btfOut_vld],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','minResRX2FFTButterfly',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,NORMALIZE,ROUNDINGMETHOD},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    minResRX2FFTButterfly.runConcurrencyMaximizer(0);


    pirelab.getDTCComp(butterfly,btfOut1FP_re,btfOut1_re,blockInfo.RoundingMethod);
    pirelab.getDTCComp(butterfly,btfOut1FP_im,btfOut1_im,blockInfo.RoundingMethod);
    pirelab.getDTCComp(butterfly,btfOut2FP_re,btfOut2_re,blockInfo.RoundingMethod);
    pirelab.getDTCComp(butterfly,btfOut2FP_im,btfOut2_im,blockInfo.RoundingMethod);
