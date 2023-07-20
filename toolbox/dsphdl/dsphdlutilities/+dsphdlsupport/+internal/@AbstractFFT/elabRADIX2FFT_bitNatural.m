function stageBitNatural=elabRADIX2FFT_bitNatural(this,topNet,blockInfo,dataRate,din_re,din_im,din_vld,softReset,dout_re,dout_im,dout_vld,startOutS,endOutS)%#ok<INUSD>







    FFTLENGTH=blockInfo.FFTLength;
    ADDRWIDTH=log2(blockInfo.FFTLength);
    WORDLENGTH=din_re.Type.WordLength;
    FRACTIONLENGTH=din_re.Type.FractionLength;


    inPortNames={din_re.Name,din_im.Name,din_vld.Name,softReset.Name};
    inPortTypes=[din_re.Type;din_im.Type;din_vld.Type;softReset.Type];
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
    'Name','RADIX2FFT_bitNatural',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inputPort=stageBitNatural.PirInputSignals;
    outputPorts=stageBitNatural.PirOutputSignals;

    din_re=inputPort(1);
    din_im=inputPort(2);
    din_vld=inputPort(3);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        softReset=inputPort(4);
    else
        softReset='';
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

    memOut_re=stageBitNatural.addSignal2('Type',din_re.Type,'Name','memOut_re');
    memOut_re.SimulinkRate=dataRate;
    memOut_im=stageBitNatural.addSignal2('Type',din_im.Type,'Name','memOut_im');
    memOut_im.SimulinkRate=dataRate;
    wrEnb=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','WrEnb');
    wrEnb.SimulinkRate=dataRate;
    wrAddr=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','wrAddr');
    wrAddr.SimulinkRate=dataRate;
    rdEnb=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','rdEnb');
    rdEnb.SimulinkRate=dataRate;
    rdAddr=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','rdAddr');
    rdAddr.SimulinkRate=dataRate;
    sampleIdx=stageBitNatural.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','sampleIdx');
    sampleIdx.SimulinkRate=dataRate;

    pirelab.getSimpleDualPortRamComp(stageBitNatural,[din_re,wrAddr,wrEnb,rdAddr],memOut_re,'dataMEM_re_1');
    pirelab.getSimpleDualPortRamComp(stageBitNatural,[din_im,wrAddr,wrEnb,rdAddr],memOut_im,'dataMEM_im_1');



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@AbstractFFT','cgireml','wrStateMachineBitNatural.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='wrStateMachineBitNatural';

    wrStateMachineBitNatural=stageBitNatural.addComponent2(...
    'kind','cgireml',...
    'Name','wrStateMachineBitNatural',...
    'InputSignals',[din_vld],...
    'OutputSignals',[wrEnb,wrAddr,sampleIdx],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','wrStateMachineBitNatural',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    wrStateMachineBitNatural.runConcurrencyMaximizer(0);


    startOutW=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','startOutW');
    startOutW.SimulinkRate=dataRate;
    endOutW=stageBitNatural.addSignal2('Type',pir_boolean_t,'Name','endOutW');
    endOutW.SimulinkRate=dataRate;
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','rdStateMachineBitNatural.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='rdStateMachineBitNatural';

    outputPorts=[rdAddr,dout_re,dout_im,dout_vld,startOutW,endOutW];
    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        pirelab.getWireComp(stageBitNatural,startOutW,startOutS);
        pirelab.getWireComp(stageBitNatural,endOutW,endOutS);
    elseif blockInfo.outMode(1)
        pirelab.getWireComp(stageBitNatural,startOutW,startOutS);
    elseif blockInfo.outMode(2)
        pirelab.getWireComp(stageBitNatural,endOutW,endOutS);
    end

    rdStateMachineBitNatural=stageBitNatural.addComponent2(...
    'kind','cgireml',...
    'Name','rdStateMachineBitNatural',...
    'InputSignals',[sampleIdx,memOut_re,memOut_im],...
    'OutputSignals',outputPorts,...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','rdStateMachineBitNatural',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{WORDLENGTH,FRACTIONLENGTH,FFTLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    rdStateMachineBitNatural.runConcurrencyMaximizer(0);

end
