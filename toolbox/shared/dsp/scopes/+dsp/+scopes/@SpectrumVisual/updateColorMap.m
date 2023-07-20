function updateColorMap(this)




    if~isempty(this.Plotter)
        this.Plotter.ColorMap=this.ColorMapMatrix;
    end
    notify(this,'DisplayUpdated');
end
