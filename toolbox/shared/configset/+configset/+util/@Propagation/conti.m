function conti(h)




    if h.Mode==3||h.Mode==4
        h.Mode=h.Mode-2;
        if h.Mode==1
            h.sl_propagate();
        elseif h.Mode==2
            h.restore();
        end
    end
