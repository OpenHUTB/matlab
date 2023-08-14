function tickLabel=getTickLabelFromStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:All')
        tickLabel=SdiVisual.TickLabelsDisplay.ALL;
    case DAStudio.message('record_playback:params:TimeAxis')
        tickLabel=SdiVisual.TickLabelsDisplay.T_AXIS;
    case DAStudio.message('record_playback:params:YAxis')
        tickLabel=SdiVisual.TickLabelsDisplay.Y_AXIS;
    otherwise
        tickLabel=SdiVisual.TickLabelsDisplay.NONE;
    end
end