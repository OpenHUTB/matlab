function stageBitNatural=elabRADIX22FFT_bitNatural(this,topNet,blockInfo,dataRate,DATA_VECSIZE,inIndex,din_re,din_im,din_vld,synReset,dout_re,dout_im,dout_vld,startOutS,endOutS)%#ok<INUSD>






    inPortNames={din_re.Name,din_im.Name,din_vld.Name,synReset.Name};
    inPortTypes=[din_re.Type;din_im.Type;din_vld.Type;synReset.Type];
    inPortRates=[dataRate;dataRate;dataRate;dataRate];
    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        outPortNames={dout_re.Name,dout_im.Name,dout_vld.Name,startOutS.Name,endOutS.Name};
        outPortTypes=[dout_re.Type;dout_im.Type;dout_vld.Type;startOutS.Type;endOutS.Type];
    elseif blockInfo.outMode(1)
        outPortNames={dout_re.Name,dout_im.Name,dout_vld.Name,startOutS.Name};
        outPortTypes=[dout_re.Type;dout_im.Type;dout_vld.Type;startOutS.Type];
    elseif blockInfo.outMode(2)
        outPortNames={dout_re.Name,dout_im.Name,dout_vld.Name,endOutS.Name};
        outPortTypes=[dout_re.Type;dout_im.Type;dout_vld.Type;endOutS.Type];
    else
        outPortNames={dout_re.Name,dout_im.Name,dout_vld.Name};
        outPortTypes=[dout_re.Type;dout_im.Type;dout_vld.Type];
    end

    stageBitNatural=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_bitNatural_',int2str(inIndex)],...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inputPort=stageBitNatural.PirInputSignals;
    outputPorts=stageBitNatural.PirOutputSignals;

    for inputIndex=1:DATA_VECSIZE
        din_re(inputIndex)=inputPort(1).split.PirOutputSignals(inputIndex);
        din_im(inputIndex)=inputPort(2).split.PirOutputSignals(inputIndex);
    end
    din_vld=inputPort(3);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        synReset=inputPort(4);
    else
        synReset='';
    end

    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        dout_re=outputPorts(1);
        dout_im=outputPorts(2);
        dout_vld=outputPorts(3);
        startOutS=outputPorts(4);
        endOutS=outputPorts(5);
    elseif blockInfo.outMode(1)
        dout_re=outputPorts(1);
        dout_im=outputPorts(2);
        dout_vld=outputPorts(3);
        startOutS=outputPorts(4);
    elseif blockInfo.outMode(2)
        dout_re=outputPorts(1);
        dout_im=outputPorts(2);
        dout_vld=outputPorts(3);
        endOutS=outputPorts(4);
    else
        dout_re=outputPorts(1);
        dout_im=outputPorts(2);
        dout_vld=outputPorts(3);
    end

    FFTLENGTH=blockInfo.FFTLength;
    ADDRWIDTH=log2(double(FFTLENGTH/DATA_VECSIZE));
    WORDLENGTH=din_re(1).Type.WordLength;
    FRACTIONLENGTH=din_re(1).Type.FractionLength;
    IC=inIndex-1;
    INC=DATA_VECSIZE;

    UniqueBits=log2(double(DATA_VECSIZE));
    LowerBits=numerictype(0,UniqueBits,0);
    Xor=fi(zeros(DATA_VECSIZE,1),LowerBits);
    Xor_cycle=min(FFTLENGTH/DATA_VECSIZE,DATA_VECSIZE);
    Xor(:)=repmat((0:Xor_cycle-1)',DATA_VECSIZE/Xor_cycle,1);
    XORValue=Xor(inIndex);

    for inputIndex=1:DATA_VECSIZE
        din_re_reg(inputIndex)=stageBitNatural.addSignal2('Type',din_re(inputIndex).Type,'Name',['din_re_reg',int2str(inputIndex)]);%#ok<*AGROW>
        din_re_reg(inputIndex).SimulinkRate=dataRate;
        din_im_reg(inputIndex)=stageBitNatural.addSignal2('Type',din_im(inputIndex).Type,'Name',['din_im_reg',int2str(inputIndex)]);
        din_im_reg(inputIndex).SimulinkRate=dataRate;
    end
    memOut_re=stageBitNatural.addSignal2('Type',din_re(1).Type,'Name','memOut_re');
    memOut_re.SimulinkRate=dataRate;
    memOut_im=stageBitNatural.addSignal2('Type',din_im(1).Type,'Name','memOut_im');
    memOut_im.SimulinkRate=dataRate;
    wrEnb=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','WrEnb');
    wrEnb.SimulinkRate=dataRate;
    wrAddr=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','wrAddr');
    wrAddr.SimulinkRate=dataRate;
    wrAddr_reg=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','wrAddr_reg');
    wrAddr_reg.SimulinkRate=dataRate;
    rdEnb=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','rdEnb');
    rdEnb.SimulinkRate=dataRate;
    rdAddr=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','rdAddr');
    rdAddr.SimulinkRate=dataRate;


    memIn_re=stageBitNatural.addSignal2('Type',din_re(1).Type,'Name','memIn_re');
    memIn_re.SimulinkRate=dataRate;
    memIn_im=stageBitNatural.addSignal2('Type',din_im(1).Type,'Name','memIn_im');
    memIn_im.SimulinkRate=dataRate;
    memIn_re_reg=stageBitNatural.addSignal2('Type',din_re(1).Type,'Name','memIn_re_reg');
    memIn_re_reg.SimulinkRate=dataRate;
    memIn_im_reg=stageBitNatural.addSignal2('Type',din_im(1).Type,'Name','memIn_im_reg');
    memIn_im_reg.SimulinkRate=dataRate;
    wrEnb_reg=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','wrEnb_reg');
    wrEnb_reg.SimulinkRate=dataRate;
    sampleCnt=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','sampleCnt');
    sampleCnt.SimulinkRate=dataRate;
    sampleCntDly=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','sampleCntDly');
    sampleCntDly.SimulinkRate=dataRate;
    if wrAddr.Type.WordLength==1
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
        '+dsphdlsupport','+internal','@AbstractFFT','cgireml','twoLocationReg.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        desc='twoLocationReg_0';

        twoLocationReg_0=stageBitNatural.addComponent2(...
        'kind','cgireml',...
        'Name','twoLocationReg_0',...
        'InputSignals',[memIn_re_reg,memIn_im_reg,wrAddr_reg,wrEnb_reg,rdAddr],...
        'OutputSignals',[memOut_re,memOut_im],...
        'ExternalSynchronousResetSignal',synReset,...
        'EMLFileName','twoLocationReg',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{WORDLENGTH,FRACTIONLENGTH},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        twoLocationReg_0.runConcurrencyMaximizer(0);
    else
        pirelab.getSimpleDualPortRamComp(stageBitNatural,[memIn_re_reg,wrAddr_reg,wrEnb_reg,rdAddr],memOut_re,['dataMEM_re_',int2str(inIndex-1)]);
        pirelab.getSimpleDualPortRamComp(stageBitNatural,[memIn_im_reg,wrAddr_reg,wrEnb_reg,rdAddr],memOut_im,['dataMEM_im_',int2str(inIndex-1)]);
    end


    FFTIdx=stageBitNatural.addSignal2('Type',pir_ufixpt_t(log2(FFTLENGTH),0),'Name','FFTIdx');
    FFTIdx.SimulinkRate=dataRate;
    FFTIdxRev=stageBitNatural.addSignal2('Type',pir_ufixpt_t(log2(FFTLENGTH),0),'Name','FFTIdxRev');
    FFTIdxRev.SimulinkRate=dataRate;
    fftIdx_vld=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','fftIdx_vld');
    fftIdx_vld.SimulinkRate=dataRate;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','fftIdx.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='fftIdx';

    fftIdxGen=stageBitNatural.addComponent2(...
    'kind','cgireml',...
    'Name','fftIdx',...
    'InputSignals',din_vld,...
    'OutputSignals',[FFTIdx,FFTIdxRev,fftIdx_vld],...
    'ExternalSynchronousResetSignal',synReset,...
    'EMLFileName','fftIdx',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,IC,INC},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    fftIdxGen.runConcurrencyMaximizer(0);


    MUXSel=stageBitNatural.addSignal2('Type',pir_ufixpt_t(log2(double(DATA_VECSIZE)),0),'Name','MUXSel');
    MUXSel.SimulinkRate=dataRate;
    MUXSel_vld=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','MUXSel_vld');
    MUXSel_vld.SimulinkRate=dataRate;
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','inMuxSel.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='inMUXSel';

    inMUXSelGen=stageBitNatural.addComponent2(...
    'kind','cgireml',...
    'Name','inMuxSel',...
    'InputSignals',[FFTIdxRev,fftIdx_vld],...
    'OutputSignals',[MUXSel,MUXSel_vld],...
    'ExternalSynchronousResetSignal',synReset,...
    'EMLFileName','inMuxSel',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,DATA_VECSIZE,XORValue},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    inMUXSelGen.runConcurrencyMaximizer(0);


    for inputIndex=1:DATA_VECSIZE
        pirelab.getIntDelayEnabledResettableComp(stageBitNatural,din_re(inputIndex),din_re_reg(inputIndex),'','',1);
        pirelab.getIntDelayEnabledResettableComp(stageBitNatural,din_im(inputIndex),din_im_reg(inputIndex),'','',1);
    end
    pirelab.getMultiPortSwitchComp(stageBitNatural,[MUXSel,din_re_reg],memIn_re,1,1);
    pirelab.getMultiPortSwitchComp(stageBitNatural,[MUXSel,din_im_reg],memIn_im,1,1);


    dly=log2(double(DATA_VECSIZE));
    pirelab.getIntDelayEnabledResettableComp(stageBitNatural,memIn_re,memIn_re_reg,'',synReset,dly);
    pirelab.getIntDelayEnabledResettableComp(stageBitNatural,memIn_im,memIn_im_reg,'',synReset,dly);
    pirelab.getIntDelayEnabledResettableComp(stageBitNatural,wrAddr,wrAddr_reg,'',synReset,dly);
    pirelab.getIntDelayEnabledResettableComp(stageBitNatural,wrEnb,wrEnb_reg,'',synReset,dly);
    pirelab.getIntDelayEnabledResettableComp(stageBitNatural,sampleCnt,sampleCntDly,'',synReset,dly+1);



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','wrAddrGenBitNaturalP.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='wrAddrGenBitNaturalP';

    wrAddrGenBitNaturalP=stageBitNatural.addComponent2(...
    'kind','cgireml',...
    'Name','wrAddrGenBitNaturalP',...
    'InputSignals',[FFTIdx,FFTIdxRev,fftIdx_vld],...
    'OutputSignals',[wrAddr,wrEnb,sampleCnt],...
    'ExternalSynchronousResetSignal',synReset,...
    'EMLFileName','wrAddrGenBitNaturalP',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,DATA_VECSIZE},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    wrAddrGenBitNaturalP.runConcurrencyMaximizer(0);


    startOutW=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','startOutW');
    startOutW.SimulinkRate=dataRate;
    endOutW=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','endOutW');
    endOutW.SimulinkRate=dataRate;
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','rdAddrGenBitNaturalP.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='rdAddrGenBitNaturalP';

    outputPorts=[rdAddr,dout_re,dout_im,dout_vld,startOutW,endOutW];
    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        pirelab.getWireComp(stageBitNatural,startOutW,startOutS);
        pirelab.getWireComp(stageBitNatural,endOutW,endOutS);
    elseif blockInfo.outMode(1)
        pirelab.getWireComp(stageBitNatural,startOutW,startOutS);
    elseif blockInfo.outMode(2)
        pirelab.getWireComp(stageBitNatural,endOutW,endOutS);
    end

    rdAddrGenBitNaturalP=stageBitNatural.addComponent2(...
    'kind','cgireml',...
    'Name','rdAddrGenBitNaturalP',...
    'InputSignals',[sampleCntDly,memOut_re,memOut_im],...
    'OutputSignals',outputPorts,...
    'ExternalSynchronousResetSignal',synReset,...
    'EMLFileName','rdAddrGenBitNaturalP',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{IC,INC,FFTLENGTH,DATA_VECSIZE},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    rdAddrGenBitNaturalP.runConcurrencyMaximizer(0);

end
