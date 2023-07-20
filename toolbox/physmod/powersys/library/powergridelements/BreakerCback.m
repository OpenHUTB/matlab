function BreakerCback(block)







    ME=get_param(block,'MaskEnables');
    if isequal('on',get_param(block,'External'))
        ME{2}='off';
        set_param(block,'MaskIconFrame','on');
        set_param(block,'MaskIconOpaque','off');
    else
        ME{2}='on';
        set_param(block,'MaskIconFrame','off');
        set_param(block,'MaskIconOpaque','on');
    end
    set_param(block,'MaskEnables',ME);