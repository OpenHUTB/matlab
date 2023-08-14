function timeSpan=getTimeSpanStr(entryValue)
    switch entryValue.mode
    case SdiVisual.ScalingMode.AUTO
        timeSpan='Auto';
    otherwise
        timeSpan=entryValue.maximum-entryValue.minimum;
    end
end