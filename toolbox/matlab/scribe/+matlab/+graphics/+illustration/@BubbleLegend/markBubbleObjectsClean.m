function markBubbleObjectsClean(hObj)
    bubblecharts=hObj.PlotChildren_I;
    for i=1:numel(bubblecharts)
        bubblecharts(i).markLegendEntryClean();
    end
end