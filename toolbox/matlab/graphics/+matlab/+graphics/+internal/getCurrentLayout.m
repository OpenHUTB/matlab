function h=getCurrentLayout(hchk)




    h=gobjects(0);

    if nargin<1||isempty(hchk)
        hchk=get(0,'CurrentFigure');
    end

    if isempty(hchk)
        return
    end

    if isgraphics(hchk,'figure')&&~isempty(hchk.CurrentAxes)
        hchk=hchk.CurrentAxes;
    end

    if isgraphics(hchk,'figure')&&~isempty(hchk.Children)
        layoutkids=hchk.Children(arrayfun(@islayout,hchk.Children));
        if~isempty(layoutkids)
            h=layoutkids(1);
        end

    elseif isa(hchk,'matlab.graphics.mixin.ChartLayoutable')
        if~isempty(hchk.Parent)&&islayout(hchk.Parent)
            h=hchk.Parent;
        end

    end
end

function x=islayout(h)
    x=isa(h,'matlab.graphics.layout.Layout');
end