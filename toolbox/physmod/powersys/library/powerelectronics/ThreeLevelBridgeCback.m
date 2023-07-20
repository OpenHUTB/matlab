function ThreeLevelBridgeCback(block)





    visibilities=get_param(block,'Maskvisibilities');

    switch get_param(block,'Device')

    case{'GTO / Diodes','IGBT / Diodes'}
        visibilities{6}='on';

    case{'MOSFET / Diodes','Ideal Switches'}
        visibilities{6}='off';
    end

    set_param(block,'Maskvisibilities',visibilities);

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    MaskEnables=get_param(block,'MaskEnables');
    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers

        MaskEnables{2}='off';
        MaskEnables{3}='off';
    else
        MaskEnables{2}='on';
        MaskEnables{3}='on';
    end
    if PowerguiInfo.SPID&&PowerguiInfo.DisableRon

        MaskEnables{5}='off';
    else
        MaskEnables{5}='on';
    end
    if PowerguiInfo.SPID&&PowerguiInfo.DisableVf

        MaskEnables{6}='off';
    else
        MaskEnables{6}='on';
    end
    set_param(block,'MaskEnables',MaskEnables);