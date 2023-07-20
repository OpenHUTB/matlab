function hints=getHints(hObj)



    if(iscategorical(hObj.XData))
        hints={};
    elseif strcmpi(hObj.Horizontal,'off')
        hints={{'DataPaddedX',abs(hObj.WidthScaleFactor)*0.8}};
    else
        hints={{'DataPaddedY',abs(hObj.WidthScaleFactor)*0.8}};
    end
