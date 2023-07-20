function ThreePhaseBreakerCback(block)





    MaskEnables=get_param(block,'MaskEnables');

    if strcmp(get_param(block,'External'),'on')
        MaskEnables{5}='off';
    else
        MaskEnables{5}='on';
    end

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    if PowerguiInfo.SPID&&PowerguiInfo.DisableRon

        MaskEnables{7}='off';
    else
        MaskEnables{7}='on';
    end

    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers

        MaskEnables{8}='off';
        MaskEnables{9}='off';
    else
        MaskEnables{8}='on';
        MaskEnables{9}='on';
    end

    set_param(block,'MaskEnables',MaskEnables);