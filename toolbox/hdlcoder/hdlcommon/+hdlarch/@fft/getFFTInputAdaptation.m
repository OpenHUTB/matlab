function[inadaptComp,RamInitNet]=getFFTInputAdaptation(hN,hInSignals,hOutSignals,FFTInfo,RamInitNet)













    if nargin<5
        RamInitNet='';
    end


    din_dtc=hInSignals(1);
    sysenb=hInSignals(2);

    bf1=hOutSignals(1);
    bf2=hOutSignals(2);
    enb_out=hOutSignals(3);
    phase=hOutSignals(4);


    addrType=pir_ufixpt_t(FFTInfo.totalStage,0);
    dataType=FFTInfo.outputType;
    ufix1Type=pir_ufixpt_t(1,0);


    waddr=hN.addSignal(addrType,'waddr');
    raddr=hN.addSignal(addrType,'raddr');
    rdenb=hN.addSignal(ufix1Type,'rdenb');
    inadaptComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name','addrc',...
    'InputSignals',sysenb,...
    'OutputSignals',[waddr,raddr,rdenb],...
    'EMLFileName','hdleml_fft_inputaddr',...
    'EMLParams',{FFTInfo.totalPoint,FFTInfo.totalStage},...
    'BlockComment','Input adaptation address generation');



    din_p=hN.addSignal(dataType,'din_p');
    pipe1Comp=pirelab.getIntDelayComp(hN,din_dtc,din_p,FFTInfo.initDelay,'din_pc');
    pipe1Comp.addComment('Pipelining delay on din.');


    waddr_p=hN.addSignal(addrType,'waddr_p');
    pipe2Comp=pirelab.getIntDelayComp(hN,waddr,waddr_p,FFTInfo.initDelay,'waddr_pc');
    pipe2Comp.addComment('Pipelining delay on waddr.');


    raddr_p=hN.addSignal(addrType,'raddr_p');
    pipe3Comp=pirelab.getIntDelayComp(hN,raddr,raddr_p,FFTInfo.initDelay,'raddr_p');
    pipe3Comp.addComment('Pipelining delay on raddr.');


    rdenb_p=hN.addSignal(ufix1Type,'rdenb_p');
    pipe4Comp=pirelab.getIntDelayComp(hN,rdenb,rdenb_p,FFTInfo.initDelay,'rdenb_p');
    pipe4Comp.addComment('Pipelining delay on rdenb.');


    rdenb_reg=hN.addSignal(ufix1Type,'rdenb_reg');
    enbComp=pirelab.getUnitDelayComp(hN,rdenb_p,rdenb_reg,'rdenb_reg');
    enbComp.addComment('Unit delay on rdenb.');



    wrenb=hN.addSignal(ufix1Type,'wrenb');
    wrenb.SimulinkRate=din_p.SimulinkRate;
    pirelab.getConstComp(hN,wrenb,1,'wrenbc');


    dout=hN.addSignal(dataType,'dout');
    hInSignals=[din_p,waddr_p,wrenb,raddr_p];
    hOutSignals=dout;
    hOutSignals.SimulinkRate=din_p.SimulinkRate;
    ramCompName=sprintf('%s_stage_init_RAM',FFTInfo.refName);
    RamInitNet=pirelab.getSimpleDualPortRamComp(hN,hInSignals,hOutSignals,ramCompName,1,-1,RamInitNet);


    RamInitNet.copyComment(FFTInfo.hcForComment);



    pc=hN.addSignal(ufix1Type,'pc');
    pcComp=pireml.getCounterFreeRunningComp(hN,pc,rdenb_reg.SimulinkRate,'phasec',1);
    pcComp.addComment('Phase adjust unit counter');


    hN.addComponent2(...
    'kind','cgireml',...
    'Name','phaselogic',...
    'InputSignals',[rdenb_reg,pc],...
    'OutputSignals',phase,...
    'EMLFileName','hdleml_fft_phaselogic',...
    'BlockComment','Phase logic controller');


    din_phase1=hN.addSignal(dataType,'din_phase1');
    din_phase2=hN.addSignal(dataType,'din_phase2');
    pirelab.getUnitDelayComp(hN,dout,din_phase1,'din_phase1_reg');
    pirelab.getUnitDelayComp(hN,din_phase1,din_phase2,'din_phase2_reg');
    enb_phase1=hN.addSignal(ufix1Type,'enb_phase1');
    enb_phase2=hN.addSignal(ufix1Type,'enb_phase2');
    pirelab.getUnitDelayComp(hN,rdenb_reg,enb_phase1,'enb_phase1_reg');
    pirelab.getUnitDelayComp(hN,enb_phase1,enb_phase2,'enb_phase2_reg');


    din_phaseout=hN.addSignal(dataType,'din_phaseout');
    enb_phaseout=hN.addSignal(ufix1Type,'enb_phaseout');
    pirelab.getSwitchComp(hN,[din_phase1,din_phase2],din_phaseout,phase,'phase_switch1','==',1);
    pirelab.getSwitchComp(hN,[enb_phase1,enb_phase2],enb_phaseout,phase,'phase_switch2','==',1);



    down=2;
    offset=1;
    pirelab.getDownSampleComp(hN,din_phaseout,bf1,down,offset,[],'ds1');
    pirelab.getDownSampleComp(hN,enb_phaseout,enb_out,down,offset,[],'ds2');

    offset=0;
    pirelab.getDownSampleComp(hN,din_phaseout,bf2,down,offset,[],'ds3');


