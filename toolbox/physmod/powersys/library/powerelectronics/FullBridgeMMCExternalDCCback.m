function FullBridgeMMCExternalDCCback(block)





    MV=get_param(block,'Maskvisibilities');

    switch lower(get_param(block,'ModelType'))

    case 'switching devices'

        MV{3}='on';
        MV{4}='on';
        MV{5}='on';

        MV{6}='off';
        MV{7}='off';
        MV{8}='off';
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';

    otherwise

        MV{3}='off';
        MV{4}='off';
        MV{5}='off';

        MV{6}='on';
        MV{7}='on';
        MV{8}='on';
        MV{9}='on';
        MV{10}='on';
        MV{11}='on';

    end

    set_param(block,'Maskvisibilities',MV)