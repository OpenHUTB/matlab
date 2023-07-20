function reset(this)



    this.YExtents=[NaN,NaN];
    hLines=this.Lines;
    for indx=1:numel(hLines)
        set(hLines(indx),'YData',NaN(size(get(hLines(indx),'XData'))));
    end
    hLines=this.MaxHoldTraceLines;
    for indx=1:numel(hLines)
        set(hLines(indx),'YData',NaN(size(get(hLines(indx),'XData'))));
    end
    hLines=this.MinHoldTraceLines;
    for indx=1:numel(hLines)
        set(hLines(indx),'YData',NaN(size(get(hLines(indx),'XData'))));
    end
end
