function ThreePhaseFaultCback(block)





    MaskEnables=get_param(block,'MaskEnables');

    if strcmp(get_param(block,'External'),'on')
        MaskEnables{6}='off';
    else
        MaskEnables{6}='on';
    end

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    if PowerguiInfo.SPID&&PowerguiInfo.DisableRon

        MaskEnables{9}='off';
    else
        MaskEnables{9}='on';
    end

    if strcmp(get_param(block,'GroundFault'),'on')
        MaskEnables{10}='on';
    else
        MaskEnables{10}='off';
    end

    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers

        MaskEnables{11}='off';
        MaskEnables{12}='off';
    else
        MaskEnables{11}='on';
        MaskEnables{12}='on';
    end

    set_param(block,'MaskEnables',MaskEnables);