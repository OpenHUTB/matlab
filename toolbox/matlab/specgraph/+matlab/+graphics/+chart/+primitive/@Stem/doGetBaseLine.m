function result=doGetBaseLine(obj)
    result=matlab.graphics.GraphicsPlaceholder;
    if~isempty(obj)
        ax=ancestor(obj,'matlab.graphics.axis.AbstractAxes','node');
        if~isempty(ax)
            xyzname='YBaseline';
            abcname='BaselineB';
            if(doGetBaselineAxis(obj)==2)
                xyzname='ZBaseline';
                abcname='BaselineC';
            end

            tm=ax.TargetManager;
            if isempty(tm)||isscalar(tm.Targets)
                result=get(ax,xyzname);
            else
                pt=tm.whichTargetContains(obj);
                if~isempty(pt)
                    result=get(pt,abcname);
                end
            end
        end
    end
end
