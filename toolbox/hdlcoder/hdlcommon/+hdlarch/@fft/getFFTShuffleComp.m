function sfComp=getFFTShuffleComp(hN,hInSignals,hOutSignals,FFTInfo,sr1Delay,stageNum)
















    x=hInSignals(1);
    y=hInSignals(2);
    shuffle_c=hInSignals(3);

    bf1=hOutSignals(1);
    bf2=hOutSignals(2);


    dataType=FFTInfo.outputType;


    y_d=hN.addSignal(dataType,'y_d');
    ramName=sprintf('%s_stage_%d_RAM',FFTInfo.refName,stageNum);
    sr1RamNet=pirelab.getRAMBasedShiftRegisterComp(hN,y,y_d,sr1Delay,'','sr1',ramName);


    if~isempty(sr1RamNet)
        sr1RamNet.copyComment(FFTInfo.hcForComment);
    end


    sw1=hN.addSignal(dataType,'sw1');
    sw1Comp=pirelab.getSwitchComp(hN,[y_d,x],sw1,shuffle_c,'switch1','==',1);
    sw1Comp.addComment('Shuffle unit switch');
    sw2Comp=pirelab.getSwitchComp(hN,[x,y_d],bf2,shuffle_c,'switch2','==',1);
    sw2Comp.addComment('Shuffle unit switch');


    pirelab.getRAMBasedShiftRegisterComp(hN,sw1,bf1,2^(stageNum-1),'','sr2',ramName,sr1RamNet);


    sfComp=sw1Comp;
