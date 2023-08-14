function sdf1=elabRADIX22FFT_SDF1(this,topNet,blockInfo,stageNum,MEMSIZE,dataRate,BITREVERSEDINPUT,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,NORMALIZE,...
    din_re,din_im,din_vld,rdAddr,rdEnb,...
    twdl_re,twdl_im,twdl_vld,...
    procEnb,softReset,...
    dout_re,dout_im,dout_vld,dinXTwdl_vld)






    InportNames={din_re.Name,din_im.Name,din_vld.Name,rdAddr.Name,rdEnb.Name,twdl_re.Name,twdl_im.Name,twdl_vld.Name,procEnb.Name,softReset.Name};
    InportTypes=[din_re.Type;din_im.Type;din_vld.Type;rdAddr.Type;rdEnb.Type;twdl_re.Type;twdl_im.Type;twdl_vld.Type;procEnb.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout_re.Name,dout_im.Name,dout_vld.Name,dinXTwdl_vld.Name};
    OutportTypes=[dout_re.Type;dout_im.Type;dout_vld.Type;dinXTwdl_vld.Type];

    sdf1=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_SDF1_',int2str(stageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=sdf1.PirInputSignals;
    outputPort=sdf1.PirOutputSignals;

    if inputPort(1).Type.WordLength==outputPort(1).Type.WordLength
        din_re=inputPort(1);
        din_im=inputPort(2);
    else
        din_re=sdf1.addSignal2('Type',dout_re.Type,'Name','din_re');
        din_re.SimulinkRate=dataRate;
        din_im=sdf1.addSignal2('Type',dout_im.Type,'Name','din_im');
        din_im.SimulinkRate=dataRate;

        pirelab.getDTCComp(sdf1,inputPort(1),din_re);
        pirelab.getDTCComp(sdf1,inputPort(2),din_im);
    end
    din_vld=inputPort(3);
    rdAddr=inputPort(4);
    rdEnb=inputPort(5);
    twdl_re=inputPort(6);
    twdl_im=inputPort(7);
    twdl_vld=inputPort(8);
    procEnb=inputPort(9);
    softReset=inputPort(10);

    ROUNDINGMETHOD=blockInfo.RoundingMethod;
    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=softReset;
    else
        syncReset='';
    end

    dout_re=outputPort(1);
    dout_im=outputPort(2);
    dout_vld=outputPort(3);
    dinXTwdl_vld=outputPort(4);

    if MEMSIZE==1
        ADDRWIDTH=1;
    else
        ADDRWIDTH=log2(MEMSIZE);
    end

    x_re=sdf1.addSignal2('Type',dout_re.Type,'Name','x_re');
    x_re.SimulinkRate=dataRate;
    x_im=sdf1.addSignal2('Type',dout_im.Type,'Name','x_im');
    x_im.SimulinkRate=dataRate;
    wrData_re=sdf1.addSignal2('Type',dout_re.Type,'Name','wrData_re');
    wrData_re.SimulinkRate=dataRate;
    wrData_im=sdf1.addSignal2('Type',dout_re.Type,'Name','wrData_im');
    wrData_im.SimulinkRate=dataRate;
    wrAddr=sdf1.addSignal2('Type',pir_fixpt_t(0,ADDRWIDTH,0),'Name','wrAddr');
    wrAddr.SimulinkRate=dataRate;
    wrEnb=sdf1.addSignal2('Type',pir_boolean_t,'Name','wrEnb');
    wrEnb.SimulinkRate=dataRate;


    if blockInfo.InputDataIsReal&&stageNum==1&&(~BITREVERSEDINPUT)
        if blockInfo.inverseFFT
            if wrAddr.Type.WordLength==1
                fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
                '+dsphdlsupport','+internal','@AbstractFFT','cgireml','twoLocationReg.m'),'r');
                fcnBody=fread(fid,Inf,'char=>char')';
                fclose(fid);

                desc='twoLocationReg_0';

                twoLocationReg_0=sdf1.addComponent2(...
                'kind','cgireml',...
                'Name','twoLocationReg_0',...
                'InputSignals',[wrData_re,wrData_im,wrAddr,wrEnb,rdAddr],...
                'OutputSignals',[x_re,x_im],...
                'ExternalSynchronousResetSignal',syncReset,...
                'EMLFileName','twoLocationReg',...
                'EMLFileBody',fcnBody,...
                'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH},...
                'EMLFlag_TreatInputIntsAsFixpt',true,...
                'EMLFlag_SaturateOnIntOverflow',false,...
                'EMLFlag_TreatInputBoolsAsUfix1',false,...
                'BlockComment',desc);

                twoLocationReg_0.runConcurrencyMaximizer(0);
            else
                pirelab.getSimpleDualPortRamComp(sdf1,[wrData_im,wrAddr,wrEnb,rdAddr],x_im,['dataMEM_im_0_',int2str(stageNum)]);
                pirelab.getConstComp(sdf1,x_re,0);
            end
        else
            if wrAddr.Type.WordLength==1
                fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
                '+dsphdlsupport','+internal','@AbstractFFT','cgireml','twoLocationReg.m'),'r');
                fcnBody=fread(fid,Inf,'char=>char')';
                fclose(fid);

                desc='twoLocationReg_0';

                twoLocationReg_0=sdf1.addComponent2(...
                'kind','cgireml',...
                'Name','twoLocationReg_0',...
                'InputSignals',[wrData_re,wrData_im,wrAddr,wrEnb,rdAddr],...
                'OutputSignals',[x_re,x_im],...
                'ExternalSynchronousResetSignal',syncReset,...
                'EMLFileName','twoLocationReg',...
                'EMLFileBody',fcnBody,...
                'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH},...
                'EMLFlag_TreatInputIntsAsFixpt',true,...
                'EMLFlag_SaturateOnIntOverflow',false,...
                'EMLFlag_TreatInputBoolsAsUfix1',false,...
                'BlockComment',desc);

                twoLocationReg_0.runConcurrencyMaximizer(0);
            else
                pirelab.getSimpleDualPortRamComp(sdf1,[wrData_re,wrAddr,wrEnb,rdAddr],x_re,['dataMEM_re_0_',int2str(stageNum)]);
                pirelab.getConstComp(sdf1,x_im,0);
            end
        end
    else
        if wrAddr.Type.WordLength==1
            fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
            '@AbstractFFT','cgireml','twoLocationReg.m'),'r');
            fcnBody=fread(fid,Inf,'char=>char')';
            fclose(fid);

            desc='twoLocationReg_0';

            twoLocationReg_0=sdf1.addComponent2(...
            'kind','cgireml',...
            'Name','twoLocationReg_0',...
            'InputSignals',[wrData_re,wrData_im,wrAddr,wrEnb,rdAddr],...
            'OutputSignals',[x_re,x_im],...
            'ExternalSynchronousResetSignal',syncReset,...
            'EMLFileName','twoLocationReg',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH},...
            'EMLFlag_TreatInputIntsAsFixpt',true,...
            'EMLFlag_SaturateOnIntOverflow',false,...
            'EMLFlag_TreatInputBoolsAsUfix1',false,...
            'BlockComment',desc);

            twoLocationReg_0.runConcurrencyMaximizer(0);
        else
            pirelab.getSimpleDualPortRamComp(sdf1,[wrData_re,wrAddr,wrEnb,rdAddr],x_re,['dataMEM_re_0_',int2str(stageNum)]);
            pirelab.getSimpleDualPortRamComp(sdf1,[wrData_im,wrAddr,wrEnb,rdAddr],x_im,['dataMEM_im_0_',int2str(stageNum)]);
        end
    end

    btf_dVld=sdf1.addSignal2('Type',pir_boolean_t(),'Name','dtf_dVld');
    btf_dVld.SimulinkRate=dataRate;
    dinXTwdlf_vld=sdf1.addSignal2('Type',pir_boolean_t(),'Name','doutf_vld');
    dinXTwdlf_vld.SimulinkRate=dataRate;
    xf_vld=sdf1.addSignal2('Type',pir_boolean_t(),'Name','xf_vld');
    xf_vld.SimulinkRate=dataRate;
    x_vld=sdf1.addSignal2('Type',pir_boolean_t(),'Name','x_vld');
    x_vld.SimulinkRate=dataRate;
    x_vld_dly=sdf1.addSignal2('Type',pir_boolean_t(),'Name','x_vld_dly');
    x_vld_dly.SimulinkRate=dataRate;
    x_re_dly=sdf1.addSignal2('Type',dout_re.Type,'Name','x_re_dly');
    x_re_dly.SimulinkRate=dataRate;
    x_im_dly=sdf1.addSignal2('Type',dout_im.Type,'Name','x_im_dly');
    x_im_dly.SimulinkRate=dataRate;


    pirelab.getIntDelayEnabledResettableComp(sdf1,rdEnb,x_vld,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sdf1,x_vld,x_vld_dly,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sdf1,x_re,x_re_dly,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sdf1,x_im,x_im_dly,'',syncReset,1);


    dinXTwdl_re=sdf1.addSignal2('Type',pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH),'Name','dinXTwdl_re');
    dinXTwdl_re.SimulinkRate=dataRate;
    dinXTwdl_im=sdf1.addSignal2('Type',pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH),'Name','dinXTwdl_im');
    dinXTwdl_im.SimulinkRate=dataRate;

    mulIn_vld=sdf1.addSignal2('Type',pir_boolean_t(),'Name','mulIn_vld');
    mulIn_vld.SimulinkRate=dataRate;

    pirelab.getLogicComp(sdf1,[din_vld,procEnb],mulIn_vld,'and');


    if stageNum==1
        pirelab.getIntDelayEnabledResettableComp(sdf1,din_re,dinXTwdl_re,'',syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(sdf1,din_im,dinXTwdl_im,'',syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(sdf1,din_vld,dinXTwdl_vld,'',syncReset,1);
    elseif strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
        MUL3=this.elabComplex3Multiply(sdf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
        din_re,din_im,din_vld,twdl_re,twdl_im,softReset,dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld);
        pirelab.instantiateNetwork(sdf1,MUL3,[din_re,din_im,din_vld,twdl_re,twdl_im,softReset],[dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld],...
        'MUL3');
    else
        MUL4=this.elabComplex4Multiply(sdf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
        din_re,din_im,din_vld,twdl_re,twdl_im,softReset,dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld);
        pirelab.instantiateNetwork(sdf1,MUL4,[din_re,din_im,din_vld,twdl_re,twdl_im,softReset],[dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld],...
        'MUL4');
    end


    xf_re=sdf1.addSignal2('Type',dout_re.Type,'Name','xf_re');
    xf_re.SimulinkRate=dataRate;
    xf_im=sdf1.addSignal2('Type',dout_im.Type,'Name','xf_im');
    xf_im.SimulinkRate=dataRate;
    xf_vld=sdf1.addSignal2('Type',pir_boolean_t,'Name','xf_vld');
    xf_vld.SimulinkRate=dataRate;
    dinXTwdlf_re=sdf1.addSignal2('Type',dout_re.Type,'Name','dinXTwdlf_re');
    dinXTwdlf_re.SimulinkRate=dataRate;
    dinXTwdlf_im=sdf1.addSignal2('Type',dout_im.Type,'Name','dinXTwdlf_im');
    dinXTwdlf_im.SimulinkRate=dataRate;
    dinXTwdlf_vld=sdf1.addSignal2('Type',pir_boolean_t,'Name','dinxTwdlf_vld');
    dinXTwdlf_vld.SimulinkRate=dataRate;
    btf1_re=sdf1.addSignal2('Type',dout_re.Type,'Name','btf1_re');
    btf1_re.SimulinkRate=dataRate;
    btf1_im=sdf1.addSignal2('Type',dout_im.Type,'Name','btf1_im');
    btf1_im.SimulinkRate=dataRate;
    btf2_re=sdf1.addSignal2('Type',dout_re.Type,'Name','btf2_re');
    btf2_re.SimulinkRate=dataRate;
    btf2_im=sdf1.addSignal2('Type',dout_im.Type,'Name','btf2_im');
    btf2_im.SimulinkRate=dataRate;
    btf_vld=sdf1.addSignal2('Type',pir_boolean_t,'Name','btf_vld');
    btf_vld.SimulinkRate=dataRate;
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22ButterflyG1.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22ButterflyG1';


    Radix22ButterflyG1=sdf1.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22ButterflyG1',...
    'InputSignals',[procEnb,dinXTwdl_re,dinXTwdl_im,dinXTwdl_vld,x_re,x_im,x_vld],...
    'OutputSignals',[xf_re,xf_im,xf_vld,dinXTwdlf_re,dinXTwdlf_im,dinXTwdlf_vld,btf1_re,btf1_im,btf2_re,btf2_im,btf_vld],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22ButterflyG1',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,MEMSIZE,ROUNDINGMETHOD},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Radix22ButterflyG1.runConcurrencyMaximizer(0);


    commutator=this.elabRADIX22FFT_COMM(sdf1,blockInfo,stageNum,MEMSIZE,dataRate,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    din_vld,...
    xf_re,xf_im,xf_vld,...
    dinXTwdlf_re,dinXTwdlf_im,dinXTwdlf_vld,...
    btf1_re,btf1_im,btf2_re,btf2_im,btf_vld,softReset,...
    wrData_re,wrData_im,wrAddr,wrEnb,...
    dout_re,dout_im,dout_vld);
    pirelab.instantiateNetwork(sdf1,commutator,[din_vld,...
    xf_re,xf_im,xf_vld,...
    dinXTwdlf_re,dinXTwdlf_im,dinXTwdlf_vld,...
    btf1_re,btf1_im,btf2_re,btf2_im,btf_vld,softReset],...
    [wrData_re,wrData_im,wrAddr,wrEnb,...
    dout_re,dout_im,dout_vld],...
    ['SDFCOMMUTATOR','_',int2str(stageNum)]);

end


