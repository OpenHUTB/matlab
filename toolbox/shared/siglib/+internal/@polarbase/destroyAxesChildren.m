function destroyAxesChildren(p)




    pname='ShowHiddenHandles';
    o=get(0,pname);
    set(0,pname,'on');
    ax=p.hAxes;

    if ishghandle(ax)
        if~isempty(ax)&&isequal(ax.Position(1:2),[0,0])
            otherAx=findobj(ax.Parent,'-depth',1,'-regexp','Type','\w*Axes');
            index=arrayfun(@(x)isa(x,'matlab.graphics.axis.PolarAxes'),otherAx);
            if any(index)
                polarAx=otherAx(index);
                polarAx.LooseInset=get(groot,'defaultaxeslooseinset');
                polarAx.Position=get(groot,'defaultaxesposition');
            elseif numel(otherAx)==1
                ax.LooseInset=get(groot,'defaultaxeslooseinset');
                ax.Position=get(groot,'defaultaxesposition');
            end
        end
    end

    check_ax_del=isa(ax,'matlab.graphics.axis.Axes')&&~ishghandle(ax);
    if~check_ax_del
        h=get(ax,'Children');
        deleteHGWidgets(h);
    end
    set(0,pname,o);


    if ishghandle(p.hFigure)
        cbtogg=uigettool(p.hFigure,'Annotation.InsertColorbar');
        if~isempty(cbtogg)
            cbtogg.Visible='on';
        end
    end