function onFigureColorChange(this)






    hVisParent=getVisualizationParent(this.Application);
    newColor=get(hVisParent,'BackgroundColor');
    hParent=get(this.Axes(1,1),'Parent');
    set(hParent,'BackgroundColor',newColor);

    if~isempty(this.DialogMgr)
        this.DialogMgr.BackgroundColor=newColor;
    end
end
