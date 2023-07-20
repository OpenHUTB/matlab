function restoreFigurePointer(p)




    f=p.hFigure;
    if~isempty(f)&&ishghandle(f)
        setptr(f,'arrow');
    end
