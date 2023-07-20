function ThreePhaseLoadBlocksCback(block)






    YConfiguration=strcmp('Y (neutral)',get_param(block,'Configuration'));
    RConntags=get_param(block,'RConnTags');

    if isempty(RConntags)
        T='';
    else
        T=RConntags{1};
    end

    YCurrentTag=strcmp('N',T);

    if YConfiguration&&~YCurrentTag
        set_param(block,'RConnTags',{'N'});
    elseif~YConfiguration&&YCurrentTag
        set_param(block,'RConnTags',{});
    end

    MV=get_param(block,'Maskvisibilities');
    if strcmp('on',get_param(block,'UnbalancedPower'))
        MV{2}='off';
        MV{7}='off';
        MV{8}='off';
        MV{9}='off';
        switch get_param(block,'Configuration')
        case 'Delta'
            MV{3}='off';
            MV{4}='on';
            MV{10}='off';
            MV{11}='off';
            MV{12}='off';
            MV{13}='on';
            MV{14}='on';
            MV{15}='on';
        otherwise
            MV{3}='on';
            MV{4}='off';
            MV{10}='on';
            MV{11}='on';
            MV{12}='on';
            MV{13}='off';
            MV{14}='off';
            MV{15}='off';
        end
    else
        MV{2}='on';
        MV{3}='off';
        MV{4}='off';
        MV{7}='on';
        MV{8}='on';
        MV{9}='on';
        MV{10}='off';
        MV{11}='off';
        MV{12}='off';
        MV{13}='off';
        MV{14}='off';
        MV{15}='off';
    end
    set_param(block,'Maskvisibilities',MV);
