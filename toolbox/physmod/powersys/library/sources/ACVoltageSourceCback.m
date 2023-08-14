function ACVoltageSourceCback(block)





    MV=get_param(block,'MaskVisibilities');
    switch get_param(block,'BusType')
    case 'swing'
        MV{7}='off';
        MV{8}='off';
        MV{9}='off';
        MV{10}='off';
    case 'PV'
        MV{7}='on';
        MV{8}='off';
        MV{9}='on';
        MV{10}='on';
    case 'PQ'
        MV{7}='on';
        MV{8}='on';
        MV{9}='off';
        MV{10}='off';
    end
    set_param(block,'Maskvisibilities',MV);