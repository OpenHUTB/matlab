function delayLineImpl=elabDelayLine(this,topNet,dataRate,...
    din,wrEnb,rdEnb,syncReset,dout,doutVld,...
    FOLDINGFACTOR,TAP_LATENCY)





    InportNames={din.Name,wrEnb.Name,rdEnb.Name,syncReset.Name};
    InportTypes=[din.Type,wrEnb.Type,rdEnb.Type,syncReset.Type];
    InportRates=[dataRate,dataRate,dataRate,dataRate];

    OutportNames={dout.Name,doutVld.Name};
    OutportTypes=[dout.Type;doutVld.Type];

    delayLineImpl=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','delayLine',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=delayLineImpl.PirInputSignals;
    outputPort=delayLineImpl.PirOutputSignals;

    din=inputPort(1);
    wrEnb=inputPort(2);
    rdEnb=inputPort(3);
    syncReset=inputPort(4);
    dout=outputPort(1);
    doutVld=outputPort(2);

    ADDRWIDTH=max(2,ceil(log2(FOLDINGFACTOR+TAP_LATENCY)));
    wrAddr=delayLineImpl.addSignal2('Type',pir_fixpt_t(0,ADDRWIDTH,0),'Name','wrAddr');
    wrAddr.SimulinkRate=dataRate;
    rdAddr=delayLineImpl.addSignal2('Type',pir_fixpt_t(0,ADDRWIDTH,0),'Name','rdAddr');
    rdAddr.SimulinkRate=dataRate;




    ramOut=delayLineImpl.addSignal2('Type',dout.Type,'Name','ramOut');
    ramOut.SimulinkRate=dataRate;
    ramOutVld=delayLineImpl.addSignal2('Type',pir_boolean_t,'Name','ramOutVld');
    ramOutVld.SimulinkRate=dataRate;
    ramByPass=delayLineImpl.addSignal2('Type',pir_fixpt_t(0,1,0),'Name','ramByPass');
    ramByPass.SimulinkRate=dataRate;
    pirelab.getSimpleDualPortRamComp(delayLineImpl,[din,wrAddr,wrEnb,rdAddr],ramOut,'delayLine');

    dinVld=rdEnb;
    dinDly=delayLineImpl.addSignal2('Type',dout.Type,'Name','dinDly');
    dinDly.SimulinkRate=dataRate;
    dinDlyVld=delayLineImpl.addSignal2('Type',pir_boolean_t,'Name','dinDlyVld');
    dinDlyVld.SimulinkRate=dataRate;
    muxOut=delayLineImpl.addSignal2('Type',dout.Type,'Name','muxOut');
    muxOut.SimulinkRate=dataRate;
    muxOutVld=delayLineImpl.addSignal2('Type',pir_boolean_t,'Name','muxOutVld');
    muxOutVld.SimulinkRate=dataRate;
    muxOutReg=delayLineImpl.addSignal2('Type',dout.Type,'Name','muxOutReg');
    muxOutReg.SimulinkRate=dataRate;
    pirelab.getIntDelayEnabledResettableComp(delayLineImpl,din,dinDly,dinVld,syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(delayLineImpl,dinVld,dinDlyVld,'',syncReset,1);
    pirelab.getSwitchComp(delayLineImpl,[dinDly,ramOut],muxOut,ramByPass,'RAMBYPASS','==',1);
    pirelab.getSwitchComp(delayLineImpl,[dinDlyVld,ramOutVld],muxOutVld,ramByPass,'RAMVLDBYPASS','==',1);
    pirelab.getIntDelayEnabledResettableComp(delayLineImpl,muxOut,muxOutReg,muxOutVld,syncReset,1);

    pirelab.getSwitchComp(delayLineImpl,[muxOut,muxOutReg],dout,muxOutVld,'BYPASSREG','==',1);
    pirelab.getWireComp(delayLineImpl,muxOutVld,doutVld);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','delayLineCtrl.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='delayLine';

    delayLineCtrl=delayLineImpl.addComponent2(...
    'kind','cgireml',...
    'Name','delayLineCtrl',...
    'InputSignals',[wrEnb,rdEnb],...
    'OutputSignals',[wrAddr,rdAddr,ramOutVld,ramByPass],...
    'EMLFileName','delayLineCtrl',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FOLDINGFACTOR,TAP_LATENCY,ADDRWIDTH},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    delayLineCtrl.runConcurrencyMaximizer(0);
end

