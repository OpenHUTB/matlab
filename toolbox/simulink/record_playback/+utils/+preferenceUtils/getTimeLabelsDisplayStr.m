function timeLabelsDisplay=getTimeLabelsDisplayStr(entryValue)
    switch entryValue
    case SdiVisual.TimeLabelsDisplay.LAST_SPARKLINE
        timeLabelsDisplay='lastSparkline';
    otherwise
        timeLabelsDisplay='allSparklines';
    end
end