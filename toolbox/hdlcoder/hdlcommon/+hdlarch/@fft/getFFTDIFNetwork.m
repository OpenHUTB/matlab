function hFFTNet=getFFTDIFNetwork(topNet,topNetIn,FFTInfo)




    if~isfield(FFTInfo,'hcForComment')
        FFTInfo.hcForComment=[];
    end


    dataType=FFTInfo.outputType;
    ufix1Type=pir_ufixpt_t(1,0);


    hFFTNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',FFTInfo.refName,...
    'InportNames',{'din','start'},...
    'InportTypes',[topNetIn(1).Type,topNetIn(2).Type],...
    'InportRates',[topNetIn(1).SimulinkRate,topNetIn(2).SimulinkRate],...
    'OutportNames',{'dout','dvalid','ready'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type]);


    hFFTNet.copyComment(FFTInfo.hcForComment);


    din=hFFTNet.PirInputSignals(1);
    start=hFFTNet.PirInputSignals(2);
    dout=hFFTNet.PirOutputSignals(1);
    dvalid=hFFTNet.PirOutputSignals(2);
    ready=hFFTNet.PirOutputSignals(3);



    FFTInfo.initDelay=2;

    FFTInfo.pipeBFDelay=5;
    FFTInfo.pipeBFDelayMin=2;
    FFTInfo.pipeAddMinusDelay=2;
    FFTInfo.pipeComplexMulDelay=2;

    FFTInfo.pipeBFSimpleDelay=2;

    FFTInfo.midStageDelay=((FFTInfo.totalPoint/2-1)+...
    (FFTInfo.totalStage-3)*FFTInfo.pipeBFDelayMin+...
    (FFTInfo.pipeBFDelay-1)+...
    FFTInfo.pipeBFDelay+...
    FFTInfo.pipeBFSimpleDelay)*2;





    start_in=hFFTNet.addSignal(ufix1Type,'start_in');
    pirelab.getWireComp(hFFTNet,start,start_in);
    start_in.SimulinkRate=din.SimulinkRate;

    hInSignals=[din,start_in];
    [initStageNet,RamInitNet]=hdlarch.fft.getFFTStageInitial(hFFTNet,hInSignals,FFTInfo);


    initStageNet.copyComment(FFTInfo.hcForComment);


    bf1=hFFTNet.addSignal(dataType,'bf1_init');
    bf2=hFFTNet.addSignal(dataType,'bf2_init');
    enb=hFFTNet.addSignal(ufix1Type,'enb_init');
    phase=hFFTNet.addSignal(ufix1Type,'phase_init');
    hOutSignals=[bf1,bf2,enb,ready,phase];


    pirelab.instantiateNetwork(hFFTNet,initStageNet,hInSignals,hOutSignals,'stage_init_inst');






    dataRate=bf1.SimulinkRate;
    butterflyNet=hdlarch.fft.getFFTButterflyDIF(hFFTNet,FFTInfo,dataRate);


    butterflyNet.copyComment(FFTInfo.hcForComment);


    hOutSignals=[bf1,bf2,enb];
    for stageNum=(FFTInfo.totalStage-1):-1:0

        midStageNet=hdlarch.fft.getFFTStageMiddle(hFFTNet,hOutSignals,FFTInfo,butterflyNet,stageNum);


        midStageNet.copyComment(FFTInfo.hcForComment);


        bf1=hFFTNet.addSignal(dataType,sprintf('bf1_stage%d',stageNum));
        bf2=hFFTNet.addSignal(dataType,sprintf('bf2_stage%d',stageNum));
        enb=hFFTNet.addSignal(ufix1Type,sprintf('enb_stage%d',stageNum));
        hInSignals=hOutSignals;
        hOutSignals=[bf1,bf2,enb];
        pirelab.instantiateNetwork(hFFTNet,midStageNet,hInSignals,hOutSignals,sprintf('stage_%d_inst',stageNum));
    end




    hInSignals=[hOutSignals,phase];
    endStageNet=hdlarch.fft.getFFTStageEnd(hFFTNet,hInSignals,FFTInfo,RamInitNet);


    endStageNet.copyComment(FFTInfo.hcForComment);


    hOutSignals=[dout,dvalid];
    pirelab.instantiateNetwork(hFFTNet,endStageNet,hInSignals,hOutSignals,'stage_end_inst');




