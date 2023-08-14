function resizePlotProps(this)
    oldYRange=this.YRange;
    numPlots=this.Rows*this.Columns;
    this.YRange=cell(numPlots,1);
    for idx=1:length(oldYRange)
        if idx>numPlots
            return
        end
        this.YRange{idx}=oldYRange{idx};
    end
end
