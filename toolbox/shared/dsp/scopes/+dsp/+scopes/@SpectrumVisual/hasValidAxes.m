function flag=hasValidAxes(this)








    flag=isempty(this.NoDataAvailableTxt)&&~isCorrectionMode(this);
    if isSpectrogramMode(this)||isCombinedViewMode(this)
        flag=flag&&~isempty(this.Plotter)&&~isempty(this.Plotter.hImage)&&...
        ishghandle(this.Plotter.hImage)&&~isequal(get(this.Plotter.hImage,'CData'),-inf(2));
    end
end
