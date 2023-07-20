function PWMGenerator3LevelCback(block)


    MV=get_param(block,'MaskVisibilities');

    switch get_param(block,'ModulatingSignals')
    case 'on'
        MV{6}='on';
        MV{7}='on';
        MV{8}='on';
    case 'off'
        MV{6}='off';
        MV{7}='off';
        MV{8}='off';
    end

    switch get_param(block,'ModulatorMode')
    case 'Synchronized'
        MV{3}='on';
        MV{4}='off';
        MV{5}='off';
        MV{6}='off';
        MV{7}='off';
        MV{8}='off';
    case 'Unsynchronized'
        MV{3}='off';
        MV{4}='on';
        MV{5}='on';
    end
    set_param(block,'MaskVisibilities',MV);