function hStageEndNet=getFFTStageEnd(topNet,topNetIn,FFTInfo,RamInitNet)





    if nargin<4
        RamInitNet='';
    end


    dataType=FFTInfo.outputType;
    ufix1Type=pir_ufixpt_t(1,0);


    hStageEndNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_stage_end',FFTInfo.refName),...
    'InportNames',{'bf1','bf2','enb_in','phase'},...
    'InportTypes',[dataType,dataType,ufix1Type,ufix1Type],...
    'InportRates',[topNetIn(1).SimulinkRate,topNetIn(2).SimulinkRate,topNetIn(3).SimulinkRate,topNetIn(4).SimulinkRate],...
    'OutportNames',{'dout','dvalid'},...
    'OutportTypes',[dataType,ufix1Type]);


    bf1=hStageEndNet.PirInputSignals(1);
    bf2=hStageEndNet.PirInputSignals(2);
    enb_in=hStageEndNet.PirInputSignals(3);
    phase=hStageEndNet.PirInputSignals(4);
    dout=hStageEndNet.PirOutputSignals(1);
    dvalid=hStageEndNet.PirOutputSignals(2);


    hdlgetclockbundle(hStageEndNet,[],bf1,1,1,0);


    din_phaseout=hStageEndNet.addSignal(dataType,'din_phaseout');
    enb_phaseout=hStageEndNet.addSignal(ufix1Type,'enb_phaseout');
    hInSignals=[bf1,bf2,enb_in,phase];
    hOutSignals=[din_phaseout,enb_phaseout];
    hdlarch.fft.getFFTOutputAdaptation(hStageEndNet,hInSignals,hOutSignals,FFTInfo);


    if~FFTInfo.isBitReversed
        br_dout=hStageEndNet.addSignal(dataType,'br_dout');
        br_enbout=hStageEndNet.addSignal(ufix1Type,'br_enbout');
        hInSignals=[din_phaseout,enb_phaseout];
        hOutSignals=[br_dout,br_enbout];
        hdlarch.fft.getFFTBitReverseComp(hStageEndNet,hInSignals,hOutSignals,FFTInfo,RamInitNet);

    else

        br_dout=din_phaseout;
        br_enbout=enb_phaseout;
    end



    outreg=hStageEndNet.addSignal(dataType,'outreg');
    pirelab.getUnitDelayComp(hStageEndNet,br_dout,outreg,'outregc');

    pirelab.getUnitDelayComp(hStageEndNet,br_enbout,dvalid,'dvalidc');



    outzero=hStageEndNet.addSignal(dataType,'outzero');
    pirelab.getConstComp(hStageEndNet,outzero,complex(0,0),'outzeroc');


    swComp=pirelab.getSwitchComp(hStageEndNet,[outreg,outzero],dout,dvalid,'output_switch','==',1);
    swComp.addComment('Output switch');
