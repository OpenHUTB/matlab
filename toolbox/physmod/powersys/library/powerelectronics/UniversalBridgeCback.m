function UniversalBridgeCback(block)





    visibilities={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'off';'off'};
    PowerguiInfo=powericon('getPowerguiInfo',bdroot(block),block);
    device=get_param(block,'device');

    switch device

    case{'Diodes','Thyristors'}

        visibilities{6}='on';
        visibilities{7}='off';
        visibilities{8}='on';
        visibilities{9}='off';
        visibilities{10}='off';
        visibilities{11}='on';
        visibilities{12}='off';

    case{'GTO / Diodes','IGBT / Diodes'}

        visibilities{2}='on';
        visibilities{3}='on';
        visibilities{5}='on';
        visibilities{6}='off';
        visibilities{7}='on';
        visibilities{8}='off';
        if isequal(device,'GTO / Diodes')
            visibilities{9}='on';
            visibilities{10}='off';
        else
            visibilities{9}='off';
            visibilities{10}='on';
        end
        visibilities{11}='on';
        visibilities{12}='off';

    case 'MOSFET / Diodes'

        visibilities{2}='on';
        visibilities{3}='on';
        visibilities{5}='on';
        visibilities{6}='off';
        visibilities{7}='off';
        visibilities{8}='off';
        visibilities{9}='off';
        visibilities{10}='off';
        visibilities{11}='on';
        visibilities{12}='off';

    case 'Ideal Switches'

        visibilities{2}='on';
        visibilities{3}='on';
        visibilities{5}='on';
        visibilities{6}='off';
        visibilities{7}='off';
        visibilities{8}='off';
        visibilities{9}='off';
        visibilities{10}='off';
        visibilities{11}='on';
        visibilities{12}='off';

    case{'Switching-function based VSC','Average-model based VSC'}

        visibilities{2}='off';
        visibilities{3}='off';
        visibilities{5}='off';
        visibilities{6}='off';
        visibilities{7}='off';
        visibilities{8}='off';
        visibilities{9}='off';
        visibilities{10}='off';
        visibilities{11}='off';
        visibilities{12}='on';

    end


    visibilities{9}='off';
    visibilities{10}='off';

    set_param(block,'Maskvisibilities',visibilities);

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

        MaskEnables{7}='off';
        MaskEnables{8}='off';
    else
        MaskEnables{7}='on';
        MaskEnables{8}='on';
    end
    if PowerguiInfo.SPID
        MaskEnables{6}='off';
        MaskEnables{9}='off';
        MaskEnables{10}='off';
    else
        MaskEnables{6}='on';
        MaskEnables{9}='on';
        MaskEnables{10}='on';
    end
    set_param(block,'MaskEnables',MaskEnables);