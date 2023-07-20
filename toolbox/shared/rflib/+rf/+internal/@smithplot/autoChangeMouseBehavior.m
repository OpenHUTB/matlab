function autoChangeMouseBehavior(p,s)








    if s.overLegend
        changeMouseBehavior(p,'legend');
        return
    elseif s.overTitleTop
        changeMouseBehavior(p,'titletop');
        return
    elseif s.overTitleBottom
        changeMouseBehavior(p,'titlebottom');
        return
    elseif s.overFigPanel


        return
    elseif~s.inAxes

        changeMouseBehavior(p,'general');
        return
    end



    if s.overGrid

        p.MagDrag_OrigRadius=s.radius;
        changeMouseBehavior(p,'grid');

    elseif s.overDataset
        p.pHoverDataSetIndex=s.overDatasetIndex;
        changeMouseBehavior(p,'dataset');

    else

        changeMouseBehavior(p,'general');
    end
