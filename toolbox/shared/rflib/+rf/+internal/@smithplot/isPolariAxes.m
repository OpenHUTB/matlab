function y=isPolariAxes(p)











    ax=p.hAxes;
    if isempty(ax)||~ishghandle(ax)


        par=p.Parent;
        if strcmpi(par.Type,'figure')

            ax=par.CurrentAxes;
        else

            ax=findobj(par,'Type','axes');
            if numel(ax)>1
                ax=ax(1);
            end
        end
        if isempty(ax)

            ax=axes('Parent',par,'Visible','off');
        end
        if strcmpi(ax.Type,'polaraxes')
            cla(ax,'reset');
            set(ax,'Visible','off');
            ax=axes('Parent',par,'Visible','off');
        end
        p.hAxes=ax;
    end

    assert(~isempty(ax))


    y=~isempty(getappdata(ax,'SmithplotAxesIndex'));


