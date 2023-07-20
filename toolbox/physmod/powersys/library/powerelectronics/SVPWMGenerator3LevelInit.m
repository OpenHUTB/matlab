function[WantBlockChoice]=SVPWMGenerator3LevelInit(block,InputType,Ts)


    MV=get_param(block,'MaskVisibilities');
    if InputType==4
        MV{5}='on';
    else
        MV{5}='off';
    end
    set_param(block,'MaskVisibilities',MV);

    if Ts==0
        WantBlockChoice='Continuous';
    else
        WantBlockChoice='Discrete';
    end

    switch InputType
    case 1
        WantBlockChoice=[WantBlockChoice,' Vref'];
    case 2
        WantBlockChoice=[WantBlockChoice,' MagPhase'];
    case 3
        WantBlockChoice=[WantBlockChoice,' AlfaBeta'];
    case 4
        WantBlockChoice=[WantBlockChoice,' Internal'];
    end