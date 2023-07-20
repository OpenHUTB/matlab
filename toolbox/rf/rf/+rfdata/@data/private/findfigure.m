function fig=findfigure(h)




    fig=getfigure(h);
    if fig==-1;return;end;
    if isempty(fig);fig=gcf;end;


    name=get(fig,'Name');
    if isempty(name)||~ishold
        name=h.Block;
    end
    if isempty(name)
        set(fig,'HandleVisibility','on');
    else
        set(fig,'NumberTitle','off','HandleVisibility','on','Name',name);
    end