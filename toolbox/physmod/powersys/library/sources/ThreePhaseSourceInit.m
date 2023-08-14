function[Ts,WantBlockChoice,Aa,Pa,Ab,Pb,Ac,Pc]=ThreePhaseSourceInit(block,Voltage,PhaseAngle,Voltage_phases,PhaseAngles_phases,VoltagePhases)





    switch VoltagePhases
    case 1
        Aa=Voltage_phases(1)*sqrt(2);
        Ab=Voltage_phases(2)*sqrt(2);
        Ac=Voltage_phases(3)*sqrt(2);
        Pa=PhaseAngles_phases(1)*pi/180;
        Pb=PhaseAngles_phases(2)*pi/180;
        Pc=PhaseAngles_phases(3)*pi/180;
    case 0
        Aa=Voltage*sqrt(2)/sqrt(3);
        Ab=Aa;
        Ac=Aa;
        Pa=PhaseAngle*pi/180;
        Pb=(PhaseAngle-120)*pi/180;
        Pc=(PhaseAngle+120)*pi/180;
    end

    WantYn=strcmp(get_param(block,'InternalConnection'),'Yn');
    ports=get_param(block,'ports');
    External=(ports(6)==1);
    if WantYn&&~External
        add_block('built-in/PMIOPort',[block,'/N']);
        set_param([block,'/N'],'Position',[20,50,40,70],'side','Left','orientation','right');
        SPortHandles=get_param([block,'/ThreePhaseSourceBlk'],'PortHandles');
        NPortHandle=get_param([block,'/N'],'PortHandles');
        add_line(block,SPortHandles.LConn,NPortHandle.RConn)
    elseif~WantYn&&External
        PortHandles=get_param([block,'/ThreePhaseSourceBlk'],'PortHandles');
        ligne1=get_param(PortHandles.LConn(1),'line');
        delete_line(ligne1);
        delete_block([block,'/N']);
    end

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if strcmp(PowerguiInfo.Mode,'Discrete')
        Ts=PowerguiInfo.Ts;
    else
        Ts=0.0;
    end

    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        WantBlockChoice='ThreePhaseSource complex';
    else
        WantBlockChoice='ThreePhaseSource';
    end

    power_initmask();