function hiliteSpanDrag_Init(p,state)












    h=p.hSpanHilite;
    if isempty(h)||~ishghandle(h)

        x=[-1,0,+1,-1]*.5;
        y=[0,1,0,0]*.5;
        ccw=[x;y];
        y=[0,-1,0,0]*.5;
        cw=[x;y];






        h=patch(...
        'Parent',p.hAxes,...
        'HandleVisibility','off',...
        'FaceColor','none',...
        'FaceAlpha',1.0,...
        'EdgeColor','none',...
        'EdgeAlpha',1.0,...
        'Clipping','on',...
        'Tag',sprintf('polariAngleSpan%d',p.pAxesIndex),...
        'UserData',{ccw,cw},...
        'Visible','off');
        p.hSpanHilite=h;


        b=hggetbehavior(h,'DataCursor');
        b.Enable=false;

    end

    if strcmpi(state,'off')
        h.Visible='off';

        return
    end

    hiliteSpanDrag_Update(p);
