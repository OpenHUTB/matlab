function[xdata,ydata]=getAllLinesData(hLines)



    xdata=get(hLines,'XData');
    ydata=get(hLines,'YData');
    if~iscell(xdata)
        xdata={xdata};
    end
    if~iscell(ydata)
        ydata={ydata};
    end

end
