function result=doGetBaseLine(obj)
    result=matlab.graphics.GraphicsPlaceholder;
    if~isempty(obj)
        ax=ancestor(obj,'matlab.graphics.axis.AbstractAxes','node');
        if~isempty(ax)
            tm=ax.TargetManager;
            if isempty(tm)||isscalar(tm.Targets)
                result=ax.YBaseline;
            else
                pt=tm.whichTargetContains(obj);
                if~isempty(pt)
                    result=pt.BaselineB;
                end
            end
        end
    end
end
