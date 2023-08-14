function[WantBlockChoice,Ts,sps]=TriangleGeneratorInit(block,Phase,Freq,Ts)




    sps=[];

    [WantBlockChoice,Ts]=DetermineBlockChoice(block,Ts,0,0);



    sps.Phase=mod(Phase,360);
    sps.Freq=Freq;
    sps.Period=1/sps.Freq;

    if sps.Phase==0
        sps.time=[0,sps.Period/2,sps.Period];
        sps.Out=[-1,1,-1];
    elseif sps.Phase<180
        sps.time=[0,(180-sps.Phase)/360,(360-sps.Phase)/360,1]*sps.Period;
        sps.Out=[-1+sps.Phase/90,1,-1,-1+sps.Phase/90];
    elseif sps.Phase==180
        sps.time=[0,sps.Period/2,sps.Period];
        sps.Out=[1,-1,1];
    else
        sps.time=[0,(360-sps.Phase)/360,(540-sps.Phase)/360,1]*sps.Period;
        sps.Out=[3-sps.Phase/90,-1,1,3-sps.Phase/90];
    end

    sps.Delay=sps.Period*sps.Phase/360;






    sps.TimeStepZ=[1,mod(1-sps.Phase/180,1)]*sps.Period/2;





