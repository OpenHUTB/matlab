function supercapacitorCback(Block,~)









    ME=get_param(Block,'MaskEnables');

    EstParam=strcmp(get_param(Block,'EstParam'),'on');


    if isempty(ver('optim'))||~license('test','Optimization_Toolbox')
        EstParam=0;
    end

    if strcmp(get_param(Block,'PresetModel'),'on')
        ME{8}='on';
        ME{9}='off';
        ME{10}='off';
        ME{11}='off';
        ME{12}='off';
        ME{13}='off';
        ME{14}='off';
    else
        if EstParam
            ME{8}='off';
            ME{9}='on';
            ME{10}='off';
            ME{11}='off';
            ME{12}='off';
            ME{13}='on';
            ME{14}='on';
        else
            ME{8}='on';
            ME{9}='on';
            ME{10}='on';
            ME{11}='on';
            ME{12}='on';
            ME{13}='off';
            ME{14}='off';
        end
    end

    if strcmp(get_param(Block,'Self_dis'),'on')
        ME{16}='on';
        ME{17}='on';
    else
        ME{16}='off';
        ME{17}='off';
    end

    if sps_Authoring(bdroot(Block))
        set_param(Block,'MaskEnables',ME);
    end