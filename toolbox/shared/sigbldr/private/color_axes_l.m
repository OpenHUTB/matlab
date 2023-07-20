function color_axes_l(axesH,style)





    styleTab={'IDLE','ICED','ICED_FS'};
    actionTab={@default_axes_bg_color_l,@light_gray_l,@default_axes_bg_color_l};

    k=strmatch(style,styleTab,'exact');

    if isempty(k)

        k=1;
    end

    set(axesH,'color',actionTab{k}());