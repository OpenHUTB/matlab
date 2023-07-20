function SwitchesEnables(block,Device)





    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers
        SNUBBER='off';
    else
        SNUBBER='on';
    end

    if PowerguiInfo.SPID&&PowerguiInfo.DisableRon
        RONENABLE='off';
    else
        RONENABLE='on';
    end

    if PowerguiInfo.SPID&&PowerguiInfo.DisableVf
        VFENABLE='off';
    else
        VFENABLE='on';
    end

    if PowerguiInfo.SPID
        LONENABLE='off';
        TAILENABLE='off';
    else
        LONENABLE='on';
        TAILENABLE='on';
    end

    TAILENABLE='off';

    if getSPSmaskvalues(block,{'Lon'})==0
        ICENABLE='off';
    else
        ICENABLE='on';
    end

    MaskEnables=get_param(block,'MaskEnables');

    switch Device

    case 'Diode'

        MaskEnables{1}=RONENABLE;
        MaskEnables{2}=LONENABLE;
        MaskEnables{3}=VFENABLE;
        MaskEnables{4}=ICENABLE;
        MaskEnables{5}=SNUBBER;
        MaskEnables{6}=SNUBBER;
        MaskEnables{7}=SNUBBER;

    case 'Thyristor'

        MaskEnables{1}=RONENABLE;
        MaskEnables{2}=LONENABLE;
        MaskEnables{3}=VFENABLE;
        MaskEnables{4}=ICENABLE;
        MaskEnables{5}=SNUBBER;
        MaskEnables{6}=SNUBBER;

    case{'Detailed Thyristor','GTO','IGBT'}

        MaskEnables{1}=RONENABLE;
        MaskEnables{2}=LONENABLE;
        MaskEnables{3}=VFENABLE;
        MaskEnables{4}=TAILENABLE;
        MaskEnables{5}=TAILENABLE;
        MaskEnables{6}=ICENABLE;
        MaskEnables{7}=SNUBBER;
        MaskEnables{8}=SNUBBER;

    case 'Breaker'

        MaskEnables{4}=RONENABLE;
        MaskEnables{5}=SNUBBER;
        MaskEnables{6}=SNUBBER;

    case 'Ideal Switch'

        MaskEnables{1}=RONENABLE;
        MaskEnables{2}=LONENABLE;
        MaskEnables{4}=SNUBBER;
        MaskEnables{5}=SNUBBER;

    case 'IGBT/Diode'

        MaskEnables{1}=RONENABLE;
        MaskEnables{2}=SNUBBER;
        MaskEnables{3}=SNUBBER;

    case 'MOSFET'

        MaskEnables{1}=RONENABLE;
        MaskEnables{2}=LONENABLE;
        MaskEnables{4}=VFENABLE;
        MaskEnables{5}=ICENABLE;
        MaskEnables{6}=SNUBBER;
        MaskEnables{7}=SNUBBER;

    end

    set_param(block,'MaskEnables',MaskEnables);