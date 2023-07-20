function tickPos=getTickPositionFromStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:TickInside')
        tickPos=SdiVisual.TickPosition.INSIDE;
    case DAStudio.message('record_playback:params:TickHide')
        tickPos=SdiVisual.TickPosition.HIDE;
    otherwise
        tickPos=SdiVisual.TickPosition.OUTSIDE;
    end
end