function delKeyPressed(p)




    s=computeHoverLocation(p,[]);
    if s.overLegend
        p.LegendVisible=false;

    elseif s.overTitleTop

        p.TitleTop='';

    elseif s.overTitleBottom

        p.TitleBottom='';
    end
