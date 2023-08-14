function updateStemPlotBaseValue(this)



    if~isempty(this.Lines)&&strcmp(get(this.Lines(1),'type'),'stem')
        set(this.Lines,'BaseValue',min(get(this.Axes(1,1),'YLim')));
    end
end
