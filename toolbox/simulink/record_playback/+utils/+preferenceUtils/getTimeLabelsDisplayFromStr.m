function timeLabelDisplay=getTimeLabelsDisplayFromStr(entryValue)

    if isempty(entryValue)
        timeLabelDisplay=SdiVisual.TimeLabelsDisplay.LAST_SPARKLINE;
        return;
    end
    switch entryValue
    case DAStudio.message('record_playback:params:ShowLastSparkline')
        timeLabelDisplay=SdiVisual.TimeLabelsDisplay.LAST_SPARKLINE;
    otherwise
        timeLabelDisplay=SdiVisual.TimeLabelsDisplay.ALL_SPARKLINES;
    end
end