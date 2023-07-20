function[xr,yr,zr]=getRulersForChild(h)









    xr=gobjects(0);
    yr=gobjects(0);
    zr=gobjects(0);
    ax=ancestor(h,'axes','node');
    if~isa(ax,'matlab.graphics.axis.Axes')
        return
    end

    if isequal(ax,h)
        names=ax.DimensionNames;
        xr=ax.(['Active',names{1},'Ruler']);
        yr=ax.(['Active',names{2},'Ruler']);
        if isprop(ax,['Active',names{3},'Ruler'])
            zr=ax.(['Active',names{3},'Ruler']);
        end
    else
        ds=ancestor(h,'matlab.graphics.axis.dataspace.DataSpace','node');
        tm=ax.TargetManager;
        if~isempty(tm)&&~isempty(ds)
            targets=tm.Children;
            for k=1:length(targets)
                target=targets(k);
                if isequal(target.DataSpace,ds)
                    xr=target.AxisA;
                    yr=target.AxisB;
                    zr=target.AxisC;
                end
            end
        end
    end
