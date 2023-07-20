function[Ts,WantBlockChoice,ka,ta,gmin,gmax,vgmin,vgmax,Rp,kp,ki,kd,td,beta,tw,go]=HydraulicTurbineInit(block,sm,gate,reg,hyd,po)





    ka=sm(1);
    ta=sm(2);
    gmin=gate(1);
    gmax=gate(2);
    vgmin=gate(3);
    vgmax=gate(4);
    Rp=reg(1);
    kp=reg(2);
    ki=reg(3);
    kd=reg(4);
    td=reg(5);
    beta=hyd(1);
    tw=hyd(2);
    go=po*(gmax-gmin);

    power_initmask();

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.Phasor
        WantBlockChoice='Continuous';
    end
    if PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor
        WantBlockChoice='Discrete';
    end
    if PowerguiInfo.Continuous
        WantBlockChoice='Continuous';
    end