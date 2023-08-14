function[WantBlockChoice,Ts,sps]=SawtoothGeneratorInit(block,Phase,Freq,Ts)




    sps=[];

    [WantBlockChoice,Ts]=DetermineBlockChoice(block,Ts,0,0);



    phase=mod(Phase,360);
    period=1/Freq;
    tableX=[0,360];
    tableY=[0,1];
    Y0=interp1(tableX,tableY,phase);

    if phase==0
        sps.time=[0,1-1/100000,1]*period;
        sps.Out=[0,1,0];
    else
        sps.time=[0,(360-phase)/360-1/100000,(360-phase)/360,1]*period;
        sps.Out=[Y0,1,0,Y0];
    end

    sps.phase=phase;
    sps.Period=period;
    sps.Freq=Freq;
    sps.Delay=period*phase/360;







    sps.TimeStepZ=[1,mod(1-phase/180,1)]*period/2;









