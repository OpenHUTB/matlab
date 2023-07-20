function ShaftCback(block)








    PresetModel=get_param(gcb,'PresetModel');
    if~strcmp(PresetModel,'No')
        Indice=eval(PresetModel(1:2));
        load('ShaftParameters');
        set_param(block,'Ksh',mat2str(ShaftParameters(Indice).Ksh));
        set_param(block,'Bsh',mat2str(ShaftParameters(Indice).Bsh));
        maskEnables={'on',...
        'off',...
        'off'};

    else
        maskEnables={'on',...
        'on',...
        'on'};
    end

    if sps_Authoring(bdroot(block))
        set_param(block,'MaskEnables',maskEnables);
    end


