function timeSpan=getTimeSpanFromStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:Auto')
        timeSpan=SdiVisual.ScalingMode.AUTO;
    otherwise
        timeSpan=SdiVisual.ScalingMode.MANUAL;
    end
end