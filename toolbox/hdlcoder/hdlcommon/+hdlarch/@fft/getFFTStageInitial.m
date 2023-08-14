function[initStageNet,RamInitNet]=getFFTStageInitial(topNet,topNetIn,FFTInfo)





    dataType=FFTInfo.outputType;
    ufix1Type=pir_ufixpt_t(1,0);


    initStageNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_stage_init',FFTInfo.refName),...
    'InportNames',{'din','start'},...
    'InportTypes',[topNetIn(1).Type,topNetIn(2).Type],...
    'InportRates',[topNetIn(1).SimulinkRate,topNetIn(2).SimulinkRate],...
    'OutportNames',{'bf1','bf2','enb_out','ready','phase'},...
    'OutportTypes',[dataType,dataType,ufix1Type,ufix1Type,ufix1Type]);


    din=initStageNet.PirInputSignals(1);
    start=initStageNet.PirInputSignals(2);
    bf1=initStageNet.PirOutputSignals(1);
    bf2=initStageNet.PirOutputSignals(2);
    enb_out=initStageNet.PirOutputSignals(3);
    ready=initStageNet.PirOutputSignals(4);
    phase=initStageNet.PirOutputSignals(5);


    hdlgetclockbundle(initStageNet,[],din,1,1,0);


    din_dtc=initStageNet.addSignal(dataType,'din_dtc');
    dtcComp=pirelab.getDTCComp(initStageNet,din,din_dtc,FFTInfo.rndMode,FFTInfo.satMode,'RWV','din_dtc');
    dtcComp.addComment('Data type conversion from input data type to output data type.');


    sysenb=initStageNet.addSignal(ufix1Type,'sysenb');
    initStageNet.addComponent2(...
    'kind','cgireml',...
    'Name','inlogic',...
    'InputSignals',start,...
    'OutputSignals',[sysenb,ready],...
    'EMLFileName','hdleml_fft_inputlogic',...
    'EMLParams',{FFTInfo.totalPoint,FFTInfo.totalStage},...
    'BlockComment','Input logic controller');


    hInSignals=[din_dtc,sysenb];
    hOutSignals=[bf1,bf2,enb_out,phase];
    [~,RamInitNet]=hdlarch.fft.getFFTInputAdaptation(initStageNet,hInSignals,hOutSignals,FFTInfo);

