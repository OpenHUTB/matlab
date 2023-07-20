function updateYLimits(this)






    yMin=[];
    yMax=[];
    if~isempty(this.YLimCache.MinYLim)
        yMin=this.YLimCache.MinYLim;
        this.YLimCache.MinYLim=[];
    end
    if~isempty(this.YLimCache.MaxYLim)
        yMax=this.YLimCache.MaxYLim;
        this.YLimCache.MaxYLim=[];
    end
    if~isempty(yMin)&&~isempty(yMax)
        this.YLim=[yMin,yMax];
    elseif~isempty(yMin)
        this.YLim(1)=yMin;
    elseif~isempty(yMax)
        this.YLim(2)=yMax;
    end
    hAxes=this.Axes(1,1);
    set(hAxes,'YScale','lin');
    if~isempty(resetplotview(hAxes,'GetStoredViewStruct'))
        zoom(hAxes(1,1),'reset');
    end
end
