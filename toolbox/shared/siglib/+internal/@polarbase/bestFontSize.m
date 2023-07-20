function pt=bestFontSize(p)




    ax=p.hAxes;
    u=ax.Units;
    ax.Units='points';
    pos=ax.Position;
    ax.Units=u;



    if any(strcmpi(p.View,{'full','top','bottom'}))

        xr=pos(3)/2;
    else

        xr=pos(3);
    end
    if any(strcmpi(p.View,{'full','left','right'}))

        yr=pos(4)/2;
    else

        yr=pos(4);
    end
    r=min(xr,yr);



    N=14;
    fontSizeLimits=p.FontSizeLimits;
    pt=max(fontSizeLimits(1),min(fontSizeLimits(2),round(r/N)-1));
