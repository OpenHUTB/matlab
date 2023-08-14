function hints=getHints(hObj)
    if strcmpi(hObj.Orientation,'vertical')
        hints={{'PaddedX',0.1}};
    else
        hints={{'PaddedY',0.1}};
    end

