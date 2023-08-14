function cacheChangeInAxesPosition(p)





    ax=p.hAxes;
    setappdata(ax,'PolariAxesPositionPreView',ax.Position);
    updateGridView(p);
