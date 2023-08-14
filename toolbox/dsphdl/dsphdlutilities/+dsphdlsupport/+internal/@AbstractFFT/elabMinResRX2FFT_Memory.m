function MEMORY=elabMinResRX2FFT_Memory(this,topNet,dataRate,blockInfo,...
    wrData1_re,wrData1_im,wrData2_re,wrData2_im,...
    wrEnb1,wrEnb2,wrEnb3,rdEnb1,rdEnb2,rdEnb3,...
    stage,initIC,unLoadPhase,syncReset,...
    rdData1_re,rdData1_im,rdData2_re,rdData2_im)





    InportNames={wrData1_re.Name,wrData1_im.Name,wrData2_re.Name,wrData2_im.Name,...
    wrEnb1.Name,wrEnb2.Name,wrEnb3.Name,rdEnb1.Name,rdEnb2.Name,rdEnb3.Name,...
    stage.Name,initIC.Name,unLoadPhase.Name,syncReset.Name};
    InportTypes=[wrData1_re.Type,wrData1_im.Type,wrData2_re.Type,wrData2_im.Type,...
    wrEnb1.Type,wrEnb2.Type,wrEnb3.Type,rdEnb1.Type,rdEnb2.Type,rdEnb3.Type,...
    stage.Type,initIC.Type,unLoadPhase.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={rdData1_re.Name,rdData1_im.Name,rdData2_re.Name,rdData2_im.Name};

    OutportTypes=[rdData1_re.Type,rdData1_im.Type,rdData2_re.Type,rdData2_im.Type];

    MEMORY=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MINRESRX2FFT_MEMORY',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=MEMORY.PirInputSignals;
    outputPort=MEMORY.PirOutputSignals;

    wrData1_re=inputPort(1);
    wrData1_im=inputPort(2);
    wrData2_re=inputPort(3);
    wrData2_im=inputPort(4);
    wrEnb1=inputPort(5);
    wrEnb2=inputPort(6);
    wrEnb3=inputPort(7);
    rdEnb1=inputPort(8);
    rdEnb2=inputPort(9);
    rdEnb3=inputPort(10);
    stage=inputPort(11);
    initIC=inputPort(12);
    unLoadPhase=inputPort(13);
    syncReset=inputPort(14);

    HASRESETPORT=blockInfo.inMode(2);
    if~HASRESETPORT
        syncReset='';
    end

    rdData1_re=outputPort(1);
    rdData1_im=outputPort(2);
    rdData2_re=outputPort(3);
    rdData2_im=outputPort(4);

    FFTLENGTH=blockInfo.FFTLength;
    BITREVIN=blockInfo.BitReversedInput;
    addrType=pir_fixpt_t(0,log2(FFTLENGTH/2),0);
    dataType=wrData1_re.Type;
    DATA_WORDLENGTH=dataType.WordLength;
    DATA_FRACTIONLENGTH=dataType.Fractionlength;

    wrData01_re=wrData1_re;
    wrData01_im=wrData1_im;

    wrData10_re=wrData2_re;
    wrData10_im=wrData2_im;
    wrData11_re=wrData2_re;
    wrData11_im=wrData2_im;

    wrData01Dly_re=MEMORY.addSignal2('Type',dataType,'Name','wrData01Dly_re');
    wrData01Dly_re.SimulinkRate=dataRate;
    wrData10Dly_re=MEMORY.addSignal2('Type',dataType,'Name','wrData10Dly_re');
    wrData10Dly_re.SimulinkRate=dataRate;
    wrData11Dly_re=MEMORY.addSignal2('Type',dataType,'Name','wrData11Dly_re');
    wrData11Dly_re.SimulinkRate=dataRate;
    wrData01Dly_im=MEMORY.addSignal2('Type',dataType,'Name','wrData01Dly_im');
    wrData01Dly_im.SimulinkRate=dataRate;
    wrData10Dly_im=MEMORY.addSignal2('Type',dataType,'Name','wrData10Dly_im');
    wrData10Dly_im.SimulinkRate=dataRate;
    wrData11Dly_im=MEMORY.addSignal2('Type',dataType,'Name','wrData11Dly_im');
    wrData11Dly_im.SimulinkRate=dataRate;

    rdData01_re=MEMORY.addSignal2('Type',dataType,'Name','rdData01_re');
    rdData01_re.SimulinkRate=dataRate;
    rdData10_re=MEMORY.addSignal2('Type',dataType,'Name','rdData10_re');
    rdData10_re.SimulinkRate=dataRate;
    rdData11_re=MEMORY.addSignal2('Type',dataType,'Name','rdData11_re');
    rdData11_re.SimulinkRate=dataRate;
    rdData01_im=MEMORY.addSignal2('Type',dataType,'Name','rdData01_im');
    rdData01_im.SimulinkRate=dataRate;
    rdData10_im=MEMORY.addSignal2('Type',dataType,'Name','rdData10_im');
    rdData10_im.SimulinkRate=dataRate;
    rdData11_im=MEMORY.addSignal2('Type',dataType,'Name','rdData11_im');
    rdData11_im.SimulinkRate=dataRate;

    rdAddr01=MEMORY.addSignal2('Type',addrType,'Name','rdAddr01');
    rdAddr01.SimulinkRate=dataRate;
    rdAddr10=MEMORY.addSignal2('Type',addrType,'Name','rdAddr10');
    rdAddr10.SimulinkRate=dataRate;
    rdAddr01_tmp=MEMORY.addSignal2('Type',addrType,'Name','rdAddr01_tmp');
    rdAddr01_tmp.SimulinkRate=dataRate;
    rdAddr10_tmp=MEMORY.addSignal2('Type',addrType,'Name','rdAddr10_tmp');
    rdAddr10_tmp.SimulinkRate=dataRate;

    memSel=MEMORY.addSignal2('Type',pir_boolean_t,'Name','memSel');%#ok<*AGROW>
    memSel.SimulinkRate=dataRate;

    wrAddr01=MEMORY.addSignal2('Type',addrType,'Name','wrAddr01');
    wrAddr01.SimulinkRate=dataRate;
    wrAddr10=MEMORY.addSignal2('Type',addrType,'Name','wrAddr10');
    wrAddr10.SimulinkRate=dataRate;

    wrEnb01=MEMORY.addSignal2('Type',pir_boolean_t,'Name','wrEnb01');%#ok<*AGROW>
    wrEnb01.SimulinkRate=dataRate;
    wrEnb10=MEMORY.addSignal2('Type',pir_boolean_t,'Name','wrEnb10');%#ok<*AGROW>
    wrEnb10.SimulinkRate=dataRate;
    wrEnb11=MEMORY.addSignal2('Type',pir_boolean_t,'Name','wrEnb11');%#ok<*AGROW>
    wrEnb11.SimulinkRate=dataRate;

    pirelab.getIntDelayEnabledResettableComp(MEMORY,wrData01_re,wrData01Dly_re,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(MEMORY,wrData01_im,wrData01Dly_im,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(MEMORY,wrData10_re,wrData10Dly_re,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(MEMORY,wrData10_im,wrData10Dly_im,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(MEMORY,wrData11_re,wrData11Dly_re,'',syncReset,2);
    pirelab.getIntDelayEnabledResettableComp(MEMORY,wrData11_im,wrData11Dly_im,'',syncReset,2);


    if wrAddr01.Type.WordLength==1
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@AbstractFFT','cgireml','twoLocationReg.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        desc='twoLocationReg_0';

        twoLocationReg_0=MEMORY.addComponent2(...
        'kind','cgireml',...
        'Name','twoLocationReg_0',...
        'InputSignals',[wrData01Dly_re,wrData01Dly_im,wrAddr01,wrEnb01,rdAddr01],...
        'OutputSignals',[rdData1_re,rdData1_im],...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFileName','twoLocationReg',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        twoLocationReg_0.runConcurrencyMaximizer(0);

        desc='twoLocationReg_1';

        twoLocationReg_1=MEMORY.addComponent2(...
        'kind','cgireml',...
        'Name','twoLocationReg_1',...
        'InputSignals',[wrData10Dly_re,wrData10Dly_im,wrAddr10,wrEnb10,rdAddr10],...
        'OutputSignals',[rdData10_re,rdData10_im],...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFileName','twoLocationReg',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        twoLocationReg_1.runConcurrencyMaximizer(0);

        desc='twoLocationReg_2';

        twoLocationReg_2=MEMORY.addComponent2(...
        'kind','cgireml',...
        'Name','twoLocationReg_2',...
        'InputSignals',[wrData11Dly_re,wrData11Dly_im,wrAddr10,wrEnb11,rdAddr10],...
        'OutputSignals',[rdData11_re,rdData11_im],...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFileName','twoLocationReg',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        twoLocationReg_2.runConcurrencyMaximizer(0);
    else
        pirelab.getSimpleDualPortRamComp(MEMORY,[wrData01Dly_re,wrAddr01,wrEnb01,rdAddr01],rdData1_re,'dataMEM_re_01');
        pirelab.getSimpleDualPortRamComp(MEMORY,[wrData01Dly_im,wrAddr01,wrEnb01,rdAddr01],rdData1_im,'dataMEM_im_01');
        pirelab.getSimpleDualPortRamComp(MEMORY,[wrData10Dly_re,wrAddr10,wrEnb10,rdAddr10],rdData10_re,'dataMEM_re_10');
        pirelab.getSimpleDualPortRamComp(MEMORY,[wrData10Dly_im,wrAddr10,wrEnb10,rdAddr10],rdData10_im,'dataMEM_im_10');
        pirelab.getSimpleDualPortRamComp(MEMORY,[wrData11Dly_re,wrAddr10,wrEnb11,rdAddr10],rdData11_re,'dataMEM_re_11');
        pirelab.getSimpleDualPortRamComp(MEMORY,[wrData11Dly_im,wrAddr10,wrEnb11,rdAddr10],rdData11_im,'dataMEM_im_11');
    end

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','minResRX2FFTMEMCtrl.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='minResRX2FFTMEMCtrl';
    ctrl_inst=MEMORY.addComponent2(...
    'kind','cgireml',...
    'Name','minResRX2FFTMEMCtrl',...
    'InputSignals',[wrEnb1,wrEnb2,wrEnb3,rdEnb1,rdEnb2,rdEnb3,stage,rdData10_re,rdData10_im,rdData11_re,rdData11_im,initIC],...
    'OutputSignals',[wrEnb01,wrEnb10,wrEnb11,wrAddr01,wrAddr10,rdAddr01_tmp,rdAddr10_tmp,rdData2_re,rdData2_im],...
    'EMLFileName','minResRX2FFTMEMCtrl',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,BITREVIN},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    ctrl_inst.runConcurrencyMaximizer(0);


    if blockInfo.BitReversedOutput
        pirelab.getSwitchComp(MEMORY,[rdAddr01_tmp,rdAddr01_tmp],rdAddr01,unLoadPhase,'','==',1);
        pirelab.getSwitchComp(MEMORY,[rdAddr10_tmp,rdAddr01_tmp],rdAddr10,unLoadPhase,'','==',1);
    else
        for i=1:addrType.WordLength
            addr01Bit(i)=MEMORY.addSignal2('Type',pir_boolean_t,'Name',['addrBit01_',int2str(i)]);%#ok<*AGROW>
            addr01Bit(i).SimulinkRate=dataRate;
            addr10Bit(i)=MEMORY.addSignal2('Type',pir_boolean_t,'Name',['addrBit10_',int2str(i)]);%#ok<*AGROW>
            addr10Bit(i).SimulinkRate=dataRate;
            pirelab.getBitSliceComp(MEMORY,rdAddr01_tmp,addr01Bit(i),i-1,i-1);
            pirelab.getBitSliceComp(MEMORY,rdAddr10_tmp,addr10Bit(i),i-1,i-1);
        end
        rdAddr01_bitRev=MEMORY.addSignal2('Type',addrType,'Name','rdAddr01_bitRev');
        rdAddr01_bitRev.SimulinkRate=dataRate;
        rdAddr10_bitRev=MEMORY.addSignal2('Type',addrType,'Name','rdAddr10_bitRev');
        rdAddr10_bitRev.SimulinkRate=dataRate;
        pirelab.getBitConcatComp(MEMORY,addr01Bit,rdAddr01_bitRev);
        pirelab.getBitConcatComp(MEMORY,addr10Bit,rdAddr10_bitRev);
        pirelab.getSwitchComp(MEMORY,[rdAddr01_bitRev,rdAddr01_tmp],rdAddr01,unLoadPhase,'','==',1);
        pirelab.getSwitchComp(MEMORY,[rdAddr10_bitRev,rdAddr10_tmp],rdAddr10,unLoadPhase,'','==',1);
    end


end

