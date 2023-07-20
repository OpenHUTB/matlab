function DetailedThyristorCback(block)





    MaskEnables=get_param(block,'MaskEnables');

    Lon=getSPSmaskvalues(block,{'Lon'});
    LonEnable=strcmp('on',MaskEnables{2});

    if Lon>0&&LonEnable

        MaskEnables{4}='on';
        MaskEnables{5}='on';
    else
        MaskEnables{4}='off';
        MaskEnables{5}='off';
    end

    set_param(block,'MaskEnables',MaskEnables);