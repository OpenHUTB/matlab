function ThreePhaseSourceCback(block)





    MV=get_param(block,'MaskVisibilities');

    switch get_param(block,'VoltagePhases')
    case 'on'
        MV{3}='off';
        MV{4}='off';
        MV{5}='on';
        MV{6}='on';
    otherwise
        MV{3}='on';
        MV{4}='on';
        MV{5}='off';
        MV{6}='off';
    end

    switch get_param(block,'SpecifyImpedance')
    case 'on'
        MV{10}='off';
        MV{11}='off';
        MV{12}='on';
        MV{13}='on';
        MV{14}='on';
    otherwise
        MV{10}='on';
        MV{11}='on';
        MV{12}='off';
        MV{13}='on';
        MV{14}='off';
    end

    ME=get_param(block,'MaskEnables');
    switch get_param(block,'NonIdealSource')
    case 'off'
        ME{9}='off';
        ME{10}='off';
        ME{11}='off';
        ME{12}='off';
        ME{13}='off';
        ME{14}='off';
    otherwise
        ME{9}='on';
        ME{10}='on';
        ME{11}='on';
        ME{12}='on';
        ME{13}='on';
        ME{14}='on';
    end
    set_param(block,'MaskEnables',ME);

    MV{15}='on';
    switch get_param(block,'BusType')
    case 'swing'
        MV{16}='off';
        MV{17}='off';
        MV{18}='off';
        MV{19}='off';
        MV{20}='off';
        MV{21}='off';
    case 'PV'
        switch get_param(block,'VoltagePhases')
        case 'on'
            MV{16}='off';
            MV{17}='off';
            MV{18}='on';
            MV{19}='off';
        case 'off'
            MV{16}='on';
            MV{17}='off';
            MV{18}='off';
            MV{19}='off';
        end
        MV{20}='on';
        MV{21}='on';
    case 'PQ'
        switch get_param(block,'VoltagePhases')
        case 'on'
            MV{16}='off';
            MV{17}='off';
            MV{18}='on';
            MV{19}='on';
        case 'off'
            MV{16}='on';
            MV{17}='on';
            MV{18}='off';
            MV{19}='off';
        end

        MV{20}='off';
        MV{21}='off';
    end

    set_param(block,'Maskvisibilities',MV);