function[brComp,RamInitNet]=getFFTBitReverseComp(hN,hInSignals,hOutSignals,FFTInfo,RamInitNet)










    if nargin<5
        RamInitNet='';
    end


    data_in=hInSignals(1);
    enb_in=hInSignals(2);

    data_out=hOutSignals(1);
    enb_out=hOutSignals(2);


    addrType=pir_ufixpt_t(FFTInfo.totalStage,0);
    ufix1Type=pir_ufixpt_t(1,0);





    addrWidth=FFTInfo.totalStage;
    numOne=floor(addrWidth/2);
    numZero=addrWidth-numOne;
    BitRevDelay=(2^addrWidth-2^numZero)-(2^numOne-1)+1;


    waddr=hN.addSignal(addrType,'waddr');
    raddr=hN.addSignal(addrType,'raddr');
    rdenb=hN.addSignal(ufix1Type,'rdenb');
    brComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name','addrc',...
    'InputSignals',enb_in,...
    'OutputSignals',[waddr,raddr,rdenb],...
    'EMLFileName','hdleml_fft_bitrevaddr',...
    'EMLParams',{FFTInfo.totalPoint,FFTInfo.totalStage,BitRevDelay},...
    'BlockComment','Bit Reverse address generation');



    wrenb=hN.addSignal(ufix1Type,'wrenb');
    pirelab.getConstComp(hN,wrenb,1,'wrenbc');


    hInSignals=[data_in,waddr,wrenb,raddr];
    ramCompName=sprintf('%s_stage_end_RAM',FFTInfo.refName);
    RamInitNet=pirelab.getSimpleDualPortRamComp(hN,hInSignals,data_out,ramCompName,1,-1,RamInitNet);


    pirelab.getUnitDelayComp(hN,rdenb,enb_out,'enbdc');




