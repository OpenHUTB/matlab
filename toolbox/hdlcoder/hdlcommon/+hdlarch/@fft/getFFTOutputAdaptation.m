function outadaptComp=getFFTOutputAdaptation(hN,hInSignals,hOutSignals,FFTInfo)










    bf1=hInSignals(1);
    bf2=hInSignals(2);
    enb_in=hInSignals(3);
    phase=hInSignals(4);

    data_out=hOutSignals(1);
    enb_out=hOutSignals(2);


    dataType=FFTInfo.outputType;
    ufix1Type=pir_ufixpt_t(1,0);


    bf1_rt=hN.addSignal(dataType,'bf1_rt');
    bf2_rt=hN.addSignal(dataType,'bf2_rt');
    enb_rt=hN.addSignal(ufix1Type,'enb_rt');

    outputRate=bf1.SimulinkRate/2;

    outadaptComp=pirelab.getRateTransitionComp(hN,bf1,bf1_rt,outputRate,[],'rt1');
    pirelab.getRateTransitionComp(hN,bf2,bf2_rt,outputRate,[],'rt2');
    pirelab.getRateTransitionComp(hN,enb_in,enb_rt,outputRate,[],'rt3');

    outadaptComp.addComment('Rate transition from internal slower rate to output faster rate');




    sc=hN.addSignal(ufix1Type,'sc');
    ctComp=pirelab.getCounterEnabledComp(hN,sc,enb_rt,'selector');
    ctComp.addComment('Switch selector counter');

    din=hN.addSignal(dataType,'din');
    swComp=pirelab.getSwitchComp(hN,[bf2_rt,bf1_rt],din,sc,'data_merge_switch','==',1);
    swComp.addComment('Switch to merge two slower rate data streams into one faster rate data stream');



    phaseDelay=FFTInfo.midStageDelay+3;
    phase_delay=hN.addSignal(ufix1Type,'phase_delay');
    phase_c=hN.addSignal(ufix1Type,'phase_c');
    pirelab.getIntDelayComp(hN,phase,phase_delay,phaseDelay-FFTInfo.totalPoint-1,'phase_sr');
    hdlarch.fft.getFFTPulseDelayComp(hN,phase_delay,phase_c,FFTInfo.totalPoint+1,'phase_d');


    din_phase=hN.addSignal(dataType,'din_phase');
    enb_phase=hN.addSignal(ufix1Type,'enb_phase');
    pirelab.getUnitDelayComp(hN,din,din_phase,'din_phase_reg');
    pirelab.getUnitDelayComp(hN,enb_rt,enb_phase,'enb_phase_reg');



    pirelab.getSwitchComp(hN,[din_phase,din],data_out,phase_c,'phase_switch1','==',1);
    pirelab.getSwitchComp(hN,[enb_phase,enb_rt],enb_out,phase_c,'phase_switch2','==',1);


