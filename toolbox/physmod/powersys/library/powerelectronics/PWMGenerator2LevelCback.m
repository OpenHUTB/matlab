function PWMGenerator2LevelCback(block)







    MV=get_param(block,'MaskVisibilities');
    ME=get_param(block,'MaskEnables');

    switch get_param(block,'ModulatingSignals')
    case 'on'
        MV{9}='on';
        MV{10}='on';
        MV{11}='on';
    case 'off'
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';
    end
    switch get_param(block,'ModulatorMode')
    case 'Synchronized'
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';
        MV{3}='off';
        MV{4}='off';
        MV{5}='on';

        ME{8}='off';
        set_param(block,'ModulatingSignals','off');
    case 'Unsynchronized'
        MV{3}='on';
        MV{4}='on';
        MV{5}='off';

        if~strcmp(get_param(bdroot(block),'EditingMode'),'Restricted')
            ME{8}='on';
        end
    end

    set_param(block,'MaskVisibilities',MV);
    set_param(block,'MaskEnables',ME);