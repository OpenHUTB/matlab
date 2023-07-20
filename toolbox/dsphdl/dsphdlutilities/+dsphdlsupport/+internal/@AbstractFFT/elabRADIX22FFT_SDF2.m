function sdf2=elabRADIX22FFT_SDF2(this,topNet,blockInfo,stageNum,MEMSIZE,dataRate,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,ROTATION,...
    din_re,din_im,din_vld,rdAddr,rdEnb,...
    procEnb,multiply_J,softReset,...
    dout_re,dout_im,dout_vld,dinXTwdl_vld)






    InportNames={din_re.Name,din_im.Name,din_vld.Name,rdAddr.Name,rdEnb.Name,procEnb.Name,multiply_J.Name,softReset.Name};
    InportTypes=[din_re.Type;din_im.Type;din_vld.Type;rdAddr.Type;rdEnb.Type;procEnb.Type;multiply_J.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout_re.Name,dout_im.Name,dout_vld.Name,dinXTwdl_vld.Name};
    OutportTypes=[dout_re.Type;dout_im.Type;dout_vld.Type;dinXTwdl_vld.Type];

    sdf2=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_SDF2_',int2str(stageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=sdf2.PirInputSignals;
    outputPort=sdf2.PirOutputSignals;

    if inputPort(1).Type.WordLength==outputPort(1).Type.WordLength
        din_re=inputPort(1);
        din_im=inputPort(2);
    else
        din_re=sdf2.addSignal2('Type',dout_re.Type,'Name','din_re');
        din_re.SimulinkRate=dataRate;
        din_im=sdf2.addSignal2('Type',dout_im.Type,'Name','din_im');
        din_im.SimulinkRate=dataRate;

        pirelab.getDTCComp(sdf2,inputPort(1),din_re);
        pirelab.getDTCComp(sdf2,inputPort(2),din_im);
    end
    din_vld=inputPort(3);
    rdAddr=inputPort(4);
    rdEnb=inputPort(5);
    procEnb=inputPort(6);
    multiply_J=inputPort(7);
    softReset=inputPort(8);

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

    x_re=sdf2.addSignal2('Type',dout_re.Type,'Name','x_re');
    x_re.SimulinkRate=dataRate;
    x_im=sdf2.addSignal2('Type',dout_im.Type,'Name','x_im');
    x_im.SimulinkRate=dataRate;
    wrData_re=sdf2.addSignal2('Type',dout_re.Type,'Name','wrData_re');
    wrData_re.SimulinkRate=dataRate;
    wrData_im=sdf2.addSignal2('Type',dout_re.Type,'Name','wrData_im');
    wrData_im.SimulinkRate=dataRate;
    wrAddr=sdf2.addSignal2('Type',pir_fixpt_t(0,ADDRWIDTH,0),'Name','wrAddr');
    wrAddr.SimulinkRate=dataRate;
    wrEnb=sdf2.addSignal2('Type',pir_boolean_t,'Name','wrEnb');
    wrEnb.SimulinkRate=dataRate;



    if wrAddr.Type.WordLength==1
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@AbstractFFT','cgireml','twoLocationReg.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        desc='twoLocationReg_0';

        twoLocationReg_0=sdf2.addComponent2(...
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
        pirelab.getSimpleDualPortRamComp(sdf2,[wrData_re,wrAddr,wrEnb,rdAddr],x_re,['dataMEM_re_0_',int2str(stageNum)]);
        pirelab.getSimpleDualPortRamComp(sdf2,[wrData_im,wrAddr,wrEnb,rdAddr],x_im,['dataMEM_im_0_',int2str(stageNum)]);
    end

    x_vld=sdf2.addSignal2('Type',pir_boolean_t(),'Name','x_vld');
    x_vld.SimulinkRate=dataRate;
    x_vld_dly=sdf2.addSignal2('Type',pir_boolean_t(),'Name','x_vld_dly');
    x_vld_dly.SimulinkRate=dataRate;
    x_re_dly=sdf2.addSignal2('Type',dout_re.Type,'Name','x_re_dly');
    x_re_dly.SimulinkRate=dataRate;
    x_im_dly=sdf2.addSignal2('Type',dout_im.Type,'Name','x_im_dly');
    x_im_dly.SimulinkRate=dataRate;


    pirelab.getIntDelayEnabledResettableComp(sdf2,rdEnb,x_vld,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sdf2,x_vld,x_vld_dly,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sdf2,x_re,x_re_dly,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sdf2,x_im,x_im_dly,'',syncReset,1);



    xf_re=sdf2.addSignal2('Type',dout_re.Type,'Name','xf_re');
    xf_re.SimulinkRate=dataRate;
    xf_im=sdf2.addSignal2('Type',dout_im.Type,'Name','xf_im');
    xf_im.SimulinkRate=dataRate;
    xf_vld=sdf2.addSignal2('Type',pir_boolean_t,'Name','xf_vld');
    xf_vld.SimulinkRate=dataRate;
    dinf_re=sdf2.addSignal2('Type',dout_re.Type,'Name','dinf_re');
    dinf_re.SimulinkRate=dataRate;
    dinf_im=sdf2.addSignal2('Type',dout_im.Type,'Name','dinf_im');
    dinf_im.SimulinkRate=dataRate;
    dinf_vld=sdf2.addSignal2('Type',pir_boolean_t,'Name','dinf_vld');
    dinf_vld.SimulinkRate=dataRate;
    btf1_re=sdf2.addSignal2('Type',dout_re.Type,'Name','btf1_re');
    btf1_re.SimulinkRate=dataRate;
    btf1_im=sdf2.addSignal2('Type',dout_im.Type,'Name','btf1_im');
    btf1_im.SimulinkRate=dataRate;
    btf2_re=sdf2.addSignal2('Type',dout_re.Type,'Name','btf2_re');
    btf2_re.SimulinkRate=dataRate;
    btf2_im=sdf2.addSignal2('Type',dout_im.Type,'Name','btf2_im');
    btf2_im.SimulinkRate=dataRate;
    btfout_vld=sdf2.addSignal2('Type',pir_boolean_t,'Name','btfout_vld');
    btfout_vld.SimulinkRate=dataRate;


    dinVld=sdf2.addSignal2('Type',pir_boolean_t(),'Name','dinVld');
    dinVld.SimulinkRate=dataRate;
    saveEnb=sdf2.addSignal2('Type',pir_boolean_t(),'Name','saveEnb');
    saveEnb.SimulinkRate=dataRate;
    btfin_re=sdf2.addSignal2('Type',dout_re.Type,'Name','btfin_re');
    btfin_re.SimulinkRate=dataRate;
    btfin_im=sdf2.addSignal2('Type',dout_re.Type,'Name','btfin_im');
    btfin_im.SimulinkRate=dataRate;
    btfin_vld=sdf2.addSignal2('Type',pir_boolean_t(),'Name','btfin_vld');
    btfin_vld.SimulinkRate=dataRate;
    if MEMSIZE>2
        pirelab.getWireComp(sdf2,din_re,btfin_re);
        pirelab.getWireComp(sdf2,din_im,btfin_im);
        pirelab.getLogicComp(sdf2,[din_vld,procEnb],btfin_vld,'and');
        pirelab.getLogicComp(sdf2,btfin_vld,saveEnb,'not');
        pirelab.getLogicComp(sdf2,[din_vld,saveEnb],dinVld,'and');
    else
        procEnb_dly1=sdf2.addSignal2('Type',pir_boolean_t(),'Name','procEnb_dly1');
        procEnb_dly1.SimulinkRate=dataRate;
        din_re_dly1=sdf2.addSignal2('Type',dout_re.Type,'Name','din_re_dly1');
        din_re_dly1.SimulinkRate=dataRate;
        din_im_dly1=sdf2.addSignal2('Type',dout_re.Type,'Name','din_im_dly1');
        din_im_dly1.SimulinkRate=dataRate;
        mulIn_vld=sdf2.addSignal2('Type',pir_boolean_t(),'Name','mulIn_vld');
        mulIn_vld.SimulinkRate=dataRate;

        pirelab.getIntDelayEnabledResettableComp(sdf2,din_re,din_re_dly1,'',syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(sdf2,din_re_dly1,btfin_re,'',syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(sdf2,din_im,din_im_dly1,'',syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(sdf2,din_im_dly1,btfin_im,'',syncReset,1);

        pirelab.getLogicComp(sdf2,[din_vld,procEnb],mulIn_vld,'and');
        pirelab.getIntDelayEnabledResettableComp(sdf2,mulIn_vld,procEnb_dly1,'',syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(sdf2,procEnb_dly1,btfin_vld,'',syncReset,1);

        pirelab.getLogicComp(sdf2,procEnb,saveEnb,'not');
        pirelab.getLogicComp(sdf2,[din_vld,saveEnb],dinVld,'and');
    end

    pirelab.getWireComp(sdf2,btfin_vld,dinXTwdl_vld);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22ButterflyG2.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22ButterflyG2';

    Radix22ButterflyG2=sdf2.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22ButterflyG2',...
    'InputSignals',[din_re,din_im,dinVld,btfin_re,btfin_im,btfin_vld,x_re_dly,x_im_dly,x_vld_dly,multiply_J],...
    'OutputSignals',[xf_re,xf_im,xf_vld,dinf_re,dinf_im,dinf_vld,btf1_re,btf1_im,btf2_re,btf2_im,btfout_vld],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22ButterflyG2',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,ROTATION,ROUNDINGMETHOD},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Radix22ButterflyG2.runConcurrencyMaximizer(0);


    commutator=this.elabRADIX22FFT_COMM(sdf2,blockInfo,stageNum,MEMSIZE,dataRate,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    din_vld,...
    xf_re,xf_im,xf_vld,...
    dinf_re,dinf_im,dinf_vld,...
    btf1_re,btf1_im,btf2_re,btf2_im,btfout_vld,softReset,...
    wrData_re,wrData_im,wrAddr,wrEnb,...
    dout_re,dout_im,dout_vld);
    pirelab.instantiateNetwork(sdf2,commutator,[din_vld,...
    xf_re,xf_im,xf_vld,...
    dinf_re,dinf_im,dinf_vld,...
    btf1_re,btf1_im,btf2_re,btf2_im,btfout_vld,softReset],...
    [wrData_re,wrData_im,wrAddr,wrEnb,...
    dout_re,dout_im,dout_vld],...
    ['SDFCOMMUTATOR','_',int2str(stageNum)]);
end

