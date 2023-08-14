function ProgrammableVoltageSourceCback(block)






    MV=get_param(block,'Maskvisibilities');

    parametres=get_param(block,'MaskValues');
    Variation=parametres{2};

    switch Variation

    case 'None';

        MV{3}='off';
        MV{4}='off';
        MV{5}='off';
        MV{6}='off';
        MV{7}='off';
        MV{8}='off';
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';
        MV{12}='off';

    otherwise

        MV{3}='on';

        switch Variation
        case{'Phase','Frequency'}
            MV{3}='off';
            MV{4}='on';
            TypeVariation=parametres{4};
        otherwise
            MV{3}='on';
            MV{4}='off';
            TypeVariation=parametres{3};
        end

        switch TypeVariation

        case 'Step'
            MV{5}='on';
            MV{6}='off';
            MV{7}='off';
            MV{8}='off';
            MV{9}='on';
            MV{10}='off';
            MV{11}='off';
            MV{12}='off';

        case 'Ramp';
            MV{5}='off';
            MV{6}='on';
            MV{7}='off';
            MV{8}='off';
            MV{9}='on';
            MV{10}='off';
            MV{11}='off';
            MV{12}='off';

        case 'Modulation';
            MV{5}='off';
            MV{6}='off';
            MV{7}='on';
            MV{8}='on';
            MV{9}='on';
            MV{10}='off';
            MV{11}='off';
            MV{12}='off';

        case 'Table of time-amplitude pairs'
            MV{5}='off';
            MV{6}='off';
            MV{7}='off';
            MV{8}='off';
            MV{9}='off';
            MV{10}='on';
            MV{11}='on';
            MV{12}='on';
        end

    end

    HarmonicGeneration=parametres{13};
    if strcmp(HarmonicGeneration,'on');
        MV{14}='on';
        MV{15}='on';
        MV{16}='on';
    else
        MV{14}='off';
        MV{15}='off';
        MV{16}='off';
    end



    switch get_param(block,'BusType')
    case 'swing'
        MV{end}='off';
        MV{end-1}='off';
        MV{end-2}='off';
        MV{end-3}='off';
    case 'PV'
        MV{end}='on';
        MV{end-1}='on';
        MV{end-2}='off';
        MV{end-3}='on';
    case 'PQ'
        MV{end}='off';
        MV{end-1}='off';
        MV{end-2}='on';
        MV{end-3}='on';
    end

    set_param(block,'Maskvisibilities',MV);