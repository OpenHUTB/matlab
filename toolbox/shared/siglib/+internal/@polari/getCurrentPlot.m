function[p,idx]=getCurrentPlot(ax)





    p=[];
    idx=[];



    if nargin<1
        fig=get(0,'CurrentFigure');
        if isempty(fig)
            return
        end
        ax=get(fig,'CurrentAxes');
    end
    if isempty(ax)||~ishghandle(ax)
        return
    end
    ht=findobj(ax,'Tag','PolariObject');
    if isempty(ht)
        return
    end

    p=ht.UserData;
    if nargout>1
        idx=p.pAxesIndex;
    end
