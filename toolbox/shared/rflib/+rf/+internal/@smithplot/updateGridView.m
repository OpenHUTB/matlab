function updateGridView(p)







    del=0.04;




    L=1.4;
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    switch lower(p.View)
    case 'full'
        xlim=[-L,L];
        ylim=[-L,L];
        delpos=[0,0,0,0];

    case 'top'
        xlim=[-L,L];
        ylim=[-del,L];
        delpos=[0,del,0,-del];

    case 'bottom'
        xlim=[-L,L];
        ylim=[-L,del];

        delpos=[0,0,0,-del];
    case 'left'
        xlim=[-L,del];
        ylim=[-L,L];

        delpos=[0,0,-del,0];
    case 'right'
        xlim=[-del,L];
        ylim=[-L,L];

        delpos=[del,0,-del,0];
    case 'top-left'
        xlim=[-L,del];
        ylim=[-del,L];

        delpos=[0,del,-del,-del];
    case 'top-right'
        xlim=[-del,L];
        ylim=[-del,L];

        delpos=[del,del,-del,-del];
    case 'bottom-left'
        xlim=[-L,del];
        ylim=[-L,del];

        delpos=[0,0,-del,-del];
    case 'bottom-right'
        xlim=[-del,L];
        ylim=[-L,del];

        delpos=[del,0,-del,-del];
    otherwise
        assert(false,'Unrecognized View value "%s"',p.View);
    end









    ax=p.hAxes;
    assert(~isempty(ax));

    pos=getappdata(ax,'PolariAxesPositionPreView');



    if~strcmpi(ax.Parent.Type,'tiledlayout')
        lis=p.hListeners;
        if isempty(lis)||isempty(lis.AxesPos)
            ax.Position=pos+delpos;
        else
            lis.AxesPos.Enabled=false;
            ax.Position=pos+delpos;
            lis.AxesPos.Enabled=true;
        end
    end

    ax.XLim=xlim;
    ax.YLim=ylim;
    ax.ZLim=[-1,1];
