function setAllLinesData(hLines,xdata,ydata)





    for indx=1:min(numel(hLines),numel(xdata))
        set(hLines(indx),'XData',xdata{indx},'YData',ydata{indx});
    end

end
