function hdlfftblk_callback(prop)











    switch lower(prop)
    case 'rounding_mode'
        if~isspblkinstalled
            error(message('hdlcoder:makehdl:needDSPSystemToolbox'));
        else

        end
    otherwise
        if isspblkinstalled
            switch lower(prop)
            case 'sine_mode'
                sine_mode_callback;
            case 'prod_mode'
                prod_mode_callback;
            case 'accum_mode'
                accum_mode_callback;
            case 'output_mode'
                output_mode_callback;
            end
        end
    end

end


function sine_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    sinemode=get_param(gcb,'sinemode');


    if strcmp(sinemode,'Same word length as input')
        maskenb{5}='off';
    else
        maskenb{5}='on';
    end
    set_param(gcb,'MaskEnables',maskenb);

end

function prod_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    prodmode=get_param(gcb,'prodmode');


    if~strcmp(prodmode,'Binary point scaling')
        maskenb{7}='off';
        maskenb{8}='off';
    else
        maskenb{7}='on';
        maskenb{8}='on';

    end
    set_param(gcb,'MaskEnables',maskenb);

end

function accum_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    accumode=get_param(gcb,'accumode');


    if~strcmp(accumode,'Binary point scaling')
        maskenb{10}='off';
        maskenb{11}='off';
    else
        maskenb{10}='on';
        maskenb{11}='on';
    end
    set_param(gcb,'MaskEnables',maskenb);

end


function output_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    outputmode=get_param(gcb,'outputmode');


    if~strcmp(outputmode,'Binary point scaling')
        maskenb{13}='off';
        maskenb{14}='off';
    else
        maskenb{13}='on';
        maskenb{14}='on';

    end

    set_param(gcb,'MaskEnables',maskenb);

end




