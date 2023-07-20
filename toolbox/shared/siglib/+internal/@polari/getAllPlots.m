function[p,idx]=getAllPlots(fig)


    p=[];
    idx=[];



    if nargin<1
        fig=get(0,'CurrentFigure');
    end
    if isempty(fig)||~ishandle(fig)
        return
    end

    ht=findobj(fig,'Tag','PolariObject');
    if isempty(ht)
        return
    end


    p=flip(get(ht,'UserData'));
    if numel(p)>1
        p=cat(1,p{:});
    end
    if nargout>1
        idx=cat(1,p.pAxesIndex);
    end
