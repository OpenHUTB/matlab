function valueSources=getAllValidValueSources(hObj)




    if strcmpi(hObj.BarLayout,'grouped')
        valueSources=["XData";"YData"];
    else
        if strcmpi(hObj.Horizontal,'on')
            valueSources=["X (Stacked)";"X (Segment)";"YData"];
        else
            valueSources=["XData";"Y (Stacked)";"Y (Segment)"];
        end
    end