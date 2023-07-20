function midStageNet=getFFTStageMiddle(topNet,topNetIn,FFTInfo,butterflyNet,stageNum)





    dataType=FFTInfo.outputType;
    ufix1Type=pir_ufixpt_t(1,0);


    midStageNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_stage_%d',FFTInfo.refName,stageNum),...
    'InportNames',{'u','v','enb_in'},...
    'InportTypes',[dataType,dataType,ufix1Type],...
    'InportRates',[topNetIn(1).SimulinkRate,topNetIn(2).SimulinkRate,topNetIn(3).SimulinkRate],...
    'OutportNames',{'bf1','bf2','enb_out'},...
    'OutportTypes',[dataType,dataType,ufix1Type]);


    u=midStageNet.PirInputSignals(1);
    v=midStageNet.PirInputSignals(2);
    enb_in=midStageNet.PirInputSignals(3);
    bf1=midStageNet.PirOutputSignals(1);
    bf2=midStageNet.PirOutputSignals(2);
    enb_out=midStageNet.PirOutputSignals(3);


    hdlgetclockbundle(midStageNet,[],u,1,1,0);



    isStageZero=stageNum==0;

    if~isStageZero

        optimizeDelay=FFTInfo.pipeBFDelay-FFTInfo.pipeBFDelayMin;
        if stageNum>=3
            xCompensateDelay=0;
            sr1Delay=2^(stageNum-1)-optimizeDelay;
            ctrlMatchBFDelay=FFTInfo.pipeBFDelayMin;
        elseif stageNum==2
            xCompensateDelay=optimizeDelay-1;
            sr1Delay=1;
            ctrlMatchBFDelay=FFTInfo.pipeBFDelay-1;
        else
            xCompensateDelay=optimizeDelay;
            sr1Delay=1;
            ctrlMatchBFDelay=FFTInfo.pipeBFDelay;
        end;



        addrType=pir_ufixpt_t(stageNum,0);
        taddr=midStageNet.addSignal(addrType,'taddr');
        countComp=pirelab.getCounterEnabledComp(midStageNet,taddr,enb_in,'tc');
        countComp.addComment('Twiddle ROM address counter');


        twiddle_out=midStageNet.addSignal(FFTInfo.sineType,'twiddle_out');
        hdlarch.fft.getFFTTwiddleComp(midStageNet,taddr,twiddle_out,FFTInfo,stageNum);


        twiddleone=midStageNet.addSignal(ufix1Type,'twiddleone');
        tcComp=pirelab.getCompareToValueComp(midStageNet,taddr,twiddleone,'==',0,'twiddleonec');
        tcComp.addComment('Twiddle equal to one control signal');




        x=midStageNet.addSignal(dataType,'x');
        y=midStageNet.addSignal(dataType,'y');
        hInSignals=[u,v,twiddle_out,twiddleone];
        hOutSignals=[x,y];
        fftComp=pirelab.instantiateNetwork(midStageNet,butterflyNet,hInSignals,hOutSignals,'butterfly_DIF_inst');
        fftComp.addComment('DIF FFT butterfly unit');

        x_p=midStageNet.addSignal(dataType,'x_p');
        if xCompensateDelay==0
            pirelab.getWireComp(midStageNet,x,x_p,'x_pc');
        else
            pirelab.getIntDelayComp(midStageNet,x,x_p,xCompensateDelay,'x_pc');
        end












        shuffle_c=midStageNet.addSignal(ufix1Type,'shuffle_c');
        scComp=pirelab.getBitSliceComp(midStageNet,taddr,shuffle_c,stageNum-1,stageNum-1);
        scComp.addComment('Shuffling unit control signal');


        shuffle_c_p=midStageNet.addSignal(ufix1Type,'shuffle_c_p');
        pipeCComp=pirelab.getIntDelayComp(midStageNet,shuffle_c,shuffle_c_p,ctrlMatchBFDelay,'pipe_shuffle_c');
        pipeCComp.addComment('Matching pipelining delays on shuffle control signal');


        hInSignals=[x_p,y,shuffle_c_p];
        hOutSignals=[bf1,bf2];
        hdlarch.fft.getFFTShuffleComp(midStageNet,hInSignals,hOutSignals,FFTInfo,sr1Delay,stageNum);



        enb_p=midStageNet.addSignal(ufix1Type,'enb_p');
        pipeEComp=pirelab.getIntDelayComp(midStageNet,enb_in,enb_p,ctrlMatchBFDelay,'pipe_enb');
        pipeEComp.addComment('Matching pipelining delays on enable signal');


        sr3Comp=hdlarch.fft.getFFTPulseDelayComp(midStageNet,enb_p,enb_out,2^(stageNum-1),'sr3');
        sr3Comp.addComment('Matching pipelining delays on enable signal');

    else


        dataRate=u.SimulinkRate;
        isSimpleArch=true;
        butterflyNet=hdlarch.fft.getFFTButterflyDIF(midStageNet,FFTInfo,dataRate,isSimpleArch);


        butterflyNet.copyComment(FFTInfo.hcForComment);


        hInSignals=[u,v];
        hOutSignals=[bf1,bf2];
        fftComp=pirelab.instantiateNetwork(midStageNet,butterflyNet,hInSignals,hOutSignals,'butterfly_DIF_inst');
        fftComp.addComment('DIF FFT butterfly unit simple');


        pirelab.getIntDelayComp(midStageNet,enb_in,enb_out,FFTInfo.pipeBFSimpleDelay,'pipe_enb');
    end


