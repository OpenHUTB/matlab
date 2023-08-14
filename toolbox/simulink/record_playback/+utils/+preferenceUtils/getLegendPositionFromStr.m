function legendPos=getLegendPositionFromStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:LegendOutsideRight')
        legendPos=SdiVisual.LegendPosition.RIGHT;
    case DAStudio.message('record_playback:params:LegendInsideLeft')
        legendPos=SdiVisual.LegendPosition.INSIDE_TOP;
    case DAStudio.message('record_playback:params:LegendInsideRight')
        legendPos=SdiVisual.LegendPosition.INSIDE_RIGHT;
    case DAStudio.message('record_playback:params:None')
        legendPos=SdiVisual.LegendPosition.LEGEND_HIDE;
    otherwise
        legendPos=SdiVisual.LegendPosition.TOP;
    end
end