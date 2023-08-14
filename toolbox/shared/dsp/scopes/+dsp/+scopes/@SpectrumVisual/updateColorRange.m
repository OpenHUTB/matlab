function updateColorRange(this)




    if~isempty(this.Plotter)
        this.Plotter.ColorLim=[evalPropertyValue(this,'MinColorLim'),...
        evalPropertyValue(this,'MaxColorLim')];
    end
end
