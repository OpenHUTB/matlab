function stageBitNaturalMux=elabRADIX22FFT_bitNaturalMux(this,topNet,blockInfo,dataRate,DATA_VECSIZE,inIndex,dMem_re,dMem_im,dMem_vld,synReset,dMuxReg_re,dMuxReg_im,dMuxReg_vld)%#ok<INUSD>






    inPortNames={dMem_re.Name,dMem_im.Name,dMem_vld.Name,synReset.Name};
    inPortTypes=[dMem_re.Type;dMem_im.Type;dMem_vld.Type;synReset.Type];
    inPortRates=[dataRate;dataRate;dataRate;dataRate];
    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        outPortNames={dMuxReg_re.Name,dMuxReg_im.Name,dMuxReg_vld.Name};
        outPortTypes=[dMuxReg_re.Type;dMuxReg_im.Type;dMuxReg_vld.Type];
    elseif blockInfo.outMode(1)
        outPortNames={dMuxReg_re.Name,dMuxReg_im.Name,dMuxReg_vld.Name};
        outPortTypes=[dMuxReg_re.Type;dMuxReg_im.Type;dMuxReg_vld.Type];
    elseif blockInfo.outMode(2)
        outPortNames={dMuxReg_re.Name,dMuxReg_im.Name,dMuxReg_vld.Name};
        outPortTypes=[dMuxReg_re.Type;dMuxReg_im.Type;dMuxReg_vld.Type];
    else
        outPortNames={dMuxReg_re.Name,dMuxReg_im.Name,dMuxReg_vld.Name};
        outPortTypes=[dMuxReg_re.Type;dMuxReg_im.Type;dMuxReg_vld.Type];
    end

    stageBitNaturalMux=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_bitNaturalMux_',int2str(inIndex)],...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    inputPort=stageBitNaturalMux.PirInputSignals;
    outputPorts=stageBitNaturalMux.PirOutputSignals;

    for inputIndex=1:DATA_VECSIZE
        dMem_re(inputIndex)=inputPort(1).split.PirOutputSignals(inputIndex);
        dMem_im(inputIndex)=inputPort(2).split.PirOutputSignals(inputIndex);
    end
    dMem_vld=inputPort(3);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        synReset=inputPort(4);
    else
        synReset='';
    end

    dMuxReg_re=outputPorts(1);
    dMuxReg_im=outputPorts(2);
    dMuxReg_vld=outputPorts(3);

    FFTLENGTH=blockInfo.FFTLength;
    IC=inIndex-1;
    INC=DATA_VECSIZE;

    for inputIndex=1:DATA_VECSIZE
        dMem_re_reg(inputIndex)=stageBitNaturalMux.addSignal2('Type',dMem_re(inputIndex).Type,'Name',['dMem_re_reg',int2str(inputIndex)]);%#ok<*AGROW>
        dMem_re_reg(inputIndex).SimulinkRate=dataRate;
        dMem_im_reg(inputIndex)=stageBitNaturalMux.addSignal2('Type',dMem_im(inputIndex).Type,'Name',['dMem_im_reg',int2str(inputIndex)]);
        dMem_im_reg(inputIndex).SimulinkRate=dataRate;
    end

    dMux_re=stageBitNaturalMux.addSignal2('Type',dMem_re(1).Type,'Name','dMux_re');%#ok<*AGROW>
    dMux_re.SimulinkRate=dataRate;
    dMux_im=stageBitNaturalMux.addSignal2('Type',dMem_re(1).Type,'Name','dMux_im');%#ok<*AGROW>
    dMux_im.SimulinkRate=dataRate;


    MUXSel=stageBitNaturalMux.addSignal2('Type',pir_ufixpt_t(log2(double(DATA_VECSIZE)),0),'Name','MUXSel');
    MUXSel.SimulinkRate=dataRate;
    MUXSel_vld=stageBitNaturalMux.addSignal2('Type',pir_boolean_t,'Name','MUXSel_vld');
    MUXSel_vld.SimulinkRate=dataRate;
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','outMuxSel.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='outMuxSel';

    outMuxSelGen=stageBitNaturalMux.addComponent2(...
    'kind','cgireml',...
    'Name','outMuxSel',...
    'InputSignals',dMem_vld,...
    'OutputSignals',[MUXSel,MUXSel_vld],...
    'ExternalSynchronousResetSignal',synReset,...
    'EMLFileName','outMuxSel',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,DATA_VECSIZE,IC,INC},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    outMuxSelGen.runConcurrencyMaximizer(0);


    for inputIndex=1:DATA_VECSIZE
        pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMem_re(inputIndex),dMem_re_reg(inputIndex),'','',1);
        pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMem_im(inputIndex),dMem_im_reg(inputIndex),'','',1);
    end
    pirelab.getMultiPortSwitchComp(stageBitNaturalMux,[MUXSel,dMem_re_reg],dMux_re,1,1);
    pirelab.getMultiPortSwitchComp(stageBitNaturalMux,[MUXSel,dMem_im_reg],dMux_im,1,1);

    dMuxDly_re=stageBitNaturalMux.addSignal2('Type',dMem_re(1).Type,'Name','dMuxDly_re');%#ok<*AGROW>
    dMuxDly_re.SimulinkRate=dataRate;
    dMuxDly_im=stageBitNaturalMux.addSignal2('Type',dMem_re(1).Type,'Name','dMuxDly_im');%#ok<*AGROW>
    dMuxDly_im.SimulinkRate=dataRate;
    dMuxSelDly_vld=stageBitNaturalMux.addSignal2('Type',pir_boolean_t,'Name','dMuxSelDly_vld');
    dMuxSelDly_vld.SimulinkRate=dataRate;

    dly=log2(double(DATA_VECSIZE))-1;
    pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMux_re,dMuxDly_re,'',synReset,dly);
    pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMux_im,dMuxDly_im,'',synReset,dly);
    pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,MUXSel_vld,dMuxSelDly_vld,'',synReset,dly);

    pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMuxDly_re,dMuxReg_re,dMuxSelDly_vld,synReset,1);
    pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMuxDly_im,dMuxReg_im,dMuxSelDly_vld,synReset,1);
    pirelab.getIntDelayEnabledResettableComp(stageBitNaturalMux,dMuxSelDly_vld,dMuxReg_vld,'',synReset,1);

end
