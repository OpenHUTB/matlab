function updateTitlePos(p,select)










    switch p.View
    case{'right','top-right','bottom-right'}
        xc=+0.5;
    case{'left','top-left','bottom-left'}
        xc=-0.5;
    otherwise
        xc=0;
    end




    is_top=strcmpi(select,'top');
    if is_top
        h=p.hTitleTop;
        off=p.TitleTopOffset+p.pTitleOffset_Temp;
        switch p.View
        case{'top','top-left','top-right'}
            y=1+off;
        case{'bottom','bottom-left','bottom-right'}
            y=off;
        otherwise
            y=1+off;
        end
    else
        h=p.hTitleBottom;
        off=p.TitleBottomOffset+p.pTitleOffset_Temp;
        switch p.View
        case{'top','top-left','top-right'}
            y=-off;
        case{'bottom','bottom-left','bottom-right'}
            y=-1-off;
        otherwise
            y=-1-off;
        end
    end

    if~isempty(h)&&ishghandle(h)

        h.Position=[xc,y,0.294];
    end
